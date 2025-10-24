# Firebase Function Fix - AI Integration

## Problem Identified

The Firebase Function was experiencing an **INTERNAL error** when called from the Flutter app. The root causes were:

1. **Wrong Package**: Using `@google/genai` instead of `@google/generative-ai`
2. **Incorrect API Usage**: The Google Generative AI SDK API was not being used correctly
3. **Wrong Model Call Pattern**: The SDK structure was outdated

## Changes Made

### 1. Updated Package Dependency

**File**: `/functions/package.json`

```json
// BEFORE
"@google/genai": "^1.26.0"

// AFTER
"@google/generative-ai": "^0.21.0"
```

### 2. Fixed Firebase Function Implementation

**File**: `/functions/index.js`

#### Key Changes:

**Before:**
```javascript
const { GoogleGenAI } = require('@google/genai');
const ai = new GoogleGenAI({ apiKey: geminiApiKey });

const response = await ai.models.generateContent({
    model: 'gemini-2.5-flash-lite-001',
    contents: userPrompt,
    config: { ... }
});
```

**After:**
```javascript
const { GoogleGenerativeAI } = require('@google/generative-ai');
const genAI = new GoogleGenerativeAI(geminiApiKey);

const model = genAI.getGenerativeModel({ 
    model: 'gemini-1.5-flash',
    generationConfig: { ... },
    systemInstruction: '...'
});

const result = await model.generateContent(prompt);
const response = await result.response;
const text = response.text();
```

## Updated Function Code

The complete updated function:

```javascript
const functions = require('firebase-functions');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const geminiApiKey = functions.config().ai.key;
const genAI = new GoogleGenerativeAI(geminiApiKey);

exports.judgeQuestion = functions
    .region('europe-west1') 
    .https.onCall(async (data, context) => { 
    
    const { question, targetWord, category } = data;

    if (!question || !targetWord) {
        throw new functions.https.HttpsError('invalid-argument', 'Question or target word is missing.');
    }

    try {
        const model = genAI.getGenerativeModel({ 
            model: 'gemini-1.5-flash',
            generationConfig: {
                responseMimeType: 'application/json',
                responseSchema: {
                    type: 'object',
                    properties: {
                        answer: {
                            type: 'string',
                            enum: ['YES', 'NO'],
                            description: 'The definitive Yes or No answer to the question.'
                        }
                    },
                    required: ['answer']
                }
            },
            systemInstruction: 'You are a strict referee for a "Yes or No" guessing game...'
        });

        const prompt = `Secret Category: ${category}.
Secret Word: ${targetWord}.
Question: "${question}"

Analyze if this question would be answered YES or NO for the secret word.`;

        const result = await model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();
        
        console.log('Gemini raw response:', text);
        
        const jsonResponse = JSON.parse(text);
        
        return { success: true, answer: jsonResponse.answer }; 

    } catch (error) {
        console.error('Gemini API Error:', error);
        throw new functions.https.HttpsError('internal', 'AI Referee failed to generate an answer.', error.message);
    }
});
```

## Deployment Steps

1. **Install Dependencies**
   ```bash
   cd functions
   npm install
   ```

2. **Deploy Function**
   ```bash
   firebase deploy --only functions:judgeQuestion
   ```

3. **Verify Deployment**
   - Check Firebase Console → Functions
   - Confirm `judgeQuestion` is deployed in `europe-west1`
   - Status should be "Healthy"

## Expected Behavior After Fix

When a user asks a question in the single player game:

### Flutter App Logs:
```
flutter: [DEBUG] Question submitted: insan mı
flutter: [DEBUG] Calling Firebase Function judgeQuestion...
flutter: [DEBUG] Sending - Question: "insan mı", Word: "Frodo Baggins", Category: "Kurgusal Karakterler"
flutter: [DEBUG] Firebase Function returned successfully
flutter: [DEBUG] Response data: {success: true, answer: NO}
flutter: [DEBUG] AI Response from Firebase: NO
flutter: [DEBUG] Converted to: No
flutter: [DEBUG] ✅ Final Answer displayed to user: No
```

### Firebase Function Logs:
```
Gemini raw response: {"answer":"NO"}
```

## Configuration Requirements

### Firebase Functions Config

The AI key must be configured:

```bash
firebase functions:config:set ai.key="YOUR_GEMINI_API_KEY"
```

⚠️ **Note**: Firebase is deprecating `functions.config()` in March 2026. Consider migrating to environment variables using `.env` files.

### Future Migration (Recommended)

Create a `.env` file in `/functions`:

```env
GEMINI_API_KEY=your_actual_api_key_here
```

Update code to use:
```javascript
require('dotenv').config();
const geminiApiKey = process.env.GEMINI_API_KEY;
```

## Testing the Fix

### 1. From Flutter App
- Run the app
- Start a single player game
- Ask a question
- Check logs for successful AI response

### 2. From Firebase Console
- Go to Functions → judgeQuestion → Logs
- Check for successful invocations
- Look for "Gemini raw response" logs

### 3. Manual Test (Firebase Emulator)
```bash
cd functions
npm run serve
```

Then call from Flutter pointing to emulator.

## Error Handling

The function now properly handles:

1. **Missing Parameters**: Returns `invalid-argument` error
2. **AI API Failures**: Returns `internal` error with details
3. **JSON Parse Errors**: Caught and logged
4. **Network Issues**: Propagated with error messages

## Performance Considerations

- **Model**: Using `gemini-1.5-flash` for fast responses
- **Region**: `europe-west1` for European users
- **Timeout**: Default 60s (sufficient for AI calls)
- **Cold Start**: ~2-3 seconds first call, <500ms subsequent

## Monitoring

### Key Metrics to Watch:
- Invocation count
- Error rate
- Execution time (should be <2s)
- Memory usage

### Alerts to Set:
- Error rate > 5%
- Execution time > 5s
- Failed invocations

## Costs

Estimated costs per 1000 questions:
- Firebase Functions: ~$0.02
- Gemini API (1.5-flash): ~$0.10
- **Total**: ~$0.12 per 1000 questions

## Next Steps

1. ✅ Fixed package dependency
2. ✅ Updated API usage
3. ⏳ Deploy to Firebase
4. ⏳ Test from Flutter app
5. 🔜 Monitor for 24 hours
6. 🔜 Consider migrating to `.env` config

## Files Modified

- `/functions/package.json` - Updated dependency
- `/functions/index.js` - Fixed API implementation

## Related Documentation

- [Google Generative AI Node.js SDK](https://github.com/google/generative-ai-js)
- [Firebase Functions Guide](https://firebase.google.com/docs/functions)
- [Gemini API Documentation](https://ai.google.dev/docs)
