import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_pro/carousel_pro.dart';

typedef void OnError(Exception exception);


const kUrl = "https://p.scdn.co/mp3-preview/3eb16018c2a700240e9dfb8817b6f2d041f15eb1?cid=774b29d4f13844c495f206cafdad9c86";
const kUrl2 = "https://p.scdn.co/mp3-preview/3eb16018c2a700240e9dfb8817b6f2d041f15eb1?cid=774b29d4f13844c495f206cafdad9c86";

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
      // home: new MyHomePage(),
      home: DefaultTabController(
      length: 4,
      child: new Scaffold(
        body: TabBarView(
          children: [
            new MyHomePage(),
            new Container(color: Colors.orange,),
          ],
        ),
        bottomNavigationBar: new TabBar(
          tabs: [
            Tab(
              icon: new Icon(Icons.home),
            ),
            Tab(
              icon: new Icon(Icons.rss_feed),
            ),
          ],
          labelColor: Colors.yellow,
          unselectedLabelColor: Colors.blue,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorPadding: EdgeInsets.all(5.0),
          indicatorColor: Colors.red,
        ),
        backgroundColor: Colors.black,
        ),
      ),
  );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _FeedState createState() => new _FeedState();
}

enum PlayerState { stopped, playing, paused }

class _FeedState extends State<MyHomePage> {
    static GlobalKey previewContainer = new GlobalKey();
    Duration duration;
    Duration position;

    AudioPlayer audioPlayer;

    String localFilePath;

    PlayerState playerState = PlayerState.stopped;

    get isPlaying => playerState == PlayerState.playing;
    get isPaused => playerState == PlayerState.paused;

    get durationText =>
        duration != null ? duration.toString().split('.').first : '';
    get positionText =>
        position != null ? position.toString().split('.').first : '';

    bool isMuted = false;

    StreamSubscription _positionSubscription;
    StreamSubscription _audioPlayerStateSubscription;


    void initAudioPlayer() {
      audioPlayer = new AudioPlayer();
      _positionSubscription = audioPlayer.onAudioPositionChanged
          .listen((p) => setState(() => position = p));
      _audioPlayerStateSubscription =
          audioPlayer.onPlayerStateChanged.listen((s) {
        if (s == AudioPlayerState.PLAYING) {
          setState(() => duration = audioPlayer.duration);
        } else if (s == AudioPlayerState.STOPPED) {
          onComplete();
          setState(() {
            position = duration;
          });
        }
      }, onError: (msg) {
        setState(() {
          playerState = PlayerState.stopped;
          duration = new Duration(seconds: 0);
          position = new Duration(seconds: 0);
        });
      });
    }

    Future play() async {
      await audioPlayer.play(kUrl);
      setState(() {
        playerState = PlayerState.playing;
      });
    }

    Future _playLocal() async {
      await audioPlayer.play(localFilePath, isLocal: true);
      setState(() => playerState = PlayerState.playing);
    }

    Future pause() async {
      await audioPlayer.pause();
      setState(() => playerState = PlayerState.paused);
    }

    Future stop() async {
      await audioPlayer.stop();
      setState(() {
        playerState = PlayerState.stopped;
        position = new Duration();
      });
    }

    Future mute(bool muted) async {
      await audioPlayer.mute(muted);
      setState(() {
        isMuted = muted;
      });
    }

