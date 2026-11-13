import 'package:flutter/material.dart';
import 'package:phonepe_replicte/bottom_NavBar.dart';
import 'package:phonepe_replicte/phonepe_flow_pages.dart';
import 'package:phonepe_replicte/phonepe_home_page.dart';
import 'package:phonepe_replicte/phonepe_scan_page.dart';
import 'package:phonepe_replicte/phonepe_tab_pages.dart';
import 'package:phonepe_replicte/phonepe_theme.dart';

class PhonePeApp extends StatefulWidget {
  const PhonePeApp({
    super.key,
    this.cameraEnabled = true,
  });

  final bool cameraEnabled;

  @override
  State<PhonePeApp> createState() => _PhonePeAppState();
}

class _PhonePeAppState extends State<PhonePeApp> {
  int _selectedIndex = 0;
  bool _scannerOpen = false;

  void _openScanner() => setState(() => _scannerOpen = true);

  void _closeScanner() => setState(() => _scannerOpen = false);

  void _onTabSelected(int index) {
    if (index == 2) {
      _openScanner();
      return;
    }
    setState(() => _selectedIndex = index);
  }

  List<Widget> _pages() => [
        PhonePeHomePage(
          onOpenMyQr: () => setState(() => _selectedIndex = 2),
          onSendMoney: (context) =>
              openPhonePeFlow(context, const SendMoneyOptionsPage()),
          onSendUpi: (context) =>
              openPhonePeFlow(context, const UpiRecipientPage()),
          onCheckBalance: (context) =>
              openPhonePeFlow(context, const CheckBalancePage()),
          onOpenWallet: (context) =>
              openPhonePeFlow(context, const WalletActivationPage()),
        ),
        const SearchTabPage(),
        QrTabPage(onScan: _openScanner),
        const AlertsTabPage(),
        HistoryTabPage(
          onNewPayment: (context) =>
              openPhonePeFlow(context, const SendMoneyOptionsPage()),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: PhonePeColors.accent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: PhonePeColors.background,
        canvasColor: PhonePeColors.background,
        dividerColor: PhonePeColors.border,
      ),
      home: Scaffold(
        body: _scannerOpen
            ? ScanQrPage(
                cameraEnabled: widget.cameraEnabled,
                onBack: _closeScanner,
              )
            : IndexedStack(
                index: _selectedIndex,
                children: _pages(),
              ),
        bottomNavigationBar: _scannerOpen
            ? null
            : bnav(
                currentIndex: _selectedIndex,
                onTap: _onTabSelected,
              ),
      ),
    );
  }
}
