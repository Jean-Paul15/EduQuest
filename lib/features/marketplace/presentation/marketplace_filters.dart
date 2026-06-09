import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MarketplaceFilters extends StatelessWidget {
  const MarketplaceFilters({
    super.key,
    required this.controller,
    required this.selectedType,
    required this.onSearch,
    required this.onTypeChanged,
  });

  final TextEditingController controller;
  final String? selectedType;
  final VoidCallback onSearch;
  final ValueChanged<String?> onTypeChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextField(
        controller: controller,
        onSubmitted: (_) => onSearch(),
        decoration: const InputDecoration(
          prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, size: 20),
          hintText: 'Recherche...',
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          for (final e in [
            (null, 'Tout'),
            ('book', 'Livres'),
            ('kit', 'Kits'),
            ('ad_slot', 'Ads'),
          ])
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(
                  e.$2,
                  style: TextStyle(
                    color: selectedType == e.$1
                        ? RuachColors.white
                        : RuachColors.cream900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: selectedType == e.$1,
                selectedColor: RuachColors.gold500,
                backgroundColor: RuachColors.cream50,
                side: BorderSide(
                  color: selectedType == e.$1
                      ? RuachColors.gold500
                      : RuachColors.cream200,
                ),
                onSelected: (_) => onTypeChanged(e.$1),
              ),
            ),
        ],
      ),
    ],
  );
}
