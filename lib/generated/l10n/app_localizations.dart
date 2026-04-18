import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl'),
  ];

  /// Bottom navigation label for fuel entries tab
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get navEntries;

  /// Bottom navigation label for price chart tab
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get navPrice;

  /// Bottom navigation label for efficiency chart tab
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get navEfficiency;

  /// Title for fuel entries list screen
  ///
  /// In en, this message translates to:
  /// **'Fuel Entries'**
  String get screenFuelEntries;

  /// Title for price chart screen
  ///
  /// In en, this message translates to:
  /// **'Price per Liter Chart'**
  String get screenPriceChart;

  /// Title for efficiency chart screen
  ///
  /// In en, this message translates to:
  /// **'Efficiency Chart'**
  String get screenEfficiencyChart;

  /// Title for add fuel entry form screen
  ///
  /// In en, this message translates to:
  /// **'Add Fuel Entry'**
  String get screenAddEntry;

  /// Title for edit fuel entry form screen
  ///
  /// In en, this message translates to:
  /// **'Edit Fuel Entry'**
  String get screenEditEntry;

  /// Label for date input field
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labelDate;

  /// Label for liters input field
  ///
  /// In en, this message translates to:
  /// **'Liters'**
  String get labelLiters;

  /// Label for kilometers input field
  ///
  /// In en, this message translates to:
  /// **'Kilometers'**
  String get labelKilometers;

  /// Label for total cost input field
  ///
  /// In en, this message translates to:
  /// **'Total Cost (€)'**
  String get labelTotalCost;

  /// Hint text for liters input field
  ///
  /// In en, this message translates to:
  /// **'Enter liters'**
  String get hintLiters;

  /// Hint text for kilometers input field
  ///
  /// In en, this message translates to:
  /// **'Enter kilometers driven'**
  String get hintKilometers;

  /// Hint text for total cost input field
  ///
  /// In en, this message translates to:
  /// **'Enter total cost'**
  String get hintTotalCost;

  /// Button label for adding a new fuel entry
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get btnAddEntry;

  /// Button label for updating existing fuel entry
  ///
  /// In en, this message translates to:
  /// **'Update Entry'**
  String get btnUpdateEntry;

  /// Button label for delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// Button label for cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// Button label for retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get btnRetry;

  /// Validation error when date is not selected
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get validationDateRequired;

  /// Validation error when selected date is in the future
  ///
  /// In en, this message translates to:
  /// **'Date cannot be in the future'**
  String get validationDateFuture;

  /// Validation error when liters value is invalid
  ///
  /// In en, this message translates to:
  /// **'Liters must be greater than 0'**
  String get validationLitersRequired;

  /// Validation error when liters exceed maximum
  ///
  /// In en, this message translates to:
  /// **'Liters cannot exceed {max}'**
  String validationLitersMax(double max);

  /// Validation error when kilometers value is invalid
  ///
  /// In en, this message translates to:
  /// **'Kilometers must be greater than 0'**
  String get validationKilometersRequired;

  /// Validation error when kilometers exceed maximum
  ///
  /// In en, this message translates to:
  /// **'Kilometers cannot exceed {max}'**
  String validationKilometersMax(double max);

  /// Validation error when total cost value is invalid
  ///
  /// In en, this message translates to:
  /// **'Total cost must be greater than 0'**
  String get validationTotalCostRequired;

  /// Warning when price per liter is outside normal range
  ///
  /// In en, this message translates to:
  /// **'Price per liter seems suspicious (€{price}/L)'**
  String warningPriceSuspicious(String price);

  /// Warning when efficiency is outside normal range
  ///
  /// In en, this message translates to:
  /// **'Efficiency seems suspicious ({efficiency} km/L)'**
  String warningEfficiencySuspicious(String efficiency);

  /// Title for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get dialogDeleteTitle;

  /// Message for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this fuel entry? This action cannot be undone.'**
  String get dialogDeleteMessage;

  /// Empty state message when no fuel entries exist
  ///
  /// In en, this message translates to:
  /// **'No fuel entries yet'**
  String get emptyNoEntries;

  /// Empty state hint for adding first entry
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first entry'**
  String get emptyNoEntriesHint;

  /// Empty state message when insufficient data for chart
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get emptyNotEnoughData;

  /// Empty state hint for chart minimum data requirement
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 fuel entries to see the chart'**
  String get emptyNotEnoughDataHint;

  /// Success message when fuel entry is added
  ///
  /// In en, this message translates to:
  /// **'Entry added successfully'**
  String get snackbarEntryAdded;

  /// Success message when fuel entry is updated
  ///
  /// In en, this message translates to:
  /// **'Entry updated successfully'**
  String get snackbarEntryUpdated;

  /// Success message when fuel entry is deleted
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get snackbarEntryDeleted;

  /// Card label for liters value
  ///
  /// In en, this message translates to:
  /// **'Liters'**
  String get cardLabelLiters;

  /// Card label for distance/kilometers value
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get cardLabelDistance;

  /// Card label for total cost value
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get cardLabelTotalCost;

  /// Card label for efficiency value
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get cardLabelEfficiency;

  /// Card label for price per liter
  ///
  /// In en, this message translates to:
  /// **'Price/L: {price}'**
  String cardLabelPricePerLiter(String price);

  /// Tooltip for delete entry button
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get tooltipDeleteEntry;

  /// Chart axis label for price per liter
  ///
  /// In en, this message translates to:
  /// **'Price/Liter'**
  String get chartLabelPricePerLiter;

  /// Chart axis label for efficiency
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get chartLabelEfficiency;

  /// Chart axis label for date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get chartLabelDate;

  /// Chart statistics label for minimum value
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get chartStatMin;

  /// Chart statistics label for maximum value
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get chartStatMax;

  /// Chart statistics label for average value
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get chartStatAvg;

  /// Chart statistics label for number of entries
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get chartStatEntries;

  /// Generic error message template
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
