import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pattern_api_service.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PatternApiService apiService = PatternApiService();
  List<String> holdings = [];
  Map<String, dynamic> scanResults = {};
  bool isLoading = false;
  final TextEditingController _tickerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHoldings();
  }

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  Future<void> _loadHoldings() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('holdings');
    setState(() {
      holdings = saved ?? ['TSLA', 'AAPL', 'NVDA'];
    });
  }

  Future<void> _saveHoldings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('holdings', holdings);
  }

  void _addTicker() {
    final ticker = _tickerController.text.trim().toUpperCase();
    if (ticker.isEmpty) return;
    if (holdings.contains(ticker)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$ticker is already in your holdings.')),
      );
      return;
    }
    setState(() => holdings.add(ticker));
    _tickerController.clear();
    _saveHoldings();
  }

  void _removeTicker(String ticker) {
    setState(() => holdings.remove(ticker));
    _saveHoldings();
  }

  Future<void> runScan() async {
    if (holdings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ticker first.')),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      String? token = await NotificationService.getFcmToken();
      final data = await apiService.scanAndNotify(holdings, token ?? '');
      setState(() => scanResults = data['results'] ?? {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  Widget _buildChart() {
    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 65), FlSpot(1, 78), FlSpot(2, 72),
                FlSpot(3, 89), FlSpot(4, 85), FlSpot(5, 92),
              ],
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.1),
              ),
            ),
          ],
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  void _showAddTickerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Ticker'),
        content: TextField(
          controller: _tickerController,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: 'e.g. AAPL',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            Navigator.pop(ctx);
            _addTicker();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _addTicker();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Robin the Hood'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add ticker',
            onPressed: _showAddTickerDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Portfolio Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildChart(),
            const SizedBox(height: 12),
            if (holdings.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: holdings.map((t) {
                  return Chip(
                    label: Text(t),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeTicker(t),
                    backgroundColor: Colors.green[50],
                    side: BorderSide(color: Colors.green[200]!),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ] else ...[
              TextButton.icon(
                onPressed: _showAddTickerDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add tickers to scan'),
              ),
              const SizedBox(height: 8),
            ],
            ElevatedButton.icon(
              onPressed: isLoading ? null : runScan,
              icon: const Icon(Icons.search),
              label: Text(isLoading ? 'Scanning...' : 'Scan My Holdings'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Signals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: scanResults.isEmpty
                  ? const Center(child: Text('No scans yet — tap Scan to begin'))
                  : ListView(
                      children: scanResults.entries.map((entry) {
                        final patterns = (entry.value as List?) ?? [];
                        if (patterns.isEmpty) {
                          return Card(
                            child: ListTile(
                              title: Text(entry.key),
                              subtitle: const Text('No patterns detected'),
                            ),
                          );
                        }
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${patterns.length} signal(s)'),
                            children: patterns.map<Widget>((p) {
                              final isBullish =
                                  p['signal']?.toString().contains('Bullish') == true;
                              return ListTile(
                                leading: Icon(
                                  isBullish ? Icons.trending_up : Icons.trending_down,
                                  color: isBullish ? Colors.green : Colors.red,
                                ),
                                title: Text(p['pattern'] ?? 'Unknown'),
                                subtitle: Text(
                                  '${p['signal'] ?? ''} • ${((p['confidence'] ?? 0) * 100).toStringAsFixed(0)}% confidence',
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
