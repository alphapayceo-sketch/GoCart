import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  final languages = ['English', 'French', 'Spanish', 'German', 'Arabic'];
  String selected = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(defaultPadding),
        itemCount: languages.length,
        separatorBuilder: (_, __) => const SizedBox(height: defaultPadding / 2),
        itemBuilder: (context, index) {
          final language = languages[index];
          final isSelected = language == selected;

          return ListTile(
            tileColor: isSelected ? primaryColor.withValues(alpha: 0.1) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultBorderRadious),
              side: BorderSide(
                color:
                    isSelected ? primaryColor : Theme.of(context).dividerColor,
              ),
            ),
            title: Text(language),
            trailing: isSelected ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() => selected = language);
            },
          );
        },
      ),
    );
  }
}
