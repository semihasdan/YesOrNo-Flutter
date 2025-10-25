const test = require('firebase-functions-test')();
const admin = require('firebase-admin');
const { expect } = require('chai');
const sinon = require('sinon');

const myFunctions = require('../index');

describe('Gameplay Functions', () => {
  let adminStub;

  beforeEach(() => {
    adminStub = sinon.stub(admin, 'firestore');
  });

  afterEach(() => {
    adminStub.restore();
    test.cleanup();
  });

  describe('submitQuestion', () => {
    it('should accept valid question and update game state', async () => {
      const userId = 'test_user_123';
      const gameId = 'game_456';
      const question = 'Is it an animal?';
      const auth = { uid: userId };
      const data = { gameId, question };
      
      const gameDoc = {
        exists: true,
        data: () => ({
          state: 'ROUND_IN_PROGRESS',
          playerIds: [userId, 'opponent_789']
        })
      };
      
      const gameRef = {
        get: sinon.stub().resolves(gameDoc),
        update: sinon.stub().resolves()
      };
      
      const db = {
        collection: sinon.stub().returns({
          doc: sinon.stub().returns(gameRef)
        })
      };
      
      adminStub.returns(db);
      
      const wrapped = test.wrap(myFunctions.submitQuestion);
      const result = await wrapped(data, { auth });
      
      expect(result.success).to.be.true;
      expect(gameRef.update.calledOnce).to.be.true;
    });

    it('should reject question that is too short', async () => {
      const userId = 'test_user_123';
      const gameId = 'game_456';
      const question = 'No';
      const auth = { uid: userId };
      const data = { gameId, question };
      
      const wrapped = test.wrap(myFunctions.submitQuestion);
      
      try {
        await wrapped(data, { auth });
        expect.fail('Should have thrown error');
      } catch (error) {
        expect(error.code).to.equal('invalid-argument');
      }
    });

    it('should reject question that is too long', async () => {
      const userId = 'test_user_123';
      const gameId = 'game_456';
      const question = 'a'.repeat(201);
      const auth = { uid: userId };
      const data = { gameId, question };
      
      const wrapped = test.wrap(myFunctions.submitQuestion);
      
      try {
        await wrapped(data, { auth });
        expect.fail('Should have thrown error');
      } catch (error) {
        expect(error.code).to.equal('invalid-argument');
      }
    });

    it('should throw error when user not in game', async () => {
      const userId = 'test_user_123';
      const gameId = 'game_456';
      const question = 'Is it an animal?';
      const auth = { uid: userId };
      const data = { gameId, question };
      
      const gameDoc = {
        exists: true,
        data: () => ({
          state: 'ROUND_IN_PROGRESS',
          playerIds: ['other_user_1', 'other_user_2']
        })
      };
      
      const gameRef = {
        get: sinon.stub().resolves(gameDoc)
      };
      
      const db = {
        collection: sinon.stub().returns({
          doc: sinon.stub().returns(gameRef)
        })
      };
      
      adminStub.returns(db);
      
      const wrapped = test.wrap(myFunctions.submitQuestion);
      
      try {
        await wrapped(data, { auth });
        expect.fail('Should have thrown error');
      } catch (error) {
        expect(error.code).to.equal('permission-denied');
      }
    });
  });

  describe('makeFinalGuess', () => {
    it('should accept correct guess and mark player as winner', async () => {
      const userId = 'test_user_123';
      const gameId = 'game_456';
      const guess = 'Cat';
      const auth = { uid: userId };
      const data = { gameId, guess };
      
      const gameDoc = {
        exists: true,
        data: () => ({
          state: 'FINAL_GUESS_PHASE',
          playerIds: [userId, 'opponent_789'],
          secretWord: 'Cat',
          players: {
            [userId]: { remainingGuesses: 3 }
          }
        })
      };
      
      const gameRef = {
        get: sinon.stub().resolves(gameDoc),
        update: sinon.stub().resolves()
      };
      
      const db = {
        collection: sinon.stub().returns({
          doc: sinon.stub().returns(gameRef)
        })
      };
      
      adminStub.returns(db);
      
      const wrapped = test.wrap(myFunctions.makeFinalGuess);
      const result = await wrapped(data, { auth });
      
      expect(result.success).to.be.true;
      expect(result.correct).to.be.true;
      expect(gameRef.update.calledOnce).to.be.true;
      
      const updateCall = gameRef.update.firstCall.args[0];
      expect(updateCall.state).to.equal('GAME_OVER');
      expect(updateCall.winnerId).to.equal(userId);
    });

    it('should reject incorrect guess and decrement remaining guesses', async () => {
      const userId = 'test_user_123';
      const gameId = 'game_456';
      const guess = 'Dog';
      const auth = { uid: userId };
      const data = { gameId, guess };
      
      const gameDoc = {
        exists: true,
        data: () => ({
          state: 'FINAL_GUESS_PHASE',
          playerIds: [userId, 'opponent_789'],
          secretWord: 'Cat',
          players: {
            [userId]: { remainingGuesses: 3 }
          }
        })
      };
      
      const gameRef = {
        get: sinon.stub().resolves(gameDoc),
        update: sinon.stub().resolves()
      };
      
      const db = {
        collection: sinon.stub().returns({
          doc: sinon.stub().returns(gameRef)
        })
      };
      
      adminStub.returns(db);
      
      const wrapped = test.wrap(myFunctions.makeFinalGuess);
      const result = await wrapped(data, { auth });
      
      expect(result.success).to.be.true;
      expect(result.correct).to.be.false;
      expect(result.remainingGuesses).to.equal(2);
    });

    it('should throw error when no guesses remaining', async () => {
      const userId = 'test_user_123';
      const gameId = 'game_456';
      const guess = 'Cat';
      const auth = { uid: userId };
      const data = { gameId, guess };
      
      const gameDoc = {
        exists: true,
        data: () => ({
          state: 'FINAL_GUESS_PHASE',
          playerIds: [userId, 'opponent_789'],
          secretWord: 'Cat',
          players: {
            [userId]: { remainingGuesses: 0 }
          }
        })
      };
      
      const gameRef = {
        get: sinon.stub().resolves(gameDoc)
      };
      
      const db = {
        collection: sinon.stub().returns({
          doc: sinon.stub().returns(gameRef)
        })
      };
      
      adminStub.returns(db);
      
      const wrapped = test.wrap(myFunctions.makeFinalGuess);
      
      try {
        await wrapped(data, { auth });
        expect.fail('Should have thrown error');
      } catch (error) {
        expect(error.code).to.equal('failed-precondition');
      }
    });
  });

  describe('processRound', () => {
    it('should transition to WAITING_FOR_ANSWERS when both players submit', async () => {
      const gameId = 'game_123';
      
      const beforeData = {
        state: 'ROUND_IN_PROGRESS',
        currentRound: 1,
        playerIds: ['user1', 'user2'],
        players: {
          user1: { currentQuestion: '' },
          user2: { currentQuestion: 'Question 2?' }
        }
      };
      
      const afterData = {
        state: 'ROUND_IN_PROGRESS',
        currentRound: 1,
        playerIds: ['user1', 'user2'],
        players: {
          user1: { currentQuestion: 'Question 1?' },
          user2: { currentQuestion: 'Question 2?' }
        }
      };
      
      const change = {
        before: { data: () => beforeData },
        after: {
          data: () => afterData,
          ref: { update: sinon.stub().resolves() }
        }
      };
      
      const wrapped = test.wrap(myFunctions.processRound);
      await wrapped(change);
      
      expect(change.after.ref.update.calledOnce).to.be.true;
      const updateCall = change.after.ref.update.firstCall.args[0];
      expect(updateCall.state).to.equal('WAITING_FOR_ANSWERS');
    });
  });

  describe('finalizeGame', () => {
    it('should award rewards to winner and loser', async () => {
      const winnerId = 'winner_123';
      const loserId = 'loser_456';
      
      const beforeData = {
        state: 'FINAL_GUESS_PHASE',
        playerIds: [winnerId, loserId]
      };
      
      const afterData = {
        state: 'GAME_OVER',
        playerIds: [winnerId, loserId],
        winnerId: winnerId
      };
      
      const userDocs = {};
      userDocs[winnerId] = {
        data: () => ({ stats: { gamesPlayed: 5, gamesWon: 2, currentStreak: 1 } })
      };
      userDocs[loserId] = {
        data: () => ({ stats: { gamesPlayed: 5, gamesWon: 1, currentStreak: 1 } })
      };
      
      const db = {
        collection: sinon.stub().returns({
          doc: sinon.stub().callsFake((id) => ({
            get: sinon.stub().resolves(userDocs[id])
          }))
        }),
        runTransaction: sinon.stub().callsFake(async (callback) => {
          const transaction = {
            get: sinon.stub().callsFake((ref) => {
              const id = ref._id;
              return Promise.resolve(userDocs[id]);
            }),
            update: sinon.stub()
          };
          await callback(transaction);
        })
      };
      
      adminStub.returns(db);
      
      const change = {
        before: { data: () => beforeData },
        after: { data: () => afterData }
      };
      
      const wrapped = test.wrap(myFunctions.finalizeGame);
      await wrapped(change);
      
      expect(db.runTransaction.calledOnce).to.be.true;
    });
  });
});
