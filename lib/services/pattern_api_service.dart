import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_service.dart';

class PatternApiService {
  // When running on Railway, the Flutter web app and backend share the same
  // domain. nginx proxies /api/* → FastAPI. For local dev, set this to your
  // local backend URL e.g. http://localhost:8000
  static const String baseUrl = '/api';

  /// Scan a list of tickers for chart patterns and trigger local notifications
  /// for high-confidence signals. No trading is performed.
  Future<Map<String, dynamic>> scanAndNotify(
      List<String> tickers, String fcmToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/scan_and_notify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tickers': tickers,
        'fcm_token': fcmToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Show local notifications for high-confidence alerts
      if (data['high_confidence_alerts'] != null) {
        for (var alert in data['high_confidence_alerts']) {
          await NotificationService.showPatternAlert(
            alert['ticker'],
            '${alert['pattern']} (${(alert['confidence'] * 100).toStringAsFixed(0)}%) — ${alert['signal']}',
          );
        }
      }
      return data;
    } else {
      throw Exception('Scan failed (${response.statusCode}): ${response.body}');
    }
  }

  // executeTrade() is intentionally removed.
  // Auto-trading will be wired up once Robinhood provides a public trading API.
}
