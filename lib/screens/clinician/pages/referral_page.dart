import 'package:flutter/material.dart';
import '../../../services/referral_service.dart';
import '../../../theme/app_colors.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({Key? key}) : super(key: key);

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  late Future<List<Referral>> _referralsFuture;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadReferrals();
  }

  void _loadReferrals() {
    setState(() {
      _referralsFuture = ReferralService.instance.getAllReferrals();
    });
  }

  List<Referral> _filterReferrals(List<Referral> referrals) {
    if (_filterStatus == 'all') return referrals;
    return referrals.where((r) => r.status == _filterStatus).toList();
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'in_transit':
        return 'In Transit';
      case 'arrived':
        return 'Arrived';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return AppColors.navy;
      case 'rejected':
        return AppColors.red;
      case 'in_transit':
        return Colors.purple;
      case 'arrived':
        return Colors.green;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Referrals',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage patient referrals',
                  style: TextStyle(fontSize: 13, color: AppColors.g600),
                ),
              ],
            ),
          ),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildFilterChip('all', 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('pending', 'Pending'),
                const SizedBox(width: 8),
                _buildFilterChip('accepted', 'Accepted'),
                const SizedBox(width: 8),
                _buildFilterChip('in_transit', 'In Transit'),
                const SizedBox(width: 8),
                _buildFilterChip('completed', 'Completed'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Referrals list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FutureBuilder<List<Referral>>(
              future: _referralsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadReferrals,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navy,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final referrals = _filterReferrals(snapshot.data ?? []);

                if (referrals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No referrals found'),
                      ],
                    ),
                  );
                }

                return Column(
                  children: List.generate(
                    referrals.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildReferralCard(referrals[index]),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.navy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildReferralCard(Referral referral) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _showReferralDetails(referral),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          referral.patientName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code: ${referral.referralCode}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(referral.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusLabel(referral.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(referral.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Reason
              Text(
                'Reason: ${referral.reason}',
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Facilities
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'From: ${referral.referringFacility?['facilityName'] ?? 'Unknown'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'To: ${referral.receivingFacility?['facilityName'] ?? 'Unknown'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Date
              Text(
                'Created: ${_formatDate(referral.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              // Action buttons
              if (referral.status == 'pending' || referral.status == 'accepted')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (referral.status == 'pending')
                        TextButton(
                          onPressed: () => _handleRejectReferral(referral),
                          child: const Text('Reject', style: TextStyle(color: AppColors.red)),
                        ),
                      const SizedBox(width: 8),
                      if (referral.status == 'pending')
                        ElevatedButton(
                          onPressed: () => _handleAcceptReferral(referral),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Accept'),
                        ),
                      if (referral.status == 'accepted')
                        ElevatedButton(
                          onPressed: () => _showTransportStatusDialog(referral),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navy,
                          ),
                          child: const Text('Update Status'),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReferralDetails(Referral referral) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Referral: ${referral.referralCode}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Patient:', referral.patientName),
              _buildDetailRow('Status:', _getStatusLabel(referral.status)),
              _buildDetailRow('Reason:', referral.reason),
              _buildDetailRow(
                'From:',
                referral.referringFacility?['facilityName'] ?? 'Unknown',
              ),
              _buildDetailRow(
                'To:',
                referral.receivingFacility?['facilityName'] ?? 'Unknown',
              ),
              _buildDetailRow('Clinical Summary:', referral.clinicalSummary),
              _buildDetailRow('Created:', _formatDate(referral.createdAt)),
              if (referral.receivingClinician != null)
                _buildDetailRow(
                  'Receiving Clinician:',
                  referral.receivingClinician?['fullName'] ?? 'Unknown',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _handleAcceptReferral(Referral referral) async {
    try {
      await ReferralService.instance.acceptReferral(referral.id);
      _loadReferrals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Referral accepted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _handleRejectReferral(Referral referral) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Referral'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter rejection reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = 'Rejected';
              try {
                await ReferralService.instance.rejectReferral(referral.id, reason);
                _loadReferrals();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Referral rejected')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showTransportStatusDialog(Referral referral) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Transport Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('In Transit'),
              onTap: () async {
                try {
                  await ReferralService.instance.updateTransportStatus(
                    referral.id,
                    'in_transit',
                  );
                  _loadReferrals();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Status updated to In Transit')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              title: const Text('Arrived'),
              onTap: () async {
                try {
                  await ReferralService.instance.updateTransportStatus(
                    referral.id,
                    'arrived',
                  );
                  _loadReferrals();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Status updated to Arrived')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
