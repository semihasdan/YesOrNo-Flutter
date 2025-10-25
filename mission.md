Master Prompt: Design a Real-Time 1v1 AI-Adjudicated "Yes or No" Game1. Task Definition & PersonaAct as a Senior Serverless Architect and Game Designer.Your task is to design a robust, scalable, and real-time 1v1 online duel mode for a mobile game called "Yes or No." The game is a modern, fast-paced version of "20 Questions."The architecture must be serverless, built on a Flutter client and a Firebase backend. All game logic must be secure, server-authoritative, and event-driven. The core mechanic relies on an AI Referee (Gemini API) to adjudicate (judge) player questions in real-time.You must design the complete, end-to-end flow, including data models, backend functions, client-side state listeners, and all edge cases.2. Core Technology StackClient: FlutterBackend: FirebaseAuthentication: Firebase Authentication (Zero-friction: Anonymous Login, Game Center/Google Play Games)Database: Cloud Firestore (for all real-time game state)Server-Side Logic: Cloud Functions (Callable, Firestore Triggers, Scheduled)AI Adjudicator: Google Gemini API (Called via a secure Cloud Function)3. Core Game Flow (Summary)Matchmaking: A user enters a queue. A Cloud Function matches two players and creates a game document.Game Loop (10 Rounds): The game starts. For 10 rounds (10 seconds each), both players submit a "Yes/No" question simultaneously.Fast-Track Mechanic: If both players submit before the 10s timer ends, the round immediately processes.AI Adjudication: A Cloud Function sends both questions to the Gemini API, which judges them against the secretWord.Results: Answers ("YES"/"NO") are written back to the game document. The next round begins.Final Guess: Players have 3 total "Final Guesses." A correct guess wins the game instantly. A wrong guess uses up a chance.Game End: The game ends if:A player guesses correctly.Both players run out of guesses (Draw).10 rounds complete, triggering a "Final Guess Phase."Scoring: The winner receives XP and Coins. A "Victory Taunt" (cosmetic) is shown to the loser.4. Firestore Data ModelsDesign the following Firestore collections. These models must be highly reactive.4.1. users/{userId}The persistent document for all user stats, currency, and inventory.{
  "username": "Player123",
  "avatarUrl": "https://...",
  "activeAvatarFrameId": "premium_gold", // Equipped cosmetic
  "activeVictoryTauntId": "taunt_fireworks", // Equipped cosmetic
  "coins": 1500,
  "xp": 120,
  "rank": "Gold",
  "stats": {
    "gamesPlayed": 20,
    "gamesWon": 15,
    "currentStreak": 3
  },
  "unlockedItems": ["frame_basic", "premium_gold", "taunt_fireworks"] // For marketplace
}
4.2. matchmakingQueue/{docId}A temporary document created when a user hits "Quick Match."{
  "userId": "user_abc123",
  "elo": 1200, // For future skill-based matchmaking
  "joinTime": "2025-10-24T18:00:00Z" // (Firestore Timestamp) For FIFO logic
}
4.3. games/{gameId} (The "Single Source of Truth")This is the most critical document. The Flutter client must have a live onSnapshot listener attached to this document for the entire duration of the match. All UI must be a direct reaction to changes in this document.Define the Game States (state field):"MATCHING": joinMatchmaking found two players. createGame trigger is firing."INITIALIZING": createGame is actively selecting a word and populating player data. (Client shows "Preparing Game...")"ROUND_IN_PROGRESS": The round is active (10s timer). Awaiting currentQuestion from both players."WAITING_FOR_ANSWERS": Round ended (timer up or fast-track). processRound is now calling the AI Referee. (Client shows "AI is judging...")"FINAL_GUESS_PHASE": Round 10 is over. A 15s timer for a final guess isactive."GAME_OVER": A winner is decided. finalizeGame trigger is running. (Client shows "Game Over" summary).{
  // --- State & Metadata ---
  "state": "ROUND_IN_PROGRESS", // See state definitions above
  "currentRound": 3,
  "roundTimerEndsAt": "2025-10-24T18:05:30Z", // (Firestore Timestamp)
  "secretWord": "Tost Makinesi", // (Turkish: Toaster)
  "category": "Mutfak Eşyaları", // (Turkish: Kitchen Appliances)
  "winnerId": null, // (e.g., "user_abc123" or "draw")

  // --- Player Data ---
  "playerIds": ["user_abc123", "user_xyz789"], // For easy querying
  "players": {
    "user_abc123": {
      "username": "Player123",
      "avatarUrl": "https://...",
      "avatarFrameId": "premium_gold",
      "remainingGuesses": 3,
      "currentQuestion": "Metalden mi yapılmış?", // (Is it made of metal?)
      "lastAnswer": "YES", // Result from the previous round
      "isReadyForNextRound": true // (For future "next round" button)
    },
    "user_xyz789": {
      "username": "Rival",
      "avatarUrl": "https://...",
      "avatarFrameId": "basic_frame",
      "remainingGuesses": 2,
      "currentQuestion": "Elektrikle mi çalışır?", // (Does it use electricity?)
      "lastAnswer": "YES",
      "isReadyForNextRound": true
    }
  },

  // --- Game Log ---
  "history": [
    {
      "round": 1,
      "user_abc123": { "question": "Canlı mı?", "answer": "NO" },
      "user_xyz789": { "question": "Yenilebilir mi?", "answer": "NO" }
    },
    {
      "round": 2,
      "user_abc123": { "question": "Büyük mü?", "answer": "NO" },
      "user_xyz789": { "question": "Evde mi bulunur?", "answer": "YES" }
    }
    // ... (Appended after each round)
  ]
}
5. Backend Architecture (Cloud Functions)Design the following serverless functions. They must be secure and efficient.5.1. joinMatchmaking (Callable Function)Trigger: Called by the Flutter client on "Quick Match" button press.Input: (data, context) - Uses context.auth.uid.Logic:Get userId from context.auth.Query matchmakingQueue (e.g., orderBy('joinTime').limit(1)).Case A (Opponent Found):Use a Firestore Transaction to atomically read and delete the opponentDoc.Create a new gameId in the games collection.Write { playerIds: [userId, opponentId], state: "MATCHING" } to the new game doc.Return { success: true, gameId: gameId } to both players (e.g., via a document write they are listening to, or direct return).Case B (Queue Empty):Create a new document in matchmakingQueue for the user: { userId, joinTime }.Return { success: true, gameId: null } (Client knows it's waiting).Client-Side: The client must listen to its matchmakingQueue doc. If the doc is deleted and a gameId is returned (or a new doc in a userGames subcollection is created), it navigates to the GameScreen.5.2. createGame (Firestore Trigger - onCreate)Trigger: onDocumentCreated('games/{gameId}') (when state is "MATCHING").Logic:Select a random secretWord and category from a secure word list.Fetch profile data (username, avatarUrl, etc.) for both playerIds from the users collection.Update the games/{gameId} document with:secretWord, categoryplayers.{p1...}, players.{p2...} (all profile data)currentRound: 1roundTimerEndsAt: (Current Time + 10 seconds)state: "ROUND_IN_PROGRESS"5.3. submitQuestion (Callable Function)Trigger: Called by the client when a user submits their question (before the 10s timer ends).Input: { "gameId": "...", "question": "..." }Logic:Validate gameId and userId.Write to games/{gameId}: players.{userId}.currentQuestion = question.(The main game loop progression is handled by the processRound trigger, not this function).5.4. judgeQuestion (Callable Function - The AI Referee)Trigger: Called by processRound function.Input: { "question": "...", "secretWord": "...", "category": "..." }Logic:Define a strict systemInstruction for the Gemini API:"You are a strict referee for a 'Yes or No' guessing game. Your only task is to determine if the user's question is logically true or false for the secret word. Your output MUST strictly be a JSON object containing ONLY the 'answer' field with the value 'YES' or 'NO'."Call the Gemini API with the prompt and the JSON schema enforcement.Include safetySettings to BLOCK_NONE to prevent false positives on simple words.try-catch block: On API failure, return { "answer": "NEUTRAL" } (or handle error).Return the structured JSON: { "answer": "YES" } or { "answer": "NO" }.5.5. processRound (Firestore Trigger - onUpdate)Trigger: onDocumentUpdated('games/{gameId}'). This is the core game loop engine.Logic:Get gameDoc data.Control 1 (Fast-Track Mechanic):Check if state == "ROUND_IN_PROGRESS".Check if both players.p1.currentQuestion and players.p2.currentQuestion are NOT null.If true: Update state: "WAITING_FOR_ANSWERS". (This immediately re-triggers this function).Control 2 (AI Adjudication):Check if state == "WAITING_FOR_ANSWERS".Get P1_Question and P2_Question.Call the judgeQuestion function twice, in parallel (Promise.all).Wait for both Answer_P1 ("YES" | "NO") and Answer_P2 ("YES" | "NO") to return.Control 3 (Round Progression):If answers are received (and state is still WAITING_FOR_ANSWERS):Create the history log entry for the round and append it to the history array.Set players.{p1}.lastAnswer = Answer_P1Set players.{p2}.lastAnswer = Answer_P2Clear questions: players.{p1}.currentQuestion = null, players.{p2}.currentQuestion = nullIncrement currentRound.If currentRound > 10: Set state: "FINAL_GUESS_PHASE" and roundTimerEndsAt (Current Time + 15s).If currentRound <= 10: Set state: "ROUND_IN_PROGRESS" and roundTimerEndsAt (Current Time + 10s).5.6. handleTimeout (Scheduled Function - Cron)Trigger: Runs every 30 seconds (onSchedule).Logic:Query games collection for:(state == "ROUND_IN_PROGRESS" AND roundTimerEndsAt <= now)(state == "FINAL_GUESS_PHASE" AND roundTimerEndsAt <= now)For each timed-out game:If ROUND_IN_PROGRESS: Set any currentQuestion that is null to "NULL" (as a timeout). Then, update state: "WAITING_FOR_ANSWERS". (This triggers processRound).If FINAL_GUESS_PHASE: Update state: "GAME_OVER". (This triggers finalizeGame).5.7. makeFinalGuess (Callable Function)Trigger: Called by client on "Make Final Guess" button press.Input: { "gameId": "...", "guess": "..." }Logic:Read gameDoc.Decrement players.{userId}.remainingGuesses by 1.Compare guess.toLowerCase() with secretWord.toLowerCase().Case A (Guess Correct):Update state: "GAME_OVER"Update winnerId: userIdCase B (Guess Incorrect):Just update the remainingGuesses count.Sub-check: If both players now have remainingGuesses == 0:Update state: "GAME_OVER"Update winnerId: "draw" (Early Draw)(This function will trigger finalizeGame if the state changes to GAME_OVER).5.8. finalizeGame (Firestore Trigger - onUpdate)Trigger: onDocumentUpdated('games/{gameId}') (when state changes to "GAME_OVER").Logic:Read winnerId.Calculate XP, Coins, and stats changes for the winner and loser (or draw).Use a Transaction to update the users/{p1Id} and users/{p2Id} documents with their new stats (e.g., gamesPlayed++, gamesWon++, coins + 50).(Optional) Set a TTL (Time-to-Live) policy on the game document to delete it after 24 hours.6. Client-Side Architecture (Flutter)The Flutter app must be a "dumb client." All UI must be a direct reflection of the gameDoc state from Firestore.6.1. State ManagementThe GameScreen widget must use a StreamBuilder or StreamProvider (Riverpod/Provider) to listen to the games/{gameId} document snapshot.The build method will be a large switch statement based on the game.state field.6.2. GameScreen (Widget) Flow// Pseudocode for the GameScreen build method
StreamBuilder<DocumentSnapshot>(
  stream: firestore.doc('games/$gameId').snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return LoadingSpinner(); // (Loading game...)
    }
    
    var game = GameModel.fromSnap(snapshot.data);
    
    // --- Persistent UI Elements ---
    // (e.g., Player Avatars, Score, Round Number, History Log)
    // ...

    // --- State-Dependent UI ---
    switch (game.state) {
      
      case "INITIALIZING":
        return WaitingForGameToStartUI(); // (Shows "Preparing Game...")

      case "ROUND_IN_PROGRESS":
        // Start/show 10s countdown timer from (game.roundTimerEndsAt)
        // Show text input field for the question
        return QuestionInputUI(timer: game.roundTimerEndsAt);

      case "WAITING_FOR_ANSWERS":
        // Show "AI is adjudicating..." animation
        // Show "Waiting for opponent..." if we submitted but they haven't
        return AIJudgingUI(); 

      case "FINAL_GUESS_PHASE":
        // Show 15s final guess timer
        return FinalGuessInputUI(timer: game.roundTimerEndsAt);

      case "GAME_OVER":
        // Navigate to/show the Game Over Summary Screen
        // (e.g., showGameSummary(game.winnerId, game.players[game.winnerId].victoryTaunt))
        return GameOverUI(game: game);
        
      default:
        return ErrorUI();
    }
  }
)
7. Edge Cases & RobustnessYou must account for:Player Disconnection (Rage Quit):Solution: The handleTimeout (Cron) function naturally handles this. If a player disconnects, they will fail to submit their question, handleTimeout will set their question to "NULL," and the game will proceed. The connected player continues playing against a "timed-out" opponent.Advanced Solution: Implement Firestore Presence. If a player is offline for >30 seconds, force state: "GAME_OVER" and set the other player as winnerId.AI Referee Error (judgeQuestion):Solution: The judgeQuestion function must have a try-catch. On API failure (e.g., 500, 429), it must return a non-blocking answer like { "answer": "NEUTRAL" } (or HATA - Error). The game must not halt.Race Conditions (Fast-Track):Solution: The processRound trigger logic handles this. It only fires the "AI Adjudication" step after checking that both questions are filled. The onUpdate trigger is idempotent and will handle rapid, near-simultaneous writes correctly.