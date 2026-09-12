import 'package:eduquest/shared/sync/service_locator.dart' hide ConnectionState;
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Download button + progress bar for video offline caching.
/// Shows a progress bar during download, a checkmark briefly when done,
/// or a download button when ready to download.
class VideoDownloadBar extends StatelessWidget {
  const VideoDownloadBar({
    super.key,
    required this.isDownloading,
    required this.progress,
    required this.isComplete,
    required this.onDownload,
  });
  final bool isDownloading;
  final double progress;
  final bool isComplete;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final can = ServiceLocator().oracle.canDownloadMedia;
    final p = const EdgeInsets.symmetric(
        horizontal: RuachSpace.s4, vertical: RuachSpace.s2);
    if (isDownloading) {
      return Padding(padding: p, child: Row(children: [
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(RuachRadius.full),
          child: LinearProgressIndicator(value: progress > 0 ? progress : null,
            minHeight: 6, backgroundColor: s.surfaceContainerHighest,
            color: RuachColors.gold500))),
        const SizedBox(width: RuachSpace.s2),
        Text('${(progress * 100).toInt()}%',
            style: TextStyle(color: s.onSurfaceVariant, fontSize: 12)),
      ]));
    }
    return Padding(padding: p, child: SizedBox(width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: can ? onDownload : null,
        icon: Icon(isComplete ? PhosphorIconsRegular.checkCircle
            : PhosphorIconsRegular.downloadSimple, size: 20),
        label: Text(isComplete
            ? 'Téléchargée pour hors-ligne'
            : 'Télécharger pour hors-ligne'),
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RuachRadius.full)),
          foregroundColor: Theme.of(context).colorScheme.primary,
          disabledForegroundColor: s.onSurfaceVariant,
          textStyle: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 12, height: 16 / 12)),
      )));
  }
}
