import 'package:flutter/material.dart';
import '../../controllers/multiplayer_game_controller.dart';
import '../countdown_timer_widget.dart';
import '../game_history_widget.dart';

/// UI for FINAL_GUESS_PHASE state
/// Shows final guess input with 15s timer
class FinalGuessPhaseUI extends StatefulWidget {
  final MultiplayerGameController controller;
  final String currentUserId;

  const FinalGuessPhaseUI({
    super.key,
    required this.controller,
    required this.currentUserId,
  });

  @override
  State<FinalGuessPhaseUI> createState() => _FinalGuessPhaseUIState();
}

class _FinalGuessPhaseUIState extends State<FinalGuessPhaseUI> {
  final TextEditingController _guessController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller.currentGuess != null) {
      _guessController.text = widget.controller.currentGuess!;
    }
  }

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingGuesses = widget.controller.remainingGuesses;
    final opponentId = widget.controller.opponentId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with timer
          _buildHeader(context),
          const SizedBox(height: 24),
          
          // Remaining guesses indicator
          _buildGuessesIndicator(remainingGuesses),
          const SizedBox(height: 24),
          
          // Category reminder
          _buildCategoryReminder(context),
          const SizedBox(height: 24),
          
          // Guess input
          if (remainingGuesses > 0)
            _buildGuessInput(context)
          else
            _buildNoGuessesRemaining(context),
          
          const SizedBox(height: 24),
          
          // History toggle
          _buildHistoryToggle(context),
          
          // History view
          if (_showHistory && opponentId != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: GameHistoryWidget(
                history: widget.controller.game?.history ?? [],
                currentUserId: widget.currentUserId,
                opponentId: opponentId,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SON TAHMİN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gizli Kelimeyi Tahmin Et!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Timer
            if (widget.controller.game?.roundTimerEndsAt != null)
              CountdownTimerWidget(
                endTime: widget.controller.game!.roundTimerEndsAt!,
                size: 60,
                activeColor: Colors.purple,
                warningColor: Colors.orange,
                dangerColor: Colors.red,
                onTimerEnd: () {
                  debugPrint('Final guess timer ended');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuessesIndicator(int remaining) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isUsed = index >= remaining;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUsed ? Colors.grey.shade300 : Colors.amber,
              shape: BoxShape.circle,
              boxShadow: isUsed
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: Icon(
              Icons.stars,
              color: isUsed ? Colors.grey.shade600 : Colors.white,
              size: 28,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCategoryReminder(BuildContext context) {
    final category = widget.controller.secretWordCategory;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.category, color: Colors.blue.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category ?? 'Yükleniyor...',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuessInput(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _guessController,
            decoration: InputDecoration(
              labelText: 'Gizli kelimeyi tahmin edin',
              hintText: 'Tahmininizi yazın...',
              prefixIcon: const Icon(Icons.lightbulb),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            textCapitalization: TextCapitalization.words,
            validator: widget.controller.validateGuess,
            onChanged: (value) {
              widget.controller.updateGuess(value);
            },
          ),
          const SizedBox(height: 16),
          
          ElevatedButton.icon(
            onPressed: widget.controller.isMakingGuess
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      final result = await widget.controller.submitFinalGuess();
                      
                      if (result != null && mounted) {
                        final isCorrect = result['correct'] as bool;
                        final remaining = result['remainingGuesses'] as int;
                        
                        if (isCorrect) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 Doğru tahmin! Kazandınız!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                remaining > 0
                                    ? 'Yanlış tahmin! $remaining hak kaldı.'
                                    : 'Tahmin hakkınız bitti!',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          _guessController.clear();
                        }
                      }
                    }
                  },
            icon: widget.controller.isMakingGuess
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(
              widget.controller.isMakingGuess ? 'Gönderiliyor...' : 'Tahmini Gönder',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoGuessesRemaining(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.block, color: Colors.red.shade600, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Tahmin Hakkınız Kalmadı',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Süre dolmasını bekleyin...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryToggle(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _showHistory = !_showHistory;
        });
      },
      icon: Icon(_showHistory ? Icons.expand_less : Icons.expand_more),
      label: Text(_showHistory ? 'Geçmişi Gizle' : 'Soru Geçmişini Göster'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
