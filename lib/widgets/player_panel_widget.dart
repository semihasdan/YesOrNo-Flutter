import 'package:flutter/material.dart';
import '../models/player_data.dart';

/// Player panel widget displaying player info, status, and stats
class PlayerPanelWidget extends StatelessWidget {
  final PlayerData playerData;
  final bool isCurrentUser;
  final bool showStatus;
  final bool compact;

  const PlayerPanelWidget({
    super.key,
    required this.playerData,
    this.isCurrentUser = false,
    this.showStatus = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact 
          ? const EdgeInsets.all(8.0) 
          : const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? Colors.blue.shade50 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser 
              ? Colors.blue.shade300 
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          _buildAvatar(),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: _buildInfo(context),
          ),
          // Status indicator
          if (showStatus)
            _buildStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        // Avatar image
        CircleAvatar(
          radius: compact ? 20 : 28,
          backgroundImage: playerData.avatarUrl.isNotEmpty
              ? NetworkImage(playerData.avatarUrl)
              : null,
          backgroundColor: Colors.grey.shade300,
          child: playerData.avatarUrl.isEmpty
              ? Icon(
                  Icons.person,
                  size: compact ? 24 : 32,
                  color: Colors.grey.shade600,
                )
              : null,
        ),
        // Frame overlay (if has frame)
        if (playerData.avatarFrameId.isNotEmpty)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getFrameColor(playerData.avatarFrameId),
                  width: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Username
        Text(
          playerData.username,
          style: TextStyle(
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Stats row
        Row(
          children: [
            // Remaining guesses
            Icon(
              Icons.stars,
              size: compact ? 14 : 16,
              color: Colors.amber,
            ),
            const SizedBox(width: 4),
            Text(
              '${playerData.remainingGuesses}',
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.amber.shade700,
              ),
            ),
            const SizedBox(width: 12),
            // Ready status
            if (playerData.isReadyForNextRound)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Hazır',
                  style: TextStyle(
                    fontSize: compact ? 10 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    final hasSubmitted = playerData.hasSubmittedQuestion;
    final color = hasSubmitted ? Colors.green : Colors.orange;
    final icon = hasSubmitted ? Icons.check_circle : Icons.pending;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: compact ? 16 : 20,
        color: color,
      ),
    );
  }

  Color _getFrameColor(String frameId) {
    // Map frame IDs to colors
    switch (frameId) {
      case 'frame_gold':
        return Colors.amber;
      case 'frame_silver':
        return Colors.grey.shade400;
      case 'frame_bronze':
        return Colors.brown;
      case 'frame_diamond':
        return Colors.cyan;
      default:
        return Colors.blue;
    }
  }
}

/// Compact player info widget for headers
class PlayerInfoHeader extends StatelessWidget {
  final PlayerData playerData;
  final bool isCurrentUser;

  const PlayerInfoHeader({
    super.key,
    required this.playerData,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar
        CircleAvatar(
          radius: 16,
          backgroundImage: playerData.avatarUrl.isNotEmpty
              ? NetworkImage(playerData.avatarUrl)
              : null,
          backgroundColor: Colors.grey.shade300,
          child: playerData.avatarUrl.isEmpty
              ? Icon(
                  Icons.person,
                  size: 20,
                  color: Colors.grey.shade600,
                )
              : null,
        ),
        const SizedBox(width: 8),
        // Username
        Text(
          playerData.username,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// Player answer display widget
class PlayerAnswerWidget extends StatelessWidget {
  final String? answer;
  final bool isRevealed;

  const PlayerAnswerWidget({
    super.key,
    required this.answer,
    this.isRevealed = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isRevealed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '???',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );
    }

    final displayText = _getAnswerDisplay(answer);
    final color = _getAnswerColor(answer);
    final icon = _getAnswerIcon(answer);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 16,
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
