import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import 'digital_pamphlet_screen.dart';
import 'scanner_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'ようこそ',
      icon: Icons.touch_app_outlined,
      helpTitle: 'モード選択',
      helpContent: '「投票モード」か「デジタルパンフモード」のどちらかを選んでください。',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildModeButton(
              context: context,
              title: '投票モード',
              subtitle: '投票を行います。パンフレットに同封された投票券をご準備ください。',
              icon: Icons.how_to_vote,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScannerScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            _buildModeButton(
              context: context,
              title: 'デジタルパンフモード',
              subtitle: 'スマートフォン上で簡易パンフレットを閲覧します。',
              icon: Icons.auto_stories,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DigitalPamphletScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }
}
