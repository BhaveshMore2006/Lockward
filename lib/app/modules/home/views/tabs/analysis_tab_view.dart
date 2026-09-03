import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/vault_item.dart';
import '../../controllers/home_controller.dart';

class AnalysisTabView extends GetView<HomeController> {
  const AnalysisTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12, width: 1.2),
            ),
            child: const Icon(Icons.person_outline_rounded, color: Colors.black87, size: 22),
          ),
          onPressed: controller.navigateToProfile,
        ),
        centerTitle: true,
        title: const Text(
          'Security',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.black, size: 30),
            onPressed: controller.navigateToNewRecord,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final vaultService = controller.vaultService;
        final score = vaultService.overallSecurityScore;
        final safeCount = vaultService.safeCount;
        final weakCount = vaultService.weakCount;
        final riskCount = vaultService.riskCount;
        final items = vaultService.items;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            const SizedBox(height: 10),
            // Donut Circular Chart
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    percentage: score / 100,
                    strokeColor: Colors.black87,
                    trackColor: Colors.black12,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$score%',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$score% secured',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 3 Stat Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    number: '$safeCount',
                    label: 'Safe',
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    number: '$weakCount',
                    label: 'Weak',
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    number: '$riskCount',
                    label: 'Risk',
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Analysis Section Header
            const Text(
              'Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // List of Accounts
            ...items.map((item) => _buildAnalysisTile(item)),
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard({
    required String number,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTile(VaultItem item) {
    Color badgeColor;
    String statusText;

    switch (item.securityStatus) {
      case SecurityStatus.safe:
        badgeColor = const Color(0xFF10B981);
        statusText = 'Safe';
        break;
      case SecurityStatus.weak:
        badgeColor = const Color(0xFFF59E0B);
        statusText = 'Weak';
        break;
      case SecurityStatus.risk:
        badgeColor = const Color(0xFFEF4444);
        statusText = 'Risk';
        break;
    }

    return InkWell(
      onTap: () => controller.navigateToDetails(item),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            // Brand icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.brandColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                item.iconLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Title & Username or Password
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.username,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Chevron
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black26,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double percentage;
  final Color strokeColor;
  final Color trackColor;

  _DonutChartPainter({
    required this.percentage,
    required this.strokeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - 16) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
