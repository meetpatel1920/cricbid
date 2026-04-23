import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import './auction_controller.dart';

class AuctionHistoryScreen extends StatelessWidget {
  const AuctionHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auctionCtrl = Get.find<AuctionController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Auction History')),
      body: Obx(() {
        final events = auctionCtrl.eventHistory;
        if (events.isEmpty) return const Center(child: Text('No auction history'));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (_, i) {
            final e = events[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: e.eventType == 'sold' ? AppColors.successSurface : AppColors.surface,
                child: Icon(e.eventType == 'sold' ? Icons.check : Icons.skip_next, color: e.eventType == 'sold' ? AppColors.success : AppColors.skipGray, size: 18),
              ),
              title: Text(e.playerName),
              subtitle: Text('Round \${e.roundNumber}'),
              trailing: e.eventType == 'sold'
                  ? Text('\${e.teamName}\n\${e.points} pts', textAlign: TextAlign.right, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600))
                  : const Text('SKIPPED', style: TextStyle(color: AppColors.skipGray)),
            );
          },
        );
      }),
    );
  }
}
