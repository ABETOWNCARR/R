# Robin the Hood

Educational chart pattern scanner and smart trading assistant for Robinhood users.

## Features
- Pattern detection (Bull Flag, Ascending Triangle, Cup & Handle, Head & Shoulders, RSI Oversold Bounce, etc.)
- Dashboard with charts
- Push notifications for high-confidence patterns
- Guided setup for Robinhood Agentic Trading
- Strong legal disclaimers for Play Store compliance

## Project Structure
```
robin_the_hood/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── disclaimer_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── scanner_screen.dart
│   │   ├── agent_controls_screen.dart
│   │   └── settings_screen.dart
│   └── services/
│       ├── notification_service.dart
│       └── pattern_api_service.dart
├── pubspec.yaml
└── README.md
```

## Next Steps
1. Run `flutter pub get`
2. Set up Firebase (add google-services.json)
3. Deploy backend to Railway
4. Update backend URL in PatternApiService
5. Create app icon
6. Add Privacy Policy link
7. Test and publish to Play Store

## Important
This is an educational project. All trading involves risk. Strong disclaimers are included.
