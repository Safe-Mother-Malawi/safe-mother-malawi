import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class BroadcastMessagesScreen extends StatefulWidget {
  const BroadcastMessagesScreen({super.key});

  @override
  State<BroadcastMessagesScreen> createState() => _BroadcastMessagesScreenState();
}

class _BroadcastMessagesScreenState extends State<BroadcastMessagesScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _broadcasts = [];

  @override
  void initState() {
    super.initState();
    _fetchBroadcasts();
  }

  Future<void> _fetchBroadcasts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await ApiService.instance.get('/notifications/broadcasts?limit=100');
      if (mounted) {
        setState(() {
          _broadcasts = res['broadcasts'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = e.toString(); _isLoading = false; });
      }
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _CreateBroadcastDialog(),
    ).then((_) => _fetchBroadcasts());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Failed to load broadcasts', style: TextStyle(fontFamily: 'Roboto', fontSize: 16)),
            TextButton(onPressed: _fetchBroadcasts, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Broadcast Messages', 
                style: TextStyle(fontFamily: 'Public Sans', fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.headings)),
              ElevatedButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add_comment_rounded),
                label: const Text('New Broadcast'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceContainerHighest),
              ),
              child: _broadcasts.isEmpty
                  ? const Center(child: Text('No broadcasts found.', style: TextStyle(color: AppColors.mutedText)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _broadcasts.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final b = _broadcasts[index];
                        final title = b['title'] ?? 'No Title';
                        final body = b['body'] ?? '';
                        final type = b['type'] ?? 'info';
                        final status = b['status'] ?? 'pending';
                        final target = b['broadcastType'] ?? 'all';
                        final recipientCount = b['recipientCount'] ?? 0;
                        final deliveredCount = b['deliveredCount'] ?? 0;
                        
                        Color statusColor = AppColors.infoText;
                        if (status == 'sent') statusColor = AppColors.successText;
                        if (status == 'failed') statusColor = AppColors.criticalText;
                        
                        Color typeColor = AppColors.primary;
                        if (type == 'alert' || type == 'emergency') typeColor = AppColors.criticalText;
                        if (type == 'warning') typeColor = AppColors.warningText;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: typeColor.withOpacity(0.1),
                            child: Icon(Icons.campaign_rounded, color: typeColor),
                          ),
                          title: Row(
                            children: [
                              Text(title, style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.people_alt_rounded, size: 14, color: AppColors.mutedText),
                                  const SizedBox(width: 4),
                                  Text('Target: $target • Recipients: $recipientCount', style: TextStyle(fontSize: 12, color: AppColors.mutedText)),
                                  const SizedBox(width: 16),
                                  Icon(Icons.send_rounded, size: 14, color: AppColors.mutedText),
                                  const SizedBox(width: 4),
                                  Text('Delivered: $deliveredCount', style: TextStyle(fontSize: 12, color: AppColors.mutedText)),
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateBroadcastDialog extends StatefulWidget {
  const _CreateBroadcastDialog();

  @override
  State<_CreateBroadcastDialog> createState() => _CreateBroadcastDialogState();
}

class _CreateBroadcastDialogState extends State<_CreateBroadcastDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  
  String _type = 'info';
  String _targetType = 'all';
  String? _targetRole;
  List<String> _selectedDistricts = [];
  
  bool _inApp = true;
  bool _push = true;
  bool _sms = false;
  
  bool _isScheduling = false;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  
  bool _isSubmitting = false;
  bool _isLoadingData = false;
  
  // Hierarchical data
  List<String> _regions = [];
  String? _selectedRegion;
  List<String> _zones = [];
  String? _selectedZone;
  List<String> _districts = [];
  List<String> _availableDistricts = [];

  @override
  void initState() {
    super.initState();
    _loadHierarchicalData();
  }

  Future<void> _loadHierarchicalData() async {
    setState(() => _isLoadingData = true);
    try {
      final res = await ApiService.instance.get('/health-facilities/regions');
      if (mounted) {
        setState(() {
          _regions = List<String>.from(res['regions'] ?? []);
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _loadZones(String region) async {
    try {
      final res = await ApiService.instance.get('/health-facilities/zones?region=$region');
      if (mounted) {
        setState(() {
          _zones = List<String>.from(res['zones'] ?? []);
          _selectedZone = null;
          _districts = [];
        });
      }
    } catch (e) {
      debugPrint('Error loading zones: $e');
    }
  }

  Future<void> _loadDistricts(String region, String zone) async {
    try {
      final res = await ApiService.instance.get('/health-facilities/districts?region=$region&zone=$zone');
      if (mounted) {
        setState(() {
          _districts = List<String>.from(res['districts'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error loading districts: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final channels = <String>[];
      if (_inApp) channels.add('in-app');
      if (_push) channels.add('push');
      if (_sms) channels.add('sms');
      
      DateTime? scheduledAt;
      if (_isScheduling && _scheduledDate != null && _scheduledTime != null) {
        scheduledAt = DateTime(
          _scheduledDate!.year, _scheduledDate!.month, _scheduledDate!.day,
          _scheduledTime!.hour, _scheduledTime!.minute
        );
      }
      
      final payload = {
        'title': _titleCtrl.text,
        'body': _bodyCtrl.text,
        'type': _type,
        'broadcastType': _targetType,
        if (_targetRole != null && _targetType == 'role') 'targetRole': _targetRole,
        if (_selectedDistricts.isNotEmpty && _targetType == 'district') 'targetDistricts': _selectedDistricts,
        'deliveryChannels': channels,
        if (scheduledAt != null) 'scheduledAt': scheduledAt.toIso8601String(),
      };
      
      await ApiService.instance.post('/notifications/broadcasts', payload);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcast created successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Broadcast Message'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bodyCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Message Body', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Message Type', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'info', child: Text('Information')),
                    DropdownMenuItem(value: 'alert', child: Text('Alert')),
                    DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
                    DropdownMenuItem(value: 'reminder', child: Text('Reminder')),
                    DropdownMenuItem(value: 'system_update', child: Text('System Update')),
                  ],
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 16),
                const Text('Audience', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: _targetType,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Users')),
                    DropdownMenuItem(value: 'role', child: Text('Specific Role')),
                    DropdownMenuItem(value: 'district', child: Text('Specific District')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _targetType = v!;
                      if (v == 'role') _targetRole = 'prenatal';
                      if (v == 'district') {
                        _selectedDistricts = [];
                        _selectedRegion = null;
                        _selectedZone = null;
                        _zones = [];
                        _districts = [];
                      }
                    });
                  },
                ),
                if (_targetType == 'role') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _targetRole,
                    decoration: const InputDecoration(labelText: 'Select Role', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'prenatal', child: Text('Prenatal Mothers')),
                      DropdownMenuItem(value: 'neonatal', child: Text('Neonatal Mothers')),
                      DropdownMenuItem(value: 'mobile-users', child: Text('Mobile Users (All)')),
                      DropdownMenuItem(value: 'clinician', child: Text('Clinicians')),
                      DropdownMenuItem(value: 'dho', child: Text('DHOs')),
                      DropdownMenuItem(value: 'admin', child: Text('Administrators')),
                      DropdownMenuItem(value: 'all-staff', child: Text('All Staff')),
                    ],
                    onChanged: (v) => setState(() => _targetRole = v!),
                  ),
                ],
                if (_targetType == 'district') ...[
                  const SizedBox(height: 16),
                  const Text('Select Districts by Region → Zone → District', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(height: 12),
                  if (_isLoadingData)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (_regions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No regions available', style: TextStyle(color: Colors.red, fontSize: 12)),
                    )
                  else ...[
                    // Region dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedRegion,
                      decoration: const InputDecoration(labelText: 'Region', border: OutlineInputBorder()),
                      items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _selectedRegion = v;
                            _selectedZone = null;
                            _zones = [];
                            _districts = [];
                          });
                          _loadZones(v);
                        }
                      },
                      validator: _targetType == 'district' ? (v) => v == null ? 'Select region' : null : null,
                    ),
                    const SizedBox(height: 12),
                    // Zone dropdown
                    if (_selectedRegion != null)
                      DropdownButtonFormField<String>(
                        value: _selectedZone,
                        decoration: const InputDecoration(labelText: 'Zone', border: OutlineInputBorder()),
                        items: _zones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                        onChanged: (v) {
                          if (v != null && _selectedRegion != null) {
                            setState(() => _selectedZone = v);
                            _loadDistricts(_selectedRegion!, v);
                          }
                        },
                        validator: _targetType == 'district' ? (v) => v == null ? 'Select zone' : null : null,
                      ),
                    const SizedBox(height: 12),
                    // Districts multi-select
                    if (_selectedZone != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Districts (select one or more)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          if (_districts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('No districts available', style: TextStyle(color: Colors.red, fontSize: 12)),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(4)),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _districts.length,
                                itemBuilder: (context, index) {
                                  final district = _districts[index];
                                  final isSelected = _selectedDistricts.contains(district);
                                  return CheckboxListTile(
                                    value: isSelected,
                                    title: Text(district, style: const TextStyle(fontSize: 13)),
                                    onChanged: (v) {
                                      setState(() {
                                        if (v == true) {
                                          _selectedDistricts.add(district);
                                        } else {
                                          _selectedDistricts.remove(district);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          if (_selectedDistricts.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Wrap(
                                spacing: 8,
                                children: _selectedDistricts.map((d) => Chip(label: Text(d), onDeleted: () {
                                  setState(() => _selectedDistricts.remove(d));
                                })).toList(),
                              ),
                            ),
                        ],
                      ),
                  ],
                ],
                const SizedBox(height: 16),
                const Text('Delivery Channels', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Checkbox(value: _inApp, onChanged: (v) => setState(() => _inApp = v!)),
                    const Text('In-App'),
                    const SizedBox(width: 16),
                    Checkbox(value: _push, onChanged: (v) => setState(() => _push = v!)),
                    const Text('Push Notification'),
                    const SizedBox(width: 16),
                    Checkbox(value: _sms, onChanged: (v) => setState(() => _sms = v!)),
                    const Text('SMS'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(value: _isScheduling, onChanged: (v) => setState(() => _isScheduling = v!)),
                    const Text('Schedule for later'),
                  ],
                ),
                if (_isScheduling) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_scheduledDate != null ? '${_scheduledDate!.toLocal()}'.split(' ')[0] : 'Select Date'),
                          onPressed: () async {
                            final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                            if (d != null) setState(() => _scheduledDate = d);
                          },
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(_scheduledTime != null ? _scheduledTime!.format(context) : 'Select Time'),
                          onPressed: () async {
                            final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            if (t != null) setState(() => _scheduledTime = t);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          child: _isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Send / Schedule'),
        ),
      ],
    );
  }
}
