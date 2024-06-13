import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: "Aplikasi Ari",
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Color.fromARGB(255, 4, 250, 110))),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    history.add(current);
    notifyListeners();
  }

  void Semuahapus() {
    history.clear();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  Future<void> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? favoritesList = prefs.getStringList('favorites');
    if (favoritesList != null) {
      favorites = favoritesList
          .map((fav) => WordPair(fav.split(' ')[0], fav.split(' ')[1]))
          .toList();
    }
  }

  Future<void> saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> favoritesList =
        favorites.map((fav) => fav.asPascalCase).toList();
    prefs.setStringList('favorites', favoritesList);
  }

  void touglefav() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
      case 1:
        page = const favoritePage();
      case 2:
        page = const historyPage();
      default:
        page = const Placeholder();
    }

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'home'),
          NavigationDestination(
              selectedIcon: Icon(Icons.favorite),
              icon: Icon(Icons.favorite_border_outlined),
              label: 'favorite'),
          NavigationDestination(
              selectedIcon: Icon(Icons.history),
              icon: Icon(Icons.history),
              label: 'history'),
        ],
      ),
      body: Container(
        child: page,
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("My Rendom idea: "),
          BigCard(pair: pair),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.touglefav();

                  //snackbar
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text('fav/UnFav word ${appState.current}'),
                    ));
                },
                icon: Icon(icon),
                label: const Text("Favorite"),
              ),
              const SizedBox(width: 25),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text("Generate"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          pair.asLowerCase,
          style: style,
        ),
      ),
    );
  }
}

class favoritePage extends StatelessWidget {
  const favoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Container(
      child: ListView(
        children: [
          Text(
            'You have ${appState.favorites.length} jumlah:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          // Text("BELAJAR FLUTTER JAGO")
          ...appState.favorites.map((wp) => ListTile(
                title: Text(wp.asCamelCase),
                onTap: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text('fav/UnFav word ${appState.current}'),
                    ));
                },
              ))
        ],
      ),
    );
  }
}

class historyPage extends StatelessWidget {
  const historyPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    // MyAppState historyState = context.watch<MyAppState>();
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            Text(
              'You have ${appState.history.length} jumlah:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...appState.history.map((wp) => ListTile(
                  title: Text(wp.asCamelCase),
                  onTap: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text('fav/UnFav word ${appState.current}'),
                      ));
                  },
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appState.Semuahapus();
        },
        child: Icon(Icons.delete),
      ),
    );
  }
}
