import 'dart:async';

import 'package:flutter/material.dart';
import 'package:widget_loading/widget_loading.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Loading',
      home: Example(),
    );
  }
}

class Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  int counter = 0;
  bool loading = true;

  late Future<Widget> future;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = Stream.periodic(Duration(seconds: 4)).listen((i) {
      setState(() {
        loading = !loading;
        counter++;
      });
    });

    future = Future.delayed(
      Duration(seconds: 4),
      () => Padding(
        padding: EdgeInsets.all(15.0),
        child: ListTile(
          leading: Text(
            'Loaded!',
            style: Theme.of(context).textTheme.headline5,
          ),
          trailing: Icon(
            Icons.account_circle,
            size: 50,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Center(
        child: ConstrainedBox(
          // Constraints for a nicer look in web demo
          constraints: BoxConstraints.loose(Size.fromWidth(750.0)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: WiperLoading.future(
                        minWidth: double.infinity,
                        future: future,
                      ),
                    ),
                  ),
                  counterCard(Curves.easeInOutCirc),
                  counterCard(Curves.easeInOutCirc,
                      builder: (width, height) => Container(
                          width: width,
                          height: height,
                          decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(5.0))),
                      wiperWidth: 50),
                  counterCard(
                    Curves.linear,
                    builder: (width, height) => Container(
                        width: width,
                        height: height,
                        decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(5.0))),
                    wiperWidth: 10,
                    deformingFactor: 0.2,
                    direction: WiperDirection.up,
                  ),
                  counterCard(Curves.easeInOutCirc,
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 30.0)),
                  counterCard(Curves.easeOutSine,
                      builder: (width, height) => Container(
                            width: width,
                            height: height,
                            decoration: BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                          ),
                      wiperWidth: 20),
                  counterCard(Curves.easeOutSine,
                      builder: (width, height) => Container(
                          width: width,
                          height: height,
                          decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(5.0))),
                      wiperWidth: 20,
                      direction: WiperDirection.left),
                  counterCardCircle(Curves.linear),
                  /*Padding(                            //web only
                    padding: const EdgeInsets.all(8.0),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => window.open('https://flutter.dev', 'new tab'),
                        child: Text('Made with Flutter'),
                      ),
                    ),
                  ),*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget counterCard(Curve curve,
          {WiperBuilder? builder,
          double wiperWidth = 15,
          double deformingFactor = 0.5,
          WiperDirection direction = WiperDirection.right,
          EdgeInsetsGeometry padding = const EdgeInsets.all(15.0)}) =>
      Card(
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: WiperLoading(
            wiperDeformingFactor: deformingFactor,
            curve: curve,
            wiperBuilder: builder,
            wiperWidth: wiperWidth,
            direction: direction,
            loading: loading,
            child: Padding(
              padding: padding,
              child: ListTile(
                leading: Text(
                  'Counter',
                  style: Theme.of(context).textTheme.headline5,
                ),
                trailing: Text(
                  '$counter',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            ),
          ),
        ),
      );

  Widget counterCardCircle(Curve curve, {WiperBuilder? builder}) => InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (c) => LoadingScaffold())),
        child: Card(
          elevation: 5.0,
          child: CircularWidgetLoading(
            dotColor: Colors.red,
            dotCount: 10,
            rollingFactor: 0.8,
            loading: loading,
            child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 50.0),
                child: ListTile(
                  leading: Text(
                    'Counter',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  trailing: Text(
                    '$counter',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                )),
          ),
        ),
      );
}

class LoadingScaffold extends StatefulWidget {
  @override
  _LoadingScaffoldState createState() => _LoadingScaffoldState();
}

class _LoadingScaffoldState extends State<LoadingScaffold> {
  Future future = Future.delayed(Duration(seconds: 3));

  late StreamSubscription _subscription;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    _subscription = Stream.periodic(Duration(seconds: 4)).listen((i) {
      setState(() {
        loading = !loading;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CircularWidgetLoading(
        padding: EdgeInsets.zero,
        child: Scaffold(
          appBar: AppBar(title: Text('Example')),
          body: Center(child: Text('Loaded!')),
        ),
        loading: loading,
      ),
    );
  }
}
