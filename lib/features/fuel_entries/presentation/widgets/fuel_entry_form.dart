// ABOUTME: Form widget for creating and editing fuel entries with validation
// ABOUTME: Handles date selection, numeric inputs, and suspicious value warnings

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/fuel_entry.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class FuelEntryForm extends StatefulWidget {
  final FuelEntry? entry;
  final Function(FuelEntry) onSubmit;

  const FuelEntryForm({
    super.key,
    this.entry,
    required this.onSubmit,
  });

  @override
  State<FuelEntryForm> createState() => _FuelEntryFormState();
}

class _FuelEntryFormState extends State<FuelEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _litersController;
  late final TextEditingController _kilometersController;
  late final TextEditingController _totalCostController;

  DateTime _selectedDate = DateTime.now();
  String? _priceWarning;
  String? _efficiencyWarning;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: DateFormat('MMM dd, yyyy').format(widget.entry?.date ?? DateTime.now()),
    );
    _litersController = TextEditingController(
      text: widget.entry?.liters.toString() ?? '',
    );
    _kilometersController = TextEditingController(
      text: widget.entry?.kilometers.toString() ?? '',
    );
    _totalCostController = TextEditingController(
      text: widget.entry?.totalCost.toString() ?? '',
    );

    if (widget.entry != null) {
      _selectedDate = widget.entry!.date;
    }

    _litersController.addListener(_checkSuspiciousValues);
    _kilometersController.addListener(_checkSuspiciousValues);
    _totalCostController.addListener(_checkSuspiciousValues);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _litersController.dispose();
    _kilometersController.dispose();
    _totalCostController.dispose();
    super.dispose();
  }

  void _checkSuspiciousValues() {
    final liters = double.tryParse(_litersController.text);
    final kilometers = double.tryParse(_kilometersController.text);
    final totalCost = double.tryParse(_totalCostController.text);

    if (liters != null && totalCost != null && liters > 0) {
      final pricePerLiter = totalCost / liters;
      final isValid = PricePerLiterValidator.validate(pricePerLiter) == null;
      setState(() {
        _priceWarning = isValid ? null : pricePerLiter.toStringAsFixed(2);
      });
    } else {
      setState(() {
        _priceWarning = null;
      });
    }

    if (liters != null && kilometers != null && liters > 0) {
      final efficiency = kilometers / liters;
      final isValid = EfficiencyValidator.validate(efficiency) == null;
      setState(() {
        _efficiencyWarning = isValid ? null : efficiency.toStringAsFixed(1);
      });
    } else {
      setState(() {
        _efficiencyWarning = null;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);

    if (_formKey.currentState!.validate()) {
      final dateValidation = DateValidator.validate(_selectedDate);
      if (dateValidation != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.validationDateFuture)),
        );
        return;
      }

      final entry = FuelEntry(
        id: widget.entry?.id ?? const Uuid().v4(),
        date: _selectedDate,
        liters: double.parse(_litersController.text),
        kilometers: double.parse(_kilometersController.text),
        totalCost: double.parse(_totalCostController.text),
      );

      widget.onSubmit(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CustomTextField(
            label: l10n.labelDate,
            controller: _dateController,
            readOnly: true,
            onTap: _selectDate,
            suffixIcon: const Icon(Icons.calendar_today),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.validationDateRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: l10n.labelLiters,
            hintText: l10n.hintLiters,
            controller: _litersController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              final parsed = double.tryParse(value ?? '');
              if (parsed == null || parsed <= 0) {
                return l10n.validationLitersRequired;
              }
              if (parsed > LitersValidator.maxLiters) {
                return l10n.validationLitersMax(LitersValidator.maxLiters);
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: l10n.labelKilometers,
            hintText: l10n.hintKilometers,
            controller: _kilometersController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            validator: (value) {
              final parsed = double.tryParse(value ?? '');
              if (parsed == null || parsed <= 0) {
                return l10n.validationKilometersRequired;
              }
              if (parsed > KilometersValidator.maxKilometers) {
                return l10n.validationKilometersMax(KilometersValidator.maxKilometers);
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: l10n.labelTotalCost,
            hintText: l10n.hintTotalCost,
            controller: _totalCostController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              final parsed = double.tryParse(value ?? '');
              if (parsed == null || parsed <= 0) {
                return l10n.validationTotalCostRequired;
              }
              return null;
            },
          ),
          if (_priceWarning != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.warningPriceSuspicious(_priceWarning!),
                      style: TextStyle(color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_efficiencyWarning != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.warningEfficiencySuspicious(_efficiencyWarning!),
                      style: TextStyle(color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              widget.entry == null ? l10n.btnAddEntry : l10n.btnUpdateEntry,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
