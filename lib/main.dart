import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp());
}
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Generated App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196f3),
        accentColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFFfafafa),
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _FeedState createState() => new _FeedState();
}

class _FeedState extends State<MyHomePage> {

    int _play_count;
    int _play_second;
    int _like_count;
    String _comment;
    String _username;
    String _post_created_date;

    @override
    void initState() {
      super.initState();
      _play_second = 30;
      _play_count = 200;
      _like_count = 30;
      _comment = 'めっちゃ洋楽!!';
      _username = 'isseimunetomo ';
      _post_created_date = '2日前';
    }

    @override
    Widget build(BuildContext context) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text('App Name'),
          ),
        body:
          new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // 再生           
              Expanded(
                child:Container(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child:Container(
                          decoration: const BoxDecoration(color: Colors.black),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Icon(IconData(0xe039, fontFamily: 'MaterialIcons'),color: Colors.white),
                              Padding(padding: EdgeInsets.all(5.0)),
                              Text(
                                _play_count.toString() + "回",
                                style: new TextStyle(fontSize:14.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w200,
                                fontFamily: "Roboto"),
                              ),
                            ]
                          ),
                        ),
                        flex: 1,
                      ),
                      Expanded(
                        child:new Stack(
                          children: <Widget>[
                            Container(
                              decoration: new BoxDecoration(
                                image: new DecorationImage(
                                  image: NetworkImage(
                                    'https://i.scdn.co/image/e63f29b1a8cde872666bb0c3b702280a3bd45ff8'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Center(
                              child:Text(
                                "0" + ":" + _play_second.toString(),
                                style: new TextStyle(fontSize:20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Roboto"),
                              ),
                            ),
                            new Align(
                              alignment: new Alignment(1.0, 1.0),
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "@" + _username,
                                    style: new TextStyle(fontSize:14.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: "Roboto"),
                                  ),
                                  Padding(padding: EdgeInsets.all(5.0)),
                                  Text(
                                    _post_created_date,
                                    style: new TextStyle(fontSize:14.0,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: "Roboto"),
                                  ),
                                ]
                              ),
                            ),                          
                          ],
                        ),
                        flex: 8,
                      ),
                      Expanded(
                        child:Container(
                          decoration: const BoxDecoration(color: Colors.black),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                _comment,
                                style: new TextStyle(fontSize:14.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Roboto"),
                              ),
                              Padding(padding: EdgeInsets.all(5.0)),
                              new Icon(IconData(0xe87d,fontFamily: 'MaterialIcons'),color: Colors.red[800]),
                              Padding(padding: EdgeInsets.all(2.0)),
                              Text(
                                "いいね " + _like_count.toString() + "件",
                                style: new TextStyle(fontSize:12.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w200,
                                fontFamily: "Roboto"),
                              ),
                            ]
                          ),
                        ),
                        flex: 1,
                      ),
                    ],
                  ),
                ),
              ),    
              // 曲情報           
              Expanded(
                child:Container(
                  color:Colors.red,
                  child:
                  Text(
                  "##",
                    style: new TextStyle(fontSize:12.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  alignment: Alignment.center,
                ),
              ),    
            ]
          ),
      );
    }
}