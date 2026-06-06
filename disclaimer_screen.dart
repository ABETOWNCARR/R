import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  Future<void> _accept(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disclaimer_accepted', true);
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.green[700], size: 36),
                  const SizedBox(width: 12),
                  const Text(
                    'Robin the Hood',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Educational Chart Pattern Scanner',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[200]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ Important Disclaimer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• This app is for EDUCATIONAL PURPOSES ONLY.\n\n'
                      '• Robin the Hood does NOT provide financial, investment, or trading advice.\n\n'
                      '• Pattern detection is algorithmic and NOT guaranteed to be accurate.\n\n'
                      '• Trading stocks involves significant risk of financial loss.\n\n'
                      '• You are solely responsible for any trading decisions you make.\n\n'
                      '• Robin the Hood and its developers are NOT liable for any losses.\n\n'
                      '• This app is NOT affiliated with Robinhood Markets, Inc.',
                      style: TextStyle(fontSize: 13, height: 1.6),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                ),
                onPressed: () => _accept(context),
                child: const Text(
                  'I Understand — Continue',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'By continuing you agree to use this app for educational purposes only.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
