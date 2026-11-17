import 'package:flutter/material.dart';

/// Every icon in the app, named by meaning rather than by glyph.
///
/// One family is used throughout: Material "outlined" for regular icons,
/// with the "rounded" filled variant only for the selected state of the
/// bottom navigation. Keeping them here makes the icon language consistent
/// and lets a glyph be swapped in one place.
abstract final class AppIcons {
  // Bottom navigation (outlined = idle, filled = selected).
  static const IconData home = Icons.home_outlined;
  static const IconData homeSelected = Icons.home_rounded;
  static const IconData bookings = Icons.event_note_outlined;
  static const IconData bookingsSelected = Icons.event_note_rounded;
  static const IconData assistant = Icons.forum_outlined;
  static const IconData assistantSelected = Icons.forum_rounded;
  static const IconData profile = Icons.person_outline_rounded;
  static const IconData profileSelected = Icons.person_rounded;

  // Navigation and actions.
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.tune_rounded;
  static const IconData retry = Icons.refresh_rounded;
  static const IconData send = Icons.arrow_upward_rounded;
  static const IconData openExternal = Icons.arrow_outward_rounded;
  static const IconData forward = Icons.arrow_forward_rounded;
  static const IconData sparkle = Icons.bolt_rounded;
  static const IconData check = Icons.check_rounded;
  static const IconData logout = Icons.logout_rounded;
  static const IconData demo = Icons.play_circle_outline_rounded;

  // Form fields.
  static const IconData email = Icons.alternate_email_rounded;
  static const IconData password = Icons.lock_outline_rounded;
  static const IconData newPassword = Icons.key_outlined;
  static const IconData person = Icons.person_outline_rounded;
  static const IconData phone = Icons.phone_outlined;
  static const IconData visible = Icons.visibility_outlined;
  static const IconData hidden = Icons.visibility_off_outlined;

  // Service and booking facts.
  static const IconData duration = Icons.schedule_outlined;
  static const IconData timeSpan = Icons.timelapse_outlined;
  static const IconData price = Icons.payments_outlined;
  static const IconData category = Icons.sell_outlined;
  static const IconData date = Icons.calendar_today_outlined;
  static const IconData calendar = Icons.event_outlined;
  static const IconData slotChosen = Icons.event_available_outlined;
  static const IconData notes = Icons.notes_rounded;
  static const IconData featured = Icons.star_rounded;
  static const IconData service = Icons.storefront_outlined;
  static const IconData cancelBooking = Icons.event_busy_outlined;
  static const IconData history = Icons.history_rounded;

  // Profile and settings.
  static const IconData editProfile = Icons.manage_accounts_outlined;
  static const IconData language = Icons.language_rounded;
  static const IconData appearance = Icons.contrast_rounded;
  static const IconData themeSystem = Icons.brightness_auto_outlined;
  static const IconData themeLight = Icons.light_mode_outlined;
  static const IconData themeDark = Icons.dark_mode_outlined;
  static const IconData radioOn = Icons.radio_button_checked_rounded;
  static const IconData radioOff = Icons.radio_button_unchecked_rounded;

  // Assistant.
  static const IconData prompt = Icons.chat_bubble_outline_rounded;

  // Feedback states.
  static const IconData empty = Icons.inbox_outlined;
  static const IconData noResults = Icons.search_off_rounded;
  static const IconData offline = Icons.wifi_off_rounded;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData info = Icons.info_outline_rounded;
  static const IconData brokenImage = Icons.image_outlined;
}
