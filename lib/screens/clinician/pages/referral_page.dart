import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../services/referral_service.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_colors.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({Key? key}) : super(key: key);

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  late Future<List<Referral>> _referralsFuture;
  String _filterStatus = 'all';
  IO.Socket? _socket;
  List<Referral> _referrals = [];

  @override
  void initState() {
    super.initState();
    _loadReferrals();
    _initializeWebSocket();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }

  void _initializeWebSocket() {
    try {
      _socket = IO.io(
        ApiService.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      _socket?.on('referral:created', (data) {
        debugPrint('📨 Referral created: $data');
        _loadReferrals();
      });

      _socket?.on('referral:updated', (data) {
        debugPrint('📨 Referral updated: $data');
        _loadReferrals();
      });

      _socket?.on('referral:accepted', (data) {
        debugPrint('✅ Referral accepted: $data');
        _loadReferrals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Referral accepted: ${data['referralCode']}')),
          );
        }
      });

      _socket?.on('referral:rejected', (data) {
        debugPrint('❌ Referral rejected: $data');
        _loadReferrals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Referral rejected: ${data['referralCode']}')),
          );
        }
      });

      _socket?.on('referral:completed', (data) {
        debugPrint('🏁 Referral completed: $data');
        _loadReferrals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Referral completed: ${data['referralCode']}')),
          );
        }
      });

      _socket?.connect();
    } catch (e) {
      debugPrint('⚠️ WebSocket connection error: $e');
    }
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const _CreateReferralDialog(),
                    ).then((_) => _loadReferrals());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Referral'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                  ),
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
              // Header row with patient name and status
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
              
              // Reason and urgency
              Text(
                'Reason: ${referral.reason}',
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (referral.urgencyNotes != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Urgency: ${referral.urgencyNotes}',
                  style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                ),
              ],
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
              
              // Transport info if available
              if (referral.transportMode != null) ...[
                Text(
                  'Transport: ${referral.transportMode}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
              ],
              
              // Rejection reason if rejected
              if (referral.rejectionReason != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Rejection: ${referral.rejectionReason}',
                    style: TextStyle(fontSize: 12, color: AppColors.red),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Treatment outcome if completed
              if (referral.treatmentOutcome != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Outcome: ${referral.treatmentOutcome}',
                    style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
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
              // Patient Information
              _buildSectionHeader('Patient Information'),
              _buildDetailRow('Name:', referral.patientName),
              if (referral.patientContact != null)
                _buildDetailRow('Contact:', referral.patientContact!),
              if (referral.patientAge != null)
                _buildDetailRow('Age:', referral.patientAge!),
              const SizedBox(height: 12),
              
              // Referral Details
              _buildSectionHeader('Referral Details'),
              _buildDetailRow('Status:', _getStatusLabel(referral.status)),
              _buildDetailRow('Reason:', referral.reason),
              _buildDetailRow('Clinical Summary:', referral.clinicalSummary),
              if (referral.urgencyNotes != null)
                _buildDetailRow('Urgency Notes:', referral.urgencyNotes!),
              const SizedBox(height: 12),
              
              // Facilities
              _buildSectionHeader('Facilities'),
              _buildDetailRow(
                'Referring Facility:',
                referral.referringFacility?['facilityName'] ?? 'Unknown',
              ),
              _buildDetailRow(
                'Receiving Facility:',
                referral.receivingFacility?['facilityName'] ?? 'Unknown',
              ),
              const SizedBox(height: 12),
              
              // Clinicians
              _buildSectionHeader('Clinicians'),
              if (referral.referringClinician != null)
                _buildDetailRow(
                  'Referring Clinician:',
                  referral.referringClinician?['fullName'] ?? 'Unknown',
                ),
              if (referral.receivingClinician != null)
                _buildDetailRow(
                  'Receiving Clinician:',
                  referral.receivingClinician?['fullName'] ?? 'Unknown',
                ),
              const SizedBox(height: 12),
              
              // Transport Information
              if (referral.transportMode != null) ...[
                _buildSectionHeader('Transport'),
                _buildDetailRow('Mode:', referral.transportMode!),
                if (referral.transportProvider != null)
                  _buildDetailRow('Provider:', referral.transportProvider!),
                if (referral.transportContact != null)
                  _buildDetailRow('Contact:', referral.transportContact!),
                if (referral.departureTime != null)
                  _buildDetailRow('Departure:', _formatDate(referral.departureTime!)),
                if (referral.arrivalTime != null)
                  _buildDetailRow('Arrival:', _formatDate(referral.arrivalTime!)),
                if (referral.transportNotes != null)
                  _buildDetailRow('Notes:', referral.transportNotes!),
                const SizedBox(height: 12),
              ],
              
              // Acceptance/Rejection
              if (referral.acceptedAt != null || referral.rejectedAt != null) ...[
                _buildSectionHeader('Response'),
                if (referral.acceptedAt != null)
                  _buildDetailRow('Accepted At:', _formatDate(referral.acceptedAt!)),
                if (referral.rejectionReason != null)
                  _buildDetailRow('Rejection Reason:', referral.rejectionReason!),
                if (referral.rejectedAt != null)
                  _buildDetailRow('Rejected At:', _formatDate(referral.rejectedAt!)),
                const SizedBox(height: 12),
              ],
              
              // Outcome
              if (referral.treatmentOutcome != null || referral.completedAt != null) ...[
                _buildSectionHeader('Outcome'),
                if (referral.treatmentOutcome != null)
                  _buildDetailRow('Treatment Outcome:', referral.treatmentOutcome!),
                if (referral.completedAt != null)
                  _buildDetailRow('Completed At:', _formatDate(referral.completedAt!)),
              ],
              
              // Timestamps
              const SizedBox(height: 12),
              _buildSectionHeader('Timestamps'),
              _buildDetailRow('Created:', _formatDate(referral.createdAt)),
              if (referral.updatedAt != null)
                _buildDetailRow('Updated:', _formatDate(referral.updatedAt!)),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppColors.navy,
        ),
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


/// Create Referral Dialog
class _CreateReferralDialog extends StatefulWidget {
  const _CreateReferralDialog({Key? key}) : super(key: key);

  @override
  State<_CreateReferralDialog> createState() => _CreateReferralDialogState();
}

class _CreateReferralDialogState extends State<_CreateReferralDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _patientNameController;
  late TextEditingController _patientContactController;
  late TextEditingController _patientAgeController;
  late TextEditingController _clinicalSummaryController;
  late TextEditingController _urgencyNotesController;

  String? _selectedReason;
  String? _selectedReferringFacility;
  String? _selectedReceivingFacility;
  String? _selectedTransportMode;
  
  List<Map<String, dynamic>> _facilities = [];
  bool _loadingFacilities = true;

  final List<String> _referralReasons = [
    'Hypertension',
    'Bleeding',
    'Infection',
    'Fetal Distress',
    'Premature Labor',
    'Placental Issues',
    'Neonatal Emergency',
    'Neonatal Infection',
    'Low Birth Weight',
    'Respiratory Distress',
    'Jaundice',
    'Other',
  ];

  final List<String> _transportModes = [
    'Ambulance',
    'Personal Vehicle',
    'Motorcycle',
    'Walking',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _patientNameController = TextEditingController();
    _patientContactController = TextEditingController();
    _patientAgeController = TextEditingController();
    _clinicalSummaryController = TextEditingController();
    _urgencyNotesController = TextEditingController();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    try {
      final facilities = await ApiService.instance.get('/health-facilities');
      if (facilities is List) {
        setState(() {
          _facilities = facilities.cast<Map<String, dynamic>>();
          _loadingFacilities = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading facilities: $e');
      setState(() => _loadingFacilities = false);
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientContactController.dispose();
    _patientAgeController.dispose();
    _clinicalSummaryController.dispose();
    _urgencyNotesController.dispose();
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
              // Patient Information
              Text('Patient Information', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _patientContactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _patientAgeController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Referral Details
              Text('Referral Details', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                decoration: const InputDecoration(
                  labelText: 'Reason for Referral *',
                  border: OutlineInputBorder(),
                ),
                items: _referralReasons.map((reason) {
                  return DropdownMenuItem(value: reason, child: Text(reason));
                }).toList(),
                onChanged: (value) => setState(() => _selectedReason = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clinicalSummaryController,
                decoration: const InputDecoration(
                  labelText: 'Clinical Summary *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _urgencyNotesController,
                decoration: const InputDecoration(
                  labelText: 'Urgency Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Facilities
              Text('Facilities', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
              const SizedBox(height: 12),
              _loadingFacilities
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _selectedReferringFacility,
                      decoration: const InputDecoration(
                        labelText: 'Referring Facility *',
                        border: OutlineInputBorder(),
                      ),
                      items: _facilities.map<DropdownMenuItem<String>>((facility) {
                        return DropdownMenuItem<String>(
                          value: facility['id'] as String,
                          child: Text(facility['facilityName'] as String? ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedReferringFacility = value),
                      validator: (value) => value == null ? 'Required' : null,
                    ),
              const SizedBox(height: 12),
              _loadingFacilities
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _selectedReceivingFacility,
                      decoration: const InputDecoration(
                        labelText: 'Receiving Facility *',
                        border: OutlineInputBorder(),
                      ),
                      items: _facilities.map<DropdownMenuItem<String>>((facility) {
                        return DropdownMenuItem<String>(
                          value: facility['id'] as String,
                          child: Text(facility['facilityName'] as String? ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedReceivingFacility = value),
                      validator: (value) => value == null ? 'Required' : null,
                    ),
              const SizedBox(height: 16),
              
              // Transport
              Text('Transport', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedTransportMode,
                decoration: const InputDecoration(
                  labelText: 'Transport Mode',
                  border: OutlineInputBorder(),
                ),
                items: _transportModes.map((mode) {
                  return DropdownMenuItem(value: mode, child: Text(mode));
                }).toList(),
                onChanged: (value) => setState(() => _selectedTransportMode = value),
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
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
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
        patientContact: _patientContactController.text.isEmpty ? null : _patientContactController.text,
        patientAge: _patientAgeController.text.isEmpty ? null : _patientAgeController.text,
        reason: _selectedReason ?? '',
        clinicalSummary: _clinicalSummaryController.text,
        urgencyNotes: _urgencyNotesController.text.isEmpty ? null : _urgencyNotesController.text,
        referringFacilityId: _selectedReferringFacility ?? '',
        receivingFacilityId: _selectedReceivingFacility ?? '',
        transportMode: _selectedTransportMode?.toLowerCase().replaceAll(' ', '_'),
      );

      await ReferralService.instance.createReferral(request);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Referral created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    }
  }
}
