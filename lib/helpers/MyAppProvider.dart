import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyAppProvider extends StatelessWidget {
  const MyAppProvider({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // This is a stream that shows how many seconds have elapsed.
        StreamProvider<int>(
          initialData: 0,
          create: (BuildContext context) =>
              Stream.periodic(Duration(milliseconds: 1000), (i) => i), 
        ),
        ChangeNotifierProvider<_MyCounterState>.value(
          value: _MyCounterState(),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: _MyDemoApp(),
      ),
    );
  }
}

// ###1. Define a state class, extending from ChangeNotifier.
class _MyCounterState extends ChangeNotifier {
  int _counter = 0;

  int get counterValue => _counter;

  void incrementCounter() {
    _counter++;
    // Must add notifyListeners() when UI need to be changed.
    notifyListeners();
  }

  void decrementCounter() {
    _counter--;
    notifyListeners();
  }
}

class _MyDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Text("Provider is the officially recommended way to manage app states, "
            "it's quite similar to ScopedModel in sharing/updating of app's "
            "state from children widgets down the widgets tree. In addition, "
            "you can provider multiple states at app root.\n\n"
            "In this example, the app's root widget is a MultiProvider, which "
            "provides two states: the number of seconds elapsed (StreamProvider) "
            "and the counter value(ChangeNotifierProvider).\n\n"
            "There's a text widget showing the seconds elapsed, and tow card "
            "widgets showing the counter value. Clicking on child widget's "
            "button would update the _MyCounterState of the app.\n"),
        _AppRootWidget(),
      ],
    );
  }
}

class _AppRootWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        children: <Widget>[
          Text('(root widget)'),
          Text('${Provider.of<int>(context)} seconds elapsed'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _CounterAndButton(),
              _CounterAndButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterAndButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Way 1 to get state up the tree: Provider.of.
    final state = Provider.of<_MyCounterState>(context);
    return Card(
      margin: EdgeInsets.all(4).copyWith(top: 32, bottom: 32),
      color: Colors.white70,
      child: Column(
        children: <Widget>[
          Text('(child widget)'),
          Text(
            '${state.counterValue}',
            style: Theme.of(context).textTheme.display1,
          ),
          ButtonBar(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => state.incrementCounter(),
              ),
              // Way 2 to get state up the tree: wrap a Consumer widget.
              Consumer<_MyCounterState>(
                builder: (BuildContext context, _MyCounterState value,
                    Widget child) {
                  return IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () => value.decrementCounter(),
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
