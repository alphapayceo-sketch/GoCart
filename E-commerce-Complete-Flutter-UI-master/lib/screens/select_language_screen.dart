import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  String selectedLanguage = "English";

  final List<Map<String, String>> languages = [
    {"name": "English", "flag": "🇺🇸"},
    {"name": "Spanish", "flag": "🇪🇸"},
    {"name": "French", "flag": "🇫🇷"},
    {"name": "German", "flag": "🇩🇪"},
    {"name": "Chinese", "flag": "🇨🇳"},
    {"name": "Japanese", "flag": "🇯🇵"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Language"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(defaultPadding),
        itemCount: languages.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final lang = languages[index];
          bool isSelected = selectedLanguage == lang["name"];
          return ListTile(
            onTap: () => setState(() => selectedLanguage = lang["name"]!),
            leading: Text(lang["flag"]!, style: const TextStyle(fontSize: 24)),
            title: Text(lang["name"]!, 
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primaryColor : blackColor,
                )),
            trailing: isSelected ? const Icon(Icons.check_circle, color: primaryColor) : null,
          );
        },
      ),
    );
  }
}
