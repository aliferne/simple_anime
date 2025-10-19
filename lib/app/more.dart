import 'package:flutter/material.dart';
import 'package:simple_anime/app/routes.dart';
import 'package:simple_anime/plugins/interaction_provider.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildOptionButton(
          title: 'Settings',
          leading: Icon(Icons.settings),
          onTap: () {
            Navigator.of(context).pushNamed(Routes.settings);
          },
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    Widget? leading,
    required String title,
    Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: getListTileButton(title: title, leading: leading, onTap: onTap),
    );
  }
}
