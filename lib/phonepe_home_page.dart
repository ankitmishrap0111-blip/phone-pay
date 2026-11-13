import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phonepe_replicte/phonepe_theme.dart';

class PhonePeHomePage extends StatelessWidget {
  const PhonePeHomePage({
    super.key,
    required this.onOpenMyQr,
    required this.onSendMoney,
    required this.onSendUpi,
    required this.onCheckBalance,
    required this.onOpenWallet,
  });

  final VoidCallback onOpenMyQr;
  final ValueChanged<BuildContext> onSendMoney;
  final ValueChanged<BuildContext> onSendUpi;
  final ValueChanged<BuildContext> onCheckBalance;
  final ValueChanged<BuildContext> onOpenWallet;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('home-screen'),
      color: PhonePeColors.background,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _HomeHeader(onOpenMyQr: onOpenMyQr),
            const _GoldBanner(),
            _MoneyTransfers(
              onSendMoney: onSendMoney,
              onSendUpi: onSendUpi,
              onCheckBalance: onCheckBalance,
              onOpenWallet: onOpenWallet,
            ),
            const _PromotionStrip(),
            const _ServiceSection(
              title: 'Recharge & Bills',
              items: [
                _Service(Icons.battery_charging_full, 'Mobile\nRecharge'),
                _Service(Icons.home_work_outlined, 'Rent via\nCredit Card'),
                _Service(Icons.lightbulb_outline, 'Electricity\nBill'),
                _Service(Icons.request_quote_outlined, 'Loan\nRepayment'),
              ],
              offer: 'Pay tuition via Credit Card',
            ),
            const _ServiceSection(
              title: 'Loans',
              items: [
                _Service(Icons.person_outline, 'Personal\nLoan'),
                _Service(Icons.trending_up, 'Mutual Funds\nLoan'),
                _Service(Icons.savings_outlined, 'Gold\nLoan'),
                _Service(Icons.speed, 'Credit\nScore'),
              ],
              offer: 'Check your credit score for FREE',
            ),
            const _ServiceSection(
              title: 'Gold, Silver & Platinum',
              items: [
                _Service(
                    Icons.monetization_on_outlined, 'Daily Gold\nwith ₹10'),
                _Service(Icons.currency_rupee, 'Buy\nGold'),
                _Service(Icons.circle_outlined, 'Daily Silver\nwith ₹10'),
                _Service(Icons.diamond_outlined, 'Buy\nSilver'),
              ],
              offer: 'Save in pure Platinum daily',
            ),
            const _ServiceSection(
              title: 'Insurance',
              items: [
                _Service(Icons.two_wheeler, 'Bike'),
                _Service(Icons.directions_car_outlined, 'Car'),
                _Service(Icons.health_and_safety_outlined, 'Health'),
                _Service(Icons.umbrella_outlined, 'Life'),
              ],
              offer: 'Explore cover for what matters',
            ),
            const _ServiceSection(
              title: 'Mutual Funds & Deposits',
              items: [
                _Service(Icons.event_available_outlined, 'Best SIP\nFunds'),
                _Service(Icons.show_chart, 'High Growth\nFunds'),
                _Service(Icons.account_balance_outlined, 'FD & Daily\nDeposit'),
                _Service(Icons.currency_rupee, 'Daily SIP\nwith ₹10'),
              ],
              offer: 'Start a SIP in 5 seconds',
            ),
            const _ServiceSection(
              title: 'Travel & Transit',
              items: [
                _Service(Icons.flight_takeoff, 'Flight'),
                _Service(Icons.directions_bus, 'Bus'),
                _Service(Icons.train_outlined, 'Train'),
                _Service(Icons.hotel_outlined, 'Hotel'),
              ],
              offer: 'Save up to 30% on Hotels',
            ),
            const _ServiceSection(
              title: 'Offers & Rewards',
              items: [
                _Service(Icons.card_giftcard, 'Offer\nZone'),
                _Service(Icons.local_activity_outlined, 'Brand\nVouchers'),
                _Service(Icons.play_circle_outline, 'Subscriptions'),
                _Service(Icons.shop_outlined, 'Google Play'),
              ],
              offer: 'Find the best offers for you',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onOpenMyQr});

  final VoidCallback onOpenMyQr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      child: Row(
        children: [
          InkWell(
            onTap: onOpenMyQr,
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: PhonePeColors.gold,
                    ),
                    child:
                        const Icon(Icons.star, color: Colors.white, size: 20),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -1,
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: BoxDecoration(
                        color: PhonePeColors.navigation,
                        shape: BoxShape.circle,
                        border: Border.all(color: PhonePeColors.border),
                      ),
                      child: const Icon(
                        Icons.qr_code_2,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          const _CoinBalance(),
          const Spacer(),
          IconButton(
            onPressed: () {},
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline, size: 24),
          ),
        ],
      ),
    );
  }
}

