import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/routes/app_routes.dart';
import '../models/user_profile.dart';
import '../models/question_object.dart';
import '../models/match_result.dart';
import '../widgets/glass_container.dart';
import '../widgets/animated_background.dart';
import '../controllers/user_controller.dart';

/// Game room screen for active gameplay - Cyber Deduction Intelligence Duel
class GameRoomScreen extends StatefulWidget {
  const GameRoomScreen({Key? key}) : super(key: key);

  @override
  State<GameRoomScreen> createState() => _GameRoomScreenState();
}

class _GameRoomScreenState extends State<GameRoomScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  final UserProfile _player2 = UserProfile.mock(
    userId: 'user456',
    username: "OPPONENT'S SIDE PANEL",
    avatar: 'https://i.pravatar.cc/150?img=2',
  );

  int _currentRound = 5;
  int _totalRounds = 10;
  int _timer = 10;
  int _maxTimer = 10;
  Timer? _countdownTimer;
  
  // Power-ups
  int _shieldCount = 2;
  int _hintCount = 1;
  
  // Questions for each player
  final List<QuestionObject> _playerQuestions = [];
  final List<QuestionObject> _opponentQuestions = [];
  int _questionCounter = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _addMockQuestions();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _questionController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_timer > 0) {
          _timer--;
        } else {
          // Timer expired, reset
          _timer = _maxTimer;
          _currentRound++;
          if (_currentRound > _totalRounds) {
            timer.cancel();
            _showGameOverDialog();
          }
        }
      });
    });
  }
  
  void _addMockQuestions() {
    // Add mock questions for demonstration
    setState(() {
      _playerQuestions.addAll([
        QuestionObject(
          questionId: 'p1',
          playerId: 'player',
          text: 'Is the main character an AI?',
          answer: QuestionAnswer.no,
          roundNumber: 1,
        ),
        QuestionObject(
          questionId: 'p2',
          playerId: 'player',
          text: 'Does the story take place in the future?',
          answer: QuestionAnswer.yes,
          roundNumber: 2,
        ),
      ]);
      
      _opponentQuestions.addAll([
        QuestionObject(
          questionId: 'o1',
          playerId: _player2.userId,
          text: 'Is the setting a cyberpunk city?',
          answer: QuestionAnswer.no,
          roundNumber: 1,
        ),
        QuestionObject(
          questionId: 'o2',
          playerId: _player2.userId,
          text: 'Is the protagonist a detective?',
          answer: QuestionAnswer.yes,
          roundNumber: 2,
        ),
      ]);
    });
  }

  void _submitQuestion() {
    if (_questionController.text.trim().isEmpty) {
      print('[DEBUG] Question is empty');
      return;
    }

    final questionText = _questionController.text.trim();
    print('[DEBUG] Question submitted: $questionText');

    // Add question to player's list
    final question = QuestionObject(
      questionId: 'q${_questionCounter++}',
      playerId: 'player',
      text: questionText,
      answer: QuestionAnswer.pending,
      roundNumber: _currentRound,
    );

    setState(() {
      _playerQuestions.add(question);
      _questionController.clear();
    });

    // Simulate answer after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final random = Random();
      final answer = random.nextBool() ? QuestionAnswer.yes : QuestionAnswer.no;

      setState(() {
        final index = _playerQuestions.indexWhere((q) => q.questionId == question.questionId);
        if (index != -1) {
          _playerQuestions[index] = question.copyWith(answer: answer);
        }
      });

      print('[DEBUG] Question answered: ${answer.name.toUpperCase()}');
    });
  }

  void _makeFinalGuess() {
    print('[DEBUG] Make Final Guess button pressed');
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    // Simulate random win/loss
    final random = Random();
    final isWinner = random.nextBool();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        isWinner: isWinner,
        result: MatchResult.mock(
          winnerId: isWinner ? 'player' : _player2.userId,
          loserId: isWinner ? _player2.userId : 'player',
          finalBounty: 100,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 12,
              children: [
                // Top Timer Section
                _buildTimerSection(),
                
                // Main Gameplay Area - Two Side Panels
                Expanded(
                  child: Row(
                    spacing: 12,
                    children: [
                      // Player Panel (Left)
                      Expanded(
                        child: Consumer<UserController>(
                          builder: (context, userController, _) {
                            final player = userController.currentUser ?? UserProfile.mock(username: 'YOUR SIDE PANEL');
                            return _buildPlayerPanel(
                              player: player,
                              questions: _playerQuestions,
                              isPlayer: true,
                            );
                          },
                        ),
                      ),
                      
                      // Opponent Panel (Right)
                      Expanded(
                        child: _buildPlayerPanel(
                          player: _player2,
                          questions: _opponentQuestions,
                          isPlayer: false,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bottom Action Bar
                _buildActionBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    final bool isCritical = _timer <= 3 && _timer > 0;
    final Color timerColor = isCritical ? const Color(0xFFFF4136) : AppColors.primaryCyan;
    
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      backgroundColor: const Color(0xFF0D0B1A).withOpacity(0.6),
      borderColor: AppColors.primaryCyan.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular Timer
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Circle
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: _timer / _maxTimer,
                    strokeWidth: 4,
                    backgroundColor: const Color(0xFF1A152E),
                    valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                  ),
                ),
                // Timer Text
                Text(
                  '$_timer',
                  style: GoogleFonts.orbitron(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: timerColor,
                    shadows: isCritical ? [
                      Shadow(
                        color: timerColor.withOpacity(0.8),
                        blurRadius: 15,
                      ),
                    ] : [
                      Shadow(
                        color: timerColor.withOpacity(0.7),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Round Counter
          Text(
            'ROUND $_currentRound OF $_totalRounds',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlayerPanel({
    required UserProfile player,
    required List<QuestionObject> questions,
    required bool isPlayer,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      backgroundColor: const Color(0xFF0D0B1A).withOpacity(0.6),
      borderColor: AppColors.primaryCyan.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Header
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPlayer ? AppColors.primaryCyan : Colors.grey,
                    width: 2,
                  ),
                  boxShadow: isPlayer ? [
                    BoxShadow(
                      color: AppColors.primaryCyan.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ] : null,
                  image: DecorationImage(
                    image: NetworkImage(player.avatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Username
              Expanded(
                child: Text(
                  player.username,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPlayer ? AppColors.primaryCyan : Colors.grey.shade400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Questions List
          Expanded(
            child: questions.isEmpty
                ? Center(
                    child: Text(
                      'No questions yet',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return _buildQuestionCard(
                        question: question,
                        isPlayer: isPlayer,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionCard({
    required QuestionObject question,
    required bool isPlayer,
  }) {
    final bool isYes = question.answer == QuestionAnswer.yes;
    final bool isPending = question.answer == QuestionAnswer.pending;
    
    Color borderColor = isPending 
        ? Colors.grey.withOpacity(0.3)
        : isYes 
            ? const Color(0xFF00FF7F) 
            : const Color(0xFFFF4136);
    
    Color answerBg = isYes 
        ? const Color(0xFF00FF7F) 
        : const Color(0xFFFF4136);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A152E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Text
          Text(
            question.text,
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: isPlayer ? Colors.white : Colors.grey.shade300,
            ),
          ),
          if (!isPending) ...[
            const SizedBox(height: 4),
            // Answer Badge
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: answerBg,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: answerBg.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  isYes ? 'YES' : 'NO',
                  style: GoogleFonts.roboto(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0A0814),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 12,
      backgroundColor: const Color(0xFF0D0B1A).withOpacity(0.6),
      borderColor: AppColors.primaryCyan.withOpacity(0.1),
      child: Column(
        children: [
          // Question Input Row
          Row(
            children: [
              // Input Field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A152E).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryCyan.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _questionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ask a yes/no question...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _submitQuestion(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Send Button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryCyan.withOpacity(0.6),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _submitQuestion,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        'SEND',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0A0814),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Bottom Action Buttons Row
          Row(
            children: [
              // Make Final Guess Button
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _makeFinalGuess,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'MAKE FINAL GUESS',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A0814),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Shield Power-Up
              _buildPowerUpButton(
                icon: Icons.shield,
                count: _shieldCount,
                color: AppColors.primaryCyan,
                onTap: () {
                  print('[DEBUG] Shield activated');
                },
              ),
              const SizedBox(width: 12),
              
              // Hint Power-Up
              _buildPowerUpButton(
                icon: Icons.lightbulb,
                count: _hintCount,
                color: const Color(0xFFFFD700),
                onTap: () {
                  print('[DEBUG] Hint activated');
                },
              ),
              const SizedBox(width: 12),
              
              // Emote Button
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      print('[DEBUG] Emote button pressed');
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.mood,
                        size: 30,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPowerUpButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
            ),
          ),
        ),
        // Count Badge
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF0A0814),
                width: 2,
              ),
            ),
            constraints: const BoxConstraints(
              minWidth: 20,
              minHeight: 20,
            ),
            child: Center(
              child: Text(
                '$count',
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0A0814),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Game Over Dialog
class GameOverDialog extends StatelessWidget {
  final bool isWinner;
  final MatchResult result;

  const GameOverDialog({
    Key? key,
    required this.isWinner,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Result text
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: isWinner
                    ? [AppColors.tertiaryGold, AppColors.primaryCyan]
                    : [AppColors.noRed, AppColors.secondaryMagenta],
              ).createShader(bounds),
              child: Text(
                isWinner ? 'YOU WIN!' : 'YOU LOSE!',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 48,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Secret word
            Text(
              'The secret word was:',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 8),
            Text(
              result.secretWord,
              style: AppTextStyles.heading2.copyWith(
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 24),

            // Points display
            Text(
              isWinner ? '+${result.finalBounty} Points' : '-10 Points',
              style: AppTextStyles.heading3.copyWith(
                color: isWinner ? AppColors.yesGreen : AppColors.noRed,
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            ElevatedButton(
              onPressed: () {
                print('[DEBUG] Play Again pressed');
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(AppRoutes.game);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCyan,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Play Again'),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () {
                print('[DEBUG] Back to Menu pressed');
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primaryCyan),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Back to Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
