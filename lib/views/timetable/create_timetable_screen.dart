import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_widgets.dart';
import './timetable_controller.dart';

class CreateTimetableScreen extends StatefulWidget {
  const CreateTimetableScreen({super.key});
  @override
  State<CreateTimetableScreen> createState() => _CreateTimetableScreenState();
}

class _CreateTimetableScreenState extends State<CreateTimetableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Tournament 2026');
  final _matchesPerDayCtrl = TextEditingController(text: '2');
  final _ttCtrl = Get.find<TimetableController>();

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(days: 30));
  bool _useGroups = false;
  int _numGroups = 4;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _matchesPerDayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Timetable')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Tournament Name',
                controller: _nameCtrl,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Date range
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'From Date',
                      readOnly: true,
                      controller: TextEditingController(text: DateFormat('dd/MM/yyyy').format(_fromDate)),
                      suffix: const Icon(Icons.calendar_today_outlined, size: 18),
                      onTap: () => _pickDate(isFrom: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'To Date',
                      readOnly: true,
                      controller: TextEditingController(text: DateFormat('dd/MM/yyyy').format(_toDate)),
                      suffix: const Icon(Icons.calendar_today_outlined, size: 18),
                      onTap: () => _pickDate(isFrom: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Matches Per Day',
                hint: '2',
                controller: _matchesPerDayCtrl,
                keyboardType: TextInputType.number,
                // inputFormatters: [
                //   FilteringTextInputFormatter.digitsOnly
                // ],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 6) {
                    return 'Enter 1-6';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Groups toggle
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Use Group Stage', style: theme.textTheme.titleSmall),
                              Text(
                                'Divide teams into groups (A, B, C...)',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _useGroups,
                          onChanged: (v) => setState(() => _useGroups = v),
                          activeColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    if (_useGroups) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Number of Groups:'),
                          const SizedBox(width: 16),
                          ...([2, 4, 8].map((n) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text('$n'),
                                  selected: _numGroups == n,
                                  onSelected: (_) => setState(() => _numGroups = n),
                                ),
                              ))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A PDF will be auto-generated and shared after creation. All players will be notified.',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Obx(() => AppButton(
                    label: 'Generate Timetable',
                    icon: Icons.auto_awesome,
                    width: double.infinity,
                    isLoading: _ttCtrl.isLoading.value,
                    onTap: _submit,
                  )),

              Obx(() {
                if (_ttCtrl.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _ttCtrl.errorMessage.value,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) {
          _toDate = _fromDate.add(const Duration(days: 30));
        }
      } else {
        _toDate = picked;
      }
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _ttCtrl.generateTimetable(
        name: _nameCtrl.text.trim(),
        fromDate: _fromDate,
        toDate: _toDate,
        matchesPerDay: int.parse(_matchesPerDayCtrl.text),
        useGroups: _useGroups,
        numGroups: _numGroups,
      );
    }
  }
}
