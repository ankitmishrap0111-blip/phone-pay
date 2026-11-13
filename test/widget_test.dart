import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phonepe_replicte/phonepe_app.dart';
import 'package:phonepe_replicte/phonepe_home_page.dart';
import 'package:phonepe_replicte/phonepe_tab_pages.dart';

void main() {
  testWidgets('header coin animation grows and can be replayed as a demo',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PhonePeApp(cameraEnabled: false));
    expect(find.text('1 Coin'), findsOneWidget);
    expect(find.text('DEMO'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();
    expect(find.text('2 Coins'), findsOneWidget);

    await tester.tap(find.text('DEMO'));
    await tester.pump();
    expect(find.text('1 Coin'), findsOneWidget);
  });

  testWidgets('gold banner coins visibly move', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PhonePeApp(cameraEnabled: false));
    final coin = find.descendant(
      of: find.byKey(const ValueKey('gold-banner-coin-3')),
      matching: find.byIcon(Icons.currency_rupee),
    );
    final initialPosition = tester.getTopLeft(coin);

    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.getTopLeft(coin), isNot(initialPosition));
  });

  testWidgets('reference tabs navigate without phone-width layout errors',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PhonePeApp(cameraEnabled: false));
    expect(find.byKey(const ValueKey('coin-balance')), findsOneWidget);
    expect(find.text('1 Coin'), findsOneWidget);

    const labels = [
      'Home',
      'Search',
      'Alerts',
      'History',
    ];
    const screenKeys = [
      'home-screen',
      'search-screen',
      'alerts-screen',
      'history-screen',
    ];

    for (var index = 0; index < labels.length; index++) {
      final tabIndex = index < 2 ? index : index + 1;
      await tester.tap(find.text(labels[index]).last);
      await tester.pumpAndSettle();
      expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index,
          tabIndex);
      expect(find.byKey(ValueKey(screenKeys[index])), findsOneWidget);
      expect(tester.takeException(), isNull, reason: screenKeys[index]);
    }

    await tester.tap(find.byIcon(Icons.qr_code_scanner).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('scan-screen')), findsOneWidget);
    expect(find.text('Scan any QR'), findsOneWidget);
    expect(find.text('Upload QR'), findsOneWidget);
    expect(find.text('Torch unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 4);
  });

  testWidgets('scanner frame stays square and visible in landscape',
      (tester) async {
    tester.view.physicalSize = const Size(760, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PhonePeApp(cameraEnabled: false));
    await tester.tap(find.byIcon(Icons.qr_code_scanner).first);
    await tester.pumpAndSettle();

    final frame = find.byKey(const ValueKey('scanner-frame'));
    final frameRect = tester.getRect(frame);
    expect(tester.getSize(frame).width, tester.getSize(frame).height);
    expect(frameRect.top, greaterThanOrEqualTo(0));
    expect(frameRect.bottom, lessThanOrEqualTo(440));
    expect(find.text('Upload QR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scanner camera controls fit on a narrow phone screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PhonePeApp(cameraEnabled: false));
    await tester.tap(find.byIcon(Icons.qr_code_scanner).first);
    await tester.pumpAndSettle();

    final frame = tester.getRect(find.byKey(const ValueKey('scanner-frame')));
    expect(frame.width, frame.height);
    expect(frame.left, greaterThanOrEqualTo(0));
    expect(frame.right, lessThanOrEqualTo(320));
    expect(find.text('Upload QR'), findsOneWidget);
    expect(find.text('Camera unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('each page renders with the dark reference palette',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final pages = <Widget>[
      PhonePeHomePage(
        onOpenMyQr: () {},
        onSendMoney: (_) {},
        onSendUpi: (_) {},
        onCheckBalance: (_) {},
        onOpenWallet: (_) {},
      ),
      const SearchTabPage(),
      QrTabPage(onScan: () {}),
      const AlertsTabPage(),
      HistoryTabPage(onNewPayment: (_) {}),
    ];
    const screenKeys = [
      'home-screen',
      'search-screen',
      'qr-screen',
      'alerts-screen',
      'history-screen',
    ];

    for (var index = 0; index < pages.length; index++) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: pages[index]),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey(screenKeys[index])), findsOneWidget);
      expect(tester.takeException(), isNull, reason: screenKeys[index]);
    }
  });

  testWidgets('home bank transfer shortcuts lead through demo flows',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PhonePeApp(cameraEnabled: false));
    await tester.tap(find.text('To Bank &\nSelf A/c'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('send-money-options-screen')),
      findsOneWidget,
    );

    await tester.tap(find.text('To Self Bank Account'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('self-account-screen')), findsOneWidget);

    await tester.tap(find.text('Demo Bank ••0000'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('amount-entry-screen')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search and history filter demo content and alerts dismiss',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PhonePeApp(cameraEnabled: false));
    await tester.tap(find.text('Search').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'mobile');
    await tester.pumpAndSettle();
    expect(find.text('Mobile\nRecharge'), findsOneWidget);
    expect(find.text('Credit\nScore'), findsNothing);

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'recharge');
    await tester.pumpAndSettle();
    expect(find.text('Mobile recharge'), findsOneWidget);
    expect(find.text('Merchant payment'), findsNothing);

    await tester.tap(find.text('Alerts').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('You are all caught up.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('demo transfer shows success and transaction detail screens',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const PhonePeApp(cameraEnabled: false));
    await tester.tap(find.text('To Bank &\nSelf A/c'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('To Self Bank Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Demo Bank ••0000'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '1');
    await tester.tap(find.text('Review transfer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Preview successful payment'));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('payment-success-screen')), findsOneWidget);
    expect(find.text('Payment Successful'), findsOneWidget);
    expect(find.text('DEMO PREVIEW • NO MONEY SENT'), findsOneWidget);

    await tester.tap(find.text('View Details'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('transaction-details-screen')),
      findsOneWidget,
    );
    expect(find.text('DEMO • NOT A REAL TRANSACTION'), findsOneWidget);
    expect(find.text('Demo transaction ID'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-screen')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
