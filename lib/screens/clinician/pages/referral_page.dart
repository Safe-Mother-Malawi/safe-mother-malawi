import 'package:flutter/material.dart';
import '../../../services/referral_service.dart';
import '../../../config/responsive_helper.dart';

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
        return Colors.blue;
      case 'rejected':
        return Colors.red;
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
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals'),
        elevation: 0,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
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
          // Referrals list
          Expanded(
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
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadReferrals,
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: referrals.length,
                  itemBuilder: (context, index) {
                    final referral = referrals[index];
                    return _buildReferralCard(referral, isMobile, isTablet);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateReferralDialog(context),
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add),
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
      selectedColor: const Color(0xFF1976D2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildReferralCard(Referral referral, bool isMobile, bool isTablet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showReferralDetails(referral),
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
                          child: const Text('Reject', style: TextStyle(color: Colors.red)),
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
                            backgroundColor: Colors.blue,
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

  void _showCreateReferralDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CreateReferralDialog(),
    ).then((_) => _loadReferrals());
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
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter rejection reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {},
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = 'Rejected'; // In real app, get from TextField
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

class _CreateReferralDialog extends StatefulWidget {
  const _CreateReferralDialog({Key? key}) : super(key: key);

  @override
  State<_CreateReferralDialog> createState() => _CreateReferralDialogState();
}

class _CreateReferralDialogState extends State<_CreateReferralDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _patientNameController;
  late TextEditingController _reasonController;
  late TextEditingController _clinicalSummaryController;
  late TextEditingController _referringFacilityController;
  late TextEditingController _receivingFacilityController;

  @override
  void initState() {
    super.initState();
    _patientNameController = TextEditingController();
    _reasonController = TextEditingController();
    _clinicalSummaryController = TextEditingController();
    _referringFacilityController = TextEditingController();
    _receivingFacilityController = TextEditingController();
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _reasonController.dispose();
    _clinicalSummaryController.dispose();
    _referringFacilityController.dispose();
    _receivingFacilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Referral'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Referral',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clinicalSummaryController,
                decoration: const InputDecoration(
                  labelText: 'Clinical Summary',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referringFacilityController,
                decoration: const InputDecoration(
                  labelText: 'Referring Facility ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _receivingFacilityController,
                decoration: const InputDecoration(
                  labelText: 'Receiving Facility ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final request = CreateReferralRequest(
        patientName: _patientNameController.text,
        reason: _reasonController.text,
        clinicalSummary: _clinicalSummaryController.text,
        referringFacilityId: _referringFacilityController.text,
        receivingFacilityId: _receivingFacilityController.text,
      );

      await ReferralService.instance.createReferral(request);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Referral created successfully')),
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
}
