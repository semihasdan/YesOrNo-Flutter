import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/routes/app_routes.dart';
import '../models/user_profile.dart';
import '../models/question_object.dart';
import '../widgets/glass_container.dart';
import '../widgets/animated_background.dart';
import '../widgets/spinning_logo_loader.dart';
import '../widgets/yes_no_logo.dart';

import '../controllers/user_controller.dart';

/// Single Player Game Screen - Practice mode with word guessing
class SinglePlayerGameScreen extends StatefulWidget {
  const SinglePlayerGameScreen({Key? key}) : super(key: key);

  @override
  State<SinglePlayerGameScreen> createState() => _SinglePlayerGameScreenState();
}

class _SinglePlayerGameScreenState extends State<SinglePlayerGameScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _guessController = TextEditingController();

  int _currentRound = 1;
  int _totalRounds = 10;
  int _timer = 10;
  int _maxTimer = 10;
  Timer? _countdownTimer;
  
  // Power-ups
  int _hintCount = 1;
  String? _currentHint;
  
  // Send button cooldown
  bool _canSendQuestion = true;
  
  // Questions for player
  final List<QuestionObject> _playerQuestions = [];
  int _questionCounter = 0;
  
  // Word selection
  String? _selectedWord;
  String? _categoryName;
  String? _wordHint;
  bool _isLoading = true;
  
  // Firebase Functions
  late FirebaseFunctions _functions;

  @override
  void initState() {
    super.initState();
    _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
    _loadRandomWord();
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _questionController.dispose();
    _guessController.dispose();
    super.dispose();
  }
  
  /// Load a random word from CategoriesTr collection
  Future<void> _loadRandomWord() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Get all documents from CategoriesTr collection
      final categoriesSnapshot = await FirebaseFirestore.instance
          .collection('CategoriesTr')
          .get();
      
      if (categoriesSnapshot.docs.isEmpty) {
        print('[ERROR] No categories found in CategoriesTr collection');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Select a random category document
      final random = Random();
      final randomCategoryDoc = categoriesSnapshot.docs[
        random.nextInt(categoriesSnapshot.docs.length)
      ];
      
      // Get the document data
      final data = randomCategoryDoc.data();
      final String categoryName = data['categoryName'] ?? 'Unknown';
      final Map<String, dynamic>? levels = data['levels'] as Map<String, dynamic>?;
      
      if (levels == null || levels.isEmpty) {
        print('[ERROR] No levels found in category: $categoryName');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Collect all words from all difficulty levels
      final List<Map<String, dynamic>> allWords = [];
      
      // Check each difficulty level: easy, medium, difficult
      for (final levelKey in ['easy', 'medium', 'difficult']) {
        if (levels.containsKey(levelKey)) {
          final levelData = levels[levelKey];
          if (levelData is List) {
            for (final item in levelData) {
              if (item is Map<String, dynamic> && item.containsKey('word')) {
                allWords.add(item);
              }
            }
          }
        }
      }
      
      if (allWords.isEmpty) {
        print('[ERROR] No words found in category: $categoryName');
        print('[DEBUG] Levels structure: $levels');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Select a random word object
      final randomWordObj = allWords[random.nextInt(allWords.length)];
      final String randomWord = randomWordObj['word'] ?? '';
      final String hint = randomWordObj['hint'] ?? 'No hint available';
      
      setState(() {
        _selectedWord = randomWord;
        _categoryName = categoryName;
        _wordHint = hint;
        _isLoading = false;
      });
      
      // Log the selected word for development
      print('[DEV] Selected Word: $_selectedWord');
      print('[DEV] Category: $_categoryName');
      print('[DEV] Hint: $hint');
      
    } catch (e) {
      print('[ERROR] Failed to load random word: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
          // Timer expired, reset for next round
          _timer = _maxTimer;
          _currentRound++;
          _canSendQuestion = true; // Reset send button for new round
          
          if (_currentRound > _totalRounds) {
            timer.cancel();
            _showTimeUpDialog();
          }
        }
      });
    });
  }

  void _submitQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      print('[DEBUG] Question is empty');
      return;
    }

    if (!_canSendQuestion) {
      print('[DEBUG] Cannot send question yet - cooldown active');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only send one question per round!'),
          backgroundColor: AppColors.noRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final questionText = _questionController.text.trim();
    print('[DEBUG] Question submitted: $questionText');

    // Disable send button until next round
    setState(() {
      _canSendQuestion = false;
    });

    // Add question to player's list with pending status
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

    // Call Firebase Function to get AI response
    try {
      print('[DEBUG] Calling Firebase Function judgeQuestion...');
      print('[DEBUG] Sending - Question: "$questionText", Word: "$_selectedWord", Category: "$_categoryName"');
      
      final callable = _functions.httpsCallable('judgeQuestion');
      final result = await callable.call({
        'question': questionText,
        'targetWord': _selectedWord,
        'category': _categoryName,
      });
      
      print('[DEBUG] Firebase Function returned successfully');

      if (!mounted) return;

      // Parse response
      final data = result.data;
      print('[DEBUG] Response data: $data');
      
      if (data['success'] == true) {
        final aiResponse = data['answer'] as String;
        print('[DEBUG] AI Response from Firebase: $aiResponse');

        // Convert AI response to QuestionAnswer
        QuestionAnswer answer;
        if (aiResponse.toUpperCase() == 'YES') {
          answer = QuestionAnswer.yes;
          print('[DEBUG] Converted to: Yes');
        } else if (aiResponse.toUpperCase() == 'NO') {
          answer = QuestionAnswer.no;
          print('[DEBUG] Converted to: No');
        } else {
          // Fallback in case of unexpected response
          answer = QuestionAnswer.no;
          print('[WARNING] Unexpected AI response: $aiResponse, defaulting to No');
        }

        // Update question with answer
        setState(() {
          final index = _playerQuestions.indexWhere((q) => q.questionId == question.questionId);
          if (index != -1) {
            _playerQuestions[index] = question.copyWith(answer: answer);
          }
        });

        print('[DEBUG] ✅ Final Answer displayed to user: ${answer == QuestionAnswer.yes ? "Yes" : "No"}');
      } else {
        print('[ERROR] Firebase Function returned success=false');
      }
    } catch (e) {
      print('[ERROR] Firebase Function call failed: $e');
      
      if (!mounted) return;
      
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get answer. Please try again.'),
          backgroundColor: AppColors.noRed,
        ),
      );
      
      // Remove the pending question
      setState(() {
        _playerQuestions.removeWhere((q) => q.questionId == question.questionId);
        _canSendQuestion = true; // Allow retry
      });
    }
  }

  void _showHint() {
    if (_hintCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hints remaining!'),
          backgroundColor: AppColors.noRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _hintCount--;
      _currentHint = _wordHint ?? 'No hint available';
    });

    print('[DEBUG] Hint activated: $_currentHint');
    
    // Show hint dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: const Color(0xFFFFD700),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hint',
                      style: AppTextStyles.heading2.copyWith(
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _currentHint ?? 'No hint available',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(
                    'Got it!',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A0814),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _makeFinalGuess() {
    print('[DEBUG] Make Final Guess button pressed');
    _showGuessDialog();
  }
  
  void _showGuessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Make Your Guess!',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.tertiaryGold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What is the word?',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _guessController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your guess...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFF1A152E).withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primaryCyan.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primaryCyan,
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: (_) => _checkGuess(context),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _guessController.clear();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.noRed),
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _checkGuess(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCyan,
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _checkGuess(BuildContext dialogContext) {
    final guess = _guessController.text.trim().toLowerCase();
    final correctWord = _selectedWord?.toLowerCase() ?? '';
    
    print('[DEBUG] Player guessed: $guess');
    print('[DEBUG] Correct word: $correctWord');
    
    // Close guess dialog
    Navigator.of(dialogContext).pop();
    _guessController.clear();
    
    // Check if guess is correct
    final isCorrect = guess == correctWord;
    
    // Show result dialog
    _showGameOverDialog(isCorrect);
  }
  
  void _showTimeUpDialog() {
    _showGameOverDialog(false, timeUp: true);
  }
  
  void _showGameOverDialog(bool isWinner, {bool timeUp = false}) {
    _countdownTimer?.cancel();
    
    String title;
    String message;
    int points;
    
    if (timeUp) {
      title = 'TIME UP!';
      message = 'You ran out of time!';
      points = 10;
    } else if (isWinner) {
      title = 'CORRECT!';
      message = 'You guessed the word!';
      points = 100;
    } else {
      title = 'WRONG!';
      message = 'Better luck next time!';
      points = 10;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                title,
                style: AppTextStyles.heading1.copyWith(
                  color: isWinner ? const Color(0xFF00FF7F) : AppColors.noRed,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 16),
              
              // Message
              Text(
                message,
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Word reveal
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A152E).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.tertiaryGold.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'The word was:',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedWord?.toUpperCase() ?? 'UNKNOWN',
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tertiaryGold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: $_categoryName',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Points
              Text(
                '+$points Points',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryCyan,
                ),
              ),
              const SizedBox(height: 32),
              
              // Play Again Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed(AppRoutes.singlePlayer);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCyan,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Play Again',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A0814),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Back to Menu Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.textSecondary),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back to Menu',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AnimatedBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const YesNoLogo(
                  size: 120.0,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top Timer Section
                _buildTimerSection(),
                
                const SizedBox(height: 12),
                
                // Main Gameplay Area - Single Player Panel
                Expanded(
                  child: Consumer<UserController>(
                    builder: (context, userController, _) {
                      final player = userController.currentUser ?? UserProfile.mock(username: 'YOU');
                      return _buildPlayerPanel(
                        player: player,
                        questions: _playerQuestions,
                        isPlayer: true,
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 12),
                
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: 12,
      backgroundColor: const Color(0xFF0D0B1A).withOpacity(0.6),
      borderColor: AppColors.primaryCyan.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular Timer
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: _timer / _maxTimer,
                    strokeWidth: 4,
                    backgroundColor: const Color(0xFF1A152E),
                    valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                  ),
                ),
                Text(
                  '$_timer',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
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
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _categoryName?.toUpperCase() ?? 'LOADING...',
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: AppColors.tertiaryGold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ROUND $_currentRound OF $_totalRounds',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
      padding: const EdgeInsets.all(10),
      borderRadius: 12,
      backgroundColor: const Color(0xFF0D0B1A).withOpacity(0.6),
      borderColor: AppColors.primaryCyan.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player Header
          Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPlayer ? AppColors.primaryCyan : AppColors.tertiaryGold,
                    width: 2,
                  ),
                  boxShadow: isPlayer ? [
                    BoxShadow(
                      color: AppColors.primaryCyan.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ] : [
                    BoxShadow(
                      color: AppColors.tertiaryGold.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(player.avatar),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  player.username,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryCyan,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
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
          Text(
            question.text,
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: isPlayer ? Colors.white : Colors.grey.shade300,
            ),
          ),
          if (!isPending) ...[
            const SizedBox(height: 4),
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
      padding: const EdgeInsets.all(10),
      borderRadius: 12,
      backgroundColor: const Color(0xFF0D0B1A).withOpacity(0.6),
      borderColor: AppColors.primaryCyan.withOpacity(0.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
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
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Ask a yes/no question...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _submitQuestion(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: _canSendQuestion 
                      ? AppColors.primaryCyan.withOpacity(0.9)
                      : Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _canSendQuestion ? [
                    BoxShadow(
                      color: AppColors.primaryCyan.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _canSendQuestion ? _submitQuestion : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Text(
                        'SEND',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _canSendQuestion 
                              ? const Color(0xFF0A0814)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _makeFinalGuess,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'MAKE FINAL GUESS',
                          textAlign: TextAlign.center,
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
              ),
              const SizedBox(width: 8),
              
              _buildPowerUpButton(
                icon: Icons.lightbulb,
                count: _hintCount,
                color: const Color(0xFFFFD700),
                onTap: _showHint,
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
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF0A0814),
                width: 1.5,
              ),
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Center(
              child: Text(
                '$count',
                style: GoogleFonts.roboto(
                  fontSize: 9,
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
