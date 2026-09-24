import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/demo_controller.dart';

class DemoTimelineHud extends StatelessWidget {
  final DemoFlowController controller;

  const DemoTimelineHud({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B), // Slate dark top HUD for contrast against mobile screen
        border: Border(bottom: BorderSide(color: Color(0xFF334155), width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Controls & Step Indicator Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // Step Badge with QuickServe Orange
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: QuickServeColors.primaryOrange.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: QuickServeColors.primaryOrange, width: 1.0),
                    ),
                    child: Text(
                      'SCREEN ${controller.currentIndex + 1}/25',
                      style: const TextStyle(
                        color: QuickServeColors.primaryOrange,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Current Screen Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.currentStep.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          controller.currentStep.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Previous Button
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 18, color: Color(0xFFCBD5E1)),
                    onPressed: () => controller.previous(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 28),
                    tooltip: 'Previous Screen',
                  ),

                  // Play/Pause Button
                  IconButton(
                    icon: Icon(
                      controller.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      size: 20,
                      color: controller.isPlaying ? QuickServeColors.statusGreen : QuickServeColors.primaryOrange,
                    ),
                    onPressed: () => controller.togglePlayPause(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 28),
                    tooltip: controller.isPlaying ? 'Pause Auto Flow' : 'Play Auto Flow',
                  ),

                  // Next Button
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 18, color: Color(0xFFCBD5E1)),
                    onPressed: () => controller.next(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 28),
                    tooltip: 'Next Screen',
                  ),

                  // 25 Screen dropdown menu
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.menu_open_rounded, size: 18, color: Colors.white),
                    color: const Color(0xFF0F172A),
                    tooltip: 'Select Screen (1 to 25)',
                    elevation: 8,
                    onSelected: (idx) => controller.jumpTo(idx),
                    itemBuilder: (context) {
                      return List.generate(DemoFlowController.steps.length, (i) {
                        final step = DemoFlowController.steps[i];
                        final isCur = i == controller.currentIndex;
                        return PopupMenuItem<int>(
                          value: i,
                          height: 36,
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: isCur ? QuickServeColors.primaryOrange : const Color(0xFF64748B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  step.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isCur ? QuickServeColors.primaryOrange : Colors.white,
                                    fontSize: 12,
                                    fontWeight: isCur ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isCur)
                                const Icon(Icons.check_circle, size: 14, color: QuickServeColors.primaryOrange),
                            ],
                          ),
                        );
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 28),
                  ),
                ],
              ),
            ),

            // Progress Bar
            LinearProgressIndicator(
              value: controller.progress,
              minHeight: 2.0,
              backgroundColor: const Color(0xFF0F172A),
              valueColor: AlwaysStoppedAnimation<Color>(
                controller.isPlaying ? QuickServeColors.statusGreen : QuickServeColors.primaryOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
