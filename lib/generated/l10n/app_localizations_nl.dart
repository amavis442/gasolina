// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get navEntries => 'Tankbeurten';

  @override
  String get navPrice => 'Prijs';

  @override
  String get navEfficiency => 'Efficiëntie';

  @override
  String get screenFuelEntries => 'Tankbeurten';

  @override
  String get screenPriceChart => 'Prijs per Liter Grafiek';

  @override
  String get screenEfficiencyChart => 'Efficiëntie Grafiek';

  @override
  String get screenAddEntry => 'Tankbeurt Toevoegen';

  @override
  String get screenEditEntry => 'Tankbeurt Bewerken';

  @override
  String get labelDate => 'Datum';

  @override
  String get labelLiters => 'Liters';

  @override
  String get labelKilometers => 'Kilometers';

  @override
  String get labelTotalCost => 'Totale Kosten (€)';

  @override
  String get hintLiters => 'Voer liters in';

  @override
  String get hintKilometers => 'Voer gereden kilometers in';

  @override
  String get hintTotalCost => 'Voer totale kosten in';

  @override
  String get btnAddEntry => 'Toevoegen';

  @override
  String get btnUpdateEntry => 'Bijwerken';

  @override
  String get btnDelete => 'Verwijderen';

  @override
  String get btnCancel => 'Annuleren';

  @override
  String get btnRetry => 'Opnieuw';

  @override
  String get validationDateRequired => 'Selecteer een datum';

  @override
  String get validationDateFuture => 'Datum mag niet in de toekomst liggen';

  @override
  String get validationLitersRequired => 'Liters moet groter zijn dan 0';

  @override
  String validationLitersMax(double max) {
    return 'Liters mag niet meer dan $max zijn';
  }

  @override
  String get validationKilometersRequired =>
      'Kilometers moet groter zijn dan 0';

  @override
  String validationKilometersMax(double max) {
    return 'Kilometers mag niet meer dan $max zijn';
  }

  @override
  String get validationTotalCostRequired =>
      'Totale kosten moet groter zijn dan 0';

  @override
  String warningPriceSuspicious(String price) {
    return 'Prijs per liter lijkt verdacht (€$price/L)';
  }

  @override
  String warningEfficiencySuspicious(String efficiency) {
    return 'Efficiëntie lijkt verdacht ($efficiency km/L)';
  }

  @override
  String get dialogDeleteTitle => 'Tankbeurt Verwijderen';

  @override
  String get dialogDeleteMessage =>
      'Weet je zeker dat je deze tankbeurt wilt verwijderen? Deze actie kan niet ongedaan worden gemaakt.';

  @override
  String get emptyNoEntries => 'Nog geen tankbeurten';

  @override
  String get emptyNoEntriesHint =>
      'Tik op de + knop om je eerste tankbeurt toe te voegen';

  @override
  String get emptyNotEnoughData => 'Niet genoeg gegevens';

  @override
  String get emptyNotEnoughDataHint =>
      'Voeg ten minste 2 tankbeurten toe om de grafiek te zien';

  @override
  String get snackbarEntryAdded => 'Tankbeurt succesvol toegevoegd';

  @override
  String get snackbarEntryUpdated => 'Tankbeurt succesvol bijgewerkt';

  @override
  String get snackbarEntryDeleted => 'Tankbeurt verwijderd';

  @override
  String get cardLabelLiters => 'Liters';

  @override
  String get cardLabelDistance => 'Afstand';

  @override
  String get cardLabelTotalCost => 'Totale Kosten';

  @override
  String get cardLabelEfficiency => 'Efficiëntie';

  @override
  String cardLabelPricePerLiter(String price) {
    return 'Prijs/L: $price';
  }

  @override
  String get tooltipDeleteEntry => 'Tankbeurt verwijderen';

  @override
  String get chartLabelPricePerLiter => 'Prijs/Liter';

  @override
  String get chartLabelEfficiency => 'Efficiëntie';

  @override
  String get chartLabelDate => 'Datum';

  @override
  String get chartStatMin => 'Min';

  @override
  String get chartStatMax => 'Max';

  @override
  String get chartStatAvg => 'Gem';

  @override
  String get chartStatEntries => 'Tankbeurten';

  @override
  String errorGeneric(String error) {
    return 'Fout: $error';
  }
}