class _CoinBalance extends StatefulWidget {
  const _CoinBalance();

  @override
  State<_CoinBalance> createState() => _CoinBalanceState();
}

class _CoinBalanceState extends State<_CoinBalance>
    with SingleTickerProviderStateMixin {
  static const _maximumDemoCoins = 10;

  late final AnimationController _coinFlipController;
  Timer? _coinTimer;
  var _coinCount = 1;

  @override
  void initState() {
    super.initState();
    _coinFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _startDemoCoinAnimation();
  }

  @override
  void dispose() {
    _coinTimer?.cancel();
    _coinFlipController.dispose();
    super.dispose();
  }

  void _startDemoCoinAnimation() {
    _coinTimer?.cancel();
    if (_coinCount != 1) setState(() => _coinCount = 1);
    _coinTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() => _coinCount++);
      _coinFlipController.forward(from: 0);
      if (_coinCount >= _maximumDemoCoins) timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleCoins = math.min(_coinCount, 4);
    return Tooltip(
      message: 'Demo coin animation · Tap to replay',
      child: Semantics(
        key: const ValueKey('coin-balance'),
        button: true,
        label: 'Demo coin animation. $_coinCount demo coins. Tap to replay.',
        child: InkWell(
          onTap: _startDemoCoinAnimation,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF33240A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF9E751D)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 23 + (visibleCoins - 1) * 3,
                  height: 23,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (var index = visibleCoins - 1; index > 0; index--)
                        Positioned(
                          left: index * 3.0,
                          child: _GoldenCoin(
                            size: 21,
                            color: index.isEven
                                ? const Color(0xFFE6A817)
                                : const Color(0xFFF2BC32),
                          ),
                        ),
                      Positioned(
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _coinFlipController,
                          child: const _GoldenCoin(),
                          builder: (context, child) {
                            final angle = _coinFlipController.value * math.pi;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(angle),
                              child: child,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'DEMO',
                      style: TextStyle(
                        color: Color(0xFFE5BD69),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) => SlideTransition(
                        position: animation.drive(
                          Tween<Offset>(
                            begin: const Offset(0, 0.65),
                            end: Offset.zero,
                          ).chain(
                            CurveTween(curve: Curves.easeOutCubic),
                          ),
                        ),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: Text(
                        '$_coinCount ${_coinCount == 1 ? 'Coin' : 'Coins'}',
                        key: ValueKey(_coinCount),
                        style: const TextStyle(
                          color: Color(0xFFFFD873),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoldenCoin extends StatelessWidget {
  const _GoldenCoin({
    this.size = 23,
    this.color = const Color(0xFFFFC928),
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFFFF0A6), color, const Color(0xFFCC8200)],
        ),
        border: Border.all(color: const Color(0xFFFFE9A0), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: const Text(
        '1',
        style: TextStyle(
          color: Color(0xFF754600),
          fontSize: 13,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _GoldBanner extends StatefulWidget {
  const _GoldBanner();

  @override
  State<_GoldBanner> createState() => _GoldBannerState();
}

class _GoldBannerState extends State<_GoldBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _coinAnimation;
  Timer? _coinPause;

  @override
  void initState() {
    super.initState();
    _coinAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..addStatusListener(_onCoinAnimationStatus);
    _coinAnimation.forward();
  }

  @override
  void dispose() {
    _coinPause?.cancel();
    _coinAnimation.dispose();
    super.dispose();
  }

  void _onCoinAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _coinPause = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _coinAnimation.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 226,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6500B8), Color(0xFF30005E), Color(0xFF17002C)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            child: _GoldCoinRow(animation: _coinAnimation),
          ),
          Positioned(
            top: 81,
            child: Column(
              children: [
                const Text(
                  '24K Gold',
                  style: TextStyle(
                    color: Color(0xFFFFD35A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '₹5400',
                        style: TextStyle(
                          color: Color(0xFFFFD35A),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: ' in 6 months',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 13),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text(
                    'Save now',
                    style: TextStyle(
                      color: Color(0xFF35105A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 1,
            child: Text(
              'Gold investments are subject to market risks.',
              style: TextStyle(color: Color(0xFFDDC9E9), fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldCoinRow extends StatelessWidget {
  const _GoldCoinRow({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (index) {
        final size = index == 3 ? 60.0 : 43.0;
        final phase = index * 0.8;
        return AnimatedBuilder(
          key: ValueKey('gold-banner-coin-$index'),
          animation: animation,
          child: Container(
            width: size,
            height: size,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index.isEven
                  ? const Color(0xFFFFDE77)
                  : const Color(0xFFF9C941),
              border: Border.all(color: const Color(0xFFFFE9A6), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0x887B4500), blurRadius: 8),
              ],
            ),
            child: Icon(
              Icons.currency_rupee,
              color: const Color(0xFF9A5A00),
              size: index == 3 ? 29 : 21,
            ),
          ),
          builder: (context, coin) {
            final progress = animation.value * math.pi * 2 + phase;
            final verticalOffset = math.sin(progress) * 7;
            final rotation = math.sin(progress) * 0.42;
            return Transform.translate(
              offset: Offset(0, verticalOffset),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(rotation),
                child: coin,
              ),
            );
          },
        );
      }),
    );
  }
}

class _MoneyTransfers extends StatelessWidget {
  const _MoneyTransfers({
    required this.onSendMoney,
    required this.onSendUpi,
    required this.onCheckBalance,
    required this.onOpenWallet,
  });

  final ValueChanged<BuildContext> onSendMoney;
  final ValueChanged<BuildContext> onSendUpi;
  final ValueChanged<BuildContext> onCheckBalance;
  final ValueChanged<BuildContext> onOpenWallet;

  @override
  Widget build(BuildContext context) {
    final items = [
      _TransferShortcut(
        Icons.phone_android,
        'To Mobile\nNumber',
        () => onSendUpi(context),
      ),
      _TransferShortcut(
        Icons.account_balance,
        'To Bank &\nSelf A/c',
        () => onSendMoney(context),
      ),
      _TransferShortcut(
        Icons.account_balance_wallet_outlined,
        'PhonePe\nWallet',
        () => onOpenWallet(context),
      ),
      _TransferShortcut(
        Icons.currency_rupee,
        'Check\nBalance',
        () => onCheckBalance(context),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Money Transfers',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF512000),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  '₹ Refer  →  ₹100',
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: items
                .map(
                  (item) => Expanded(
                    child: InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: const BoxDecoration(
                                color: PhonePeColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.icon,
                                color: const Color(0xFFE7C8FF),
                                size: 29,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              item.label,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(fontSize: 12, height: 1.25),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PromotionStrip extends StatelessWidget {
  const _PromotionStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: const [
          _PromoCard(
            icon: Icons.percent,
            text: 'Use PPPF10 for 10% off on loan*',
            width: 286,
          ),
          SizedBox(width: 9),
          _PromoCard(
            icon: Icons.monetization_on_outlined,
            text: 'Buy 24K Gold',
            width: 190,
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.icon,
    required this.text,
    required this.width,
  });

  final IconData icon;
  final String text;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: PhonePeColors.surface,
        border: Border.all(color: PhonePeColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: PhonePeColors.accentLight, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceSection extends StatelessWidget {
  const _ServiceSection({
    required this.title,
    required this.items,
    this.offer,
  });

  final String title;
  final List<_Service> items;
  final String? offer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((item) => Expanded(child: _ServiceTile(service: item)))
                .toList(),
          ),
          if (offer != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    decoration: BoxDecoration(
                      color: PhonePeColors.surface,
                      border: Border.all(color: PhonePeColors.border),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      offer!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: PhonePeColors.surface,
                    border: Border.all(color: PhonePeColors.border),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'More',
                        style: TextStyle(
                          color: PhonePeColors.accentLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward,
                        size: 15,
                        color: PhonePeColors.accentLight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 28),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});

  final _Service service;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: PhonePeColors.surface,
              border: Border.all(color: PhonePeColors.border),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Icon(
                service.icon,
                color: PhonePeColors.accentLight,
                size: 27,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            service.label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, height: 1.15),
          ),
        ],
      ),
    );
  }
}

class _Service {
  const _Service(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _TransferShortcut {
  const _TransferShortcut(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}
