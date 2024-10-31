import 'package:flutter/material.dart';

class MyDrawerTile extends StatelessWidget {
  final String tileName;
  final IconData tileIcon;
  final void Function()? onTap;

  const MyDrawerTile({
    super.key,
    required this.tileName,
    required this.tileIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        tileIcon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        tileName,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onTap: onTap,
    );
  }
}
