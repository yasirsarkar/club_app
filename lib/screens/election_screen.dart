// lib/screens/election_screen.dart

import 'package:flutter/material.dart';

class ElectionScreen extends StatelessWidget {
  const ElectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Election System')),
      body: const Center(child: Text('Election features will be here.')),
    );
  }
}