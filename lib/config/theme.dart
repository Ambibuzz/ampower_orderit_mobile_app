import 'package:orderit/config/styles.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTheme {
  static const primarycolor = Color(0xFF006CB5);
  static TextTheme textTheme = TextTheme(
    displayLarge:
        GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 57.0)),
    displayMedium:
        GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 45.0)),
    displaySmall:
        GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 36.0)),
    headlineLarge:
        GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 32.0)),
    headlineMedium:
        GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 28.0)),
    headlineSmall:
        GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 24.0)),
    titleLarge: GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 18.0)),
    titleMedium: GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 16.0)),
    titleSmall: GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 14.0)),
    bodyLarge: GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 16.0)),
    bodyMedium: GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 14.0)),
    bodySmall: GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 12.0)),
    labelLarge: GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 14.0)),
    labelMedium: GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 12.0)),
    labelSmall: GoogleFonts.dmSans(textStyle: const TextStyle(fontSize: 11.0)),
  );

  static TextStyle appBarTitleTextStyle = GoogleFonts.dmSans(
      textStyle: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: primarycolor,
  ));

  static TextStyle fontStyle = GoogleFonts.dmSans();

  static TextStyle dialogTitleTextStyle = GoogleFonts.dmSans(
      textStyle: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.15));

  static TextStyle dialogContentTextStyle = GoogleFonts.dmSans(
      textStyle: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4));

  static TextStyle buttonTextStyle = GoogleFonts.dmSans(
      textStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 0.15));

  static const buttonPadding = EdgeInsets.symmetric(
      horizontal: Sizes.horizontalSmallPadding,
      vertical: Sizes.verticalExtraSmallPadding);

  static const buttonShape =
      RoundedRectangleBorder(borderRadius: Corners.xxlBorder);

  static final buttonShapeWithBorder = RoundedRectangleBorder(
    borderRadius: Corners.xxlBorder,
    side: BorderSide(color: Colors.white, width: 1),
  );

  static const buttonBorder = Corners.xxlBorder;

  static const double elevation = 3;

  static const double dividerThickness = 1;

  static double iconSize = FontSizes.s24;

  static Color fillColorGrey = const Color(0xFFF3F3F3);

  // static final Color primarycolor = Palette.primaryColor;

  //Light Theme
  static Color backgroundColorLight = const Color(0xFFF2F2F2);
  static Brightness brightnessLight = Brightness.light;
  static Color disabledColorLight = const Color(0xFFA5A5A5);
  static Color dangerColor = const Color(0xFFE33629);
  static Color errorColorLight = const Color(0xFFB00020);
  static Color appBarIconThemeColorLight = const Color(0xFFFFFFFF);
  static Color onBackgroundColorLight = const Color(0xFF000000);
  static Color onErrorColorLight = const Color(0xFFFFFFFF);
  static Color onPrimaryColorLight = const Color(0xFFFFFFFF);
  static Color onSecondaryColorLight = const Color(0xFFFFFFFF);
  static Color onSurfaceColorLight = const Color(0xFF000000);
  static Color primaryColorLight = primarycolor;
  static Color primaryVariantLight = const Color(0xFF3700B3);
  static Color secondaryColorLight = const Color(0xFFFF731D);
  static Color secondaryVariantLight = const Color(0xFF018786);
  static Color surfaceColorLight = const Color(0xFFFAFAFA);

  //Dark Theme
  static Color backgroundColorDark = const Color(0xFF121212);
  static Brightness brightnessDark = Brightness.dark;
  static Color disabledColorDark = const Color(0xFFA5A5A5);
  static Color errorColorDark = const Color(0xFFCF6679);
  static Color onBackgroundColorDark = const Color(0xFFFFFFFF);
  static Color onErrorColorDark = const Color(0xFF000000);
  static Color onPrimaryColorDark = const Color(0xFF000000);
  static Color onSecondaryColorDark = const Color(0xFF000000);
  static Color onSurfaceColorDark = const Color(0xFFFFFFFF);
  static Color primaryColorDark = const Color(0xFFBB86FC);
  static Color primaryVariantDark = const Color(0xFF3700B3);
  static Color secondaryColorDark = const Color(0xFF03DAC6);
  static Color secondaryVariantDark = const Color(0xFF03DAC6);
  static Color surfaceColorDark = const Color(0xFF424242);

  //Chart Color Data
  static Color chartColorTarget = primaryColorLight;
  static Color chartColorAchievement = const Color(0xFFFF731D);
  static Color chartColorPrediction = Colors.green;
  static Color tableHeaderColor = const Color(0xFFF5F5F7);

  static var dropdownColor = const Color(0xFFD9D9D9);
  static var imageBorderColor = const Color(0xFFD9D9D9);
  static var toastMessageBgColor = const Color(0xFFB0D1E8);
  static var iconColor = const Color(0xFF666666);
  static var borderColor = const Color(0xFF666666);
  static var tableBorderColor = const Color(0xFFD6D6D6);
  static var successColor = const Color(0xFF45B36D);

  static ThemeData lightTheme({Color? primaryColor}) {
    return ThemeData(
      textTheme: textTheme,
      scaffoldBackgroundColor: backgroundColorLight,
      disabledColor: disabledColorLight,
      primaryColor: primaryColor ?? primaryColorLight,
      brightness: brightnessLight,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColorLight,
        titleTextStyle: appBarTitleTextStyle,
        surfaceTintColor: backgroundColorLight,
        actionsIconTheme:
            IconThemeData(color: appBarIconThemeColorLight, size: iconSize),
        iconTheme:
            IconThemeData(color: appBarIconThemeColorLight, size: iconSize),
        elevation: elevation,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor ?? primaryColorLight,
        disabledColor: disabledColorLight,
        textTheme: ButtonTextTheme.primary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        surfaceTintColor: surfaceColorLight,
        backgroundColor: surfaceColorLight,
      ),
      cardTheme: CardTheme(
          color: surfaceColorLight,
          elevation: elevation,
          surfaceTintColor: surfaceColorLight,
          shape: const RoundedRectangleBorder(borderRadius: Corners.xlBorder)),
      checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStateProperty.all(onBackgroundColorLight),
          fillColor: WidgetStateProperty.all(backgroundColorLight),
          side: BorderSide(color: onBackgroundColorLight, width: 1)),
      dataTableTheme: DataTableThemeData(
        decoration: BoxDecoration(
          color: surfaceColorLight,
          borderRadius: Corners.xlBorder,
        ),
        headingRowHeight: 50,
      ),
      dialogTheme: DialogTheme(
          backgroundColor: backgroundColorLight,
          titleTextStyle:
              dialogTitleTextStyle.copyWith(color: onSurfaceColorLight),
          contentTextStyle:
              dialogContentTextStyle.copyWith(color: onSurfaceColorLight),
          elevation: elevation),
      dialogBackgroundColor: backgroundColorLight,
      dividerColor: const Color(0xFFE7E5E5),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE7E5E5),
        thickness: dividerThickness,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(secondaryColorLight),
          elevation: WidgetStateProperty.all(elevation),
          padding: WidgetStateProperty.all(buttonPadding),
          textStyle: WidgetStateProperty.all(buttonTextStyle),
          shape: WidgetStateProperty.all(buttonShape),
          foregroundColor: WidgetStateProperty.all(onPrimaryColorLight),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor ?? primaryColorLight,
        foregroundColor: onSecondaryColorLight,
        disabledElevation: elevation,
        elevation: elevation,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: surfaceColorLight,
        textColor: Colors.black,
        iconColor: Colors.black,
        collapsedIconColor: Colors.black,
        collapsedBackgroundColor: surfaceColorLight,
        collapsedTextColor: Colors.black,
        // shape: const RoundedRectangleBorder(borderRadius: Corners.xlBorder),
      ),
      iconTheme: IconThemeData(color: onBackgroundColorLight, size: iconSize),
      inputDecorationTheme: InputDecorationTheme(
        // fillColor: surfaceColorLight,
        fillColor: backgroundColorLight,
        filled: true,
        // isDense: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor,
          ),
          borderRadius: Corners.xxlBorder,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: errorColorLight,
          ),
          borderRadius: Corners.xxlBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: primaryColor ?? primaryColorLight,
          ),
          borderRadius: Corners.xxlBorder,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: errorColorLight,
          ),
          borderRadius: Corners.xxlBorder,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.all(primaryColor ?? primaryColorLight),
          elevation: WidgetStateProperty.all(elevation),
          textStyle: WidgetStateProperty.all(buttonTextStyle),
          padding: WidgetStateProperty.all(buttonPadding),
          shape: WidgetStateProperty.all(buttonShapeWithBorder),
          foregroundColor: WidgetStateProperty.all(onPrimaryColorLight),
        ),
      ),
      primaryIconTheme: IconThemeData(
          color: primaryColor ?? primaryColorLight, size: iconSize),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onBackgroundColorLight,
        actionTextColor: backgroundColorLight,
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(secondaryColorLight),
          elevation: WidgetStateProperty.all(elevation),
          textStyle: WidgetStateProperty.all(buttonTextStyle),
          padding: WidgetStateProperty.all(buttonPadding),
          shape: WidgetStateProperty.all(buttonShape),
          foregroundColor: WidgetStateProperty.all(onPrimaryColorLight),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme(
              primary: primaryColor ?? primaryColorLight,
              secondary: secondaryColorLight,
              surface: surfaceColorLight,
              error: errorColorLight,
              onPrimary: onPrimaryColorLight,
              onSecondary: onSecondaryColorLight,
              onSurface: onSurfaceColorLight,
              onError: onErrorColorLight,
              brightness: brightnessLight)
          .copyWith(surface: surfaceColorLight)
          .copyWith(error: errorColorLight),
    );
  }

  static ThemeData darkTheme({Color? primaryColor}) {
    return ThemeData(
      textTheme: textTheme,
      scaffoldBackgroundColor: backgroundColorDark,
      disabledColor: disabledColorDark,
      primaryColor: primaryColor ?? primaryColorDark,
      brightness: brightnessDark,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColorDark,
        titleTextStyle: appBarTitleTextStyle,
        actionsIconTheme:
            IconThemeData(color: onBackgroundColorDark, size: iconSize),
        iconTheme: IconThemeData(color: onBackgroundColorDark, size: iconSize),
        elevation: elevation,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor ?? primaryColorDark,
        disabledColor: disabledColorDark,
        textTheme: ButtonTextTheme.primary,
      ),
      cardTheme: CardTheme(color: surfaceColorDark, elevation: elevation),
      checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStateProperty.all(onBackgroundColorDark),
          fillColor: WidgetStateProperty.all(backgroundColorDark),
          side: BorderSide(color: onBackgroundColorDark, width: 1)),
      dataTableTheme: DataTableThemeData(
        decoration: BoxDecoration(
            color: surfaceColorDark, borderRadius: Corners.medBorder),
      ),
      dialogTheme: DialogTheme(
          backgroundColor: backgroundColorDark,
          titleTextStyle:
              dialogTitleTextStyle.copyWith(color: onSurfaceColorDark),
          contentTextStyle:
              dialogContentTextStyle.copyWith(color: onSurfaceColorDark),
          elevation: elevation),
      dialogBackgroundColor: backgroundColorDark,
      dividerColor: onBackgroundColorDark,
      dividerTheme: DividerThemeData(
        color: onBackgroundColorDark,
        thickness: dividerThickness,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.all(primaryColor ?? primaryColorDark),
          elevation: WidgetStateProperty.all(elevation),
          padding: WidgetStateProperty.all(buttonPadding),
          textStyle: WidgetStateProperty.all(buttonTextStyle),
          shape: WidgetStateProperty.all(buttonShape),
          foregroundColor: WidgetStateProperty.all(onPrimaryColorDark),
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: backgroundColorDark,
        textColor: Colors.white,
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        collapsedBackgroundColor: backgroundColorDark,
        collapsedTextColor: Colors.white,
        // shape: const RoundedRectangleBorder(borderRadius: Corners.xxlBorder),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor ?? primaryColorDark,
        foregroundColor: onSecondaryColorDark,
        disabledElevation: elevation,
        elevation: elevation,
      ),
      iconTheme: IconThemeData(color: onBackgroundColorDark, size: iconSize),
      inputDecorationTheme: InputDecorationTheme(
        // fillColor: surfaceColor,
        filled: true,
        isDense: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: Corners.xxlBorder,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: errorColorDark,
          ),
          borderRadius: Corners.xxlBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: primaryColor ?? primaryColorDark,
          ),
          borderRadius: Corners.xxlBorder,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: errorColorDark,
          ),
          borderRadius: Corners.xxlBorder,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.all(primaryColor ?? primaryColorDark),
          elevation: WidgetStateProperty.all(elevation),
          textStyle: WidgetStateProperty.all(buttonTextStyle),
          padding: WidgetStateProperty.all(buttonPadding),
          shape: WidgetStateProperty.all(buttonShapeWithBorder),
          foregroundColor: WidgetStateProperty.all(onPrimaryColorDark),
        ),
      ),
      primaryIconTheme: IconThemeData(
          color: primaryColor ?? primaryColorDark, size: iconSize),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all(primaryColor ?? primaryColorDark),
            elevation: WidgetStateProperty.all(elevation),
            textStyle: WidgetStateProperty.all(buttonTextStyle),
            padding: WidgetStateProperty.all(buttonPadding),
            shape: WidgetStateProperty.all(buttonShape),
            foregroundColor: WidgetStateProperty.all(onPrimaryColorDark)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onBackgroundColorDark,
        actionTextColor: backgroundColorDark,
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(
          fillColor: primaryColor ?? primaryColorDark,
          borderColor: onBackgroundColorDark,
          selectedBorderColor: onBackgroundColorDark,
          selectedColor: primaryColor ?? primaryColorDark),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme(
              primary: primaryColor ?? primaryColorDark,
              secondary: secondaryColorDark,
              surface: surfaceColorDark,
              error: errorColorDark,
              onPrimary: onPrimaryColorDark,
              onSecondary: onSecondaryColorDark,
              onSurface: onBackgroundColorDark,
              onError: onErrorColorDark,
              brightness: brightnessDark)
          .copyWith(surface: surfaceColorDark)
          .copyWith(error: errorColorDark),
    );
  }
}
