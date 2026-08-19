import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class GetHelpScreen extends StatelessWidget {
  const GetHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Get Help"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          _buildHelpTile(context, Icons.question_answer, "FAQ", "Frequently asked questions"),
          _buildHelpTile(context, Icons.email, "Email Us", "Support response within 24h"),
          _buildHelpTile(context, Icons.phone, "Call Us", "Available 9am - 6pm"),
          _buildHelpTile(context, Icons.chat_bubble, "Live Chat", "Chat with our support team"),
        ],
      ),
    );
  }

  Widget _buildHelpTile(BuildContext context, IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: blackColor40)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}
