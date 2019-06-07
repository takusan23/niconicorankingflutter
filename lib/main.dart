import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ニコニコ動画ランキング',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ニコニコ動画ランキング'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String title;
  var rankings_title_list;
  var rankings_description_list;
  int bottom_nav_select;

  @override
  Widget build(BuildContext context) {
    if (title == null) {
      title = "ニコニコ動画ランキング";
    }
    if (rankings_title_list == null) {
      rankings_title_list = [];
      rankings_description_list = [];
      bottom_nav_select = 0;
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Text(
                    rankings_title_list[index],
                    style: new TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    rankings_description_list[index],
                    style: new TextStyle(fontSize: 10),
                  )
                ],
              ),
            ),
          );
        },
        itemCount: rankings_title_list.length,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        onTap: nav_click,
        currentIndex: bottom_nav_select,
        items: [
          new BottomNavigationBarItem(
              icon: new Icon(Icons.calendar_today), title: new Text("毎時")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.calendar_today), title: new Text("24時間")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.calendar_today), title: new Text("週間")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.calendar_today), title: new Text("月間")),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.calendar_today), title: new Text("合計")),
        ],
      ),
    );
  }

  Future getWebAPI(String option) async {
    rankings_title_list = [];
    rankings_description_list = [];
    http.Response http_response = await http.get(
        'https://www.nicovideo.jp/ranking/fav/$option/all?rss=2.0&lang=ja-jp');
    parseHTML(http_response.body);
  }

  //パース
  void parseHTML(String html) {
    var document = parse(html);
    var rankings = document.getElementsByTagName("item");

    //forで回す
    for (int i = 0; i < rankings.length; i++) {
      setState(() {
        rankings_title_list
            .add(rankings[i].getElementsByTagName("title")[0].text);
        rankings_description_list.add(rankings[i]
            .getElementsByTagName("description")[0]
            .getElementsByClassName("nico-description")[0]
            .text);
      });
    }
  }

  //メニュークリック
  void nav_click(int position) {
    setState(() {
      switch (position) {
        case 0:
          getWebAPI("hourly");
          break;
        case 1:
          getWebAPI("daily");
          break;
        case 2:
          getWebAPI("weekly");
          break;
        case 3:
          getWebAPI("monthly");
          break;
        case 4:
          getWebAPI("total");
          break;
      }
      bottom_nav_select = position;
    });
  }
}
