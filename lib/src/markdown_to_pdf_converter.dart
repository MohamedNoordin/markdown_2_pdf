import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'markdown_to_pdf_builder.dart';
import 'models/markdown_source.dart';
import 'models/pdf_options.dart';
import 'utils/pdf_styles.dart';

/// Main class for converting markdown to PDF
class MarkdownToPdfConverter {
  late final MarkdownToPdfBuilder _builder;
  final PdfOptions _options;
  final PdfStyles _styles;

  Future<void>? _initFuture;

  MarkdownToPdfConverter({ PdfOptions? options })
      : _options = options ?? const PdfOptions(),
  _styles = PdfStyles() {
    _builder = MarkdownToPdfBuilder(
      styles: _styles,
      options: _options,
    );
  }

  Future<void> ensureInitialized() => _initFuture ??= _initializeFonts();

  /// Convert markdown from HTTP response to PDF and save to file
  Future<File> convertToFile(
    MarkdownSource source, {
    String? fileName,
  }) async {
    final markdownContent = await source.getContent();
    await ensureInitialized();

    final document = await _buildDocument(markdownContent);

    final directory = await getApplicationDocumentsDirectory();
    final file =
        File('${directory.path}/${fileName ?? 'markdown_document.pdf'}');

    final pdfBytes = await document.save();
    await file.writeAsBytes(pdfBytes);

    return file;
  }

  /// Convert markdown from HTTP response to PDF and return as bytes
  Future<Uint8List> convertToBytes(MarkdownSource source) async {
    final markdownContent = await source.getContent();
    await ensureInitialized();

    final document = await _buildDocument(markdownContent);

    return document.save();
  }

  /// Convert markdown from HTTP response to PDF and share/print
  Future<void> convertAndShare(MarkdownSource source) async {
    final markdownContent = await source.getContent();
    await ensureInitialized();

    final document = await _buildDocument(markdownContent);

    final pdfBytes = await document.save();
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: _options.title ?? 'markdown_document.pdf',
    );
  }

  /// Convert markdown from HTTP response to PDF and print
  Future<void> convertAndPrint(MarkdownSource source) async {
    final markdownContent = await source.getContent();
    await ensureInitialized();

    final document = await _buildDocument(markdownContent);

    final pdfBytes = await document.save();
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
    );
  }

  Future<pw.Document> _buildDocument(String markdownContent) async {
    final document = await Isolate.run(() async {
      _styles.initializeFonts();
      return _builder.buildDocument(markdownContent);
    });

    return document;
  }

  /// Initialize fonts for PDF generation
  Future<void> _initializeFonts() async {
    pw.Font? regular;
    pw.Font? bold;
    pw.Font? italic;
    pw.Font? monospace;

    TransferableTypedData? regularData;
    TransferableTypedData? boldData;
    TransferableTypedData? italicData;
    TransferableTypedData? monospaceData;

    try {
      switch (_options.fonts.regularFontFamily.toLowerCase()) {
        case 'opensans':
          regular = await PdfGoogleFonts.openSansRegular();
          break;
        case 'lato':
          regular = await PdfGoogleFonts.latoRegular();
          break;
        default:
          regular = await PdfGoogleFonts.robotoRegular();
      }

      switch (_options.fonts.boldFontFamily.toLowerCase()) {
        case 'opensans':
          bold = await PdfGoogleFonts.openSansBold();
          break;
        case 'lato':
          bold = await PdfGoogleFonts.latoBold();
          break;
        default:
          bold = await PdfGoogleFonts.robotoBold();
      }

      switch (_options.fonts.italicFontFamily.toLowerCase()) {
        case 'opensans':
          italic = await PdfGoogleFonts.openSansItalic();
          break;
        case 'lato':
          italic = await PdfGoogleFonts.latoItalic();
          break;
        default:
          italic = await PdfGoogleFonts.robotoItalic();
      }

      switch (_options.fonts.monospaceFontFamily.toLowerCase()) {
        case 'sourcecodepro':
          monospace = await PdfGoogleFonts.sourceCodeProRegular();
          break;
        default:
          monospace = await PdfGoogleFonts.robotoMonoRegular();
      }
    } catch (e) {
      regular = await PdfGoogleFonts.openSansRegular();
      bold = await PdfGoogleFonts.openSansBold();
      italic = await PdfGoogleFonts.openSansItalic();
      monospace = await PdfGoogleFonts.openSansRegular();
    }

    // Convert to transferable data (SAFE)
    if (regular is pw.TtfFont) {
      regularData = TransferableTypedData.fromList([regular.data]);
    }

    if (bold is pw.TtfFont) {
      boldData = TransferableTypedData.fromList([bold.data]);
    }

    if (italic is pw.TtfFont) {
      italicData = TransferableTypedData.fromList([italic.data]);
    }

    if (monospace is pw.TtfFont) {
      monospaceData = TransferableTypedData.fromList([monospace.data]);
    }

    // IMPORTANT: pass TRANSFERABLE DATA, not Font objects
    _styles.setFontData(
      regularFontData: regularData,
      boldFontData: boldData,
      italicFontData: italicData,
      monospaceFontData: monospaceData,
    );

    _styles.setTheme(_options.theme);
  }
}
