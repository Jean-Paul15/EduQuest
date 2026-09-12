import 'package:eduquest/features/assistant/domain/ai_chat_artifact.dart';
import 'package:eduquest/shared/ui/chart_palette.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum PlotMode { preview, full }

/// Rendu d'un artifact `plot`.
///
/// - [PlotMode.preview] : croquis dépouillé (axes au zéro, pas de cadre ni de
///   graduations, pas d'interaction) — sert d'accroche vers le plein écran.
/// - [PlotMode.full] : graduations, grille, lecture des coordonnées au toucher,
///   pincer pour zoomer.
class ArtifactPlot extends StatelessWidget {
  const ArtifactPlot({
    super.key,
    required this.data,
    this.mode = PlotMode.preview,
    this.showGrid = true,
    this.showAsymptotes = true,
    this.showFeatures = true,
    this.transformationController,
  });

  final Map<String, dynamic> data;
  final PlotMode mode;
  final bool showGrid;
  final bool showAsymptotes;
  final bool showFeatures;
  final TransformationController? transformationController;

  bool get _full => mode == PlotMode.full;

  ({double minX, double maxX, double minY, double maxY}) get _bounds {
    final d = data['domain'];
    final x = (d is Map ? d['x'] : null) as List? ?? const [-10, 10];
    final y = (d is Map ? d['y'] : null) as List? ?? const [-10, 10];
    return (
      minX: (x.first as num).toDouble(),
      maxX: (x.last as num).toDouble(),
      minY: (y.first as num).toDouble(),
      maxY: (y.last as num).toDouble(),
    );
  }

  List<Map> get _asymptotes {
    final feats = data['features'];
    final list = (feats is Map ? feats['asymptotes'] : null) as List? ?? const [];
    return list.whereType<Map>().toList();
  }

  List<({String label, Color color})> _seriesLegend(Brightness brightness) {
    final series = (data['series'] as List?) ?? const [];
    return [
      for (var s = 0; s < series.length; s++)
        (
          label: '${(series[s] as Map)['label'] ?? 'f${s + 1}'}',
          color: RuachChart.seriesAt(brightness, s),
        ),
    ];
  }

