import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/routes/app_routes.dart';
import '../models/user_profile.dart';
import '../models/question_object.dart';
import '../models/match_result.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/question_card_widget.dart';
import '../widgets/circular_timer_widget.dart';
import '../widgets/glass_container.dart';

/// Game room screen for active gameplay
class GameRoomScreen extends StatefulWidget {
  const GameRoomScreen({Key? key}) : super(key: key);

  @override
  State<GameRoomScreen> createState() => _GameRoomScreenState();
}

class _GameRoomScreenState extends State<GameRoomScreen> {
  final TextEditingController _questionController = TextEditingController();
  final UserProfile _player1 = UserProfile.mock(username: 'You');
  final UserProfile _player2 = UserProfile.mock(
    userId: 'user456',
    username: 'Opponent',
    avatar: 'https://i.pravatar.cc/150?img=2',
  );

  int _bounty = 100;
  int _timer = 10;
  final List<QuestionObject> _questions = [];
  int _questionCounter = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_timer > 0) {
          _timer--;
        } else {
          _timer = 10;
          if (_bounty > 5) {
            _bounty -= 5;
          }
        }
      });
    });
  }

  void _submitQuestion() {
    if (_questionController.text.trim().isEmpty) {
      print('[DEBUG] Question is empty');
      return;
    }

    final questionText = _questionController.text.trim();
    print('[DEBUG] Question submitted: $questionText');

    // Add question with pending status
    final question = QuestionObject(
      questionId: 'q${_questionCounter++}',
      playerId: _player1.userId,
      text: questionText,
      answer: QuestionAnswer.pending,
      roundNumber: _questions.length + 1,
    );

    setState(() {
      _questions.insert(0, question);
      _questionController.clear();
    });

    // Simulate answer after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final random = Random();
      final answer =
          random.nextBool() ? QuestionAnswer.yes : QuestionAnswer.no;

      setState(() {
        final index = _questions.indexWhere((q) => q.questionId == question.questionId);
        if (index != -1) {
          _questions[index] = question.copyWith(answer: answer);
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
          winnerId: isWinner ? _player1.userId : _player2.userId,
          loserId: isWinner ? _player2.userId : _player1.userId,
          finalBounty: _bounty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        
        // Show confirmation dialog before leaving
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundDark2,
            title: Text(
              'Leave Game?',
              style: AppTextStyles.heading3,
            ),
            content: Text(
              'Are you sure you want to leave this game? You will lose progress.',
              style: AppTextStyles.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Leave',
                  style: TextStyle(color: AppColors.noRed),
                ),
              ),
            ],
          ),
        );
        
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundDark,
                AppColors.backgroundDark2,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Bounty Display
                _buildBountyBar(),

                // Main gameplay area
                Expanded(
                  child: Stack(
                    children: [
                      // Player zones and questions
                      Column(
                        children: [
                          // Player 2 Zone (Top - Opponent)
                          Expanded(
                            child: _buildPlayerZone(_player2, true),
                          ),

                          // Central Timer
                          _buildCentralTimer(),

                          // Player 1 Zone (Bottom - You)
                          Expanded(
                            child: _buildPlayerZone(_player1, false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Bar
                _buildActionBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBountyBar() {
    return GlassContainer(
      borderRadius: 0,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'BOUNTY: ',
            style: AppTextStyles.timerMedium.copyWith(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '$_bounty PTS',
            style: AppTextStyles.timerMedium.copyWith(
              fontSize: 24,
              color: AppColors.tertiaryGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerZone(UserProfile player, bool isOpponent) {
    final isActivePlayer = !isOpponent;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: isOpponent
              ? BorderSide.none
              : BorderSide(
                  color: isActivePlayer
                      ? AppColors.primaryCyan
                      : AppColors.textSecondary.withOpacity(0.3),
                  width: 2,
                ),
          bottom: isOpponent
              ? BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  width: 2,
                )
              : BorderSide.none,
        ),
      ),
      child: Column(
        children: [
          // Player header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                AvatarWidget(
                  imageUrl: player.avatar,
                  size: AvatarSize.small,
                  borderColor:
                      isActivePlayer ? AppColors.primaryCyan : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  player.username,
                  style: AppTextStyles.heading4.copyWith(
                    color: isActivePlayer
                        ? AppColors.primaryCyan
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Questions list
          Expanded(
            child: _questions.isEmpty
                ? Center(
                    child: Text(
                      'No questions yet',
                      style: AppTextStyles.subtitle,
                    ),
                  )
                : ListView.builder(
                    reverse: isOpponent,
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      return QuestionCardWidget(
                        text: _questions[index].text,
                        status: _questions[index].answer,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentralTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: CircularTimerWidget(
        seconds: _timer,
        maxSeconds: 10,
      ),
    );
  }

  Widget _buildActionBar() {
    return GlassContainer(
      borderRadius: 0,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Question input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    hintText: 'Ask a yes/no question...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _submitQuestion(),
                ),
              ),
              const SizedBox(width: 12),
              CustomButton(
                variant: ButtonVariant.primary,
                onPressed: _submitQuestion,
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Make Guess button
          CustomButton(
            variant: ButtonVariant.tertiary,
            onPressed: _makeFinalGuess,
            width: double.infinity,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  'Make Final Guess',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            CustomButton(
              variant: ButtonVariant.primary,
              onPressed: () {
                print('[DEBUG] Play Again pressed');
                // Close dialog and restart game
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(AppRoutes.game);
              },
              width: double.infinity,
              child: const Text('Play Again'),
            ),

            const SizedBox(height: 12),

            CustomButton(
              variant: ButtonVariant.secondary,
              onPressed: () {
                print('[DEBUG] Back to Menu pressed');
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                );
              },
              width: double.infinity,
              child: const Text('Back to Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
