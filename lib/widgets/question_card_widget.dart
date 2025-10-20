import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:yes_or_no/core/theme/app_colors.dart';
import 'package:yes_or_no/core/theme/app_text_styles.dart';
import 'package:yes_or_no/models/question_object.dart';

/// Question card widget with status-based styling
class QuestionCardWidget extends StatelessWidget {
  final String text;
  final QuestionAnswer status;

  const QuestionCardWidget({
    Key? key,
    required this.text,
    required this.status,
  }) : super(key: key);

  Color get _borderColor {
    switch (status) {
      case QuestionAnswer.yes:
        return AppColors.yesGreen;
      case QuestionAnswer.no:
        return AppColors.noRed;
      case QuestionAnswer.pending:
        return AppColors.borderGlass;
    }
  }

  Color get _glowColor {
    switch (status) {
      case QuestionAnswer.yes:
        return AppColors.yesGreen;
      case QuestionAnswer.no:
        return AppColors.noRed;
      case QuestionAnswer.pending:
        return Colors.transparent;
    }
  }

  String get _statusText {
    switch (status) {
      case QuestionAnswer.yes:
        return 'YES';
      case QuestionAnswer.no:
        return 'NO';
      case QuestionAnswer.pending:
        return 'Pending...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassPanelBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _borderColor,
          width: status == QuestionAnswer.pending ? 1 : 2,
        ),
        boxShadow: status != QuestionAnswer.pending
            ? [
                BoxShadow(
                  color: _glowColor.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.body.copyWith(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _borderColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _borderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  _statusText,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _borderColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
