import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/multiplayer_game_session.dart';
import '../providers/multiplayer_game_provider.dart';
import '../controllers/multiplayer_game_controller.dart';
import '../widgets/multiplayer_game_states/round_in_progress_ui.dart';
import '../widgets/multiplayer_game_states/waiting_for_answers_ui.dart';
import '../widgets/multiplayer_game_states/final_guess_phase_ui.dart';
import '../widgets/multiplayer_game_states/game_over_ui.dart';

/// Main multiplayer game screen with state-based UI rendering
class MultiplayerGameScreen extends StatefulWidget {
  final String gameId;

  const MultiplayerGameScreen({
    super.key,
    required this.gameId,
  });

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  late MultiplayerGameController _controller;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    
    // Get current user ID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı oturumu bulunamadı')),
        );
      });
      return;
    }
    _currentUserId = user.uid;
    
    // Initialize controller
    final gameProvider = Provider.of<MultiplayerGameProvider>(context, listen: false);
    _controller = MultiplayerGameController(
      gameProvider: gameProvider,
      currentUserId: _currentUserId,
    );
    
    // Start watching game
    _controller.watchGame(widget.gameId);
  }

  @override
  void dispose() {
    _controller.stopWatchingGame();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<MultiplayerGameController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: _buildAppBar(context, controller),
            body: _buildBody(context, controller),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, MultiplayerGameController controller) {
    return AppBar(
      title: const Text('Çok Oyunculu Oyun'),
      centerTitle: true,
      leading: controller.isGameOver
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showExitConfirmation(context),
            ),
      actions: [
        // Round indicator
        if (!controller.isGameOver)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Tur ${controller.currentRound}/10',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, MultiplayerGameController controller) {
    // Error state
    if (controller.errorMessage != null) {
      return _buildErrorState(context, controller.errorMessage!);
    }

    // Loading state
    if (controller.game == null) {
      return _buildLoadingState();
    }

    // Render based on game state
    return _buildGameStateUI(context, controller);
  }

  Widget _buildGameStateUI(BuildContext context, MultiplayerGameController controller) {
    final gameState = controller.gameState;

    switch (gameState) {
      case GameState.matching:
      case GameState.initializing:
        return _buildInitializingState(context, controller);
      
      case GameState.roundInProgress:
        return RoundInProgressUI(
          controller: controller,
          currentUserId: _currentUserId,
        );
      
      case GameState.waitingForAnswers:
        return WaitingForAnswersUI(
          controller: controller,
        );
      
      case GameState.finalGuessPhase:
        return FinalGuessPhaseUI(
          controller: controller,
          currentUserId: _currentUserId,
        );
      
      case GameState.gameOver:
        return GameOverUI(
          controller: controller,
          currentUserId: _currentUserId,
          onPlayAgain: () => _handlePlayAgain(context),
          onExit: () => Navigator.of(context).pop(),
        );
      
      default:
        return _buildUnknownState(context);
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Oyun yükleniyor...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInitializingState(BuildContext context, MultiplayerGameController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Title
            const Text(
              'Oyun Hazırlanıyor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              'Gizli kelime seçiliyor ve oyuncular eşleştiriliyor...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Bir Hata Oluştu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home),
              label: const Text('Ana Menüye Dön'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnknownState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Bilinmeyen Durum',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Oyun beklenmedik bir durumda. Lütfen çıkıp tekrar deneyin.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.refresh),
              label: const Text('Yeniden Dene'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oyundan Çık'),
        content: const Text(
          'Oyundan çıkmak istediğinize emin misiniz? Bu oyunu kaybetmenize neden olabilir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit game
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Çık'),
          ),
        ],
      ),
    );
  }

  void _handlePlayAgain(BuildContext context) {
    // Navigate to matchmaking screen
    Navigator.of(context).pushReplacementNamed('/matchmaking');
  }
}
