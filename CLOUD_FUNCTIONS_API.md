# Cloud Functions API Documentation

## Overview

This document details all Cloud Functions for the Real-Time 1v1 "Yes or No" multiplayer game.

**Base Region**: `europe-west1`  
**Total Functions**: 8  
**Authentication**: All callable functions require Firebase Authentication

---

## Table of Contents

1. [Callable Functions](#callable-functions)
   - [joinMatchmaking](#joinmatchmaking)
   - [submitQuestion](#submitquestion)
   - [makeFinalGuess](#makefinalguess)
   - [judgeQuestion](#judgequestion)
2. [Firestore Triggers](#firestore-triggers)
   - [createGame](#creategame)
   - [processRound](#processround)
   - [finalizeGame](#finalizegame)
3. [Scheduled Functions](#scheduled-functions)
   - [handleTimeout](#handletimeout)

---

## Callable Functions

### joinMatchmaking

**Purpose**: Handles player queue entry and opponent matching.

**Trigger**: HTTPS Callable Function  
**Authentication**: Required  
**Region**: `europe-west1`

#### Input Parameters
```typescript
{
  // No parameters - uses context.auth.uid
}
```

#### Output Schema
```typescript
{
  success: boolean,
  gameId: string | null  // null if added to queue, string if match found
}
```

#### Logic Flow
1. Extract `userId` from authenticated context
2. Query `matchmakingQueue` collection (FIFO - ordered by `joinTime`)
3. **Case A - Opponent Found**:
   - Use transaction to delete opponent's queue entry
   - Create new `games/{gameId}` document with state=`MATCHING`
   - Return `{ success: true, gameId: "<id>" }`
4. **Case B - Queue Empty**:
   - Create queue entry with `{ userId, elo: 1200, joinTime: serverTimestamp }`
   - Return `{ success: true, gameId: null }`

#### Error Responses
- `unauthenticated`: User not logged in
- `internal`: Database operation failed

#### Usage Example
```dart
final functions = FirebaseFunctions.instance;
final result = await functions
    .httpsCallable('joinMatchmaking')
    .call();

if (result.data['gameId'] != null) {
  // Match found! Navigate to game
  navigateToGame(result.data['gameId']);
} else {
  // Added to queue, listen for match
  listenToQueue();
}
```

---

### submitQuestion

**Purpose**: Records player's question submission during active round.

**Trigger**: HTTPS Callable Function  
**Authentication**: Required  
**Region**: `europe-west1`

#### Input Parameters
```typescript
{
  gameId: string,      // Game session ID
  question: string     // Player's question (5-200 chars)
}
```

#### Output Schema
```typescript
{
  success: boolean,
  message: string
}
```

#### Logic Flow
1. Validate `gameId` and `question`
2. Sanitize question (trim whitespace)
3. Verify game exists and state is `ROUND_IN_PROGRESS`
4. Verify user is a player in the game
5. Check if question already submitted for this round
6. Update `games/{gameId}`: `players.{userId}.currentQuestion = question`

#### Validation Rules
- Question length: 5-200 characters
- Game state must be `ROUND_IN_PROGRESS`
- User must be in `playerIds` array
- Cannot resubmit if `currentQuestion` exists

#### Error Responses
- `unauthenticated`: User not logged in
- `invalid-argument`: Missing or invalid parameters
- `not-found`: Game doesn't exist
- `failed-precondition`: Game not in correct state or already submitted
- `permission-denied`: User not a player in this game

#### Usage Example
```dart
final result = await functions
    .httpsCallable('submitQuestion')
    .call({
      'gameId': gameId,
      'question': 'Metalden mi yapılmış?',
    });

if (result.data['success']) {
  print('Question submitted successfully');
}
```

---

### makeFinalGuess

**Purpose**: Allows player to attempt final word guess.

**Trigger**: HTTPS Callable Function  
**Authentication**: Required  
**Region**: `europe-west1`

#### Input Parameters
```typescript
{
  gameId: string,   // Game session ID
  guess: string     // Player's guess for the secret word
}
```

#### Output Schema
```typescript
{
  success: boolean,
  correct: boolean,              // Was the guess correct?
  remainingGuesses: number       // Remaining guesses after this attempt
}
```

#### Logic Flow
1. Validate `gameId` and `guess`
2. Verify game exists and user is a player
3. Check `remainingGuesses > 0`
4. Compare sanitized guess with `secretWord` (case-insensitive)
5. **If correct**:
   - Update `state: "GAME_OVER"`, `winnerId: userId`
   - Return `{ success: true, correct: true, remainingGuesses: N }`
6. **If incorrect**:
   - Decrement `remainingGuesses`
   - Check if both players have 0 guesses → Draw
   - Return `{ success: true, correct: false, remainingGuesses: N }`

#### Validation Rules
- Guess is trimmed and converted to lowercase
- Player must have `remainingGuesses > 0`
- Max 3 guesses per player per game

#### Error Responses
- `unauthenticated`: User not logged in
- `invalid-argument`: Missing parameters
- `not-found`: Game doesn't exist
- `permission-denied`: User not a player
- `failed-precondition`: No remaining guesses

#### Usage Example
```dart
final result = await functions
    .httpsCallable('makeFinalGuess')
    .call({
      'gameId': gameId,
      'guess': 'tost makinesi',
    });

if (result.data['correct']) {
  showVictoryScreen();
} else {
  showIncorrectGuess(result.data['remainingGuesses']);
}
```

---

### judgeQuestion

**Purpose**: AI adjudication of Yes/No questions (called internally by processRound).

**Trigger**: HTTPS Callable Function  
**Authentication**: Required  
**Region**: `europe-west1`

#### Input Parameters
```typescript
{
  question: string,    // Player's question
  targetWord: string,  // Secret word
  category: string     // Word category
}
```

#### Output Schema
```typescript
{
  success: boolean,
  answer: "YES" | "NO" | "NEUTRAL"
}
```

#### AI Configuration
- **Model**: `gemini-2.5-flash`
- **Safety Settings**: `BLOCK_NONE` (all categories)
- **Response Format**: Enforced JSON schema
- **System Instruction**: "You are a strict referee for a 'Yes or No' guessing game..."

#### Logic Flow
1. Sanitize question (remove quotes)
2. Construct prompt with category, secret word, and question
3. Call Gemini API with structured JSON output
4. Parse response and normalize to uppercase
5. Return `{ success: true, answer: "YES" | "NO" }`
6. On error: Return `{ success: false, answer: "NEUTRAL" }`

#### Error Handling
- API timeout → `NEUTRAL`
- JSON parse error → `NEUTRAL`
- Content blocking → `NEUTRAL`
- 400 Bad Request → `NEUTRAL`

#### Usage Example (Internal)
```javascript
const result = await callJudgeQuestion(
  'Elektrikle mi çalışır?',
  'Tost Makinesi',
  'Mutfak Eşyaları'
);
// result: { success: true, answer: 'YES' }
```

---

## Firestore Triggers

### createGame

**Purpose**: Initializes game session with secret word and player data.

**Trigger**: `onDocumentCreated('games/{gameId}')`  
**Condition**: Only when `state === 'MATCHING'`  
**Region**: `europe-west1`

#### Trigger Data
```typescript
{
  state: 'MATCHING',
  playerIds: [string, string],
  currentRound: 0,
  players: {},
  history: [],
  winnerId: null,
  secretWord: null,
  category: null,
  roundTimerEndsAt: null
}
```

#### Logic Flow
1. Check if state is `MATCHING` (skip if not)
2. Select random word from `wordList.js` using `getRandomWord()`
3. Fetch player profiles from `users/{playerId}` collection
4. Use fallback data if profile doesn't exist
5. Calculate `roundTimerEndsAt = now + 10 seconds`
6. Update game document with:
   - `state: "ROUND_IN_PROGRESS"`
   - `currentRound: 1`
   - `secretWord`, `category`
   - `players.{p1}` and `players.{p2}` (initialized player data)
   - `roundTimerEndsAt`

#### Player Data Initialization
```typescript
players: {
  [playerId]: {
    username: string,
    avatarUrl: string,
    avatarFrameId: string,
    remainingGuesses: 3,
    currentQuestion: null,
    lastAnswer: null,
    isReadyForNextRound: false
  }
}
```

#### Error Handling
- On error: Update `state: "GAME_OVER"`, `winnerId: "error"`

---

### processRound

**Purpose**: Core game loop orchestrator - handles fast-track, AI adjudication, and round progression.

**Trigger**: `onDocumentUpdated('games/{gameId}')`  
**Region**: `europe-west1`

#### Control Gates

**CONTROL 1: Fast-Track Detection**
- **Condition**: `state === 'ROUND_IN_PROGRESS'` AND both players submitted questions
- **Action**: Update `state: "WAITING_FOR_ANSWERS"`
- **Effect**: Re-triggers function to execute Control 2

**CONTROL 2: AI Adjudication**
- **Condition**: `state === 'WAITING_FOR_ANSWERS'` AND state just changed
- **Action**: 
  1. Call `judgeQuestion` for both players in parallel
  2. Wait for both AI responses
  3. Proceed to Control 3

**CONTROL 3: Round Progression**
- **Actions**:
  1. Create history entry for current round
  2. Update `lastAnswer` for both players
  3. Clear `currentQuestion` for both players
  4. Append history entry to `history` array
  5. Determine next state:
     - If `currentRound >= 10`: `state: "FINAL_GUESS_PHASE"`, timer +15s
     - Else: `state: "ROUND_IN_PROGRESS"`, `currentRound++`, timer +10s

#### History Entry Format
```typescript
{
  round: number,
  [playerId1]: {
    question: string,
    answer: "YES" | "NO" | "NEUTRAL"
  },
  [playerId2]: {
    question: string,
    answer: "YES" | "NO" | "NEUTRAL"
  }
}
```

#### Error Handling
- AI failure → Continue with `NEUTRAL` answers
- Idempotent design prevents duplicate processing

---

### finalizeGame

**Purpose**: Awards rewards, updates stats, and cleans up when game ends.

**Trigger**: `onDocumentUpdated('games/{gameId}')`  
**Condition**: `beforeData.state !== 'GAME_OVER'` AND `afterData.state === 'GAME_OVER'`  
**Region**: `europe-west1`

#### Reward Calculation

| Outcome | Winner XP | Winner Coins | Loser XP | Loser Coins |
|---------|-----------|--------------|----------|-------------|
| Normal Win | +50 | +100 | +10 | +0 |
| Draw | +20 | +20 | +20 | +20 |
| Error | +0 | +0 | +0 | +0 |

#### Logic Flow
1. Read `winnerId` from game document
2. Calculate rewards based on outcome (win/loss/draw)
3. Use Firestore transaction to update both `users/{playerId}` documents:
   - Increment `xp` and `coins`
   - Update `stats.gamesPlayed`, `stats.gamesWon`
   - Update `stats.currentStreak` (increment for winner, reset to 0 for loser)

#### Stats Updates

**Winner**:
```typescript
{
  xp: +50,
  coins: +100,
  stats: {
    gamesPlayed: +1,
    gamesWon: +1,
    currentStreak: +1  // Added to existing streak
  }
}
```

**Loser**:
```typescript
{
  xp: +10,
  coins: +0,
  stats: {
    gamesPlayed: +1,
    gamesWon: +0,
    currentStreak: 0   // Reset
  }
}
```

#### Error Handling
- If user document doesn't exist: Skip rewards (log warning)
- Transaction ensures atomic updates for both players

---

## Scheduled Functions

### handleTimeout

**Purpose**: Processes games with expired timers.

**Trigger**: Cloud Scheduler (cron job)  
**Schedule**: Every 30 seconds  
**Region**: `europe-west1`

#### Logic Flow
1. Get current server timestamp
2. Query games with expired `ROUND_IN_PROGRESS` timers:
   - `state === 'ROUND_IN_PROGRESS'`
   - `roundTimerEndsAt <= now`
   - Limit 100
3. For each expired round:
   - Check each player's `currentQuestion`
   - If null/empty: Set to `"TIMEOUT_NO_QUESTION"`
   - Update `state: "WAITING_FOR_ANSWERS"` (triggers `processRound`)
4. Query games with expired `FINAL_GUESS_PHASE` timers:
   - `state === 'FINAL_GUESS_PHASE'`
   - `roundTimerEndsAt <= now`
   - Limit 100
5. For each expired final guess:
   - Update `state: "GAME_OVER"`, `winnerId: "draw"`

#### Firestore Indexes Required
- Composite index on `games` collection:
  - `state` (ASC) + `roundTimerEndsAt` (ASC)

#### Execution Monitoring
- View logs: `firebase functions:log --only handleTimeout`
- Cloud Console: Cloud Scheduler → Execution history

---

## Error Codes Reference

| Code | Description | User Action |
|------|-------------|-------------|
| `unauthenticated` | User not logged in | Sign in anonymously |
| `invalid-argument` | Missing/invalid parameters | Check input values |
| `not-found` | Document doesn't exist | Verify game/user exists |
| `permission-denied` | Not authorized for action | Ensure user is player |
| `failed-precondition` | State mismatch or constraint | Check game state |
| `internal` | Server/API error | Retry or contact support |

---

## Rate Limiting

**Current Implementation**: None (will be added in future)

**Recommended Limits**:
- `joinMatchmaking`: 5 calls per minute per user
- `submitQuestion`: 1 call per 10 seconds per user per game
- `makeFinalGuess`: 3 calls per game per user (enforced by logic)

---

## Performance Metrics

**Typical Response Times** (production):
- `joinMatchmaking`: ~200-500ms
- `submitQuestion`: ~100-200ms
- `makeFinalGuess`: ~150-300ms
- `judgeQuestion`: ~500-2000ms (Gemini API call)
- `createGame`: ~300-800ms (trigger)
- `processRound`: ~1000-3000ms (AI adjudication)
- `finalizeGame`: ~200-500ms (trigger)
- `handleTimeout`: ~500-2000ms (batch processing)

---

## Security Considerations

1. **Authentication**: All callable functions verify `context.auth`
2. **Authorization**: Functions check user is in `playerIds` array
3. **Input Validation**: All inputs sanitized and validated
4. **Idempotency**: Triggers handle duplicate invocations
5. **Rate Limiting**: Implemented at application level (future)

---

**API Version**: 1.0.0  
**Last Updated**: 2025-10-25  
**Region**: europe-west1
