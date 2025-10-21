
import 'package:flutter/material.dart';
import 'package:yes_or_no/core/theme/app_colors.dart';
import 'package:yes_or_no/models/user_profile.dart';
import 'package:yes_or_no/widgets/avatar_widget.dart';
import 'package:yes_or_no/widgets/animated_background.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<UserProfile> leaderboard = _getMockLeaderboard();

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Leaderboard'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView.builder(
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final user = leaderboard[index];
            return ListTile(
              leading: Text('#${index + 1}'),
              title: Row(
                children: [
                  AvatarWidget(
                    imageUrl: user.avatar,
                    size: AvatarSize.small,
                    badge: user.rankIcon,
                  ),
                  const SizedBox(width: 16),
                  Text(user.username),
                ],
              ),
              trailing: Text(user.rank, style: const TextStyle(color: AppColors.tertiaryGold)),
            );
          },
        ),
      ),
    );
  }

  List<UserProfile> _getMockLeaderboard() {
    return [
      UserProfile.mock(username: 'PlayerOne', rank: 'Gold'),
      UserProfile.mock(username: 'PlayerTwo', rank: 'Silver'),
      UserProfile.mock(username: 'PlayerThree', rank: 'Bronze'),
      UserProfile.mock(username: 'PlayerFour', rank: 'Bronze'),
      UserProfile.mock(username: 'PlayerFive', rank: 'Bronze'),
    ];
  }
}
