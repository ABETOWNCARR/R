import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Auto-trading is not available until Robinhood opens a public trading API.
/// This screen manages notification/alert preferences only.
/// The Smart Agent section is visible but locked, ready to enable later.
class AgentControlsScreen extends StatefulWidget {
  const AgentControlsScreen({super.key});

  @override
  State<AgentControlsScreen> createState() => _AgentControlsScreenState();
}

class _AgentControlsScreenState extends State<AgentControlsScreen> {
  bool alertsEnabled = true;
  double confidenceThreshold = 0.75;
  bool alertBullish = true;
  bool alertBearish = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      alertsEnabled = prefs.getBool('alerts_enabled') ?? true;
      confidenceThreshold = prefs.getDouble('confidence_threshold') ?? 0.75;
      alertBullish = prefs.getBool('alert_bullish') ?? true;
      alertBearish = prefs.getBool('alert_bearish') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alerts_enabled', alertsEnabled);
    await prefs.setDouble('confidence_threshold', confidenceThreshold);
    await prefs.setBool('alert_bullish', alertBullish);
    await prefs.setBool('alert_bearish', alertBearish);
    await prefs.setString('trading_mode', 'alerts');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert settings saved.')),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.green[700],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Controls'),
        actions: [
          TextButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('Notifications'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Pattern Alerts'),
                  subtitle: const Text('Push notifications when patterns are detected'),
                  value: alertsEnabled,
                  activeColor: Colors.green[700],
                  onChanged: (v) => setState(() => alertsEnabled = v),
                ),
                if (alertsEnabled) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Bullish Signals'),
                    subtitle: const Text('Bull Flag, RSI Bounce, MACD Crossover, etc.'),
                    value: alertBullish,
                    activeColor: Colors.green[700],
                    onChanged: (v) => setState(() => alertBullish = v),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Bearish Signals'),
                    subtitle: const Text('Death Cross, RSI Overbought, MACD Bear Cross, etc.'),
                    value: alertBearish,
                    activeColor: Colors.green[700],
                    onChanged: (v) => setState(() => alertBearish = v),
                  ),
                ],
              ],
            ),
          ),
          _sectionHeader('Alert Sensitivity'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Minimum confidence to alert: ${(confidenceThreshold * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Only notify when a pattern is detected with at least this confidence level.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Slider(
                    value: confidenceThreshold,
                    min: 0.50,
                    max: 0.95,
                    divisions: 45,
                    activeColor: Colors.green[700],
                    label: '${(confidenceThreshold * 100).toStringAsFixed(0)}%',
                    onChanged: (v) => setState(() => confidenceThreshold = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('More alerts (50%)', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      Text('Fewer alerts (95%)', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _sectionHeader('Smart Agent — Coming Soon'),
          Stack(
            children: [
              Opacity(
                opacity: 0.35,
                child: Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Enable Auto-Trading'),
                        subtitle: const Text('Automatically execute trades on signals'),
                        value: false,
                        onChanged: null,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Buy on Bullish Signals'),
                        value: false,
                        onChanged: null,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Sell on Bearish Signals'),
                        value: false,
                        onChanged: null,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _showComingSoonSheet(context),
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Available when Robinhood opens API access',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.blue[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Smart Agent auto-trading will be enabled once Robinhood provides '
                    'a public trading API. Until then, Robin the Hood operates in '
                    'alerts-only mode — detecting patterns and notifying you so you '
                    'can make your own trading decisions.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showComingSoonSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Smart Agent — Coming Soon',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Automatic trade execution requires Robinhood to offer a public '
              'trading API. This feature is fully built and ready — it will be '
              'unlocked as soon as that API becomes available.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }
}
