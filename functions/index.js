const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } = require('@google/generative-ai');
const { getRandomWord } = require('./wordList');

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

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

// ============================================================================
// MATCHMAKING & GAME MANAGEMENT FUNCTIONS
// ============================================================================

/**
 * joinMatchmaking - Callable Function
 * Handles player queue entry and opponent matching
 * 
 * Input: { } (uses context.auth.uid)
 * Output: { success: true, gameId: string | null }
 */
exports.joinMatchmaking = functions
    .region('europe-west1')
    .https.onCall(async (data, context) => {
        // 1. Authentication check
        if (!context.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
        }
        
        const userId = context.auth.uid;
        console.log(`joinMatchmaking called by user: ${userId}`);
        
        try {
            // 2. Query matchmaking queue for an opponent (FIFO - oldest entry)
            const queueSnapshot = await db.collection('matchmakingQueue')
                .orderBy('joinTime', 'asc')
                .limit(1)
                .get();
            
            // Case A: Opponent found
            if (!queueSnapshot.empty) {
                const opponentDoc = queueSnapshot.docs[0];
                const opponentId = opponentDoc.data().userId;
                
                // Don't match with self
                if (opponentId === userId) {
                    console.log('Found self in queue, creating new queue entry');
                    // Delete old entry and create new one
                    await opponentDoc.ref.delete();
                    await db.collection('matchmakingQueue').add({
                        userId: userId,
                        elo: 1200,
                        joinTime: admin.firestore.FieldValue.serverTimestamp(),
                    });
                    return { success: true, gameId: null };
                }
                
                console.log(`Match found! Player1: ${opponentId}, Player2: ${userId}`);
                
                // Use transaction to atomically delete queue entry and create game
                const gameId = await db.runTransaction(async (transaction) => {
                    // Delete opponent's queue entry
                    transaction.delete(opponentDoc.ref);
                    
                    // Create new game document
                    const newGameRef = db.collection('games').doc();
                    transaction.set(newGameRef, {
                        state: 'MATCHING',
                        playerIds: [opponentId, userId],
                        currentRound: 0,
                        players: {},
                        history: [],
                        winnerId: null,
                        secretWord: null,
                        category: null,
                        roundTimerEndsAt: null,
                    });
                    
                    return newGameRef.id;
                });
                
                console.log(`Game created with ID: ${gameId}`);
                return { success: true, gameId: gameId };
            }
            
            // Case B: Queue is empty, add user to queue
            console.log('No opponent found, adding to queue');
            await db.collection('matchmakingQueue').add({
                userId: userId,
                elo: 1200,
                joinTime: admin.firestore.FieldValue.serverTimestamp(),
            });
            
            return { success: true, gameId: null };
            
        } catch (error) {
            console.error('joinMatchmaking error:', error);
            throw new functions.https.HttpsError('internal', 'Failed to join matchmaking', error.message);
        }
    });

/**
 * createGame - Firestore Trigger (onCreate)
 * Initializes game session with secret word and player data
 * 
 * Trigger: games/{gameId} onCreate when state='MATCHING'
 */
