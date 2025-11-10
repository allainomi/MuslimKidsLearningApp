import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MuslimKidsApp());
}

class MuslimKidsApp extends StatefulWidget {
  const MuslimKidsApp({Key? key}) : super(key: key);

  @override
  State<MuslimKidsApp> createState() => _MuslimKidsAppState();
}

class _MuslimKidsAppState extends State<MuslimKidsApp> {
  Locale _locale = const Locale('en');

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'en' ? const Locale('ur') : const Locale('en');
    });
  }

  String t(String en, String ur) => _locale.languageCode == 'en' ? en : ur;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muslim Kids Learning App',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(toggleLocale: _toggleLocale, t: t),
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback toggleLocale;
  final String Function(String, String) t;
  const HomeScreen({required this.toggleLocale, required this.t, Key? key}) : super(key: key);

  Future<List<dynamic>> _loadJson(String path) async {
    final raw = await rootBundle.loadString(path);
    return json.decode(raw) as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final title = t('Muslim Kids Learning App', 'مسلمان بچوں کے لیے تعلیمی ایپ');
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: t('Toggle Language', 'زبان تبدیل کریں'),
            icon: const Icon(Icons.language),
            onPressed: toggleLocale,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          CardItem(
            title: t('Quran', 'قرآن'),
            subtitle: t('Short Surahs with audio', 'مختصر سورتیں - آڈیو کے ساتھ'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GenericListScreen(
              title: t('Quran', 'قرآن'),
              assetPath: 'assets/data/surahs.json',
              t: t,
            ))),
          ),
          CardItem(
            title: t('Duas', 'دعائیں'),
            subtitle: t('Daily supplications', 'روزمرہ کی دعائیں'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GenericListScreen(
              title: t('Duas', 'دعائیں'),
              assetPath: 'assets/data/duas.json',
              t: t,
            ))),
          ),
          CardItem(
            title: t('Stories', 'کہانیاں'),
            subtitle: t('Islamic stories for kids', 'بچوں کے لیے اسلامی کہانیاں'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GenericListScreen(
              title: t('Stories', 'کہانیاں'),
              assetPath: 'assets/data/stories.json',
              t: t,
            ))),
          ),
          CardItem(
            title: t('Quiz', 'کوئز'),
            subtitle: t('Fun multiple-choice questions', 'دلچسپ سوالات'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(t: t))),
          ),
        ],
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const CardItem({required this.title, required this.subtitle, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical:8),
      child: ListTile(
        leading: const Icon(Icons.menu_book_outlined),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class GenericListScreen extends StatefulWidget {
  final String title;
  final String assetPath;
  final String Function(String, String) t;
  const GenericListScreen({required this.title, required this.assetPath, required this.t, Key? key}) : super(key: key);

  @override
  State<GenericListScreen> createState() => _GenericListScreenState();
}

class _GenericListScreenState extends State<GenericListScreen> {
  List<dynamic> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString(widget.assetPath);
    setState(() {
      items = (json.decode(raw) as List<dynamic>);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: loading ? const Center(child: CircularProgressIndicator()) :
      ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (_, i){
          final it = items[i];
          final nameEn = it['title_en'] ?? it['title'] ?? 'Item';
          final nameUr = it['title_ur'] ?? it['title'] ?? 'آئٹم';
          return ListTile(
            title: Text(widget.t(nameEn, nameUr)),
            subtitle: it['subtitle_en']!=null ? Text(widget.t(it['subtitle_en'], it['subtitle_ur'] ?? '')) : null,
          );
        }
      ),
    );
  }
}

class QuizScreen extends StatelessWidget {
  final String Function(String, String) t;
  const QuizScreen({required this.t, Key? key}) : super(key: key);

  final sample = const [
    {"q_en":"Which is the first surah of the Quran?","q_ur":"قرآن کی پہلی سورہ کون سی ہے؟","options":["Al-Fatiha","Al-Baqarah","Al-Ikhlas"],"answer":0},
    {"q_en":"What do we say before eating?","q_ur":"کھانے سے پہلے ہم کیا کہتے ہیں؟","options":["Bismillah","Alhamdulillah","Subhanallah"],"answer":0}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('Quiz', 'کوئز')),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sample.length,
        itemBuilder: (_, i){
          final q = sample[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical:8),
            child: ListTile(
              title: Text(t(q['q_en']!, q['q_ur']!)),
              subtitle: Text(t('Options available','جوابات دستیاب')),
            ),
          );
        }
      ),
    );
  }
}
