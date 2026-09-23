import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'FireShots POS';
  static const String nequiNumber = '3180948848';
  static const String nequiName = 'JESUS ALBEIRO VILLACORTE CORDOBA';

  static const String brebNumber = '3175383745';
  static const String brebName = 'JESUS ALBEIRO VILLACORTE CORDOBA';
  static const String brebBank = 'Bancolombia';

  static const String phone1 = '3175383745';
  static const String phone2 = '3114414955';
  static const String instagramUrl =
      'https://www.instagram.com/fireshotspasto?utm_source=ig_web_button_share_sheet&igsh=ZDNlZDc0MzIxNw==';
  static const String whatsappMessage =
      'Hola, quiero reservar una mesa para [X] personas el día [Día] a las [Hora]';

  static const List<String> staffNames = [
    'Esneyder',
    'Dayana',
    'Isa',
    'Yesid',
    'Gaby',
    'Majo',
    'Santi',
  ];

  static const List<String> paymentMethods = [
    'Efectivo',
    'Nequi',
    'Bancolombia',
    'Transferencia',
    'Bre-b',
    'Otro',
  ];

  static const List<String> debtSources = [
    'Rey de los Licores',
    'Bar de al lado',
    'Compra Chepelicores',
    'Otro',
  ];

  static const List<String> cloakroomItemTypes = [
    'Chaqueta',
    'Celular',
    'Vape',
    'Otro',
  ];

  static const List<String> productCategories = [
    'Licores Nacionales',
    'Whisky',
    'Vodka',
    'Tequila',
    'Cervezas',
    'Varios',
  ];

  static const int maxCloakroomTickets = 15;
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color primaryOrange = Color(0xFFFFA500);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundCard = Color(0xFF1E1E1E);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB0B0B0);

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String normalizeImageUrl(String url) {
    final trimmed = url.trim();
    // Google Drive shared link → direct image
    final driveRegExp = RegExp(r'drive\.google\.com/file/d/([^/]+)');
    final match = driveRegExp.firstMatch(trimmed);
    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/thumbnail?id=$fileId&sz=w600';
    }
    // Google Drive uc export link
    final ucRegExp = RegExp(r'drive\.google\.com/uc\?.*[&?]id=([^&]+)');
    final ucMatch = ucRegExp.firstMatch(trimmed);
    if (ucMatch != null) {
      final fileId = ucMatch.group(1);
      return 'https://drive.google.com/thumbnail?id=$fileId&sz=w600';
    }
    return trimmed;
  }
}
