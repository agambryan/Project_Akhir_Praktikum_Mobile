import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bmkg_app/screens/splash_screen.dart';
import 'package:bmkg_app/providers/weather_provider.dart';
import 'package:bmkg_app/providers/earthquake_provider.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => WeatherProvider()),
          ChangeNotifierProvider(create: (_) => EarthquakeProvider()),
        ],
        child: const MaterialApp(
          home: SplashScreen(),
        ),
      ),
    );

    // Verify splash screen loads with BMKG text
    expect(find.text('BMKG'), findsOneWidget);
    expect(find.text('Cuaca & Gempa Bumi'), findsOneWidget);
  });
}
