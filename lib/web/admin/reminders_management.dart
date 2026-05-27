import 'package:flutter/material.dart';
import '../../state/reminders_store.dart';
import '../shared/widgets/reminder_card.dart';

class RemindersManagementScreen extends StatefulWidget {
  const RemindersManagementScreen({Key? key}) : super(key: key);

  @override
  State<RemindersManagementScreen> createState() => _RemindersManagementScreenState();
}

class _RemindersManagementScreenState extends State<RemindersManagementScreen> {
  final store = RemindersStore.instance;
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () => setState(() {});
    store.addListener(_listener);
    _loadData();
  }

  @override
  void dispose() {
    store.removeListener(_listener);
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!store.loaded) {
      await store.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders Management'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateReminderDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create Reminder'),
      ),
      body: store.loading
          ? const Center(child: CircularProgressIndicator())
          : store.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${store.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          store.reload();
                          _loadData();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary cards
                        Row(
                          children: [
                            _buildStatCard('Total', store.totalCount.toString(), Colors.blue),
                            const SizedBox(width: 12),
                            _buildStatCard('Pending', store.pendingCount.toString(), Colors.orange),
                            const SizedBox(width: 12),
                            _buildStatCard('Sent', store.sentCount.toString(), Colors.green),
                            const SizedBox(width: 12),
                            _buildStatCard('Failed', store.failedCount.toString(), Colors.red),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Filters
                        _buildFilters(),
                        const SizedBox(height: 24),
                        // Results
                        Text(
                          'Reminders (${store.reminders.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (store.reminders.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('No reminders found'),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: store.reminders.length,
                            itemBuilder: (context, index) {
                              final reminder = store.reminders[index];
                              return ReminderCard(
                                reminder: reminder,
                                onAcknowledge: () => _acknowledgeReminder(reminder),
                                onCancel: () => _cancelReminder(reminder),
                                onDelete: () => _deleteReminder(reminder),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (store.selectedStatus != null || store.selectedType != null)
                TextButton(
                  onPressed: () {
                    store.clearFilters();
                    setState(() {});
                  },
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFilterDropdown(
                label: 'Status',
                value: store.selectedStatus?.toString().split('.').last,
                items: ['pending', 'sent', 'failed', 'cancelled'],
                onChanged: (value) {
                  if (value == null) {
                    store.setStatusFilter(null);
                  } else {
                    final status = ReminderStatus.values.firstWhere(
                      (s) => s.toString().split('.').last == value,
                    );
                    store.setStatusFilter(status);
                  }
                  setState(() {});
                },
              ),
              _buildFilterDropdown(
                label: 'Type',
                value: store.selectedType?.toString().split('.').last,
                items: ['appointment', 'ironTablet', 'ancVisit', 'vaccine', 'prenatalCheckup', 'neonatalCheckup', 'custom'],
                onChanged: (value) {
                  if (value == null) {
                    store.setTypeFilter(null);
                  } else {
                    final type = ReminderType.values.firstWhere(
                      (t) => t.toString().split('.').last == value,
                    );
                    store.setTypeFilter(type);
                  }
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text('All $label'),
          ),
          ...items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          )),
        ],
        onChanged: onChanged,
      ),
    );
  }

  void _acknowledgeReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Acknowledge Reminder'),
        content: Text('Mark "${reminder.title}" as acknowledged?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await store.acknowledgeReminder(reminder.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder acknowledged')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Acknowledge'),
          ),
        ],
      ),
    );
  }

  void _cancelReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Reminder'),
        content: Text('Cancel reminder "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await store.cancelReminder(reminder.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder cancelled')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Cancel Reminder'),
          ),
        ],
      ),
    );
  }

  void _deleteReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Delete reminder "${reminder.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await store.deleteReminder(reminder.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder deleted')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateReminderDialog() {
    final _formKey = GlobalKey<FormState>();
    String _title = '';
    String _body = '';
    ReminderType _type = ReminderType.custom;
    ReminderFrequency _frequency = ReminderFrequency.once;
    DateTime _scheduledFor = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Create Reminder'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    onSaved: (v) => _title = v!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Body'),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    onSaved: (v) => _body = v!,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ReminderType>(
                    decoration: const InputDecoration(labelText: 'Type'),
                    value: _type,
                    items: ReminderType.values
                        .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.toString().split('.').last),
                        ))
                        .toList(),
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ReminderFrequency>(
                    decoration: const InputDecoration(labelText: 'Frequency'),
                    value: _frequency,
                    items: ReminderFrequency.values
                        .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f.toString().split('.').last),
                        ))
                        .toList(),
                    onChanged: (v) => setState(() => _frequency = v!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Scheduled For'),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _scheduledFor.toString().split('.')[0],
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: _scheduledFor,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _scheduledFor = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pop(ctx);

                  try {
                    await store.createReminder(
                      title: _title,
                      body: _body,
                      type: _type,
                      frequency: _frequency,
                      scheduledFor: _scheduledFor,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reminder created successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