  List<LineChartBarData> _bars(ColorScheme scheme, Brightness brightness) {
    final bars = <LineChartBarData>[];
    final series = (data['series'] as List?) ?? const [];
    for (var s = 0; s < series.length; s++) {
      final color = RuachChart.seriesAt(brightness, s);
      final segments = (series[s] as Map)['segments'] as List? ?? const [];
      for (final seg in segments) {
        final spots = <FlSpot>[];
        for (final p in seg as List) {
          final pt = p as List;
          final x = (pt[0] as num).toDouble();
          final y = (pt[1] as num).toDouble();
          if (x.isFinite && y.isFinite) spots.add(FlSpot(x, y));
        }
        if (spots.length < 2) continue;
        bars.add(LineChartBarData(
          spots: spots,
          color: color,
          barWidth: _full ? 2.4 : 2,
          isCurved: false,
          dotData: const FlDotData(show: false),
        ));
      }
    }
    final feats = data['features'];
    if (feats is Map && showFeatures) {
      final marks = <FlSpot>[];
      for (final k in ['roots', 'extrema']) {
        for (final m in (feats[k] as List? ?? const []).whereType<Map>()) {
          final x = m['x'], y = m['y'];
          if (x is num && y is num) marks.add(FlSpot(x.toDouble(), y.toDouble()));
        }
      }
      if (marks.isNotEmpty) {
        final mk = RuachChart.marker(scheme);
        bars.add(LineChartBarData(
          spots: marks..sort((a, b) => a.x.compareTo(b.x)),
          barWidth: 0,
          color: mk,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: _full ? 4 : 3,
              color: mk,
              strokeWidth: 1.5,
              strokeColor: scheme.surface,
            ),
          ),
        ));
      }
    }

    // Asymptote oblique : fl_chart ne trace que H/V nativement, on la pose
    // comme un segment pointillé sur toute la largeur du domaine.
    final asy = RuachChart.asymptote(scheme);
    final b = _bounds;
    for (final a in showAsymptotes ? _asymptotes : const <Map>[]) {
      if ('${a['kind']}' != 'oblique') continue;
      final m = a['m'], c = a['b'];
      if (m is! num || c is! num) continue;
      final md = m.toDouble(), cd = c.toDouble();
      bars.add(LineChartBarData(
        spots: [
          FlSpot(b.minX, md * b.minX + cd),
          FlSpot(b.maxX, md * b.maxX + cd),
        ],
        color: asy,
        barWidth: 1.2,
        dashArray: const [5, 4],
        dotData: const FlDotData(show: false),
      ));
    }
    return bars;
  }

  ExtraLinesData _extraLines(BuildContext context, ColorScheme scheme) {
    final h = <HorizontalLine>[];
    final v = <VerticalLine>[];
    final b = _bounds;
    final labelStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: scheme.onSurfaceVariant);

    if (!_full) {
      final ax = RuachChart.axis(scheme);
      if (b.minY <= 0 && b.maxY >= 0) {
        h.add(HorizontalLine(y: 0, color: ax, strokeWidth: 1));
      }
      if (b.minX <= 0 && b.maxX >= 0) {
        v.add(VerticalLine(x: 0, color: ax, strokeWidth: 1));
      }
    }

    final asy = RuachChart.asymptote(scheme);
    for (final a in showAsymptotes ? _asymptotes : const <Map>[]) {
      final kind = '${a['kind']}';
      if (kind == 'vertical' && a['x'] is num) {
        v.add(VerticalLine(
          x: (a['x'] as num).toDouble(),
          color: asy,
          strokeWidth: 1.2,
          dashArray: const [5, 4],
          label: _full
              ? VerticalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: labelStyle,
                  labelResolver: (_) => 'x = ${_fmt((a['x'] as num).toDouble())}',
                )
              : VerticalLineLabel(),
        ));
      } else if (kind == 'horizontal' && a['y'] is num) {
        h.add(HorizontalLine(
          y: (a['y'] as num).toDouble(),
          color: asy,
          strokeWidth: 1.2,
          dashArray: const [5, 4],
          label: _full
              ? HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: labelStyle,
                  labelResolver: (_) =>
                      '${a['label'] ?? 'y = ${_fmt((a['y'] as num).toDouble())}'}',
                )
              : HorizontalLineLabel(),
        ));
      }
    }
    return ExtraLinesData(horizontalLines: h, verticalLines: v);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final b = _bounds;
    final grid = RuachChart.grid(scheme);

    final chart = LineChart(
      LineChartData(
        minX: b.minX, maxX: b.maxX, minY: b.minY, maxY: b.maxY,
        clipData: const FlClipData.all(),
        lineBarsData: _bars(scheme, brightness),
        extraLinesData: _extraLines(context, scheme),
        gridData: FlGridData(
          show: _full && showGrid,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (_) => FlLine(color: grid, strokeWidth: .5),
          getDrawingVerticalLine: (_) => FlLine(color: grid, strokeWidth: .5),
        ),
        borderData: FlBorderData(show: false),
        titlesData: _full
            ? FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (v, _) =>
                        Text(_fmt(v), style: Theme.of(context).textTheme.labelSmall),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (v, _) =>
                        Text(_fmt(v), style: Theme.of(context).textTheme.labelSmall),
                  ),
                ),
              )
            : const FlTitlesData(
                topTitles: AxisTitles(),
                rightTitles: AxisTitles(),
                bottomTitles: AxisTitles(),
                leftTitles: AxisTitles(),
              ),
        lineTouchData: LineTouchData(
          enabled: _full,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '(${_fmt(s.x)} ; ${_fmt(s.y)})',
                      TextStyle(color: scheme.onInverseSurface, fontSize: 11),
                    ))
                .toList(),
          ),
        ),
      ),
    );

    final legend = _seriesLegend(brightness);
    final legendRow = legend.length > 1
        ? Padding(
            padding: EdgeInsets.only(top: _full ? RuachSpace.s2 : 6),
            child: Wrap(
              spacing: RuachSpace.s3,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                for (final e in legend)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 10, height: 3,
                      decoration: BoxDecoration(
                        color: e.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(e.label,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ]),
              ],
            ),
          )
        : null;

    if (!_full) {
      if (legendRow == null) return chart;
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Expanded(child: chart),
        legendRow,
      ]);
    }
    return Column(children: [
      Expanded(
        child: InteractiveViewer(
          transformationController: transformationController,
          minScale: 1,
          maxScale: 8,
          child: Padding(
            padding: const EdgeInsets.all(RuachSpace.s3),
            child: chart,
          ),
        ),
      ),
      if (legendRow != null)
        Padding(
          padding: const EdgeInsets.only(bottom: RuachSpace.s2),
          child: legendRow,
        ),
    ]);
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e6) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }
}

