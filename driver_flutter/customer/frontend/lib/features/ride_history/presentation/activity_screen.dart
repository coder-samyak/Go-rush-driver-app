import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/theme/tokens.dart';
import '../../../shared/widgets/error_states/gorush_empty_state.dart';
import '../../../core/ride/data/ride_repository.dart';
import '../../../core/ride/domain/ride_models.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final RideRepository _rideRepository = HttpRideRepository();
  List<Ride>? _rides;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final rides = await _rideRepository.getRideHistory();
      if (mounted) {
        setState(() {
          _rides = rides;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity', style: GoRushTypography.headline),
        backgroundColor: GoRushColors.surface,
        elevation: GoRushElevation.low,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)));
    }
    if (_error != null) {
      return Center(
        child: Text('Failed to load activity: $_error', style: const TextStyle(color: Colors.red)),
      );
    }
    if (_rides == null || _rides!.isEmpty) {
      return const GoRushEmptyState(
        icon: Icons.receipt_long,
        title: 'No rides yet',
        message: 'Your past and upcoming rides will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: const Color(0xFF00C853),
      child: ListView.builder(
        itemCount: _rides!.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final ride = _rides![index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(ride.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(ride.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ride.status.name.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(ride.status),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 10, color: Color(0xFF00C853)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ride.pickupAddress, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ride.dropoffAddress, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${(ride.quoteSnapshot.fareBreakdown.total.amountMinor / 100).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        ride.paymentMethod,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(RideStatus status) {
    if (status == RideStatus.rideCompleted) return const Color(0xFF00C853);
    if (status == RideStatus.cancelled) return Colors.red;
    return Colors.blue;
  }
}
