import 'package:flutter/material.dart';
import '../services/pattern_api_service.dart';
import '../services/notification_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final PatternApiService _api = PatternApiService();
  bool isLoading = false;
  Map<String, dynamic> results = {};

  final List<String> popularTickers = [
    'AAPL', 'TSLA', 'NVDA', 'MSFT', 'GOOGL',
    'AMZN', 'META', 'AMD', 'NFLX', 'SPY',
  ];

  Future<void> _scan() async {
    setState(() {
      isLoading = true;
      results = {};
    });
    try {
      final token = await NotificationService.getFcmToken();
      final data = await _api.scanAndNotify(popularTickers, token ?? '');
      setState(() => results = data['results'] ?? {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pattern Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _scan,
            tooltip: 'Scan now',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tickers being scanned
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green[50],
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: popularTickers.map((t) => Chip(
                label: Text(t, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.green[200]!),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ),

          if (isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Scanning for patterns...'),
                  ],
                ),
              ),
            )
          else if (results.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('Tap the refresh button to scan for patterns'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _scan,
                      icon: const Icon(Icons.search),
                      label: const Text('Scan Now'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: results.entries.map((entry) {
                  final patterns = (entry.value as List?) ?? [];
                  if (patterns.isEmpty) return const SizedBox.shrink();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text('${patterns.length} pattern(s) detected'),
                      children: patterns.map<Widget>((p) {
                        final isBullish =
                            p['signal']?.toString().contains('Bullish') == true;
                        final confidence = (p['confidence'] ?? 0) * 100;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                isBullish ? Colors.green[100] : Colors.red[100],
                            child: Icon(
                              isBullish
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: isBullish ? Colors.green[700] : Colors.red[700],
                              size: 20,
                            ),
                          ),
                          title: Text(p['pattern'] ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p['signal'] ?? ''),
                              Text(
                                p['detail'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: confidence >= 75
                                  ? Colors.green[100]
                                  : Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${confidence.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: confidence >= 75
                                    ? Colors.green[800]
                                    : Colors.orange[800],
                              ),
                            ),
                          ),
                          isThreeLine: true,
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
