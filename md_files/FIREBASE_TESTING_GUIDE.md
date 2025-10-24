# Firebase Function Testing Guide

## Current Status

The Firebase Function `judgeQuestion` has been fixed and is being deployed. The main issue was using an incorrect Gemini model name.

## Issues Found and Fixed

### 1. Model Name Error ✅ FIXED
**Error**: `models/gemini-1.5-flash-latest is not found`
**Solution**: Changed from `gemini-1.5-flash-latest` to `gemini-1.5-flash`

### 2. Syntax Error ✅ FIXED
**Error**: Double `new` keyword on line 35
**Solution**: Removed duplicate `new` keyword

### 3. API Call Structure ✅ FIXED
**Error**: Incorrect `generateContent` call format
**Solution**: Fixed to use correct SDK API:
```javascript
const result = await model.generateContent(userPrompt);
const response = await result.response;
const responseText = response.text();
```

## Testing the Function

### Method 1: Test Script (Recommended)

We've created a test script at `/functions/test_function.js` that you can run locally:

```bash
cd functions
export GEMINI_API_KEY="your-actual-api-key"
node test_function.js
```

**Expected Output:**
```
Testing Gemini API...

=== Test 1: Is Orion a constellation? ===
Response: {"answer":"YES"}
Parsed: { answer: 'YES' }

=== Test 2: Does a sampler have strings? ===
Response: {"answer":"NO"}
Parsed: { answer: 'NO' }

=== Test 3: Is scissors a fruit? ===
Response: {"answer":"NO"}
Parsed: { answer: 'NO' }

✅ All tests passed!
```

### Method 2: Test from Flutter App

1. **Hot restart** the Flutter app (not hot reload)
2. Start a single player game
3. Ask a question
4. Check the logs

**Expected Logs:**
```
flutter: [DEBUG] Question submitted: telli mi
flutter: [DEBUG] Calling Firebase Function judgeQuestion...
flutter: [DEBUG] Sending - Question: "telli mi", Word: "Örnekleyici", Category: "Müzik Aletleri"
flutter: [DEBUG] Firebase Function returned successfully
flutter: [DEBUG] Response data: {success: true, answer: NO}
flutter: [DEBUG] AI Response from Firebase: NO
flutter: [DEBUG] Converted to: No
flutter: [DEBUG] ✅ Final Answer displayed to user: No
```

### Method 3: Check Firebase Logs

```bash
firebase functions:log
```

**Look for:**
- ✅ "Callable request verification passed"
- ✅ "Gemini raw response: {\"answer\":\"YES\"}" or "NO"
- ❌ Any errors or 404/400 status codes

## Deployment Status

Check if deployment completed:

```bash
firebase functions:list
```

**Expected Output:**
```
✔ functions: Loaded functions definitions from source: judgeQuestion
┌────────────────┬───────────────┬───────┐
│ Function       │ Trigger       │ Region│
├────────────────┼───────────────┼───────┤
│ judgeQuestion  │ HTTPS         │ europe-west1
└────────────────┴───────────────┴───────┘
```

## Troubleshooting

### If you still get INTERNAL error:

1. **Check Firebase Console**
   - Go to https://console.firebase.google.com
   - Navigate to Functions
   - Check if `judgeQuestion` shows as "Healthy"

2. **Check API Key**
   ```bash
   firebase functions:config:get
   ```
   Should show:
   ```json
   {
     "ai": {
       "key": "your-api-key"
     }
   }
   ```

3. **Re-deploy with verbose logging**
   ```bash
   firebase deploy --only functions:judgeQuestion --debug
   ```

4. **Check recent logs**
   ```bash
   firebase functions:log | head -50
   ```

## Common Errors and Solutions

### Error: "404 Not Found - models/xxx"
**Cause**: Wrong model name
**Solution**: Use `gemini-1.5-flash` (not -latest, not 2.5-flash)

### Error: "400 Bad Request - Invalid value at 'contents'"
**Cause**: Wrong API call structure
**Solution**: Pass string directly to `generateContent()`, not as `{contents: string}`

### Error: "API key not configured"
**Cause**: Missing Gemini API key
**Solution**: 
```bash
firebase functions:config:set ai.key="YOUR_KEY"
firebase deploy --only functions
```

### Error: "INTERNAL" with no details
**Cause**: Function crashed or JSON parse error
**Solution**: Check Firebase logs for the actual error

## Performance Benchmarks

Expected response times:
- **Cold start**: 2-4 seconds (first call after deployment)
- **Warm**: 500-1500ms (subsequent calls)
- **Timeout**: 60 seconds (function will fail if exceeded)

## Cost Estimation

Per 1000 questions:
- Firebase Functions invocations: ~$0.02
- Gemini API calls (gemini-1.5-flash): ~$0.10
- Total: ~$0.12 per 1000 questions

## Security Checklist

- ✅ API key stored in Firebase config (not in code)
- ✅ Function requires authentication (context.auth)
- ✅ Input validation (question, targetWord, category)
- ✅ Input sanitization (removes quotes)
- ✅ Error handling with proper error codes
- ✅ Regional deployment (europe-west1)

## Next Steps

1. ✅ Fix model name
2. ⏳ Wait for deployment to complete
3. ⏳ Test from Flutter app
4. ⏳ Verify logs show success
5. 🔜 Monitor for 24 hours
6. 🔜 Set up alerts for errors

## Files Modified

- `/functions/index.js` - Main function implementation
- `/functions/package.json` - Dependencies
- `/functions/test_function.js` - Local test script (NEW)

## Quick Commands Reference

```bash
# Deploy function
firebase deploy --only functions:judgeQuestion

# View logs
firebase functions:log

# List functions
firebase functions:list

# Get config
firebase functions:config:get

# Set config
firebase functions:config:set ai.key="YOUR_KEY"

# Test locally
cd functions && node test_function.js
```

## Support

If issues persist after all fixes:
1. Check Firebase Console for function status
2. Review complete logs with `firebase functions:log`
3. Test the Gemini API key separately
4. Verify Firebase project billing is enabled
5. Check if Gemini API is enabled in Google Cloud Console