    void onComplete() {
      setState(() => playerState = PlayerState.stopped);
    }

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
      initAudioPlayer();
      initPlatformState();
    }

    @override
    void dispose() {
      _positionSubscription.cancel();
      _audioPlayerStateSubscription.cancel();
      audioPlayer.stop();
      super.dispose();
    }

    String _platformVersion = 'Unknown';
    Permission permission;

    initPlatformState() async {
      String platformVersion;
      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        platformVersion = await SimplePermissions.platformVersion;
      } on PlatformException {
        platformVersion = 'Failed to get platform version.';
      }

      if (!mounted) return;

      setState(() {
        _platformVersion = platformVersion;
      });
    }

    void checkLibralyPermission() async {
      // パーミッションの確認・要求
      print('権限チェック');
      if (await SimplePermissions.checkPermission(Permission.PhotoLibrary)) {
        final res = await SimplePermissions.requestPermission(Permission.PhotoLibrary);
        print("permission request result is " + res.toString());
      }
    }

    Future<String> takeScreenShot() async{
      RenderRepaintBoundary boundary = previewContainer.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage();
      final directory = (await getApplicationDocumentsDirectory()).path;
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      print(pngBytes);
      String filepath = '$directory/screenshot.png';
      File imgFile = new File(filepath);
      imgFile.writeAsBytes(pngBytes);
      return filepath;
    }

    void shareThirdPArty() async {
      await checkLibralyPermission();
      String filepath = await takeScreenShot();
      _launchURL(filepath);      
    }

    // String timestamp_format(){
    //   var now = new DateTime.now();
    //   var formatter = new DateFormat('yyyy-MM-dd');
    //   String formatted = formatter.format(now);
    //   print(formatted); // something like 2013-04-20
    //   return formatted;
    // }

    _launchURL(String imageUrl) async {
      String url = 'instagram://library?LocalIdentifier=$imageUrl';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    Widget _buildPlayer() => new Container(
          padding: new EdgeInsets.all(16.0),
          child: new Column(mainAxisSize: MainAxisSize.min, children: [
            new Row(mainAxisSize: MainAxisSize.min, children: [
              new IconButton(
                  onPressed: isPlaying ? null : () => play(),
                  iconSize: 64.0,
                  icon: new Icon(Icons.play_arrow),
                  color: Colors.cyan),
              new IconButton(
                  onPressed: isPlaying ? () => pause() : null,
                  iconSize: 64.0,
                  icon: new Icon(Icons.pause),
                  color: Colors.cyan),
              new IconButton(
                  onPressed: isPlaying || isPaused ? () => stop() : null,
                  iconSize: 64.0,
                  icon: new Icon(Icons.stop),
                  color: Colors.cyan),
            ]),
            duration == null
                ? new Container()
                : new Slider(
                    value: position?.inMilliseconds?.toDouble() ?? 0.0,
                    onChanged: (double value) =>
                        audioPlayer.seek((value / 1000).roundToDouble()),
                    min: 0.0,
                    max: duration.inMilliseconds.toDouble()),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new IconButton(
                    onPressed: () => mute(true),
                    icon: new Icon(Icons.headset_off),
                    color: Colors.cyan),
                new IconButton(
                    onPressed: () => mute(false),
                    icon: new Icon(Icons.headset),
                    color: Colors.cyan),
              ],
            ),
            new Row(mainAxisSize: MainAxisSize.min, children: [
              new Padding(
                  padding: new EdgeInsets.all(12.0),
                  child: new Stack(children: [
                    new CircularProgressIndicator(
                        value: 1.0,
                        valueColor: new AlwaysStoppedAnimation(Colors.grey[300])),
                    new CircularProgressIndicator(
                      value: position != null && position.inMilliseconds > 0
                          ? (position?.inMilliseconds?.toDouble() ?? 0.0) /
                              (duration?.inMilliseconds?.toDouble() ?? 0.0)
                          : 0.0,
                      valueColor: new AlwaysStoppedAnimation(Colors.cyan),
                      backgroundColor: Colors.yellow,
                    ),
                  ])),
              new Text(
                  position != null
                      ? "${positionText ?? ''} / ${durationText ?? ''}"
                      : duration != null ? durationText : '',
                  style: new TextStyle(fontSize: 24.0))
            ])
          ]));

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
                child:RepaintBoundary(
                  key: previewContainer,
                  child:Container(
                  decoration: BoxDecoration(color: Colors.black),
                    child: Column(
                      children: <Widget>[
                        // 再生回数バー
                        Expanded(
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
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
                              Padding(
                                padding: EdgeInsets.only(right:1.0),
                                child:IconButton(
                                  icon: Icon(IconData(0xe0e2, fontFamily: 'MaterialIcons'),color: Colors.white),
                                  onPressed: () { shareThirdPArty(); },
                                ),
                              ),
                            ]
                          ),
                          flex: 1,
                        ),
                        // ジャケット写真
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
              ),    
              // 曲情報           
              Expanded(
                child:Container(
                  color:Colors.red,
                  child:
                    Center(
                         child: new Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              new Material(child: _buildPlayer()),
                              localFilePath != null
                                  ? new Text(localFilePath)
                                  : new Container(),
                            ]),
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