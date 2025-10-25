const test = require('firebase-functions-test')();
const admin = require('firebase-admin');
const { expect } = require('chai');
const sinon = require('sinon');

// Initialize test environment
const myFunctions = require('../index');

describe('Matchmaking Functions', () => {
  let adminStub;

  beforeEach(() => {
    // Stub Firestore
    adminStub = sinon.stub(admin, 'firestore');
  });

  afterEach(() => {
    // Restore stubs
    adminStub.restore();
    test.cleanup();
  });

  describe('joinMatchmaking', () => {
    it('should add user to queue when no opponent available', async () => {
      const userId = 'test_user_123';
      const auth = { uid: userId };
      
      // Mock empty queue
      const queueSnapshot = {
        empty: true,
        docs: []
      };
      
      const queueCollection = {
        orderBy: sinon.stub().returnsThis(),
        limit: sinon.stub().returnsThis(),
        get: sinon.stub().resolves(queueSnapshot),
        add: sinon.stub().resolves({ id: 'queue_entry_123' })
      };
      
      const db = {
        collection: sinon.stub().returns(queueCollection)
      };
      
      adminStub.returns(db);
      
      const wrapped = test.wrap(myFunctions.joinMatchmaking);
      const result = await wrapped({}, { auth });
      
      expect(result.success).to.be.true;
      expect(result.gameId).to.be.null;
      expect(queueCollection.add.calledOnce).to.be.true;
    });

    it('should create game when opponent found in queue', async () => {
      const userId = 'test_user_123';
      const opponentId = 'opponent_456';
      const auth = { uid: userId };
      
      // Mock queue with opponent
      const queueDoc = {
        id: 'queue_entry_789',
        data: () => ({ userId: opponentId, elo: 1200 }),
        ref: { delete: sinon.stub().resolves() }
      };
      
      const queueSnapshot = {
        empty: false,
        docs: [queueDoc]
      };
      
      const gameRef = {
        id: 'game_123',
        set: sinon.stub().resolves()
      };
      
      const db = {
        collection: sinon.stub().callsFake((name) => {
          if (name === 'matchmakingQueue') {
            return {
              orderBy: sinon.stub().returnsThis(),
              limit: sinon.stub().returnsThis(),
              get: sinon.stub().resolves(queueSnapshot)
            };
          } else if (name === 'games') {
            return {
              doc: sinon.stub().returns(gameRef)
            };
          }
        }),
        runTransaction: sinon.stub().callsFake(async (callback) => {
          const transaction = {
            delete: sinon.stub(),
            set: sinon.stub()
          };
          await callback(transaction);
          return gameRef.id;
        })
      };
      
      adminStub.returns(db);
      
      const wrapped = test.wrap(myFunctions.joinMatchmaking);
      const result = await wrapped({}, { auth });
      
      expect(result.success).to.be.true;
      expect(result.gameId).to.equal('game_123');
    });

    it('should throw error when user not authenticated', async () => {
      const wrapped = test.wrap(myFunctions.joinMatchmaking);
      
      try {
        await wrapped({}, {});
        expect.fail('Should have thrown error');
      } catch (error) {
        expect(error.code).to.equal('unauthenticated');
      }
    });
  });

  describe('createGame', () => {
    it('should initialize game with secret word and player data', async () => {
      const gameId = 'game_123';
      const playerIds = ['user1', 'user2'];
      
      const gameData = {
        state: 'MATCHING',
        playerIds: playerIds,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      };
      
      const snapshot = {
        id: gameId,
        data: () => gameData,
        ref: {
          update: sinon.stub().resolves()
        }
      };
      
      const userDoc1 = {
        exists: true,
        data: () => ({
          username: 'Player1',
          avatarUrl: 'https://example.com/avatar1.jpg',
          activeAvatarFrameId: 'frame1'
        })
      };
      
      const userDoc2 = {
        exists: true,
        data: () => ({
          username: 'Player2',
          avatarUrl: 'https://example.com/avatar2.jpg',
          activeAvatarFrameId: 'frame2'
        })
      };
      
      const db = {
        collection: sinon.stub().returns({
          doc: sinon.stub().callsFake((id) => ({
            get: sinon.stub().resolves(id === 'user1' ? userDoc1 : userDoc2)
          }))
        })
      };
      
      adminStub.returns(db);
      
      const wrapped = test.wrap(myFunctions.createGame);
      await wrapped(snapshot);
      
      expect(snapshot.ref.update.calledOnce).to.be.true;
      const updateCall = snapshot.ref.update.firstCall.args[0];
      expect(updateCall.state).to.equal('ROUND_IN_PROGRESS');
      expect(updateCall.currentRound).to.equal(1);
      expect(updateCall.secretWord).to.exist;
      expect(updateCall.category).to.exist;
    });

    it('should not process if state is not MATCHING', async () => {
      const snapshot = {
        data: () => ({ state: 'ROUND_IN_PROGRESS' }),
        ref: { update: sinon.stub() }
      };
      
      const wrapped = test.wrap(myFunctions.createGame);
      const result = await wrapped(snapshot);
      
      expect(result).to.be.null;
      expect(snapshot.ref.update.called).to.be.false;
    });
  });
});
