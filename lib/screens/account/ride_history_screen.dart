import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../i18n/strings.dart';
import '../../models/ride.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/babi_icon.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppState>().loadRideHistory());
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = app.t;
    final rides = app.rideHistory;

    return AccountScaffold(
      title: t.rideHistory,
      child: rides.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(40), child: Text(t.noRides, style: AppTheme.manrope(color: AppColors.ink3))))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: rides.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _card(t, rides[i]),
            ),
    );
  }

  Widget _card(Strings t, Ride r) {
    final cancelled = r.status == RideStatus.cancelled;
    final statusColor = cancelled ? AppColors.rose : AppColors.green;
    final statusText = cancelled ? t.statusCancelled : t.statusCompleted;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(r.vehicleClass?.name ?? t.trip, style: AppTheme.manrope(size: 14, weight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(statusText, style: AppTheme.manrope(size: 10, weight: FontWeight.w700, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _point(AppColors.green, false, r.pickup.name),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: SizedBox(
              height: 10,
              child: VerticalDivider(color: AppColors.line2, thickness: 2, width: 2),
            ),
          ),
          _point(AppColors.ink, true, r.dropoff.name),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.line),
          const SizedBox(height: 10),
          Row(
            children: [
              const BabiIcon('clock', size: 14, color: AppColors.ink3),
              const SizedBox(width: 6),
              Text('${r.distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km · ${r.durationMinutes} min',
                  style: AppTheme.manrope(size: 12, weight: FontWeight.w600, color: AppColors.ink3)),
              const Spacer(),
              Text('${groupThousands(r.fare.total)} F', style: AppTheme.numeric(size: 16, weight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _point(Color dot, bool square, String label) {
    return Row(
      children: [
        square
            ? Container(width: 9, height: 9, color: dot)
            : Container(width: 9, height: 9, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: 11),
        Expanded(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.manrope(size: 13, weight: FontWeight.w600)),
        ),
      ],
    );
  }
}
