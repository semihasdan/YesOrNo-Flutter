# Single Player Game Enhancements

## Overview
Enhanced the single player game screen with improved gameplay mechanics, Firebase AI integration, and better user experience.

## Changes Implemented

### 1. Send Button Cooldown ✅
- **Implementation**: Send button can only be used once per round (every 10 seconds)
- **Visual Feedback**: 
  - Button becomes grayed out when disabled
  - Active state shows cyan glow effect
  - Disabled state has gray appearance
- **User Notification**: SnackBar appears if user tries to send while on cooldown
- **Reset**: Automatically resets at the start of each new round

### 2. Shield Button Removal ✅
- **Removed**: Shield power-up button completely removed from the action bar
- **UI Update**: Action bar now only shows "Make Final Guess" button and Hint button

### 3. Hint System ✅
- **Display**: Beautiful dialog with glass container effect
- **Adaptive Layout**: 
  - Scrollable container with max height of 50% screen
  - Handles both short and long hints properly
- **Content**: Shows hint from Firestore word data
- **Count**: Displays remaining hint count with badge
- **Visual Effects**: Gold color theme with lightbulb icon

### 4. Firebase AI Integration ✅
- **Package Added**: `cloud_functions: ^5.1.5` to pubspec.yaml
- **Function Call**: Integrated `judgeQuestion` Firebase Function
- **Region**: Configured for `europe-west1`
- **Data Sent**:
  - `question`: User's yes/no question
  - `targetWord`: The secret word to guess
  - `category`: The category name
- **Response Processing**:
  - Receives AI response ('YES' or 'NO')
  - Converts to 'Yes' or 'No' display format
  - Handles uppercase/lowercase variations
  - Updates question card with colored answer badge
- **Error Handling**:
  - Catches Firebase Function errors
  - Shows user-friendly error message
  - Allows retry by removing pending question
  - Re-enables send button on error

## Technical Details

### State Variables Added
```dart
bool _canSendQuestion = true;          // Send button cooldown
String? _currentHint;                   // Currently displayed hint
String? _wordHint;                      // Hint from Firestore
FirebaseFunctions _functions;           // Firebase Functions instance
```

### Key Methods

#### `_submitQuestion()`
- **Purpose**: Handles question submission with AI integration
- **Process**:
  1. Validates question input
  2. Checks cooldown status
  3. Disables send button
  4. Creates pending question
  5. Calls Firebase Function
  6. Processes AI response
  7. Updates UI with answer

#### `_showHint()`
- **Purpose**: Displays hint dialog
- **Features**:
  - Checks hint availability
  - Decrements hint count
  - Shows adaptive dialog
  - Stores current hint for display

#### `_startTimer()`
- **Updated**: Resets `_canSendQuestion` flag at each round start
- **Purpose**: Enables send button for new rounds

## UI Enhancements

### Send Button States
- **Active**: Cyan background with glow effect
- **Disabled**: Gray background, no glow, muted text
- **Interaction**: Only responds to tap when active

### Hint Dialog
- **Header**: Lightbulb icon + "Hint" title in gold
- **Content**: Scrollable text area for variable-length hints
- **Button**: "Got it!" confirmation button
- **Theme**: Glass morphism effect matching game aesthetic

### Question Cards
- **Pending**: Gray border, no answer badge
- **Answered**: 
  - Green border + "YES" badge for positive
  - Red border + "NO" badge for negative
  - Capitalized display format

## Firebase Function Integration

### Function Name
`judgeQuestion`

### Expected Request Format
```javascript
{
  question: string,
  targetWord: string,
  category: string
}
```

### Expected Response Format
```javascript
{
  success: boolean,
  answer: 'YES' | 'NO'
}
```

### Error Handling
- Network errors
- Invalid responses
- Timeout handling
- User-friendly error messages

## User Experience Improvements

1. **Clear Feedback**: Visual indicators for all button states
2. **Fair Gameplay**: One question per round limit
3. **Better Hints**: Full hint text displayed in readable format
4. **AI Integration**: Real-time AI responses for question validation
5. **Error Recovery**: Graceful error handling with retry capability

## Testing Recommendations

1. **Send Button Cooldown**:
   - Verify button disabled after first send
   - Confirm re-enable at round start
   - Test rapid clicking prevention

2. **Hint System**:
   - Test with short hints (< 50 chars)
   - Test with long hints (> 500 chars)
   - Verify hint count decrements
   - Test behavior when no hints remain

3. **Firebase Integration**:
   - Test with valid yes/no questions
   - Test with ambiguous questions
   - Test network error scenarios
   - Verify response display format

4. **Shield Removal**:
   - Confirm shield button not visible
   - Verify layout adapts correctly
   - Test responsive design

## Dependencies Updated

```yaml
dependencies:
  cloud_functions: ^5.1.5  # NEW
  cloud_firestore: ^5.6.2
  firebase_core: ^3.10.1
  firebase_auth: ^5.3.4
```

## Files Modified

1. `/lib/screens/single_player_game_screen.dart` - Main implementation
2. `/pubspec.yaml` - Added cloud_functions dependency

## Notes for Developers

- The Firebase Function must be deployed to `europe-west1` region
- AI model used: `gemini-2.5-flash-lite-001`
- Response schema enforces strict 'YES'/'NO' format
- All hint text comes from Firestore `CategoriesTr` collection
- Send button cooldown syncs with round timer (10 seconds)

## Future Enhancements

- Add loading spinner during AI processing
- Implement hint preview on hover
- Add sound effects for send/receive
- Track question history statistics
- Add hint difficulty levels
