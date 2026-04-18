// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navEntries => 'Entries';

  @override
  String get navPrice => 'Price';

  @override
  String get navEfficiency => 'Efficiency';

  @override
  String get screenFuelEntries => 'Fuel Entries';

  @override
  String get screenPriceChart => 'Price per Liter Chart';

  @override
  String get screenEfficiencyChart => 'Efficiency Chart';

  @override
  String get screenAddEntry => 'Add Fuel Entry';

  @override
  String get screenEditEntry => 'Edit Fuel Entry';

  @override
  String get labelDate => 'Date';

  @override
  String get labelLiters => 'Liters';

  @override
  String get labelKilometers => 'Kilometers';

  @override
  String get labelTotalCost => 'Total Cost (€)';

  @override
  String get hintLiters => 'Enter liters';

  @override
  String get hintKilometers => 'Enter kilometers driven';

  @override
  String get hintTotalCost => 'Enter total cost';

  @override
  String get btnAddEntry => 'Add Entry';

  @override
  String get btnUpdateEntry => 'Update Entry';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnRetry => 'Retry';

  @override
  String get validationDateRequired => 'Please select a date';

  @override
  String get validationDateFuture => 'Date cannot be in the future';

  @override
  String get validationLitersRequired => 'Liters must be greater than 0';

  @override
  String validationLitersMax(double max) {
    return 'Liters cannot exceed $max';
  }

  @override
  String get validationKilometersRequired =>
      'Kilometers must be greater than 0';

  @override
  String validationKilometersMax(double max) {
    return 'Kilometers cannot exceed $max';
  }

  @override
  String get validationTotalCostRequired => 'Total cost must be greater than 0';

  @override
  String warningPriceSuspicious(String price) {
    return 'Price per liter seems suspicious (€$price/L)';
  }

  @override
  String warningEfficiencySuspicious(String efficiency) {
    return 'Efficiency seems suspicious ($efficiency km/L)';
  }

  @override
  String get dialogDeleteTitle => 'Delete Entry';

  @override
  String get dialogDeleteMessage =>
      'Are you sure you want to delete this fuel entry? This action cannot be undone.';

  @override
  String get emptyNoEntries => 'No fuel entries yet';

  @override
  String get emptyNoEntriesHint => 'Tap the + button to add your first entry';

  @override
  String get emptyNotEnoughData => 'Not enough data';

  @override
  String get emptyNotEnoughDataHint =>
      'Add at least 2 fuel entries to see the chart';

  @override
  String get snackbarEntryAdded => 'Entry added successfully';

  @override
  String get snackbarEntryUpdated => 'Entry updated successfully';

  @override
  String get snackbarEntryDeleted => 'Entry deleted';

  @override
  String get cardLabelLiters => 'Liters';

  @override
  String get cardLabelDistance => 'Distance';

  @override
  String get cardLabelTotalCost => 'Total Cost';

  @override
  String get cardLabelEfficiency => 'Efficiency';

  @override
  String cardLabelPricePerLiter(String price) {
    return 'Price/L: $price';
  }

  @override
  String get tooltipDeleteEntry => 'Delete entry';

  @override
  String get chartLabelPricePerLiter => 'Price/Liter';

  @override
  String get chartLabelEfficiency => 'Efficiency';

  @override
  String get chartLabelDate => 'Date';

  @override
  String get chartStatMin => 'Min';

  @override
  String get chartStatMax => 'Max';

  @override
  String get chartStatAvg => 'Avg';

  @override
  String get chartStatEntries => 'Entries';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }
}
