import 'package:flutter/material.dart';
import 'package:phonepe_replicte/phonepe_theme.dart';

class SearchTabPage extends StatefulWidget {
  const SearchTabPage({super.key});

  @override
  State<SearchTabPage> createState() => _SearchTabPageState();
}

class _SearchTabPageState extends State<SearchTabPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setQuery(String query) {
    setState(() {
      _query = query;
      _searchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('search-screen'),
      color: PhonePeColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _HelpButtonRow(),
            const SizedBox(height: 17),
            const Text(
              'Search',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 19),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value.trim()),
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Type or speak here...',
                hintStyle: const TextStyle(color: PhonePeColors.muted),
                prefixIcon: const Icon(Icons.search, size: 27),
                suffixIcon: const Icon(Icons.mic_none),
                filled: true,
                fillColor: PhonePeColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 17),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(34),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 31),
            const Text(
              '✨  Try searching for',
              style: TextStyle(
                color: PhonePeColors.accentLight,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _SuggestionChip(
                    'Check my credit score',
                    onTap: () => _setQuery('credit score'),
                  ),
                  const SizedBox(width: 9),
                  _SuggestionChip(
                    'Show my unpaid bills',
                    onTap: () => _setQuery('unpaid bills'),
                  ),
                  const SizedBox(width: 9),
                  _SuggestionChip(
                    'Mobile recharge',
                    onTap: () => _setQuery('mobile recharge'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 31),
            const _SectionTitle('Popular'),
            const SizedBox(height: 14),
            _PopularSearches(query: _query, onSelect: _setQuery),
            if (_query.isEmpty) ...[
              const SizedBox(height: 24),
              const _SectionTitle('New for you'),
              const SizedBox(height: 13),
              SizedBox(
                height: 226,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _DiscoveryCard(
                      icon: Icons.people_alt_outlined,
                      title: 'Set up UPI Circle',
                      subtitle: 'Pay for your loved ones anytime',
                      color: Color(0xFF552B84),
                    ),
                    SizedBox(width: 12),
                    _DiscoveryCard(
                      icon: Icons.ondemand_video,
                      title: 'Check credit videos',
                      subtitle: 'Get custom insights on your score',
                      color: Color(0xFF113B6B),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class QrTabPage extends StatelessWidget {
  const QrTabPage({super.key, required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('qr-screen'),
      color: PhonePeColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const _HelpButtonRow(),
            const SizedBox(height: 12),
            const Text(
              'MY QR',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3B3B3E),
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 17),
              decoration: BoxDecoration(
                color: PhonePeColors.navigation,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: PhonePeColors.border),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: PhonePeColors.gold,
                        child: Icon(
                          Icons.currency_rupee,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 9),
                      Text(
                        'Demo wallet • 0000',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  const _DemoQrCode(),
                  const SizedBox(height: 12),
                  const Text(
                    'DEMO QR • NOT FOR PAYMENTS',
                    style: TextStyle(
                      color: PhonePeColors.accentLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'UPI ID: demo@phonepe',
                        style: TextStyle(
                          color: PhonePeColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.copy, color: PhonePeColors.muted, size: 17),
                    ],
                  ),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      Expanded(
                        child: _DemoActionButton(
                          icon: Icons.download_outlined,
                          label: 'Download',
                          onPressed: () => _showDemoNotice(context),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _DemoActionButton(
                          icon: Icons.share_outlined,
                          label: 'Share',
                          onPressed: () => _showDemoNotice(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'This preview does not accept or send payments.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PhonePeColors.muted, fontSize: 11),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan any QR'),
              style: FilledButton.styleFrom(
                backgroundColor: PhonePeColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertsTabPage extends StatefulWidget {
  const AlertsTabPage({super.key});

  @override
  State<AlertsTabPage> createState() => _AlertsTabPageState();
}

class _AlertsTabPageState extends State<AlertsTabPage> {
  bool _alertVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('alerts-screen'),
      color: PhonePeColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _HelpButtonRow(),
            const SizedBox(height: 20),
            const Text(
              'Alerts',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 35),
            if (_alertVisible)
              _AlertItem(
                onDismiss: () => setState(() => _alertVisible = false),
                onTap: () => _showDemoNotice(context),
              )
            else
              const Text(
                'You are all caught up.',
                style: TextStyle(color: PhonePeColors.muted),
              ),
            const SizedBox(height: 30),
            const _OfferZone(),
          ],
        ),
      ),
    );
  }
}

class HistoryTabPage extends StatefulWidget {
  const HistoryTabPage({super.key, required this.onNewPayment});

  final ValueChanged<BuildContext> onNewPayment;

  @override
  State<HistoryTabPage> createState() => _HistoryTabPageState();
}

class _HistoryTabPageState extends State<HistoryTabPage> {
  static const _transactions = <_HistoryEntry>[
    _HistoryEntry(
        'November 2026', '₹0.00', 'Merchant payment', '11 Nov', '₹20'),
    _HistoryEntry(
        'November 2026', '₹0.00', 'Mobile recharge', '02 Nov', '₹320'),
    _HistoryEntry('October 2026', '₹0.00', 'Bill payment', '29 Oct', '₹1'),
    _HistoryEntry('October 2026', '₹0.00', 'Wallet transfer', '18 Oct', '₹120'),
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase();
    final filtered = _transactions
        .where(
          (entry) =>
              entry.name.toLowerCase().contains(query) ||
              entry.date.toLowerCase().contains(query) ||
              entry.amount.toLowerCase().contains(query),
        )
        .toList();
    final children = <Widget>[
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: _HelpButtonRow(),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 17, 16, 19),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'History',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _showDemoNotice(context),
              icon: const Icon(Icons.download_outlined, size: 17),
              label: const Text('My Statements'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PhonePeColors.text,
                side: const BorderSide(color: PhonePeColors.border),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _HistorySearchBar(
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
      ),
      const SizedBox(height: 28),
    ];

    for (final month in _transactions.map((entry) => entry.month).toSet()) {
      final monthEntries =
          filtered.where((entry) => entry.month == month).toList();
      if (monthEntries.isEmpty) continue;
      children.add(_MonthHeader(month, monthEntries.first.total));
      children.addAll(
        monthEntries.map(
          (entry) => _TransactionRow(
            name: entry.name,
            date: entry.date,
            amount: entry.amount,
            status: 'Failed',
            onTap: () => _showDemoNotice(context),
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      children.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 26),
          child: Text(
            'No matching activity',
            textAlign: TextAlign.center,
            style: TextStyle(color: PhonePeColors.muted),
          ),
        ),
      );
    }
    children.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: FilledButton.icon(
          onPressed: () => widget.onNewPayment(context),
          icon: const Icon(Icons.add),
          label: const Text('New Payment'),
          style: FilledButton.styleFrom(
            backgroundColor: PhonePeColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );

    return Container(
      key: const ValueKey('history-screen'),
      color: PhonePeColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          children: children,
        ),
      ),
    );
  }
}

class _HistoryEntry {
  const _HistoryEntry(
      this.month, this.total, this.name, this.date, this.amount);

  final String month;
  final String total;
  final String name;
  final String date;
  final String amount;
}

class _HelpButtonRow extends StatelessWidget {
  const _HelpButtonRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        IconButton(
          onPressed: () => _showDemoNotice(context),
          tooltip: 'Help',
          icon: const Icon(Icons.help_outline, size: 24),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip(this.label, {required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: PhonePeColors.surface,
          border: Border.all(color: const Color(0xFF56351E)),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

class _PopularSearches extends StatelessWidget {
  const _PopularSearches({required this.query, required this.onSelect});

  final String query;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.speed, 'Credit\nScore'),
      (Icons.battery_charging_full, 'Mobile\nRecharge'),
      (Icons.request_quote_outlined, 'Loan\nRepayment'),
      (Icons.local_taxi_outlined, 'FASTag\nRecharge'),
    ];
    final matches = items
        .where(
          (item) => item.$2
              .replaceAll('\n', ' ')
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .toList();

    if (matches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Text(
          'No matching shortcuts',
          style: TextStyle(color: PhonePeColors.muted),
        ),
      );
    }

    return Row(
      children: matches
          .map(
            (item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => onSelect(item.$2.replaceAll('\n', ' ')),
                  borderRadius: BorderRadius.circular(11),
                  child: Column(
                    children: [
                      Container(
                        height: 49,
                        decoration: BoxDecoration(
                          color: PhonePeColors.surface,
                          border: Border.all(color: PhonePeColors.border),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(
                          child: Icon(
                            item.$1,
                            color: PhonePeColors.accentLight,
                            size: 27,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        item.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 194,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: PhonePeColors.surface,
        border: Border.all(color: PhonePeColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: color,
              child: Icon(icon, size: 66, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: PhonePeColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoQrCode extends StatelessWidget {
  const _DemoQrCode();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: _DemoQrPainter(),
        child: Center(
          child: Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.currency_rupee,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const count = 29;
    final cell = size.width / count;
    final black = Paint()..color = const Color(0xFF050505);
    final white = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, white);

    for (var row = 0; row < count; row++) {
      for (var column = 0; column < count; column++) {
        if (_isFinderCell(row, column)) continue;
        final value = (row * 17 + column * 13 + row * column * 7) % 19;
        if (value < 9) {
          canvas.drawRect(
            Rect.fromLTWH(column * cell, row * cell, cell, cell),
            black,
          );
        }
      }
    }

    _drawFinder(canvas, 0, 0, cell, black, white);
    _drawFinder(canvas, count - 7, 0, cell, black, white);
    _drawFinder(canvas, 0, count - 7, cell, black, white);
  }

  bool _isFinderCell(int row, int column) {
    return (row < 8 && column < 8) ||
        (row < 8 && column >= 21) ||
        (row >= 21 && column < 8);
  }

  void _drawFinder(
    Canvas canvas,
    int startColumn,
    int startRow,
    double cell,
    Paint black,
    Paint white,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(startColumn * cell, startRow * cell, 7 * cell, 7 * cell),
      black,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (startColumn + 1) * cell,
        (startRow + 1) * cell,
        5 * cell,
        5 * cell,
      ),
      white,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (startColumn + 2) * cell,
        (startRow + 2) * cell,
        3 * cell,
        3 * cell,
      ),
      black,
    );
  }

  @override
  bool shouldRepaint(covariant _DemoQrPainter oldDelegate) => false;
}

class _DemoActionButton extends StatelessWidget {
  const _DemoActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 1),
      style: OutlinedButton.styleFrom(
        foregroundColor: PhonePeColors.text,
        side: const BorderSide(color: PhonePeColors.border),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({required this.onDismiss, required this.onTap});

  final VoidCallback onDismiss;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 23,
          backgroundColor: Colors.white,
          child:
              Icon(Icons.phone_android, color: PhonePeColors.accent, size: 25),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: InkWell(
            onTap: onTap,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your monthly mobile plan is due soon.',
                  style: TextStyle(fontSize: 15, height: 1.35),
                ),
                SizedBox(height: 4),
                Text(
                  'Review available recharge options.',
                  style: TextStyle(color: PhonePeColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Column(
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 19),
            ),
            const Text('1d', style: TextStyle(color: PhonePeColors.muted)),
          ],
        ),
      ],
    );
  }
}

class _OfferZone extends StatelessWidget {
  const _OfferZone();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.card_giftcard, 'Offers for you', 'Exciting offers'),
      (Icons.star, 'Most Popular', 'Top picks today'),
      (Icons.arrow_forward, 'All Offers', ''),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF171514), PhonePeColors.background],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O F F E R  Z O N E',
            style: TextStyle(color: PhonePeColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 15),
          Row(
            children: items.map((item) {
              return Expanded(
                child: InkWell(
                  onTap: () => _showDemoNotice(context),
                  borderRadius: BorderRadius.circular(13),
                  child: Container(
                    height: 144,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: PhonePeColors.navigation,
                      border: Border.all(color: PhonePeColors.border),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.$1,
                          color: PhonePeColors.accentLight,
                          size: 31,
                        ),
                        const SizedBox(height: 9),
                        Text(
                          item.$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (item.$3.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.$3,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: PhonePeColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _HistorySearchBar extends StatelessWidget {
  const _HistorySearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: PhonePeColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 24),
          const SizedBox(width: 13),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: PhonePeColors.muted),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 30, child: VerticalDivider(width: 18)),
          const Icon(Icons.tune, size: 23),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader(this.month, this.total);

  final String month;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PhonePeColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
      child: Row(
        children: [
          Expanded(
            child: Text(
              month,
              style: const TextStyle(color: PhonePeColors.muted, fontSize: 15),
            ),
          ),
          Text(total, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.name,
    required this.date,
    required this.amount,
    required this.status,
    required this.onTap,
  });

  final String name;
  final String date;
  final String amount;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 17),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 21,
              backgroundColor: PhonePeColors.surfaceLight,
              child: Icon(
                Icons.north_east,
                color: PhonePeColors.muted,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment to',
                    style: TextStyle(color: PhonePeColors.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(name, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 5),
                  Text(
                    date,
                    style: const TextStyle(
                      color: PhonePeColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      status,
                      style: const TextStyle(color: PhonePeColors.muted),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.error,
                      color: PhonePeColors.danger,
                      size: 15,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showDemoNotice(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('This feature is not connected in the demo.'),
    ),
  );
}
