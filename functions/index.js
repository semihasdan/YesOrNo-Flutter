const functions = require('firebase-functions');
const { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } = require('@google/generative-ai'); 

// --- Yapılandırma ---
// API Anahtarını Firebase Yapılandırmasından Güvenli Şekilde Çekiyoruz.
const geminiApiKey = functions.config().ai.key; 

// Flutter'dan çağrılacak HTTPS Callable Function
exports.judgeQuestion = functions
    .region('europe-west1') // Fonksiyon Avrupa sunucularında çalışır
    .https.onCall(async (data, context) => { 
    
    // 0. API Anahtarı Kontrolü
    const currentApiKey = functions.config().ai.key; 
    if (!currentApiKey) {
        throw new functions.https.HttpsError('unauthenticated', 'Gemini API key is not configured.');
    }
    
    // Her çağrıda modeli başlatmak daha güvenilir.
    const genAI = new GoogleGenerativeAI(currentApiKey);

    const { question, targetWord, category } = data;

    // 1. Veri Doğrulama ve Temizleme
    if (!question || !targetWord || !category) {
        throw new functions.https.HttpsError('invalid-argument', 'Question, word, or category is missing.');
    }
    
    // JSON Payload ve URL kodlama hatalarını önlemek için tüm tırnak işaretlerini (", ') kaldırıyoruz.
    const cleanedQuestion = question.replace(/["']/g, '').trim(); 
    
    if (cleanedQuestion.length === 0) {
         throw new functions.https.HttpsError('invalid-argument', 'Question is empty after cleaning.');
    }

    try {
        // GÜVENLİK AYARLARI: İçerik engellemeyi en aza indir
        const safetySettings = [
            {
                category: HarmCategory.HARM_CATEGORY_HARASSMENT,
                threshold: HarmBlockThreshold.BLOCK_NONE,
            },
            {
                category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
                threshold: HarmBlockThreshold.BLOCK_NONE,
            },
            {
                category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
                threshold: HarmBlockThreshold.BLOCK_NONE,
            },
            {
                category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
                threshold: HarmBlockThreshold.BLOCK_NONE,
            },
        ];

        const systemInstruction = 
            'You are a strict referee for a "Yes or No" guessing game. Your only task is to determine if the user\'s question is logically true or false for the secret word. Your output MUST strictly be a JSON object containing ONLY the "answer" field with the value "YES" or "NO".';

        // --- HATA 3 DÜZELTMESİ (SyntaxError) ---
        // 'config:' objesi kaldırıldı.
        // systemInstruction ve safetySettings ana objeye taşındı.
        // responseMimeType ve responseSchema 'generationConfig' objesi içine alındı.
        const model = genAI.getGenerativeModel({ 
            model: 'gemini-2.5-flash', 
            systemInstruction: systemInstruction,
            safetySettings: safetySettings,
            generationConfig: {
                responseMimeType: 'application/json',
                responseSchema: {
                    type: 'object',
                    properties: {
                        answer: {
                            type: 'string',
                            enum: ['YES', 'NO'],
                        }
                    },
                    required: ['answer']
                },
            }
        });

        const userPrompt = `Secret Category: ${category}. Secret Word: ${targetWord}. Question: ${cleanedQuestion}`;

        // 3. generateContent çağrısı (HATA 1 DÜZELTİLDİ)
        const result = await model.generateContent(userPrompt);
        
        // 4. Cevabı güvenli bir şekilde ayrıştırma (HATA 2 DÜZELTİLDİ)
        const responseText = result.response.text(); 

        if (!responseText) {
             console.error('Gemini Error: API produced no text output.');
             throw new functions.https.HttpsError('internal', 'AI did not produce text output (Likely a safety block or content restriction).');
        }

        console.log('Gemini raw response:', responseText);
        
        // Model artık JSON dönmeye zorlandığı için bu satır başarılı olmalı.
        const jsonResponse = JSON.parse(responseText.trim()); 
        
        // 5. Başarılı dönüş
        return { success: true, answer: jsonResponse.answer.toUpperCase() }; 

    } catch (error) {
        console.error('Gemini API Error:', error);
        
        const errorMessage = error.message || 'Unknown API error.';
        
        // SyntaxError hatası (JSON parse) veya 400 hatası için
        if (errorMessage.includes('400') || error instanceof SyntaxError) {
             throw new functions.https.HttpsError('internal', 
                'AI Referee format hatası. (400 Bad Request veya JSON Parse Error). İçerik/kısıtlama reddi veya model hatası.', 
                errorMessage);
        }
        
        throw new functions.https.HttpsError('internal', 'AI Referee failed to generate an answer. Check logs for API details.', errorMessage);
    }
});
