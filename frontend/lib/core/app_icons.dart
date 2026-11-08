import 'package:flutter/material.dart';

/// NutriView single source of truth for iconography.
///
/// ## The NutriView icon standard
///
/// 1. **One family:** Material Icons **Rounded** only. Every value below is
///    declared as `Icons.<name>_rounded`, so the plain, `_outlined` and
///    `_sharp` variants can never reach a screen by accident.
///    `test/design_system_standards_test.dart` fails the build if a raw
///    `Icons.*` reference appears anywhere in `lib/` outside this file, or if
///    a value here is not written in the `_rounded` family.
/// 2. **One style language:**
///    * outline glyphs (`*_outline_rounded`) = information, status, guidance
///      and form-field identity (info, error, lock, mail, person).
///    * filled glyphs (`*_rounded`) = actions, navigation, content and data.
/// 3. **Sizes come from a role token** ([sizeMicro] … [sizeBrand]), never a
///    number invented per page. Screens reference `AppIcons.sizeX`.
/// 4. No Cupertino icons, no custom icon fonts, no emoji.
///
/// Import this file instead of `package:flutter/material.dart` icon constants
/// whenever a widget needs an icon.
class AppIcons {
  AppIcons._();

  // ---------------------------------------------------------------------------
  // Icon size tokens — pick by ROLE, not per page.
  // ---------------------------------------------------------------------------
  /// Inline micro glyph sitting next to 11–12px meta text.
  static const double sizeMicro = 12;

  /// Compact glyph next to 13–14px captions, bylines and timestamps.
  static const double sizeSmall = 14;

  /// Glyph inside cards, list rows and secondary content.
  static const double sizeMedium = 16;

  /// Leading glyph for section leads and segmented/tab labels.
  static const double sizeLarge = 18;

  /// Standard interactive size: form field icons, nav items, icon buttons.
  static const double sizeControl = 20;

  /// Toolbar / app-bar action glyph.
  static const double sizeToolbar = 22;

  /// Header control and dialog glyph.
  static const double sizeHeader = 24;

  /// Empty state, status panel and confirmation glyph.
  static const double sizeState = 28;

  /// Larger empty state inside a panel.
  static const double sizeStateLarge = 32;

  /// Full empty-state icon block.
  static const double sizeEmpty = 36;

  /// Feature block / large brand glyph.
  static const double sizeFeature = 40;

  /// Hero badge, success lockup and empty-state lockup glyph.
  static const double sizeBrand = 44;

  /// Oversized decorative illustration glyph (scan CTA centrepiece).
  static const double sizeIllustration = 110;

  // ---------------------------------------------------------------------------
  // Navigation & app chrome
  // ---------------------------------------------------------------------------
  static const IconData arrowBack = Icons.arrow_back_rounded;
  static const IconData arrowForward = Icons.arrow_forward_rounded;
  static const IconData arrowForwardIos = Icons.arrow_forward_ios_rounded;
  static const IconData arrowDropDown = Icons.arrow_drop_down_rounded;
  static const IconData chevronLeft = Icons.chevron_left_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData clear = Icons.clear_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData gridView = Icons.grid_view_rounded;
  static const IconData dashboard = Icons.dashboard_rounded;
  static const IconData login = Icons.login_rounded;
  static const IconData logout = Icons.logout_rounded;
  static const IconData menu = Icons.menu_rounded;
  static const IconData moreVert = Icons.more_vert_rounded;
  static const IconData arrowOutward = Icons.arrow_outward_rounded;
  static const IconData manageSearch = Icons.manage_search_rounded;
  static const IconData fullscreen = Icons.fullscreen_rounded;
  static const IconData settings = Icons.settings_rounded;

  // ---------------------------------------------------------------------------
  // Authentication & form fields (outline style, one visual family)
  // ---------------------------------------------------------------------------
  static const IconData email = Icons.mail_outline_rounded;
  static const IconData lock = Icons.lock_outline_rounded;
  static const IconData personOutline = Icons.person_outline_rounded;
  static const IconData visibility = Icons.visibility_rounded;
  static const IconData visibilityOff = Icons.visibility_off_rounded;
  static const IconData fingerprint = Icons.fingerprint_rounded;
  static const IconData face = Icons.face_rounded;
  static const IconData phone = Icons.phone_rounded;

  // ---------------------------------------------------------------------------
  // People, roles & account
  // ---------------------------------------------------------------------------
  static const IconData person = Icons.person_rounded;
  static const IconData personPin = Icons.person_pin_rounded;
  static const IconData personAddAlt = Icons.person_add_alt_1_rounded;
  static const IconData peopleAlt = Icons.people_alt_rounded;
  static const IconData badge = Icons.badge_rounded;
  static const IconData adminPanelSettings = Icons.admin_panel_settings_rounded;
  static const IconData medicalServices = Icons.medical_services_rounded;
  static const IconData security = Icons.security_rounded;
  static const IconData shield = Icons.shield_rounded;
  static const IconData theaterComedy = Icons.theater_comedy_rounded;

