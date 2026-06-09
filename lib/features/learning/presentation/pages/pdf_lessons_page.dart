import 'dart:async';
import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/learning/data/pdf_lesson_repository.dart';
import 'package:eduquest/features/learning/domain/pdf_lesson.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/ruach_animations.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:eduquest/features/learning/presentation/widgets/pdf_lesson_tile.dart';

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
    await context.pushNamed(AppRoutes.pdfViewer, queryParameters: {
      'title': l.title,
      'url': l.url,
      'emptyLabel': 'PDF non disponible.',
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_lessons.isEmpty) return const Center(child: CircularProgressIndicator());
    return ListView.separated(
      padding: const EdgeInsets.all(RuachSpace.s4),
      itemCount: _lessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
      itemBuilder: (_, i) {
        final l = _lessons[i];
        return staggerItem(
          index: i,
          child: PdfLessonTile(
            lesson: l,
            isOffline: _offline[l.id] == true,
            onTap: () => _open(l),
          ),
        );
      },
    );
  }
}