exports.createGame = functions
    .region('europe-west1')
    .firestore.document('games/{gameId}')
    .onCreate(async (snapshot, context) => {
        const gameId = context.params.gameId;
        const gameData = snapshot.data();
        
        console.log(`createGame triggered for game: ${gameId}`);
        
        // Only process if state is MATCHING
        if (gameData.state !== 'MATCHING') {
            console.log('Game state is not MATCHING, skipping');
            return null;
        }
        
        try {
            const playerIds = gameData.playerIds;
            if (!playerIds || playerIds.length !== 2) {
                console.error('Invalid playerIds in game document');
                return null;
            }
            
            // 1. Select random word
            const wordData = getRandomWord();
            console.log(`Selected word: ${wordData.word}, category: ${wordData.category}`);
            
            // 2. Fetch player profiles
            const [player1Doc, player2Doc] = await Promise.all([
                db.collection('users').doc(playerIds[0]).get(),
                db.collection('users').doc(playerIds[1]).get(),
            ]);
            
            // Use fallback data if profile doesn't exist
            const player1Data = player1Doc.exists ? player1Doc.data() : {
                username: `Player${playerIds[0].substring(0, 4)}`,
                avatar: `https://i.pravatar.cc/150?u=${playerIds[0]}`,
                activeAvatarFrameId: 'basic',
            };
            
            const player2Data = player2Doc.exists ? player2Doc.data() : {
                username: `Player${playerIds[1].substring(0, 4)}`,
                avatar: `https://i.pravatar.cc/150?u=${playerIds[1]}`,
                activeAvatarFrameId: 'basic',
            };
            
            // 3. Calculate round timer (current time + 10 seconds)
            const roundTimerEndsAt = admin.firestore.Timestamp.fromMillis(
                Date.now() + 10000 // 10 seconds
            );
            
            // 4. Update game document
            await snapshot.ref.update({
                state: 'ROUND_IN_PROGRESS',
                currentRound: 1,
                secretWord: wordData.word,
                category: wordData.category,
                roundTimerEndsAt: roundTimerEndsAt,
                players: {
                    [playerIds[0]]: {
                        username: player1Data.username,
                        avatarUrl: player1Data.avatar,
                        avatarFrameId: player1Data.activeAvatarFrameId || 'basic',
                        remainingGuesses: 3,
                        currentQuestion: null,
                        lastAnswer: null,
                        isReadyForNextRound: false,
                    },
                    [playerIds[1]]: {
                        username: player2Data.username,
                        avatarUrl: player2Data.avatar,
                        avatarFrameId: player2Data.activeAvatarFrameId || 'basic',
                        remainingGuesses: 3,
                        currentQuestion: null,
                        lastAnswer: null,
                        isReadyForNextRound: false,
                    },
                },
            });
            
            console.log(`Game ${gameId} initialized successfully`);
            return null;
            
        } catch (error) {
            console.error('createGame error:', error);
            // Update game state to indicate error
            await snapshot.ref.update({
                state: 'GAME_OVER',
                winnerId: 'error',
            });
            return null;
        }
    });

/**
 * submitQuestion - Callable Function
 * Records player's question submission during active round
 * 
 * Input: { gameId: string, question: string }
 * Output: { success: true, message: string }
 */
exports.submitQuestion = functions
    .region('europe-west1')
    .https.onCall(async (data, context) => {
        // 1. Authentication check
        if (!context.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
        }
        
        const userId = context.auth.uid;
        const { gameId, question } = data;
        
        // 2. Input validation
        if (!gameId || !question) {
            throw new functions.https.HttpsError('invalid-argument', 'gameId and question are required.');
        }
        
        // Sanitize and validate question
        const sanitizedQuestion = question.trim();
        if (sanitizedQuestion.length < 5 || sanitizedQuestion.length > 200) {
            throw new functions.https.HttpsError('invalid-argument', 'Question must be between 5 and 200 characters.');
        }
        
        console.log(`submitQuestion: User ${userId} in game ${gameId}`);
        
        try {
            const gameRef = db.collection('games').doc(gameId);
            const gameDoc = await gameRef.get();
            
            if (!gameDoc.exists) {
                throw new functions.https.HttpsError('not-found', 'Game not found.');
            }
            
            const gameData = gameDoc.data();
            
            // 3. Verify game state
            if (gameData.state !== 'ROUND_IN_PROGRESS') {
                throw new functions.https.HttpsError('failed-precondition', 'Game is not in ROUND_IN_PROGRESS state.');
            }
            
            // 4. Verify user is a player
            if (!gameData.playerIds.includes(userId)) {
                throw new functions.https.HttpsError('permission-denied', 'User is not a player in this game.');
            }
            
            // 5. Check if already submitted
            if (gameData.players[userId].currentQuestion) {
                throw new functions.https.HttpsError('failed-precondition', 'Question already submitted for this round.');
            }
            
            // 6. Update player's current question
            await gameRef.update({
                [`players.${userId}.currentQuestion`]: sanitizedQuestion,
            });
            
            console.log(`Question submitted successfully for user ${userId}`);
            return { success: true, message: 'Question submitted successfully' };
            
        } catch (error) {
            console.error('submitQuestion error:', error);
            if (error instanceof functions.https.HttpsError) {
                throw error;
            }
            throw new functions.https.HttpsError('internal', 'Failed to submit question', error.message);
        }
    });

