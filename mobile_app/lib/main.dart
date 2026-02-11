// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MoApp());
// }

// class MoApp extends StatelessWidget {
//   const MoApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Mo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         scaffoldBackgroundColor: Colors.white,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Mo',
//                 style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 'Automatic Wedding Video Highlights',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//               const SizedBox(height: 40),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // next step: video picker
//                   },
//                   child: const Text(
//                     'Create Wedding Highlight',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const V2XDashboardApp());
}

class V2XDashboardApp extends StatelessWidget {
  const V2XDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'V2X Connect Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F67D7)),
        scaffoldBackgroundColor: const Color(0xFFF3F5F9),
      ),
      home: const DashboardScreen(),
    );
  }
}

/// ---------------------------
/// Dashboard Screen
/// ---------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String activeTab = 'Overview';

  bool isRecording = true;
  Duration elapsed = const Duration(seconds: 15);
  Timer? _timer;

  // Mock data (replace with live BSM decoding later)
  final bsm = const _BsmData(
    pps: 14.0,
    signed: false,
    latitude: 39.351355,
    longitude: -76.579667,
    elevationFt: 109,
    gpsAccuracyFt: 43.69,
    distanceToLaneEnd: null,
    heading: 'North',
    speed: null,
    speedLimit: null,
  );

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (isRecording) {
        setState(() => elapsed += const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatElapsed(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopNavBar(
            activeTab: activeTab,
            onTabSelected: (t) => setState(() => activeTab = t),
            isRecording: isRecording,
            onToggleRecording: () => setState(() => isRecording = !isRecording),
            elapsedText: _formatElapsed(elapsed),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 1100;

                if (isNarrow) {
                  // Stack cards vertically for smaller screens
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      BsmCard(bsm: bsm),
                      const SizedBox(height: 16),
                      const MapCard(),
                      const SizedBox(height: 16),
                      const RightCardsGrid(oneColumn: true),
                    ],
                  );
                }

                // Wide dashboard layout (matches screenshot vibe)
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 420,
                        child: Column(children: const [_LeftColumn()]),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: RightCardsGrid(oneColumn: false)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftColumn extends StatelessWidget {
  const _LeftColumn();

  @override
  Widget build(BuildContext context) {
    // In wide layout, we re-use the same cards
    // but keep them fixed-height-ish like the screenshot.
    return Column(
      children: const [_LeftBsmWrapper(), SizedBox(height: 16), MapCard()],
    );
  }
}

class _LeftBsmWrapper extends StatelessWidget {
  const _LeftBsmWrapper();

  @override
  Widget build(BuildContext context) {
    // Use a fixed mock BSM for this wrapper.
    const bsm = _BsmData(
      pps: 14.0,
      signed: false,
      latitude: 39.351355,
      longitude: -76.579667,
      elevationFt: 109,
      gpsAccuracyFt: 43.69,
      distanceToLaneEnd: null,
      heading: 'North',
      speed: null,
      speedLimit: null,
    );
    return const BsmCard(bsm: bsm);
  }
}

/// ---------------------------
/// Top Navigation Bar
/// ---------------------------
class TopNavBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabSelected;
  final bool isRecording;
  final VoidCallback onToggleRecording;
  final String elapsedText;

  const TopNavBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    required this.isRecording,
    required this.onToggleRecording,
    required this.elapsedText,
  });

  static const _blue = Color.fromARGB(255, 196, 150, 2);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _blue,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const _Brand(),
            const SizedBox(width: 16),
            _NavChipRow(activeTab: activeTab, onTabSelected: onTabSelected),
            const Spacer(),
            _RecordButton(isRecording: isRecording, onTap: onToggleRecording),
            const SizedBox(width: 10),
            _TimerPill(text: elapsedText),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Text(
          'Guide',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(width: 8),
        Text(
          'V2X Connect',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _NavChipRow extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabSelected;

  const _NavChipRow({required this.activeTab, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final tabs = const ['Overview', 'MAP & SPAT', 'Data Stream', 'Settings'];

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: tabs.map((t) {
        final selected = t == activeTab;
        return InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => onTabSelected(t),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(selected ? 0.0 : 0.22),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _iconForTab(t),
                  size: 18,
                  color: selected ? const Color(0xFF2F67D7) : Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  t,
                  style: TextStyle(
                    color: selected ? const Color(0xFF2F67D7) : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconForTab(String tab) {
    switch (tab) {
      case 'Overview':
        return Icons.dashboard_rounded;
      case 'MAP & SPAT':
        return Icons.map_rounded;
      case 'Data Stream':
        return Icons.cloud_rounded;
      case 'Settings':
        return Icons.settings_rounded;
      default:
        return Icons.circle;
    }
  }
}

class _RecordButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const _RecordButton({required this.isRecording, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            isRecording ? Icons.stop_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  final String text;
  const _TimerPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// ---------------------------
/// Left Side: BSM Card
/// ---------------------------
class BsmCard extends StatelessWidget {
  final _BsmData bsm;
  const BsmCard({super.key, required this.bsm});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Basic Safety Message (BSM)',
      subtitle:
          '${bsm.pps.toStringAsFixed(1)} p/s    ${bsm.signed ? "Signed" : "Unsigned"}',
      trailing: const _CardActions(),
      child: Column(
        children: [
          _MetricRow(label: 'Latitude', value: bsm.latitude.toStringAsFixed(6)),
          _MetricRow(
            label: 'Longitude',
            value: bsm.longitude.toStringAsFixed(6),
          ),
          _MetricRow(label: 'Elevation', value: '${bsm.elevationFt} ft'),
          _MetricRow(
            label: 'GPS Accuracy',
            value: '${bsm.gpsAccuracyFt.toStringAsFixed(2)} ft',
          ),
          _MetricRow(
            label: 'Distance to Lane End',
            value: bsm.distanceToLaneEnd == null
                ? 'N/A'
                : '${bsm.distanceToLaneEnd!.toStringAsFixed(1)} m',
            valueColor: bsm.distanceToLaneEnd == null ? Colors.red : null,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SmallInfoBox(
                  title: 'Heading',
                  value: bsm.heading ?? 'N/A',
                  leading: Icons.navigation_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallInfoBox(
                  title: 'Speed',
                  value: bsm.speed == null
                      ? 'N/A'
                      : '${bsm.speed!.toStringAsFixed(1)}',
                  leading: Icons.speed_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallInfoBox(
                  title: 'Speed Limit',
                  value: bsm.speedLimit == null
                      ? 'N/A'
                      : '${bsm.speedLimit!.toStringAsFixed(0)}',
                  leading: Icons.signpost_rounded,
                  valueColor: bsm.speedLimit == null ? Colors.red : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MetricRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: Colors.black.withOpacity(0.68),
      fontWeight: FontWeight.w600,
    );
    final valueStyle = TextStyle(
      color: valueColor ?? Colors.black.withOpacity(0.80),
      fontWeight: FontWeight.w800,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

class _SmallInfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData leading;
  final Color? valueColor;

  const _SmallInfoBox({
    required this.title,
    required this.value,
    required this.leading,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8EF)),
      ),
      child: Row(
        children: [
          Icon(leading, size: 18, color: Colors.black.withOpacity(0.55)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? const Color(0xFF1A1D29),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.directions_car_rounded,
            size: 22,
            color: Color(0xFF2F67D7),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------
/// Left Side: MAP Card
/// ---------------------------
class MapCard extends StatelessWidget {
  const MapCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'MAP',
      trailing: const _CardActions(),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: _MiniPair(label: 'Map ID', value: 'N/A'),
              ),
              Expanded(
                child: _MiniPair(label: 'Lane', value: 'N/A'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 250,
              color: const Color(0xFFE9ECF5),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.75,
                      child: Image(
                        image: AssetImage('assets/map_placeholder.jpg'),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            alignment: Alignment.center,
                            child: Text(
                              'Map image placeholder\n(Add your asset or a network tile)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.55),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // little car marker vibe
                  Positioned(
                    left: 140,
                    top: 130,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPair extends StatelessWidget {
  final String label;
  final String value;

  const _MiniPair({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.map_rounded,
          size: 18,
          color: Colors.black.withOpacity(0.55),
        ),
        const SizedBox(width: 8),
        Text(
          '$label  ',
          style: TextStyle(
            color: Colors.black.withOpacity(0.6),
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

/// ---------------------------
/// Right Side Cards Grid
/// ---------------------------
class RightCardsGrid extends StatelessWidget {
  final bool oneColumn;
  const RightCardsGrid({super.key, required this.oneColumn});

  @override
  Widget build(BuildContext context) {
    final cards = const [
      _EmptyDataCard(title: 'Signal Phase & Timing (SPAT)'),
      _EmptyDataCard(title: 'Other BSMs'),
      _EmptyDataCard(title: 'SRM & SSM'),
      _EmptyDataCard(title: 'Traveler Information Message (TIM)'),
      _EmptyDataCard(title: 'Personal Safety Message (PSM)'),
    ];

    if (oneColumn) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i != cards.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    }

    // 2-column grid like screenshot
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.9,
      children: cards,
    );
  }
}

class _EmptyDataCard extends StatelessWidget {
  final String title;
  const _EmptyDataCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: title,
      trailing: const _CardActions(),
      child: Center(
        child: Text(
          'NO DATA AVAILABLE',
          style: TextStyle(
            color: Colors.black.withOpacity(0.35),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------
/// Re-usable Card Shell
/// ---------------------------
class DashboardCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  const DashboardCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E8EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1D29),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.55),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          ExpandedIfPossible(child: child),
        ],
      ),
    );
  }
}

/// Allows card content to expand when inside GridView, but not crash in Column/ListView.
class ExpandedIfPossible extends StatelessWidget {
  final Widget child;
  const ExpandedIfPossible({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final parent = context.findAncestorWidgetOfExactType<GridView>();
    if (parent != null) {
      return Expanded(child: child);
    }
    return child;
  }
}

class _CardActions extends StatelessWidget {
  const _CardActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionIcon(icon: Icons.open_in_new_rounded, onTap: () {}),
        const SizedBox(width: 8),
        _ActionIcon(icon: Icons.description_outlined, onTap: () {}),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F3F8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: Colors.black.withOpacity(0.65)),
        ),
      ),
    );
  }
}

/// ---------------------------
/// Data Models
/// ---------------------------
class _BsmData {
  final double pps;
  final bool signed;
  final double latitude;
  final double longitude;
  final int elevationFt;
  final double gpsAccuracyFt;
  final double? distanceToLaneEnd;
  final String? heading;
  final double? speed;
  final double? speedLimit;

  const _BsmData({
    required this.pps,
    required this.signed,
    required this.latitude,
    required this.longitude,
    required this.elevationFt,
    required this.gpsAccuracyFt,
    this.distanceToLaneEnd,
    this.heading,
    this.speed,
    this.speedLimit,
  });
}
