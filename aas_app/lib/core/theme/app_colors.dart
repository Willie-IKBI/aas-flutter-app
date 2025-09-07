import 'package:flutter/material.dart';

/// AAS App Color Palette
///
/// Modern color system with improved contrast and visual hierarchy
class AppColors {
  AppColors._();

  // ===== BASE COLORS =====

  /// Primary brand colors
  static const Color jet = Color(0xFF1A1A1A); // Softer black
  static const Color jet100 = Color(0xFF0A0A0A);
  static const Color jet200 = Color(0xFF1E1E1E);
  static const Color jet300 = Color(0xFF2D2D2D);
  static const Color jet400 = Color(0xFF3C3C3C);
  static const Color jet500 = Color(0xFF4B4B4B);
  static const Color jet600 = Color(0xFF5A5A5A);
  static const Color jet700 = Color(0xFF696969);
  static const Color jet800 = Color(0xFF787878);
  static const Color jet900 = Color(0xFF878787);

  /// Neutral colors
  static const Color timberwolf = Color(0xFFF5F5F5); // Softer white
  static const Color timberwolf100 = Color(0xFFE8E8E8);
  static const Color timberwolf200 = Color(0xFFD1D1D1);
  static const Color timberwolf300 = Color(0xFFBABABA);
  static const Color timberwolf400 = Color(0xFFA3A3A3);
  static const Color timberwolf500 = Color(0xFF8C8C8C);
  static const Color timberwolf600 = Color(0xFF757575);
  static const Color timberwolf700 = Color(0xFF5E5E5E);
  static const Color timberwolf800 = Color(0xFF474747);
  static const Color timberwolf900 = Color(0xFF303030);

  /// Brand accent colors
  static const Color redCmyk = Color(0xFFE53E3E); // Softer red
  static const Color redCmyk100 = Color(0xFFFED7D7);
  static const Color redCmyk200 = Color(0xFFFEB2B2);
  static const Color redCmyk300 = Color(0xFFFC8181);
  static const Color redCmyk400 = Color(0xFFF56565);
  static const Color redCmyk500 = Color(0xFFE53E3E);
  static const Color redCmyk600 = Color(0xFFC53030);
  static const Color redCmyk700 = Color(0xFF9B2C2C);
  static const Color redCmyk800 = Color(0xFF742A2A);
  static const Color redCmyk900 = Color(0xFF521B1B);

  /// Secondary accent colors
  static const Color orangeCrayola = Color(0xFFED8936); // Softer orange
  static const Color orangeCrayola100 = Color(0xFFFEEBC8);
  static const Color orangeCrayola200 = Color(0xFFFBD38D);
  static const Color orangeCrayola300 = Color(0xFFF6AD55);
  static const Color orangeCrayola400 = Color(0xFFED8936);
  static const Color orangeCrayola500 = Color(0xFFDD6B20);
  static const Color orangeCrayola600 = Color(0xFFC05621);
  static const Color orangeCrayola700 = Color(0xFF9C4221);
  static const Color orangeCrayola800 = Color(0xFF7C2D12);
  static const Color orangeCrayola900 = Color(0xFF651A07);

  // ===== SEMANTIC COLORS =====

  /// Primary brand color
  static const Color primary = redCmyk500;
  static const Color primaryLight = redCmyk400;
  static const Color primaryDark = redCmyk600;
  static const Color onPrimary = Colors.white;

  /// Secondary brand color
  static const Color secondary = orangeCrayola500;
  static const Color secondaryLight = orangeCrayola400;
  static const Color secondaryDark = orangeCrayola600;
  static const Color onSecondary = Colors.white;

  /// Background colors
  static const Color background = Color(0xFF0F0F0F); // Very dark gray
  static const Color onBackground = timberwolf;
  static const Color surface = Color(0xFF1A1A1A); // Dark gray
  static const Color onSurface = timberwolf;
  static const Color surfaceVariant = Color(0xFF2D2D2D); // Medium gray
  static const Color onSurfaceVariant = timberwolf200;

  /// Container colors
  static const Color primaryContainer = redCmyk100;
  static const Color onPrimaryContainer = redCmyk900;
  static const Color secondaryContainer = orangeCrayola100;
  static const Color onSecondaryContainer = orangeCrayola900;

  /// Info colors
  static const Color info = Color(0xFF3182CE);
  static const Color onInfo = Colors.white;
  static const Color infoContainer = Color(0xFFBEE3F8);
  static const Color onInfoContainer = Color(0xFF2A4365);

  /// Success colors
  static const Color success = Color(0xFF38A169);
  static const Color onSuccess = Colors.white;
  static const Color successContainer = Color(0xFFC6F6D5);
  static const Color onSuccessContainer = Color(0xFF22543D);

  /// Warning colors
  static const Color warning = Color(0xFFD69E2E);
  static const Color onWarning = Colors.white;
  static const Color warningContainer = Color(0xFFFEFCBF);
  static const Color onWarningContainer = Color(0xFF744210);

  /// Error colors
  static const Color error = Color(0xFFE53E3E);
  static const Color onError = Colors.white;
  static const Color errorContainer = Color(0xFFFED7D7);
  static const Color onErrorContainer = Color(0xFF742A2A);

  /// Outline and divider colors
  static const Color outline = Color(0xFF4A5568);
  static const Color outlineVariant = Color(0xFF718096);
  static const Color divider = Color(0xFF2D3748);

  /// Shadow colors
  static const Color shadow = jet100;
  static const Color scrim = Color(0x52000000);

  /// Surface tint color
  static const Color surfaceTint = primary;

  // ===== GRADIENTS =====

  /// Modern background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F0F0F), // Very dark gray
      Color(0xFF1A1A1A), // Dark gray
      Color(0xFF2D2D2D), // Medium gray
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Card gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A1A),
      Color(0xFF2D2D2D),
    ],
  );

  /// Primary button gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      redCmyk500,
      redCmyk600,
    ],
  );

  /// Secondary button gradient
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      orangeCrayola500,
      orangeCrayola600,
    ],
  );

  /// Info gradient
  static const LinearGradient infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      info,
      Color(0xFF2A4365),
    ],
  );

  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      success,
      Color(0xFF22543D),
    ],
  );

  /// Warning gradient
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      warning,
      Color(0xFF744210),
    ],
  );

  /// Glassmorphism effect
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF), // 10% white
      Color(0x0DFFFFFF), // 5% white
    ],
  );

  // ===== SOCIAL COLORS =====

  /// Google brand colors
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleGreen = Color(0xFF34A853);

  /// Apple brand colors
  static const Color appleBlack = Color(0xFF000000);
  static const Color appleGray = Color(0xFF8E8E93);

  // ===== STATUS COLORS =====

  /// Order status colors
  static const Color statusDraft = timberwolf400;
  static const Color statusInProgress = info;
  static const Color statusWaitingApproval = warning;
  static const Color statusApproved = success;
  static const Color statusInProduction = secondary;
  static const Color statusComplete = success;
  static const Color statusCancelled = error;

  /// Stage colors
  static const Color stageOrderCaptured = info;
  static const Color stageWashBay = Color(0xFF00BCD4);
  static const Color stageAssessment = warning;
  static const Color stageQuotation = secondary;
  static const Color stageApproval = warning;
  static const Color stageJobCommence = primary;
  static const Color stagePaint = orangeCrayola;
  static const Color stageDispatch = success;
}
