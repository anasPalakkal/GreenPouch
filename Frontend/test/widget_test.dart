import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:front_end/main.dart';
import 'package:front_end/core/theme/theme_provider.dart';
import 'package:front_end/features/analytics/provider/analytics_provider.dart';
import 'package:front_end/core/providers/user_profile_provider.dart';
import 'package:front_end/core/providers/transaction_provider.dart';
import 'package:front_end/core/providers/account_provider.dart';
import 'package:front_end/features/goals/provider/goal_provider.dart';

void main() {
  testWidgets('GreenPouch app loads correctly', (WidgetTester tester) async {

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
          ChangeNotifierProvider(create: (_) => UserProfileProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
          ChangeNotifierProvider(create: (_) => AccountProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
        ],
        child: const GreenPouch(),
      ),
    );

    /// Let splash + async complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    /// Verify app loaded
    expect(find.byType(GreenPouch), findsOneWidget);
  });
}