import 'package:flutter/material.dart';

/// Trade execution is not available until Robinhood opens a public trading API.
/// Preserved for future use — currently unreachable from the UI.
class TradeConfirmationScreen extends StatelessWidget {
  final String ticker;
  final String action;
  final double quantity;

  const TradeConfirmationScreen({
    super.key,
    required this.ticker,
    required this.action,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto-Trading Unavailable')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 24),
            const Text('Auto-Trading Coming Soon',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text(
              'Automatic trade execution will be available once Robinhood '
              'provides a public trading API.\n\nIn the meantime, Robin the Hood '
              'will alert you when patterns are detected so you can place trades manually.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