  // ---------------------------------------------------------------------------
  // Food, nutrition & measurement
  // ---------------------------------------------------------------------------
  static const IconData restaurant = Icons.restaurant_rounded;
  static const IconData restaurantMenu = Icons.restaurant_menu_rounded;
  static const IconData lunchDining = Icons.lunch_dining_rounded;
  static const IconData flatware = Icons.flatware_rounded;
  static const IconData fastfood = Icons.fastfood_rounded;
  static const IconData noMeals = Icons.no_meals_rounded;
  static const IconData grain = Icons.grain_rounded;
  static const IconData eggAlt = Icons.egg_alt_rounded;
  static const IconData waterDrop = Icons.water_drop_rounded;
  static const IconData localFire = Icons.local_fire_department_rounded;
  static const IconData fitnessCenter = Icons.fitness_center_rounded;
  static const IconData balance = Icons.balance_rounded;
  static const IconData calculate = Icons.calculate_rounded;
  static const IconData pieChart = Icons.pie_chart_rounded;
  static const IconData pieChartOutline = Icons.pie_chart_outline_rounded;
  static const IconData trackChanges = Icons.track_changes_rounded;
  static const IconData bolt = Icons.bolt_rounded;
  static const IconData factCheck = Icons.fact_check_rounded;
  static const IconData analytics = Icons.analytics_rounded;

  // ---------------------------------------------------------------------------
  // Scanner & camera
  // ---------------------------------------------------------------------------
  static const IconData qrCodeScanner = Icons.qr_code_scanner_rounded;
  static const IconData cameraAlt = Icons.camera_alt_rounded;
  static const IconData photoLibrary = Icons.photo_library_rounded;
  static const IconData centerFocusStrong = Icons.center_focus_strong_rounded;

  // ---------------------------------------------------------------------------
  // Content, articles & documents
  // ---------------------------------------------------------------------------
  static const IconData article = Icons.article_rounded;
  static const IconData menuBook = Icons.menu_book_rounded;
  static const IconData receiptLong = Icons.receipt_long_rounded;
  static const IconData history = Icons.history_rounded;
  static const IconData calendarMonth = Icons.calendar_month_rounded;
  static const IconData calendarToday = Icons.calendar_today_rounded;
  static const IconData accessTime = Icons.access_time_rounded;
  static const IconData imageNotSupported = Icons.image_not_supported_rounded;
  static const IconData brokenImage = Icons.broken_image_rounded;
  static const IconData code = Icons.code_rounded;
  static const IconData copy = Icons.copy_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData editNote = Icons.edit_note_rounded;
  static const IconData campaign = Icons.campaign_rounded;
  static const IconData businessCenter = Icons.business_center_rounded;

  // ---------------------------------------------------------------------------
  // CRUD & primary actions
  // ---------------------------------------------------------------------------
  static const IconData add = Icons.add_rounded;
  static const IconData addCircleOutline = Icons.add_circle_outline_rounded;
  static const IconData delete = Icons.delete_rounded;
  static const IconData deleteForever = Icons.delete_forever_rounded;
  static const IconData block = Icons.block_rounded;
  static const IconData cancel = Icons.cancel_rounded;
  static const IconData compareArrows = Icons.compare_arrows_rounded;
  static const IconData smartToy = Icons.smart_toy_rounded;
  static const IconData autoAwesome = Icons.auto_awesome_rounded;
  static const IconData sync = Icons.sync_rounded;
  static const IconData searchOff = Icons.search_off_rounded;
  static const IconData category = Icons.category_rounded;
  static const IconData image = Icons.image_rounded;
  static const IconData cloudUpload = Icons.cloud_upload_rounded;
  static const IconData save = Icons.save_rounded;
  static const IconData send = Icons.send_rounded;
  static const IconData label = Icons.label_rounded;

  // ---------------------------------------------------------------------------
  // Status, feedback & guidance (outline style)
  // ---------------------------------------------------------------------------
  static const IconData error = Icons.error_outline_rounded;
  static const IconData warning = Icons.warning_rounded;
  static const IconData warningAmber = Icons.warning_amber_rounded;
  static const IconData info = Icons.info_outline_rounded;
  static const IconData infoOutline = Icons.info_outline_rounded;
  static const IconData checkCircle = Icons.check_circle_rounded;
  static const IconData checkCircleOutline = Icons.check_circle_outline_rounded;
  static const IconData check = Icons.check_rounded;
  static const IconData priorityHigh = Icons.priority_high_rounded;
  static const IconData helpOutline = Icons.help_outline_rounded;
  static const IconData lightbulbOutline = Icons.lightbulb_outline_rounded;
}
