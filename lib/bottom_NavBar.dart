import 'package:flutter/material.dart';
import 'package:phonepe_replicte/phonepe_theme.dart';

class bnav extends StatelessWidget {
  const bnav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;

  static const _items = <({IconData icon, IconData activeIcon, String label})>[
    (icon: Icons.home_outlined, activeIcon: Icons.home_filled, label: 'Home'),
    (icon: Icons.search, activeIcon: Icons.search, label: 'Search'),
    (
      icon: Icons.qr_code_scanner,
      activeIcon: Icons.qr_code_scanner,
      label: 'QR'
    ),
    (
      icon: Icons.notifications_none,
      activeIcon: Icons.notifications,
      label: 'Alerts'
    ),
    (
      icon: Icons.access_time,
      activeIcon: Icons.access_time_filled,
      label: 'History'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 74,
        color: PhonePeColors.navigation,
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = currentIndex == index;
            final isQr = index == 2;
            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: '${item.label} Tab ${index + 1} of ${_items.length}',
                child: InkResponse(
                  onTap: () => onTap?.call(index),
                  radius: 34,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isQr)
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            color: PhonePeColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 31,
                          ),
                        )
                      else ...[
                        if (index == 3)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                selected ? item.activeIcon : item.icon,
                                color: selected
                                    ? Colors.white
                                    : PhonePeColors.muted,
                                size: 25,
                              ),
                              Positioned(
                                top: -5,
                                right: -5,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0C9B50),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: PhonePeColors.navigation,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Text(
                                    '1',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Icon(
                            selected ? item.activeIcon : item.icon,
                            color:
                                selected ? Colors.white : PhonePeColors.muted,
                            size: 25,
                          ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          maxLines: 1,
                          style: TextStyle(
                            color:
                                selected ? Colors.white : PhonePeColors.muted,
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
