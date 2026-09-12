import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QR d'un billet RuachEdu : modules Ink haute lisibilité, yeux or, monogramme
/// central. Fond blanc forcé même en thème sombre — les lecteurs exigent une
/// zone claire ; l'identité passe par les formes, la couleur des yeux, le
/// monogramme et le cadre, jamais au prix du contraste.
class TicketQrView extends StatelessWidget {
  const TicketQrView({super.key, required this.data, this.dimension = 232});

  final String data;
  final double dimension;

  static const _mark = 'assets/images/ruachedu-mark-transparent.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: RuachColors.white,
        borderRadius: BorderRadius.circular(RuachRadius.lg),
        border: Border.all(color: RuachColors.gold300, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(_mark, width: 18, height: 18),
              const SizedBox(width: RuachSpace.s2),
              const Text(
                'RuachEdu',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: RuachColors.cream900,
                ),
              ),
            ],
          ),
          const SizedBox(height: RuachSpace.s3),
          QrImageView(
            data: data,
            size: dimension,
            backgroundColor: RuachColors.white,
            gapless: false,
            errorCorrectionLevel: QrErrorCorrectLevel.H,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.circle,
              color: RuachColors.gold600,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.circle,
              color: RuachColors.cream900,
            ),
            embeddedImage: const AssetImage(_mark),
            embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(38, 38)),
          ),
        ],
      ),
    );
  }
}