/**
 * processRound - Firestore Trigger (onUpdate)
 * Core game loop orchestrator: handles fast-track, AI adjudication, and round progression
 * 
 * Trigger: games/{gameId} onUpdate
 */
exports.processRound = functions
    .region('europe-west1')
    .firestore.document('games/{gameId}')
    .onUpdate(async (change, context) => {
        const gameId = context.params.gameId;
        const beforeData = change.before.data();
        const afterData = change.after.data();
        
        console.log(`processRound triggered for game: ${gameId}, state: ${afterData.state}`);
        
        // CONTROL 1: Fast-Track Detection
        if (afterData.state === 'ROUND_IN_PROGRESS') {
            const playerIds = afterData.playerIds;
            const players = afterData.players;
            
            // Check if both players have submitted questions
            const bothSubmitted = playerIds.every(playerId => 
                players[playerId].currentQuestion && 
                players[playerId].currentQuestion.trim().length > 0
            );
            
            if (bothSubmitted) {
                console.log('Both players submitted - triggering AI adjudication');
                await change.after.ref.update({
                    state: 'WAITING_FOR_ANSWERS',
                });
                return null; // Re-trigger will handle AI adjudication
            }
            return null; // Wait for both submissions
        }
        
        // CONTROL 2: AI Adjudication
        if (afterData.state === 'WAITING_FOR_ANSWERS' && beforeData.state !== 'WAITING_FOR_ANSWERS') {
            console.log('Starting AI adjudication');
            
            const playerIds = afterData.playerIds;
            const players = afterData.players;
            const secretWord = afterData.secretWord;
            const category = afterData.category;
            
            try {
                // Call judgeQuestion for both players in parallel
                const [result1, result2] = await Promise.all([
                    callJudgeQuestion(
                        players[playerIds[0]].currentQuestion || 'TIMEOUT_NO_QUESTION',
                        secretWord,
                        category
                    ),
                    callJudgeQuestion(
                        players[playerIds[1]].currentQuestion || 'TIMEOUT_NO_QUESTION',
                        secretWord,
                        category
                    ),
                ]);
                
                const answer1 = result1.success ? result1.answer : 'NEUTRAL';
                const answer2 = result2.success ? result2.answer : 'NEUTRAL';
                
                console.log(`AI answers: P1=${answer1}, P2=${answer2}`);
                
                // CONTROL 3: Round Progression
                const currentRound = afterData.currentRound;
                
                // Create history entry
                const historyEntry = {
                    round: currentRound,
                    [playerIds[0]]: {
                        question: players[playerIds[0]].currentQuestion || 'TIMEOUT',
                        answer: answer1,
                    },
                    [playerIds[1]]: {
                        question: players[playerIds[1]].currentQuestion || 'TIMEOUT',
                        answer: answer2,
                    },
                };
                
                // Prepare update data
                const updateData = {
                    [`players.${playerIds[0]}.lastAnswer`]: answer1,
                    [`players.${playerIds[0]}.currentQuestion`]: null,
                    [`players.${playerIds[1]}.lastAnswer`]: answer2,
                    [`players.${playerIds[1]}.currentQuestion`]: null,
                    history: admin.firestore.FieldValue.arrayUnion(historyEntry),
                };
                
                // Determine next state
                if (currentRound >= 10) {
                    // Move to final guess phase
                    updateData.state = 'FINAL_GUESS_PHASE';
                    updateData.roundTimerEndsAt = admin.firestore.Timestamp.fromMillis(
                        Date.now() + 15000 // 15 seconds
                    );
                    console.log('Round 10 complete - entering FINAL_GUESS_PHASE');
                } else {
                    // Continue to next round
                    updateData.state = 'ROUND_IN_PROGRESS';
                    updateData.currentRound = currentRound + 1;
                    updateData.roundTimerEndsAt = admin.firestore.Timestamp.fromMillis(
                        Date.now() + 10000 // 10 seconds
                    );
                    console.log(`Moving to round ${currentRound + 1}`);
                }
                
                await change.after.ref.update(updateData);
                return null;
                
            } catch (error) {
                console.error('AI adjudication error:', error);
                // Continue game with NEUTRAL answers on error
                const updateData = {
                    [`players.${playerIds[0]}.lastAnswer`]: 'NEUTRAL',
                    [`players.${playerIds[0]}.currentQuestion`]: null,
                    [`players.${playerIds[1]}.lastAnswer`]: 'NEUTRAL',
                    [`players.${playerIds[1]}.currentQuestion`]: null,
                    state: 'ROUND_IN_PROGRESS',
                    currentRound: afterData.currentRound + 1,
                    roundTimerEndsAt: admin.firestore.Timestamp.fromMillis(Date.now() + 10000),
                };
                await change.after.ref.update(updateData);
                return null;
            }
        }
        
        return null;
    });

