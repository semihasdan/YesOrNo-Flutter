// Test script for Firebase Function
const { GoogleGenerativeAI } = require('@google/generative-ai');

// Replace with your actual API key for testing
const API_KEY = process.env.GEMINI_API_KEY || 'your-api-key-here';

async function testGeminiAPI() {
    try {
        console.log('Testing Gemini API...');
        
        const genAI = new GoogleGenerativeAI(API_KEY);
        
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
                        }
                    },
                    required: ['answer']
                }
            },
            systemInstruction: 'You are a strict referee for a "Yes or No" guessing game. Your only task is to determine if the user\'s question is logically true or false for the secret word. Your output MUST strictly be a JSON object containing ONLY the "answer" field with the value "YES" or "NO".'
        });

        // Test 1: Simple question
        console.log('\n=== Test 1: Is Orion a constellation? ===');
        const test1Prompt = 'Secret Category: Gezegenler ve Astronomik Nesneler.\nSecret Word: Orion.\nQuestion: takımyıldız mı';
        const result1 = await model.generateContent(test1Prompt);
        const response1 = await result1.response;
        const text1 = response1.text();
        console.log('Response:', text1);
        console.log('Parsed:', JSON.parse(text1));

        // Test 2: Negative question  
        console.log('\n=== Test 2: Does a sampler have strings? ===');
        const test2Prompt = 'Secret Category: Müzik Aletleri.\nSecret Word: Örnekleyici.\nQuestion: telli mi';
        const result2 = await model.generateContent(test2Prompt);
        const response2 = await result2.response;
        const text2 = response2.text();
        console.log('Response:', text2);
        console.log('Parsed:', JSON.parse(text2));

        // Test 3: Object question
        console.log('\n=== Test 3: Is scissors a fruit? ===');
        const test3Prompt = 'Secret Category: Günlük Eşyalar.\nSecret Word: Makas.\nQuestion: meyve mi';
        const result3 = await model.generateContent(test3Prompt);
        const response3 = await result3.response;
        const text3 = response3.text();
        console.log('Response:', text3);
        console.log('Parsed:', JSON.parse(text3));

        console.log('\n✅ All tests passed!');
        
    } catch (error) {
        console.error('❌ Error:', error.message);
        if (error.response) {
            console.error('Response data:', await error.response.text());
        }
        process.exit(1);
    }
}

// Run the test
testGeminiAPI();
