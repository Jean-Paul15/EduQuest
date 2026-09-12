import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Palette et primitives visuelles du bilan PDF, alignées sur le design system
/// RuachEdu (Ink / Gold / Cream). Aucun texte de contenu ici.
class BilanPalette {
  static final ink = PdfColor.fromInt(0xFF2A2218);
  static final gold = PdfColor.fromInt(0xFFC89A5A);
  static final goldDeep = PdfColor.fromInt(0xFFA97C3C);
  static final cream = PdfColor.fromInt(0xFFF7F0E3);
  static final creamLine = PdfColor.fromInt(0xFFE7D9C2);
  static final body = PdfColor.fromInt(0xFF3A3226);
  static final muted = PdfColor.fromInt(0xFF7A6E5C);
  static final radarFill = PdfColor.fromInt(0x55C89A5A);
}

pw.ThemeData? _cachedTheme;

/// Thème serif du bilan. Tinos est métriquement compatible avec Times New Roman
/// et couvre l'Unicode latin étendu (accents français, apostrophe typographique),
/// ce que les polices PDF intégrées (`Font.times()`) ne savent pas faire. Les
/// fichiers sont embarqués comme assets : aucune dépendance réseau à l'export.
Future<pw.ThemeData> buildBilanTheme() async {
  if (_cachedTheme != null) return _cachedTheme!;
  Future<pw.Font> load(String v) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/Tinos-$v.ttf'));
  _cachedTheme = pw.ThemeData.withFont(
    base: await load('Regular'),
    bold: await load('Bold'),
    italic: await load('Italic'),
    boldItalic: await load('BoldItalic'),
  ).copyWith(
    defaultTextStyle:
        pw.TextStyle(fontSize: 10.5, color: BilanPalette.body, lineSpacing: 2.5),
  );
  return _cachedTheme!;
}

/// Bandeau de couverture : grand code Holland sur fond crème, filet doré.
pw.Widget bilanCover(String hollandCode, String? subtitle) => pw.Container(
  width: double.infinity,
  padding: const pw.EdgeInsets.fromLTRB(24, 26, 24, 22),
  decoration: pw.BoxDecoration(
    color: BilanPalette.cream,
    borderRadius: pw.BorderRadius.circular(10),
    border: pw.Border.all(color: BilanPalette.creamLine),
  ),
  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Text('Ton bilan d’orientation',
        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: BilanPalette.ink)),
    pw.SizedBox(height: 10),
    pw.Text(hollandCode,
        style: pw.TextStyle(
            fontSize: 40, fontWeight: pw.FontWeight.bold, color: BilanPalette.goldDeep, letterSpacing: 3)),
    pw.SizedBox(height: 6),
    pw.Container(width: 54, height: 3, color: BilanPalette.gold),
    if (subtitle != null && subtitle.isNotEmpty) ...[
      pw.SizedBox(height: 10),
      pw.Text(subtitle, style: pw.TextStyle(fontSize: 10, color: BilanPalette.muted)),
    ],
  ]),
);

/// Titre de section avec filet doré dessous, cohérent partout dans le document.
pw.Widget bilanSectionTitle(String text) => pw.Container(
  margin: const pw.EdgeInsets.only(top: 6, bottom: 8),
  padding: const pw.EdgeInsets.only(bottom: 4),
  decoration: pw.BoxDecoration(
    border: pw.Border(bottom: pw.BorderSide(color: BilanPalette.gold, width: 1.5)),
  ),
  child: pw.Text(text,
      style: pw.TextStyle(fontSize: 13.5, fontWeight: pw.FontWeight.bold, color: BilanPalette.ink)),
);

pw.Widget bilanFooter(pw.Context c) => pw.Container(
  alignment: pw.Alignment.centerLeft,
  margin: const pw.EdgeInsets.only(top: 8),
  child: pw.Text(
    'Bilan fondé sur le modèle RIASEC (Holland). Outil d’aide à la décision, '
    'pas un verdict. Page ${c.pageNumber} sur ${c.pagesCount}.',
    style: pw.TextStyle(fontSize: 7.5, color: BilanPalette.muted),
  ),
);
