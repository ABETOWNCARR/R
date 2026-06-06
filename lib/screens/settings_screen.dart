import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'agent_controls_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  static const String _privacyPolicyUrl = 'https://your-site.com/privacy-policy';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('alerts_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alerts_enabled', value);
    setState(() => notificationsEnabled = value);
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(_privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open privacy policy.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            title: const Text('Pattern Alerts'),
            subtitle: const Text('Push notifications when patterns are detected'),
            value: notificationsEnabled,
            activeColor: Colors.green[700],
            onChanged: _toggleNotifications,
          ),
          ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: const Text('Alert Settings'),
            subtitle: const Text('Sensitivity, signal types'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AgentControlsScreen()),
            ).then((_) => _loadSettings()),
          ),
          const Divider(),
          const _SectionHeader(title: 'Auto-Trading'),
          ListTile(
            leading: Icon(Icons.smart_toy_outlined, color: Colors.grey[400]),
            title: Text('Smart Agent', style: TextStyle(color: Colors.grey[500])),
            subtitle: Text(
              'Available when Robinhood opens API access',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Coming Soon', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ),
            onTap: () => showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (ctx) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.smart_toy_outlined, size: 44, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Smart Agent — Coming Soon',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text(
                      'Auto-trading will be enabled once Robinhood provides a public trading API. '
                      'The feature is fully built and ready to unlock when that happens.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          const _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Robin the Hood'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Robin the Hood',
              applicationVersion: '1.0.0',
              children: const [
                Text('Educational chart pattern scanner for Robinhood users.\n\nNot affiliated with Robinhood Markets, Inc.'),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Privacy Policy'),
            onTap: _openPrivacyPolicy,
          ),
          const Divider(),
          const _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Reset All Settings', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset Settings?'),
                  content: const Text('This will clear all saved preferences.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                _loadSettings();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green[700], letterSpacing: 1.1),
      ),
    );
  }
}
