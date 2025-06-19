import 'dart:math';
import 'package:flutter/material.dart';

const Color ratpLightGreen = Color(0xFF59E2C1);
const Color ratpGreen = Color(0xFF23D5AB);

class ResultScreen extends StatelessWidget {
  final List<List<List<String>>> trajets;

  const ResultScreen({super.key, required this.trajets});

  @override
  Widget build(BuildContext context) {
    String? dep;
    String? arr;
    if (trajets.isNotEmpty && trajets[0].isNotEmpty) {
      dep = trajets[0][0][0];
      arr = trajets[0].last[1];
    }

    final uniqueTrajets = <String, List<List<String>>>{};
    for (var trajet in trajets) {
      final hash = trajet.map((e) => e.join('|')).join('->');
      uniqueTrajets.putIfAbsent(hash, () => trajet);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: ratpLightGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18, left: 16, right: 16, bottom: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: const EdgeInsets.only(right: 10),
                      ),
                      Expanded(
                        child: Text(
                          dep != null && arr != null ? '$dep   ➔   $arr' : "Résultats",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 26),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: uniqueTrajets.isEmpty
                      ? const Center(
                    child: Text(
                      "Aucun trajet trouvé.",
                      style: TextStyle(fontSize: 18, color: ratpGreen),
                    ),
                  )
                      : ListView(
                    padding: const EdgeInsets.only(top: 12, bottom: 20, left: 10, right: 10),
                    children: uniqueTrajets.values
                        .map((steps) => _ResultCard(steps: steps))
                        .toList(),
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

class _ResultCard extends StatelessWidget {
  final List<List<String>> steps;

  const _ResultCard({required this.steps});

  static const rameAssets = [
    'assets/metro_arriere.png',
    'assets/metro_milieu.png',
    'assets/metro_avant.png'
  ];
  static const rameLabels = ['Rame arrière', 'Rame milieu', 'Rame avant'];

  String buildDescription(List<List<String>> steps) {
    if (steps.isEmpty) return '';
    if (steps.length == 1) {
      return '${steps[0][0]} → ${steps[0][1]} par la ligne ${steps[0][2]}';
    }
    final desc = <String>[];
    for (int i = 0; i < steps.length; i++) {
      final s = steps[i];
      if (i == 0) {
        desc.add('${s[0]} → ${s[1]} par la ligne ${s[2]}');
      } else {
        desc.add('${s[0]} → ${s[1]} par la ligne ${s[2]}');
      }
    }
    return desc.join(', puis ');
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final rameIndex = random.nextInt(3);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 24,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            buildDescription(steps),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.radio_button_checked, color: ratpGreen, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(steps.length, (i) {
                    final step = steps[i];
                    final isLast = i == steps.length - 1;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step[0],
                          style: TextStyle(
                            fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
                            color: i == 0 ? ratpGreen : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Métro ligne ${step[2]}',
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        if (!isLast)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: SizedBox(
                              width: 10,
                              height: 30,
                              child: CustomPaint(
                                painter: _DashedLinePainter(),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Image.asset(
                    rameAssets[rameIndex],
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rameLabels[rameIndex],
                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.location_on, color: Colors.pink, size: 20),
              const SizedBox(width: 2),
              Text(
                steps.last[1],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashWidth = 6.0;
    const dashSpace = 6.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
}
