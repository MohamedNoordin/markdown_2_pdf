import 'package:markdown/markdown.dart' as md;
import 'package:pdf/widgets.dart' as pw;

import 'models/pdf_options.dart';
import 'utils/pdf_styles.dart';

class MarkdownToPdfBuilder {
  MarkdownToPdfBuilder({ required PdfStyles styles, PdfOptions? options }) :
        _styles = styles,
        _options = options ?? const PdfOptions();

  final PdfStyles _styles;
  final PdfOptions _options;

  /// Build the PDF document from markdown source
  /// Runs on the main isolate
  Future<pw.Document> buildDocument(String markdownContent) async {
    final document = pw.Document();

    final mdDoc = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
    final nodes = mdDoc.parse(markdownContent);

    document.addPage(
      pw.MultiPage(
        pageFormat: _options.pageFormat,
        margin: _options.margins,
        header: _options.headerText != null ? _buildHeader : null,
        footer: _buildFooter,
        build: (context) => _buildContent(nodes),
      ),
    );

    return document;
  }

  /// Build header for PDF pages
  pw.Widget _buildHeader(pw.Context context) {
    // Use custom header if provided
    if (_options.customHeader != null) {
      return _options.customHeader!(context);
    }

    if (_options.headerText == null) return pw.Container();

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _options.theme.borderColor),
        ),
      ),
      child: pw.Text(
        _options.headerText!,
        style: _styles.header,
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Build footer for PDF pages
  pw.Widget _buildFooter(pw.Context context) {
    // Use custom footer if provided
    if (_options.customFooter != null) {
      return _options.customFooter!(context);
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: _options.theme.borderColor),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          if (_options.footerText != null)
            pw.Text(
              _options.footerText!,
              style: _styles.footer,
            ),
          if (_options.includePageNumbers)
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: _styles.pageNumber,
            ),
        ],
      ),
    );
  }

  /// Build content from markdown nodes
  List<pw.Widget> _buildContent(List<md.Node> nodes) {
    final widgets = <pw.Widget>[];

    for (final node in nodes) {
      final widget = _buildNode(node);
      if (widget != null) {
        widgets.add(widget);
      }
    }

    return widgets;
  }

  /// Build a single markdown node
  pw.Widget? _buildNode(md.Node node) {
    if (node is md.Element) {
      return _buildElement(node);
    } else if (node is md.Text) {
      return pw.Text(
        _sanitizeText(node.text),
        style: _styles.defaultText,
      );
    }
    return null;
  }

  /// Sanitize text to handle special characters
  String _sanitizeText(String text) => text
      .replaceAll('•', '-') // Replace bullet points with dashes
      .replaceAll('–', '-') // Replace en-dash with regular dash
      .replaceAll('—', '-') // Replace em-dash with regular dash
      .replaceAll('"', '"') // Replace smart quotes
      .replaceAll('"', '"')
      .replaceAll(''', "'")  // Replace smart apostrophes
        .replaceAll(''', "'");

  /// Build an element from markdown
  pw.Widget? _buildElement(md.Element element) {
    switch (element.tag) {
      case 'h1':
        return pw.Container(
          margin: const pw.EdgeInsets.only(top: 24, bottom: 16),
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom:
              pw.BorderSide(color: _options.theme.primaryColor, width: 2),
            ),
          ),
          child: pw.Text(
            _sanitizeText(element.textContent),
            style: _styles.heading1,
          ),
        );
      case 'h2':
        return pw.Container(
          margin: const pw.EdgeInsets.only(top: 20, bottom: 12),
          padding: const pw.EdgeInsets.only(bottom: 6),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom:
              pw.BorderSide(color: _options.theme.borderColor, width: 1),
            ),
          ),
          child: pw.Text(
            _sanitizeText(element.textContent),
            style: _styles.heading2,
          ),
        );
      case 'h3':
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
          child: pw.Text(
            _sanitizeText(element.textContent),
            style: _styles.heading3,
          ),
        );
      case 'h4':
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
          child: pw.Text(
            _sanitizeText(element.textContent),
            style: _styles.heading4,
          ),
        );
      case 'h5':
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
          child: pw.Text(
            _sanitizeText(element.textContent),
            style: _styles.heading5,
          ),
        );
      case 'h6':
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
          child: pw.Text(
            _sanitizeText(element.textContent),
            style: _styles.heading6,
          ),
        );
      case 'p':
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            _sanitizeText(element.textContent),
            style: _styles.defaultText,
          ),
        );
      case 'blockquote':
        return pw.Container(
          margin: const pw.EdgeInsets.only(left: 20, bottom: 12),
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              left: pw.BorderSide(
                  color: _options.theme.blockquoteColor, width: 4),
            ),
            color: _options.theme.backgroundColor,
          ),
          child: pw.Text(
            _sanitizeText(element.textContent),
            style: _styles.blockquote,
          ),
        );
      case 'code':
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: _options.theme.codeBackgroundColor,
            border: pw.Border.all(color: _options.theme.borderColor),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Text(
            _sanitizeText(element.textContent),
            style: _styles.code,
          ),
        );
      case 'pre':
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: _options.theme.codeBackgroundColor,
            border: pw.Border.all(color: _options.theme.borderColor),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Text(
            _sanitizeText(element.textContent),
            style: _styles.code,
          ),
        );
      case 'ul':
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: element.children
              ?.map((child) => _buildNode(child))
              .where((widget) => widget != null)
              .cast<pw.Widget>()
              .toList() ??
              [],
        );
      case 'ol':
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: element.children
              ?.asMap()
              .entries
              .map((entry) => pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${entry.key + 1}. ',
                style: _styles.defaultText,
              ),
              pw.Expanded(
                child: _buildNode(entry.value) ?? pw.Container(),
              ),
            ],
          ))
              .toList() ??
              [],
        );
      case 'li':
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '- ',
                style: _styles.defaultText,
              ),
              pw.Expanded(
                child: pw.Text(
                  _sanitizeText(element.textContent),
                  style: _styles.defaultText,
                ),
              ),
            ],
          ),
        );
      case 'table':
        return _buildTable(element);
      case 'strong':
      case 'b':
        return pw.Text(
          element.textContent,
          style: _styles.bold,
        );
      case 'em':
      case 'i':
        return pw.Text(
          element.textContent,
          style: _styles.italic,
        );
      case 'a':
        return pw.Text(
          element.textContent,
          style: _styles.link,
        );
      case 'hr':
        return pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 20),
          height: 2,
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [
                _options.theme.borderColor,
                _options.theme.primaryColor,
                _options.theme.borderColor,
              ],
            ),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1)),
          ),
        );
      default:
        return pw.Text(
          element.textContent,
          style: _styles.defaultText,
        );
    }
  }

  /// Build a table from markdown
  pw.Widget _buildTable(md.Element table) {
    final rows = <List<Map<String, dynamic>>>[];

    // Handle GitHub Flavored markdown table structure
    for (final child in table.children ?? []) {
      if (child is md.Element &&
          (child.tag == 'thead' || child.tag == 'tbody')) {
        for (final row in child.children ?? []) {
          if (row is md.Element && row.tag == 'tr') {
            final cells = <Map<String, dynamic>>[];
            for (final cell in row.children ?? []) {
              if (cell is md.Element &&
                  (cell.tag == 'td' || cell.tag == 'th')) {
                cells.add({
                  'content': cell.textContent,
                  'isHeader': cell.tag == 'th' || child.tag == 'thead',
                  'alignment': _getCellAlignment(cell),
                });
              }
            }
            if (cells.isNotEmpty) {
              rows.add(cells);
            }
          }
        }
      } else if (child is md.Element && child.tag == 'tr') {
        // Fallback for direct tr elements
        final cells = <Map<String, dynamic>>[];
        for (final cell in child.children ?? []) {
          if (cell is md.Element && (cell.tag == 'td' || cell.tag == 'th')) {
            cells.add({
              'content': cell.textContent,
              'isHeader': cell.tag == 'th',
              'alignment': _getCellAlignment(cell),
            });
          }
        }
        if (cells.isNotEmpty) {
          rows.add(cells);
        }
      }
    }

    if (rows.isEmpty) return pw.Container();

    // Calculate column widths based on content
    final columnWidths = _calculateColumnWidths(rows);

    // Build table with advanced styling
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Table(
        border: _options.tableStyle.showBorders
            ? pw.TableBorder.all(color: _options.tableStyle.borderColor)
            : null,
        columnWidths: columnWidths,
        children: rows.asMap().entries.map((entry) {
          final rowIndex = entry.key;
          final cells = entry.value;
          final isHeaderRow = rowIndex == 0;

          return pw.TableRow(
            decoration: _getRowDecoration(rowIndex, isHeaderRow),
            children: cells
                .map((cell) => _buildTableCell(cell, isHeaderRow))
                .toList(),
          );
        }).toList(),
      ),
    );
  }

  /// Calculate optimal column widths based on content
  Map<int, pw.TableColumnWidth> _calculateColumnWidths(
      List<List<Map<String, dynamic>>> rows) {
    if (rows.isEmpty) return {};

    final columnCount = rows.first.length;
    final columnWidths = <int, pw.TableColumnWidth>{};

    if (_options.enableAdvancedTables) {
      // Calculate content-based widths
      final maxLengths = List<int>.filled(columnCount, 0);

      for (final row in rows) {
        for (int i = 0; i < row.length && i < columnCount; i++) {
          final contentLength = row[i]['content'].toString().length;
          if (contentLength > maxLengths[i]) {
            maxLengths[i] = contentLength;
          }
        }
      }

      final totalLength = maxLengths.reduce((a, b) => a + b);

      for (int i = 0; i < columnCount; i++) {
        if (totalLength > 0) {
          final ratio = maxLengths[i] / totalLength;
          columnWidths[i] = pw.FlexColumnWidth(ratio);
        } else {
          columnWidths[i] = const pw.FlexColumnWidth(1.0);
        }
      }
    } else {
      // Use equal width columns
      for (int i = 0; i < columnCount; i++) {
        columnWidths[i] = const pw.FlexColumnWidth(1.0);
      }
    }

    return columnWidths;
  }

  /// Get row decoration based on styling options
  pw.BoxDecoration? _getRowDecoration(int rowIndex, bool isHeaderRow) {
    if (isHeaderRow) {
      return pw.BoxDecoration(
        color: _options.tableStyle.headerBackgroundColor,
      );
    }

    if (_options.tableStyle.alternateRowColors && rowIndex % 2 == 1) {
      return pw.BoxDecoration(
        color: _options.tableStyle.alternateRowColor,
      );
    }

    return null;
  }

  /// Build individual table cell
  pw.Widget _buildTableCell(Map<String, dynamic> cell, bool isHeaderRow) {
    final content = cell['content'].toString();
    final isHeader = cell['isHeader'] as bool || isHeaderRow;
    final alignment = cell['alignment'] as pw.TextAlign;

    return pw.Padding(
      padding: _options.tableStyle.cellPadding,
      child: pw.Text(
        content,
        style: isHeader
            ? _styles.tableHeader
            .copyWith(color: _options.tableStyle.headerTextColor)
            : _styles.tableCell,
        textAlign: alignment,
      ),
    );
  }

  /// Get cell alignment from markdown attributes
  pw.TextAlign _getCellAlignment(md.Element cell) {
    // Check for alignment attributes in the cell
    final attributes = cell.attributes;
    final align = attributes['align']?.toLowerCase();
    switch (align) {
      case 'left':
        return pw.TextAlign.left;
      case 'center':
        return pw.TextAlign.center;
      case 'right':
        return pw.TextAlign.right;
      case 'justify':
        return pw.TextAlign.justify;
      default:
        return pw.TextAlign.left;
    }
  }
}
