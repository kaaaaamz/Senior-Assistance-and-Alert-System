import 'package:authtest/welcome.dart';
import 'package:flutter/material.dart';
import 'package:authtest/roles.dart';
import 'package:authtest/langconsts.dart';
import 'package:authtest/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);
  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  List<Language> languages = Language.languageList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body:Stack(children: [
        Padding(
        padding: EdgeInsets.fromLTRB(10, 100, 10, 10),
        child: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          return Container(
            
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  leading: Text(
                    languages[index].flag,
                    style: TextStyle(fontSize: 20),
                  ),
                  title: Text(languages[index].name),
                  subtitle: Text(languages[index].languageCode),
                  onTap: () async {
                      Locale _locale = await setLocale(languages[index].languageCode);
                      MyApp.setLocale(context, _locale);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WelcomePage(),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    ),
    Positioned(
  top: 33,
  left: 0,
  child: Row(
    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
    // crossAxisAlignment: CrossAxisAlignment.baseline,
    children: [
      IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  ),
),
      ]
      )
    );
  }
}
class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;

  Language(this.id, this.flag, this.name, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, "🇬🇧", "English", "en"),
      Language(2, "🇩🇿", "اَلْعَرَبِيَّةُ", "ar"),
      Language(3, "🇫🇷", "français", "fr"),
    ];
  }
}