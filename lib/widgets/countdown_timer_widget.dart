import 'dart:async';
import 'package:flutter/material.dart';

/// Server-authoritative countdown timer widget
/// Displays remaining time with visual feedback
class CountdownTimerWidget extends StatefulWidget {
  final DateTime endTime;
  final VoidCallback? onTimerEnd;
  final double size;
  final Color? activeColor;
  final Color? warningColor;
  final Color? dangerColor;
  final int warningThreshold; // seconds
  final int dangerThreshold; // seconds
  final bool showText;

  const CountdownTimerWidget({
    super.key,
    required this.endTime,
    this.onTimerEnd,
    this.size = 60.0,
    this.activeColor,
    this.warningColor,
    this.dangerColor,
    this.warningThreshold = 5,
    this.dangerThreshold = 3,
    this.showText = true,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _timerEnded = false;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime) {
      _calculateRemainingTime();
      _resetTimer();
    }
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    final difference = widget.endTime.difference(now);
    _remainingSeconds = difference.inSeconds > 0 ? difference.inSeconds : 0;
    _timerEnded = _remainingSeconds == 0;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        final now = DateTime.now();
        final difference = widget.endTime.difference(now);
        _remainingSeconds = difference.inSeconds > 0 ? difference.inSeconds : 0;

        if (_remainingSeconds == 0 && !_timerEnded) {
          _timerEnded = true;
          widget.onTimerEnd?.call();
          timer.cancel();
        }
      });
    });
  }

  void _resetTimer() {
    _timerEnded = false;
    _startTimer();
  }

  Color _getCurrentColor() {
    if (_remainingSeconds <= widget.dangerThreshold) {
      return widget.dangerColor ?? Colors.red;
    } else if (_remainingSeconds <= widget.warningThreshold) {
      return widget.warningColor ?? Colors.orange;
    } else {
      return widget.activeColor ?? Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 4,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.grey.shade300,
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: _remainingSeconds / 10.0, // Assume max 10 seconds for rounds
              strokeWidth: 4,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getCurrentColor(),
              ),
            ),
          ),
          // Time text
          if (widget.showText)
            Text(
              '$_remainingSeconds',
              style: TextStyle(
                fontSize: widget.size * 0.35,
                fontWeight: FontWeight.bold,
                color: _getCurrentColor(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Linear countdown timer bar
class CountdownTimerBar extends StatefulWidget {
  final DateTime endTime;
  final VoidCallback? onTimerEnd;
  final double height;
  final Color? activeColor;
  final Color? backgroundColor;
  final bool showText;

  const CountdownTimerBar({
    super.key,
    required this.endTime,
    this.onTimerEnd,
    this.height = 8.0,
    this.activeColor,
    this.backgroundColor,
    this.showText = false,
  });

  @override
  State<CountdownTimerBar> createState() => _CountdownTimerBarState();
}

class _CountdownTimerBarState extends State<CountdownTimerBar> {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _timerEnded = false;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownTimerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime) {
      _calculateRemainingTime();
      _resetTimer();
    }
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    final difference = widget.endTime.difference(now);
    _remainingSeconds = difference.inSeconds > 0 ? difference.inSeconds : 0;
    _totalSeconds = _remainingSeconds; // Store initial value
    _timerEnded = _remainingSeconds == 0;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        final now = DateTime.now();
        final difference = widget.endTime.difference(now);
        _remainingSeconds = difference.inSeconds > 0 ? difference.inSeconds : 0;

        if (_remainingSeconds == 0 && !_timerEnded) {
          _timerEnded = true;
          widget.onTimerEnd?.call();
          timer.cancel();
        }
      });
    });
  }

  void _resetTimer() {
    _timerEnded = false;
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showText)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '$_remainingSeconds saniye',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.activeColor ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.height / 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: widget.height,
            backgroundColor: widget.backgroundColor ?? Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.activeColor ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
