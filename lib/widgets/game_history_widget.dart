import 'package:flutter/material.dart';
import '../models/game_history_entry.dart';

/// Widget displaying round-by-round game history
class GameHistoryWidget extends StatelessWidget {
  final List<GameHistoryEntry> history;
  final String currentUserId;
  final String opponentId;

  const GameHistoryWidget({
    super.key,
    required this.history,
    required this.currentUserId,
    required this.opponentId,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Text(
          'Henüz oynanmış tur yok',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        return _buildHistoryEntry(context, entry);
      },
    );
  }

  Widget _buildHistoryEntry(BuildContext context, GameHistoryEntry entry) {
    final myData = entry.playerData[currentUserId];
    final opponentData = entry.playerData[opponentId];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: ExpansionTile(
        title: Row(
          children: [
            // Round number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${entry.round}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Summary
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tur ${entry.round}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildAnswerBadge(myData?.answer, isCurrentUser: true),
                      const SizedBox(width: 8),
                      const Text('vs', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      _buildAnswerBadge(opponentData?.answer, isCurrentUser: false),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current user's Q&A
                _buildPlayerQA(
                  context,
                  'Sen',
                  myData,
                  isCurrentUser: true,
                ),
                const Divider(height: 24),
                // Opponent's Q&A
                _buildPlayerQA(
                  context,
                  'Rakip',
                  opponentData,
                  isCurrentUser: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerQA(
    BuildContext context,
    String label,
    RoundPlayerData? data, {
    required bool isCurrentUser,
  }) {
    if (data == null) {
      return Text(
        '$label: Veri yok',
        style: const TextStyle(fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isCurrentUser 
                ? Theme.of(context).primaryColor 
                : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        // Question
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Soru:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.question,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Answer
        Row(
          children: [
            const Text(
              'Cevap:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            _buildAnswerBadge(data.answer, isCurrentUser: isCurrentUser),
          ],
        ),
      ],
    );
  }

  Widget _buildAnswerBadge(String? answer, {required bool isCurrentUser}) {
    final displayText = _getAnswerDisplay(answer);
    final color = _getAnswerColor(answer);
    final icon = _getAnswerIcon(answer);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getAnswerDisplay(String? answer) {
    if (answer == null || answer.isEmpty) return '-';
    
    switch (answer.toUpperCase()) {
      case 'YES':
        return 'EVET';
      case 'NO':
        return 'HAYIR';
      case 'NEUTRAL':
        return 'BİLİNMİYOR';
      default:
        return answer;
    }
  }

  Color _getAnswerColor(String? answer) {
    if (answer == null || answer.isEmpty) return Colors.grey;
    
    switch (answer.toUpperCase()) {
      case 'YES':
        return Colors.green;
      case 'NO':
        return Colors.red;
      case 'NEUTRAL':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getAnswerIcon(String? answer) {
    if (answer == null || answer.isEmpty) return Icons.help_outline;
    
    switch (answer.toUpperCase()) {
      case 'YES':
        return Icons.check_circle;
      case 'NO':
        return Icons.cancel;
      case 'NEUTRAL':
        return Icons.help;
      default:
        return Icons.help_outline;
    }
  }
}

/// Compact history summary widget
class GameHistorySummary extends StatelessWidget {
  final List<GameHistoryEntry> history;
  final String currentUserId;
  final String opponentId;

  const GameHistorySummary({
    super.key,
    required this.history,
    required this.currentUserId,
    required this.opponentId,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: history.map((entry) {
          final myAnswer = entry.playerData[currentUserId]?.answer;
          final color = _getAnswerColor(myAnswer);
          
          return Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                '${entry.round}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getAnswerColor(String? answer) {
    if (answer == null || answer.isEmpty) return Colors.grey;
    
    switch (answer.toUpperCase()) {
      case 'YES':
        return Colors.green;
      case 'NO':
        return Colors.red;
      case 'NEUTRAL':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