/**
 * Helper function to call judgeQuestion internally
 */
async function callJudgeQuestion(question, targetWord, category) {
    try {
        const apiKey = functions.config().ai.key;
        if (!apiKey) {
            return { success: false, answer: 'NEUTRAL' };
        }
        
        const genAI = new GoogleGenerativeAI(apiKey);
        const cleanedQuestion = question.replace(/["']/g, '').trim();
        
        const safetySettings = [
            { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_NONE },
            { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_NONE },
            { category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold: HarmBlockThreshold.BLOCK_NONE },
            { category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold: HarmBlockThreshold.BLOCK_NONE },
        ];
        
        const systemInstruction = 
            'You are a strict referee for a "Yes or No" guessing game. Your only task is to determine if the user\'s question is logically true or false for the secret word. Your output MUST strictly be a JSON object containing ONLY the "answer" field with the value "YES" or "NO".';
        
        const model = genAI.getGenerativeModel({ 
            model: 'gemini-2.5-flash', 
            systemInstruction: systemInstruction,
            safetySettings: safetySettings,
            generationConfig: {
                responseMimeType: 'application/json',
                responseSchema: {
                    type: 'object',
                    properties: { answer: { type: 'string', enum: ['YES', 'NO'] } },
                    required: ['answer']
                },
            }
        });
        
        const userPrompt = `Secret Category: ${category}. Secret Word: ${targetWord}. Question: ${cleanedQuestion}`;
        const result = await model.generateContent(userPrompt);
        const responseText = result.response.text();
        
        if (!responseText) {
            return { success: false, answer: 'NEUTRAL' };
        }
        
        const jsonResponse = JSON.parse(responseText.trim());
        return { success: true, answer: jsonResponse.answer.toUpperCase() };
        
    } catch (error) {
        console.error('callJudgeQuestion error:', error);
        return { success: false, answer: 'NEUTRAL' };
    }
}

/**
 * makeFinalGuess - Callable Function
 * Allows player to attempt final word guess
 * 
 * Input: { gameId: string, guess: string }
 * Output: { success: true, correct: boolean, remainingGuesses: number }
 */
exports.makeFinalGuess = functions
    .region('europe-west1')
    .https.onCall(async (data, context) => {
        // 1. Authentication check
        if (!context.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
        }
        
        const userId = context.auth.uid;
        const { gameId, guess } = data;
        
        // 2. Input validation
        if (!gameId || !guess) {
            throw new functions.https.HttpsError('invalid-argument', 'gameId and guess are required.');
        }
        
        const sanitizedGuess = guess.trim().toLowerCase();
        
        console.log(`makeFinalGuess: User ${userId} in game ${gameId}, guess: ${sanitizedGuess}`);
        
        try {
            const gameRef = db.collection('games').doc(gameId);
            const gameDoc = await gameRef.get();
            
            if (!gameDoc.exists) {
                throw new functions.https.HttpsError('not-found', 'Game not found.');
            }
            
            const gameData = gameDoc.data();
            
            // 3. Verify user is a player
            if (!gameData.playerIds.includes(userId)) {
                throw new functions.https.HttpsError('permission-denied', 'User is not a player in this game.');
            }
            
            // 4. Check remaining guesses
            const playerData = gameData.players[userId];
            if (playerData.remainingGuesses <= 0) {
                throw new functions.https.HttpsError('failed-precondition', 'No remaining guesses.');
            }
            
            // 5. Check guess
            const secretWord = gameData.secretWord.toLowerCase();
            const isCorrect = sanitizedGuess === secretWord;
            
            console.log(`Guess correct: ${isCorrect}`);
            
            // 6. Update game
            const newRemainingGuesses = playerData.remainingGuesses - 1;
            
            if (isCorrect) {
                // Winner!
                await gameRef.update({
                    state: 'GAME_OVER',
                    winnerId: userId,
                    [`players.${userId}.remainingGuesses`]: newRemainingGuesses,
                });
                return { success: true, correct: true, remainingGuesses: newRemainingGuesses };
            } else {
                // Incorrect guess
                await gameRef.update({
                    [`players.${userId}.remainingGuesses`]: newRemainingGuesses,
                });
                
                // Check if both players are out of guesses
                const otherPlayerId = gameData.playerIds.find(id => id !== userId);
                const otherPlayerGuesses = gameData.players[otherPlayerId].remainingGuesses;
                
                if (newRemainingGuesses === 0 && otherPlayerGuesses === 0) {
                    // Draw - both out of guesses
                    await gameRef.update({
                        state: 'GAME_OVER',
                        winnerId: 'draw',
                    });
                }
                
                return { success: true, correct: false, remainingGuesses: newRemainingGuesses };
            }
            
        } catch (error) {
            console.error('makeFinalGuess error:', error);
            if (error instanceof functions.https.HttpsError) {
                throw error;
            }
            throw new functions.https.HttpsError('internal', 'Failed to process guess', error.message);
        }
    });

/**
 * handleTimeout - Scheduled Function
 * Processes games with expired timers (runs every 30 seconds)
 * 
 * Trigger: Cloud Scheduler (cron job)
 */
exports.handleTimeout = functions
    .region('europe-west1')
    .pubsub.schedule('every 30 seconds')
    .onRun(async (context) => {
        console.log('handleTimeout cron job started');
        
        const now = admin.firestore.Timestamp.now();
        
        try {
            // Query games with expired timers in ROUND_IN_PROGRESS state
            const expiredRoundsSnapshot = await db.collection('games')
                .where('state', '==', 'ROUND_IN_PROGRESS')
                .where('roundTimerEndsAt', '<=', now)
                .limit(100)
                .get();
            
            console.log(`Found ${expiredRoundsSnapshot.size} expired rounds`);
            
            // Process each expired round
            const roundPromises = expiredRoundsSnapshot.docs.map(async (doc) => {
                const gameData = doc.data();
                const playerIds = gameData.playerIds;
                const players = gameData.players;
                
                // Set null questions to TIMEOUT
                const updates = {};
                playerIds.forEach(playerId => {
                    if (!players[playerId].currentQuestion || players[playerId].currentQuestion.trim() === '') {
                        updates[`players.${playerId}.currentQuestion`] = 'TIMEOUT_NO_QUESTION';
                    }
                });
                
                // Transition to WAITING_FOR_ANSWERS to trigger AI adjudication
                updates.state = 'WAITING_FOR_ANSWERS';
                
                await doc.ref.update(updates);
                console.log(`Game ${doc.id}: Timeout processed, moving to WAITING_FOR_ANSWERS`);
            });
            
            await Promise.all(roundPromises);
            
            // Query games with expired timers in FINAL_GUESS_PHASE state
            const expiredFinalGuessSnapshot = await db.collection('games')
                .where('state', '==', 'FINAL_GUESS_PHASE')
                .where('roundTimerEndsAt', '<=', now)
                .limit(100)
                .get();
            
            console.log(`Found ${expiredFinalGuessSnapshot.size} expired final guess phases`);
            
            // Process each expired final guess phase
            const finalGuessPromises = expiredFinalGuessSnapshot.docs.map(async (doc) => {
                await doc.ref.update({
                    state: 'GAME_OVER',
                    winnerId: 'draw', // No one guessed correctly in time
                });
                console.log(`Game ${doc.id}: Final guess timeout, ending as draw`);
            });
            
            await Promise.all(finalGuessPromises);
            
            console.log('handleTimeout cron job completed successfully');
            return null;
            
        } catch (error) {
            console.error('handleTimeout error:', error);
            return null;
        }
    });

/**
 * finalizeGame - Firestore Trigger (onUpdate)
 * Awards rewards, updates stats, and cleans up when game ends
 * 
 * Trigger: games/{gameId} onUpdate when state changes to GAME_OVER
 */
exports.finalizeGame = functions
    .region('europe-west1')
    .firestore.document('games/{gameId}')
    .onUpdate(async (change, context) => {
        const gameId = context.params.gameId;
        const beforeData = change.before.data();
        const afterData = change.after.data();
        
        // Only process when state changes to GAME_OVER
        if (beforeData.state !== 'GAME_OVER' && afterData.state === 'GAME_OVER') {
            console.log(`finalizeGame triggered for game: ${gameId}`);
            
            const playerIds = afterData.playerIds;
            const winnerId = afterData.winnerId;
            
            try {
                // Calculate rewards based on outcome
                const rewards = {};
                
                if (winnerId === 'draw') {
                    // Draw - both players get participation rewards
                    playerIds.forEach(playerId => {
                        rewards[playerId] = {
                            xp: 20,
                            coins: 20,
                            statsUpdate: {
                                gamesPlayed: 1,
                                gamesWon: 0,
                                currentStreak: 0,
                            },
                        };
                    });
                } else if (winnerId === 'error') {
                    // Error state - no rewards
                    console.log('Game ended in error state, no rewards');
                    return null;
                } else {
                    // Normal win/loss
                    const loserId = playerIds.find(id => id !== winnerId);
                    
                    rewards[winnerId] = {
                        xp: 50,
                        coins: 100,
                        statsUpdate: {
                            gamesPlayed: 1,
                            gamesWon: 1,
                            currentStreak: 1, // Will be added to existing
                        },
                    };
                    
                    rewards[loserId] = {
                        xp: 10,
                        coins: 0,
                        statsUpdate: {
                            gamesPlayed: 1,
                            gamesWon: 0,
                            currentStreak: -999, // Reset to 0
                        },
                    };
                }
                
                // Update user documents in a transaction
                await db.runTransaction(async (transaction) => {
                    // Fetch both user documents
                    const userRefs = playerIds.map(playerId => db.collection('users').doc(playerId));
                    const userDocs = await Promise.all(userRefs.map(ref => transaction.get(ref)));
                    
                    // Update each user
                    userDocs.forEach((userDoc, index) => {
                        const playerId = playerIds[index];
                        const reward = rewards[playerId];
                        
                        if (!reward) return;
                        
                        if (userDoc.exists) {
                            const userData = userDoc.data();
                            const currentStats = userData.stats || { gamesPlayed: 0, gamesWon: 0, currentStreak: 0 };
                            
                            const newStreak = reward.statsUpdate.currentStreak === -999 
                                ? 0 
                                : currentStats.currentStreak + reward.statsUpdate.currentStreak;
                            
                            transaction.update(userDoc.ref, {
                                xp: admin.firestore.FieldValue.increment(reward.xp),
                                coins: admin.firestore.FieldValue.increment(reward.coins),
                                'stats.gamesPlayed': admin.firestore.FieldValue.increment(reward.statsUpdate.gamesPlayed),
                                'stats.gamesWon': admin.firestore.FieldValue.increment(reward.statsUpdate.gamesWon),
                                'stats.currentStreak': newStreak,
                            });
                            
                            console.log(`User ${playerId}: +${reward.xp} XP, +${reward.coins} coins`);
                        } else {
                            console.log(`User ${playerId} document not found, skipping rewards`);
                        }
                    });
                });
                
                console.log(`Game ${gameId} finalized successfully`);
                return null;
                
            } catch (error) {
                console.error('finalizeGame error:', error);
                return null;
            }
        }
        
        return null;
    });
