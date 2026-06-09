import 'dart:async';
import 'dart:typed_data';
import 'package:eduquest/features/gamification/data/revision_tracker.dart';
import 'package:eduquest/features/offline/data/pdf_runtime_cache.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AppPdfViewer extends StatefulWidget {
  const AppPdfViewer({super.key, required this.url, required this.emptyLabel});
  final String url;
  final String emptyLabel;

  @override
  State<AppPdfViewer> createState() => _AppPdfViewerState();
}

class _AppPdfViewerState extends State<AppPdfViewer> {
  final _cache = PdfRuntimeCache();
  final _tracker = RevisionTracker();
  String? _error;
  List<int>? _bytes;
  bool _booting = true;
  late final DateTime _openedAt;

  bool get _valid => widget.url.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _openedAt = _tracker.start();
    _boot();
  }

  @override
  void dispose() {
    unawaited(_tracker.stop(_openedAt));
    super.dispose();
  }

  Future<void> _boot() async {
    if (!_valid) {
      if (mounted) setState(() => _booting = false);
      return;
    }
    final cached = await _cache.load(widget.url);
    if (mounted) {
      setState(() {
        _bytes = cached;
        _booting = false;
      });
    }
    unawaited(_sync());
  }

  Future<void> _sync() async {
    if (!_valid) return;
    final synced = await _cache.sync(widget.url);
    if (mounted && synced != null) {
      setState(() => _bytes = synced);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_valid) {
      return EmptyState(title: 'PDF indisponible', subtitle: widget.emptyLabel);
    }
    if (_error != null) {
      return EmptyState(title: 'Lecture impossible', subtitle: _error!);
    }
    final b = _bytes;
    if (b != null && b.isNotEmpty) {
      return SfPdfViewer.memory(
        Uint8List.fromList(b),
        canShowPaginationDialog: true,
        enableDoubleTapZooming: true,
        onDocumentLoadFailed: (d) => setState(() => _error = d.description),
      );
    }
    if (_booting) return const Center(child: CircularProgressIndicator());
    return SfPdfViewer.network(
      widget.url,
      canShowPaginationDialog: true,
      enableDoubleTapZooming: true,
      onDocumentLoadFailed: (d) => setState(() => _error = d.description),
    );
  }
}

