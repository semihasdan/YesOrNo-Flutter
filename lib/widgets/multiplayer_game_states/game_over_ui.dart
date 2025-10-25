import 'package:flutter/material.dart';
import '../../controllers/multiplayer_game_controller.dart';
import '../game_history_widget.dart';

/// UI for GAME_OVER state
/// Shows victory/defeat screen with rewards
class GameOverUI extends StatefulWidget {
  final MultiplayerGameController controller;
  final String currentUserId;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const GameOverUI({
    super.key,
    required this.controller,
    required this.currentUserId,
    required this.onPlayAgain,
    required this.onExit,
  });

  @override
  State<GameOverUI> createState() => _GameOverUIState();
}

class _GameOverUIState extends State<GameOverUI> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final isWinner = widget.controller.isWinner;
    final isDraw = widget.controller.isDraw;
    final secretWord = widget.controller.game?.secretWord;
    final opponentId = widget.controller.opponentId;

    return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Result banner
              _buildResultBanner(context, isWinner, isDraw),
              const SizedBox(height: 24),
              
              // Secret word reveal
              _buildSecretWordReveal(context, secretWord),
              const SizedBox(height: 24),
              
              // Rewards display
              if (isWinner)
                _buildRewardsDisplay(context),
              
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
              
              const SizedBox(height: 24),
              
              // Action buttons
              _buildActionButtons(context),
            ],
          ),
        );
  }

  Widget _buildResultBanner(BuildContext context, bool isWinner, bool isDraw) {
    Color backgroundColor;
    Color textColor;
    String title;
    IconData icon;

    if (isDraw) {
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade900;
      title = 'BERABERE!';
      icon = Icons.handshake;
    } else if (isWinner) {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade900;
      title = 'KAZANDIN!';
      icon = Icons.emoji_events;
    } else {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade900;
      title = 'KAYBETTİN!';
      icon = Icons.sentiment_dissatisfied;
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 80,
            color: textColor,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecretWordReveal(BuildContext context, String? secretWord) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'GİZLİ KELİME',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            secretWord ?? '???',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsDisplay(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              '🎁 ÖDÜLLER',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRewardItem(
                  icon: Icons.stars,
                  label: 'XP',
                  value: '+50',
                  color: Colors.purple,
                ),
                _buildRewardItem(
                  icon: Icons.monetization_on,
                  label: 'Coin',
                  value: '+100',
                  color: Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 40,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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
      label: Text(_showHistory ? 'Geçmişi Gizle' : 'Oyun Geçmişini Göster'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: widget.onPlayAgain,
          icon: const Icon(Icons.refresh),
          label: const Text(
            'Tekrar Oyna',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: widget.onExit,
          icon: const Icon(Icons.home),
          label: const Text(
            'Ana Menüye Dön',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
