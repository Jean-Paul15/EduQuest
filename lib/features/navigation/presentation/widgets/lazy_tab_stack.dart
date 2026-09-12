import 'package:flutter/material.dart';

class LazyTabStack extends StatefulWidget {
  const LazyTabStack({
    super.key,
    required this.index,
    required this.builders,
  });

  final int index;
  final List<WidgetBuilder> builders;

  @override
  State<LazyTabStack> createState() => _LazyTabStackState();
}

class _LazyTabStackState extends State<LazyTabStack> {
  late final List<bool> _built;

  @override
  void initState() {
    super.initState();
    _built = List<bool>.filled(widget.builders.length, false);
    _built[widget.index] = true;
  }

  @override
  void didUpdateWidget(covariant LazyTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_built[widget.index]) {
      _built[widget.index] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.builders.length, (index) {
        final visible = index == widget.index;
        return Offstage(
          offstage: !visible,
          child: ExcludeFocus(
            excluding: !visible,
            child: TickerMode(
              enabled: visible,
              child:
                  _built[index] ? widget.builders[index](context) : const SizedBox.shrink(),
            ),
          ),
        );
      }),
    );
  }
}