/// Route plein écran : explorer la courbe — pincer / boutons pour zoomer,
/// déplacer, lire les coordonnées au toucher, afficher/masquer grille,
/// asymptotes et points remarquables.
class ArtifactPlotPage extends StatefulWidget {
  const ArtifactPlotPage({super.key, required this.artifact});
  final AiChatArtifact artifact;

  @override
  State<ArtifactPlotPage> createState() => _ArtifactPlotPageState();
}

class _ArtifactPlotPageState extends State<ArtifactPlotPage> {
  final _tc = TransformationController();
  bool _grid = true;
  bool _asymptotes = true;
  bool _features = true;
  static const _min = 1.0;
  static const _max = 8.0;

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  void _scaleBy(double factor) {
    final current = _tc.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(_min, _max);
    final size = context.size ?? const Size(320, 320);
    final c = Offset(size.width / 2, size.height / 2);
    setState(() {
      _tc.value = Matrix4.identity()
        ..translateByDouble(c.dx, c.dy, 0, 1)
        ..scaleByDouble(next, next, 1, 1)
        ..translateByDouble(-c.dx, -c.dy, 0, 1);
    });
  }

  void _resetView() => setState(() => _tc.value = Matrix4.identity());

  bool get _hasAsymptotes {
    final f = widget.artifact.data['features'];
    return f is Map && (f['asymptotes'] as List? ?? const []).isNotEmpty;
  }

  bool get _hasFeatures {
    final f = widget.artifact.data['features'];
    if (f is! Map) return false;
    return (f['roots'] as List? ?? const []).isNotEmpty ||
        (f['extrema'] as List? ?? const []).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: RuachAppBar(
        title: widget.artifact.title.isEmpty ? 'Courbe' : widget.artifact.title,
        showBack: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                RuachSpace.s3, RuachSpace.s2, RuachSpace.s3, 0,
              ),
              child: Wrap(
                spacing: RuachSpace.s2,
                children: [
                  FilterChip(
                    label: const Text('Grille'),
                    selected: _grid,
                    onSelected: (v) => setState(() => _grid = v),
                  ),
                  if (_hasAsymptotes)
                    FilterChip(
                      label: const Text('Asymptotes'),
                      selected: _asymptotes,
                      onSelected: (v) => setState(() => _asymptotes = v),
                    ),
                  if (_hasFeatures)
                    FilterChip(
                      label: const Text('Points'),
                      selected: _features,
                      onSelected: (v) => setState(() => _features = v),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ArtifactPlot(
                      data: widget.artifact.data,
                      mode: PlotMode.full,
                      showGrid: _grid,
                      showAsymptotes: _asymptotes,
                      showFeatures: _features,
                      transformationController: _tc,
                    ),
                  ),
                  Positioned(
                    right: RuachSpace.s3,
                    bottom: RuachSpace.s3,
                    child: Column(
                      children: [
                        _ZoomButton(
                          icon: Icons.add_rounded,
                          onTap: () => _scaleBy(1.5),
                          scheme: scheme,
                        ),
                        const SizedBox(height: RuachSpace.s2),
                        _ZoomButton(
                          icon: Icons.remove_rounded,
                          onTap: () => _scaleBy(1 / 1.5),
                          scheme: scheme,
                        ),
                        const SizedBox(height: RuachSpace.s2),
                        _ZoomButton(
                          icon: Icons.center_focus_strong_rounded,
                          onTap: _resetView,
                          scheme: scheme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.onTap,
    required this.scheme,
  });
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RuachRadius.md),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(RuachRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(RuachSpace.s2),
          child: Icon(icon, size: 20, color: scheme.onSurface),
        ),
      ),
    );
  }
}
