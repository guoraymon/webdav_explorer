import 'package:flutter/material.dart';

class LabelButton extends StatelessWidget {
  const LabelButton({
    Key? key,
    required this.icon,
    required this.label,
    this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32,
            color: onTap == null ? theme.disabledColor : null,
          ),
          Text(
            label,
            style: TextStyle(color: onTap == null ? theme.disabledColor : null),
          ),
        ],
      ),
    );
  }
}
