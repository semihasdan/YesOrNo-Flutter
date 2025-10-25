import 'package:flutter/material.dart';
import '../../controllers/multiplayer_game_controller.dart';
import '../../models/player_data.dart';
import '../countdown_timer_widget.dart';
import '../player_panel_widget.dart';

/// UI for ROUND_IN_PROGRESS state
/// Shows question input, timer, and player panels
class RoundInProgressUI extends StatefulWidget {
  final MultiplayerGameController controller;
  final String currentUserId;

  const RoundInProgressUI({
    super.key,
    required this.controller,
    required this.currentUserId,
  });

  @override
  State<RoundInProgressUI> createState() => _RoundInProgressUIState();
}

class _RoundInProgressUIState extends State<RoundInProgressUI> {
  final TextEditingController _questionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize with current question if exists
    if (widget.controller.currentQuestion != null) {
      _questionController.text = widget.controller.currentQuestion!;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myData = widget.controller.myPlayerData;
    final opponentData = widget.controller.opponentData;
    final remainingTime = widget.controller.remainingSeconds;
    final hasSubmitted = widget.controller.hasSubmittedQuestion;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Round info and timer
          _buildHeader(context, remainingTime),
          const SizedBox(height: 24),
          
          // Category hint
          _buildCategoryHint(context),
          const SizedBox(height: 24),
          
          // Player panels
          Row(
            children: [
              Expanded(
                child: _buildPlayerPanel(myData, isCurrentUser: true, hasSubmitted: hasSubmitted),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPlayerPanel(opponentData, isCurrentUser: false, hasSubmitted: widget.controller.opponentHasSubmitted),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Question input or submitted state
          if (!hasSubmitted)
            _buildQuestionInput(context)
          else
            _buildSubmittedState(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int? remainingSeconds) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Round number
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TUR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${widget.controller.currentRound}/10',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Timer
            if (remainingSeconds != null && widget.controller.game?.roundTimerEndsAt != null)
              CountdownTimerWidget(
                endTime: widget.controller.game!.roundTimerEndsAt!,
                size: 60,
                activeColor: Theme.of(context).primaryColor,
                warningColor: Colors.orange,
                dangerColor: Colors.red,
                onTimerEnd: () {
                  debugPrint('Round timer ended');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHint(BuildContext context) {
    final category = widget.controller.secretWordCategory;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kategori İpucu',
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

  Widget _buildPlayerPanel(PlayerData? data, {required bool isCurrentUser, required bool hasSubmitted}) {
    if (data == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PlayerPanelWidget(
      playerData: data,
      isCurrentUser: isCurrentUser,
      showStatus: true,
      compact: false,
    );
  }

  Widget _buildQuestionInput(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input field
          TextFormField(
            controller: _questionController,
            decoration: InputDecoration(
              labelText: 'Sorunuzu yazın',
              hintText: 'Evet/Hayır sorusu sorun...',
              prefixIcon: const Icon(Icons.question_answer),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              counterText: '${_questionController.text.length}/200',
            ),
            maxLength: 200,
            maxLines: 3,
            validator: widget.controller.validateQuestion,
            onChanged: (value) {
              widget.controller.updateQuestion(value);
              setState(() {}); // Update counter
            },
          ),
          const SizedBox(height: 16),
          
          // Submit button
          ElevatedButton.icon(
            onPressed: widget.controller.isSubmittingQuestion
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await widget.controller.submitQuestion();
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Soru gönderildi!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
            icon: widget.controller.isSubmittingQuestion
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
              widget.controller.isSubmittingQuestion ? 'Gönderiliyor...' : 'Soruyu Gönder',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          // Help text
          const SizedBox(height: 12),
          Text(
            '💡 Gizli kelimeyi bulmak için Evet/Hayır soruları sorun!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittedState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300, width: 2),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Sorunuz Gönderildi!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.controller.opponentHasSubmitted
                ? 'AI soruları değerlendiriyor...'
                : 'Rakibinizin sorusunu bekliyorsunuz...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          if (!widget.controller.opponentHasSubmitted) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
            ),
          ],
        ],
      ),
    );
  }
}
