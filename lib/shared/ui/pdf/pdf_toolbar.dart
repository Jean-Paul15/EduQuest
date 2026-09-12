import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';

class PdfToolbar extends StatelessWidget {
  const PdfToolbar({super.key, required this.controller,
    required this.currentPage, required this.totalPages,
    required this.viewedPages, required this.onMarkComplete,
    this.onToggleBookmarks, this.onSearch});

  final PdfViewerController controller;
  final int currentPage;
  final int totalPages;
  final Set<int> viewedPages;
  final VoidCallback onMarkComplete;
  final VoidCallback? onToggleBookmarks;
  final VoidCallback? onSearch;

  double get _pct => totalPages > 0 ? viewedPages.length / totalPages : 0;
  void _zIn() => controller.zoomLevel =
      (controller.zoomLevel + 0.25).clamp(0.5, 3.0);
  void _zOut() => controller.zoomLevel =
      (controller.zoomLevel - 0.25).clamp(0.5, 3.0);

  void _jumpDlg(BuildContext context) {
    final tc = TextEditingController(text: '$currentPage');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: RuachColors.ink50,
      title: const Text('Aller à la page',
          style: TextStyle(color: RuachColors.cream50)),
      content: TextField(controller: tc,
        keyboardType: TextInputType.number, autofocus: true,
        style: const TextStyle(color: RuachColors.cream50),
        decoration: const InputDecoration(
          hintText: 'Numéro de page',
          hintStyle: TextStyle(color: RuachColors.cream500))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: const Text('Annuler',
              style: TextStyle(color: RuachColors.cream500))),
        TextButton(onPressed: () {
          final p = int.tryParse(tc.text);
          if (p != null && p >= 1 && p <= totalPages) {
            controller.jumpToPage(p); Navigator.pop(ctx); }
        }, child: const Text('Aller',
            style: TextStyle(color: RuachColors.gold500))),
      ]));
  }

  Widget _btn(IconData i, double sz, VoidCallback? t, [double w = 40]) =>
      IconButton(icon: Icon(i, size: sz, color: RuachColors.cream50),
        onPressed: t, padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: w, minHeight: w));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: RuachColors.ink50,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(RuachRadius.lg))),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          _btn(PhosphorIconsRegular.caretLeft, 24,
              () => controller.previousPage()),
          Expanded(child: GestureDetector(
            onTap: () => _jumpDlg(context),
            child: Text('Page $currentPage / $totalPages',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14,
                    color: RuachColors.cream50)))),
          _btn(PhosphorIconsRegular.caretRight, 24,
              () => controller.nextPage()),
        ]),
        const SizedBox(height: RuachSpace.s1),
        ClipRRect(borderRadius: BorderRadius.circular(RuachRadius.full),
          child: LinearProgressIndicator(value: _pct,
            backgroundColor: RuachColors.ink400,
            color: RuachColors.gold500, minHeight: 4)),
        const SizedBox(height: RuachSpace.s1),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          if (onToggleBookmarks != null)
            _btn(PhosphorIconsRegular.bookmarks, 20, onToggleBookmarks, 36),
          if (onSearch != null)
            _btn(PhosphorIconsRegular.magnifyingGlass, 20, onSearch, 36),
          _btn(PhosphorIconsRegular.plus, 20, _zIn, 36),
          _btn(PhosphorIconsRegular.minus, 20, _zOut, 36),
          if (_pct >= 0.85 && totalPages > 0)
            RuachButton(label: 'Terminé', onPressed: onMarkComplete),
        ]),
      ]));
  }
}
