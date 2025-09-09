import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return PopupMenuButton<String>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                languageProvider.currentLanguageName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          onSelected: (String value) {
            if (value == 'en') {
              languageProvider.changeLanguage('en', 'US');
            } else if (value == 'vi') {
              languageProvider.changeLanguage('vi', 'VN');
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  const Text('🇺🇸'),
                  const SizedBox(width: 8),
                  const Text('English'),
                  if (languageProvider.currentLocale.languageCode == 'en')
                    const Icon(Icons.check, color: Colors.green),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'vi',
              child: Row(
                children: [
                  const Text('🇻🇳'),
                  const SizedBox(width: 8),
                  const Text('Tiếng Việt'),
                  if (languageProvider.currentLocale.languageCode == 'vi')
                    const Icon(Icons.check, color: Colors.green),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
