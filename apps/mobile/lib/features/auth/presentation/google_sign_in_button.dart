import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: null, // wired in Task 16
        icon: const Icon(Icons.g_mobiledata),
        label: const Text('Continue with Google'),
      ),
    );
  }
}
