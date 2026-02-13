import 'dart:async';
import 'package:eduquest/features/learning/data/pdf_lesson_repository.dart';
import 'package:eduquest/features/learning/domain/pdf_lesson.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/pdf/app_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PdfLessonsPage extends StatefulWidget {
  const PdfLessonsPage({super.key});
  @override
  State<PdfLessonsPage> createState() => _PdfLessonsPageState();
}

class _PdfLessonsPageState extends State<PdfLessonsPage> {
  final _repo = PdfLessonRepository();
  List<PdfLesson> _lessons = const [];
  final Map<String, bool> _offline = {};
  RealtimeChannel? _channel;

  @override
  void initState() { super.initState(); _load(); _startRealtime(); }

  @override
  void dispose() {
    final ch = _channel;
    if (ch != null) Supabase.instance.client.removeChannel(ch);
    super.dispose();
  }

  Future<void> _load() async {
    final lessons = await _repo.listPublished();
    if (!mounted) return;
    for (final l in lessons) { _offline[l.id] = await _repo.isAvailableOffline(l); }
    if (!mounted) return;
    setState(() => _lessons = lessons);
    unawaited(_silentRefresh(lessons));
  }

  Future<void> _silentRefresh(List<PdfLesson> lessons) async {
    await _repo.warmAndRefresh(lessons);
    for (final l in lessons) { _offline[l.id] = await _repo.isAvailableOffline(l); }
    if (mounted) setState(() {});
  }

  void _startRealtime() {
    if (!Env.hasSupabase) return;
    _channel = Supabase.instance.client.channel('pdf-lessons')
      .onPostgresChanges(
        event: PostgresChangeEvent.all, schema: 'public', table: 'resources',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'type', value: 'pdf'),
        callback: (_) => _load())
      .subscribe();
  }

  Future<void> _open(PdfLesson l) async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => AppPdfViewerPage(title: l.title, url: l.url, emptyLabel: 'PDF non disponible.')));
  }

  @override
  Widget build(BuildContext context) {
    if (_lessons.isEmpty) return const Center(child: CircularProgressIndicator());
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpace.l),
      itemCount: _lessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpace.s),
      itemBuilder: (_, i) {
        final l = _lessons[i];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(AppRadius.card)),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(AppRadius.xs)),
              child: const Icon(Icons.picture_as_pdf_rounded, size: 20, color: AppColors.primary)),
            title: Text(l.title, style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            subtitle: Text(_offline[l.id] == true ? 'Disponible hors ligne' : 'Synchronisation...',
              style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            onTap: () => _open(l)),
        );
      },
    );
  }
}
