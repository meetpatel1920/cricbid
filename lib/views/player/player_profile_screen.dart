import 'package:flutter/material.dart';

class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: const Center(child: Text('Player profile editing coming soon')),
    );
  }
}
