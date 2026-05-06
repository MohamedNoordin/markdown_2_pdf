import 'dart:isolate';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/pdf_options.dart';

/// Predefined styles for PDF generation
class PdfStyles {
  TransferableTypedData? _regularFontData;
  TransferableTypedData? _boldFontData;
  TransferableTypedData? _italicFontData;
  TransferableTypedData? _monospaceFontData;
  PdfTheme _theme = const PdfTheme();

  late pw.Font? _regularFont;
  late pw.Font? _boldFont;
  late pw.Font? _italicFont;
  late pw.Font? _monospaceFont;

  bool _initialized = false;

  void initializeFonts() {
    if (_initialized) return;

    _regularFont = _buildFont(_regularFontData);
    _boldFont = _buildFont(_boldFontData);
    _italicFont = _buildFont(_italicFontData);
    _monospaceFont = _buildFont(_monospaceFontData);

    _initialized = true;
  }


  /// Set fonts for the styles
  void setFontData({
    TransferableTypedData? regularFontData,
    TransferableTypedData? boldFontData,
    TransferableTypedData? italicFontData,
    TransferableTypedData? monospaceFontData,
  }) {
    _regularFontData = regularFontData;
    _boldFontData = boldFontData;
    _italicFontData = italicFontData;
    _monospaceFontData = monospaceFontData;
  }

  /// Set theme for the styles
  void setTheme(PdfTheme theme) {
    _theme = theme;
  }

  /// Get current theme
  PdfTheme get theme => _theme;

  /// Default text style
  pw.TextStyle get defaultText => pw.TextStyle(
    fontSize: 12,
    color: _theme.textColor,
    font: _regularFont,
    fontFallback: [_regularFont, _boldFont].whereType<pw.Font>().toList(),
  );

  /// Heading 1 style
  pw.TextStyle get heading1 => pw.TextStyle(
    fontSize: 24,
    color: _theme.primaryColor,
    font: _boldFont,
    fontFallback: [_boldFont, _regularFont].whereType<pw.Font>().toList(),
  );

  /// Heading 2 style
  pw.TextStyle get heading2 => pw.TextStyle(
    fontSize: 20,
    color: _theme.primaryColor,
    font: _boldFont,
    fontFallback: [_boldFont, _regularFont].whereType<pw.Font>().toList(),
  );

  /// Heading 3 style
  pw.TextStyle get heading3 => pw.TextStyle(
    fontSize: 18,
    color: _theme.primaryColor,
    font: _boldFont,
    fontFallback: [_boldFont, _regularFont].whereType<pw.Font>().toList(),
  );

  /// Heading 4 style
  pw.TextStyle get heading4 => pw.TextStyle(
    fontSize: 16,
    color: _theme.primaryColor,
    font: _boldFont,
    fontFallback: [_boldFont, _regularFont].whereType<pw.Font>().toList(),
  );

  /// Heading 5 style
  pw.TextStyle get heading5 => pw.TextStyle(
    fontSize: 14,
    color: _theme.primaryColor,
    font: _boldFont,
    fontFallback: [_boldFont, _regularFont].whereType<pw.Font>().toList(),
  );

  /// Heading 6 style
  pw.TextStyle get heading6 => pw.TextStyle(
    fontSize: 12,
    color: _theme.primaryColor,
    font: _boldFont,
    fontFallback: [_boldFont, _regularFont].whereType<pw.Font>().toList(),
  );

  /// Code style
  pw.TextStyle get code => pw.TextStyle(
    fontSize: 10,
    color: const PdfColor.fromInt(0xFFD32F2F),
    font: _monospaceFont,
    fontFallback: [_monospaceFont, _regularFont].whereType<pw.Font>().toList(),
  );

  /// Blockquote style
  pw.TextStyle get blockquote => pw.TextStyle(
    fontSize: 12,
    color: _theme.secondaryColor,
    font: _italicFont,
    fontFallback: [_italicFont, _regularFont].whereType<pw.Font>().toList(),
  );

  /// Link style
  pw.TextStyle get link => pw.TextStyle(
    fontSize: 12,
    color: _theme.primaryColor,
    font: _regularFont,
    fontFallback: [_regularFont, _boldFont].whereType<pw.Font>().toList(),
  );

  /// Bold text style
  pw.TextStyle get bold => pw.TextStyle(
    fontSize: 12,
    color: _theme.textColor,
    font: _boldFont,
    fontFallback: [_boldFont, _regularFont].whereType<pw.Font>().toList(),
  );

  /// Italic text style
  pw.TextStyle get italic => pw.TextStyle(
    fontSize: 12,
    color: _theme.textColor,
    font: _italicFont,
    fontFallback: [_italicFont, _regularFont].whereType<pw.Font>().toList(),
  );

  /// Table header style
  pw.TextStyle get tableHeader => pw.TextStyle(
    fontSize: 12,
    color: _theme.backgroundColor,
    font: _boldFont,
    fontFallback: [_boldFont, _regularFont].whereType<pw.Font>().toList(),
  );

  /// Table cell style
  pw.TextStyle get tableCell => pw.TextStyle(
    fontSize: 11,
    color: _theme.textColor,
    font: _regularFont,
    fontFallback: [_regularFont, _boldFont].whereType<pw.Font>().toList(),
  );

  /// Header style
  pw.TextStyle get header => pw.TextStyle(
    fontSize: 10,
    color: _theme.secondaryColor,
    font: _regularFont,
    fontFallback: [_regularFont, _boldFont].whereType<pw.Font>().toList(),
  );

  /// Footer style
  pw.TextStyle get footer => pw.TextStyle(
    fontSize: 10,
    color: _theme.secondaryColor,
    font: _regularFont,
    fontFallback: [_regularFont, _boldFont].whereType<pw.Font>().toList(),
  );

  /// Page number style
  pw.TextStyle get pageNumber => pw.TextStyle(
    fontSize: 10,
    color: _theme.secondaryColor,
    font: _regularFont,
    fontFallback: [_regularFont, _boldFont].whereType<pw.Font>().toList(),
  );

  pw.Font? _buildFont(TransferableTypedData? data) {
    if (data == null) return null;

    final uint8 = data.materialize().asUint8List();
    final byteData = uint8.buffer.asByteData();

    return pw.Font.ttf(byteData);
  }
}
