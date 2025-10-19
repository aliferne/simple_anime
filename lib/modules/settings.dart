import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_anime/conf.dart';
// TODO: Rewrite backend (no flask), then add LikePage to demostrate liked pic
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: _buildAppThemeModeSettingBlock(
        context: context,
        blockTitle: "ThemeMode",
      ),
    );
  }

  Widget _buildAppThemeModeSettingBlock({
    required BuildContext context,
    required String blockTitle,
  }) {
    final themeMode = Provider.of<AppThemeMode>(context);

    return _buildSettingBlock(
      context: context,
      blockTitle: blockTitle,
      children: [
        _buildCustomContainer(
          context: context,
          top: 10,
          bottom: 10,
          child: ListTile(
            leading: Icon(Icons.brightness_medium),
            title: Text('Switch Mode'),
            trailing: DropdownButton(
              value: themeMode.themeModeString,
              items: [
                DropdownMenuItem(
                  value: AppThemeModeEnum.light.name,
                  child: Icon(Icons.sunny),
                ),
                DropdownMenuItem(
                  value: AppThemeModeEnum.dark.name,
                  child: Icon(Icons.nightlight),
                ),
                DropdownMenuItem(
                  value: AppThemeModeEnum.followSys.name,
                  child: Icon(Icons.sync),
                ),
              ],
              onChanged: (value) {
                themeMode.setAppThemeMode(value!);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomContainer({
    required BuildContext context,
    required Widget child,
    double top = 0,
    double bottom = 0,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.1,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.grey.withAlpha(15), spreadRadius: 2),
        ],
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(top),
          bottom: Radius.circular(bottom),
        ),
      ),
      child: child,
    );
  }

  Widget _buildSettingBlock({
    required BuildContext context,
    required String blockTitle,
    required List<Widget> children,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Align(alignment: Alignment.center, child: Text(blockTitle)),
        ),
        ...children,
      ],
    );
  }
}
