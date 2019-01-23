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
import './custom_app_bar.dart';

typedef void OnError(Exception exception);

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
        primaryColor: const Color(0xFF000000),
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
        resizeToAvoidBottomPadding: false,
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
    Duration minus_duration;
    Duration position;
    AudioPlayer audioPlayer;
    StreamSubscription _positionSubscription;
    StreamSubscription _audioPlayerStateSubscription;

    void initAudioPlayer() {
      audioPlayer = new AudioPlayer();
      init_play_list();
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
      await audioPlayer.play(playlist[_play_index]['preview_url']);
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

    void init_play_list() {
      _play_index = 0;
      update_play_list();
    }

    void update_play_list() {
      var songs = {
        'preview_url' : 'https://p.scdn.co/mp3-preview/3eb16018c2a700240e9dfb8817b6f2d041f15eb1?cid=774b29d4f13844c495f206cafdad9c86',
        'title' : 'tofubeats - all I wanna do'
      };
      var songs2 = {
        'preview_url' : 'https://p.scdn.co/mp3-preview/3eb16018c2a700240e9dfb8817b6f2d041f15eb1?cid=774b29d4f13844c495f206cafdad9c86',
        'title' : 'tofubeats - 水星'
      };
      var songs3 = {
        'preview_url' : 'https://p.scdn.co/mp3-preview/3eb16018c2a700240e9dfb8817b6f2d041f15eb1?cid=774b29d4f13844c495f206cafdad9c86',
        'title' : 'tofubeats - RUN'
      };
      playlist.add(songs);
      playlist.add(songs2);
      playlist.add(songs3);

      String hashtag = '#中目黒';
      String hashtag2 = '#チル';
      String hashtag3 = '#午後二時';
      String hashtag4 = '#ゆっくり休日';
      hashtags.add(hashtag);
      hashtags.add(hashtag2);
      hashtags.add(hashtag3);
      hashtags.add(hashtag4);
    }

    void onComplete() {
      // 次の曲を再生する
      if(playlist.length != _play_index+1){
        _play_index++;
        play();
      }
    }

    int play_count;
    int play_second;
    int like_count;
    String comment;
    String username;
    String post_created_date;
    String playlist_title;
    String localFilePath;
    PlayerState playerState = PlayerState.stopped;
    get isPlaying => playerState == PlayerState.playing;
    get isPaused => playerState == PlayerState.paused;
    get durationText =>
        duration != null ? duration.toString().split('.').first : '';
    get positionText =>
        position != null ? position.toString().split('.').first : '';
    get minus_durationText =>
        position != null ? (duration - position).toString().split('.').first : '';
    bool isMuted = false;
    var playlist = new List();
    var hashtags = new List();
    int _play_index = 0;

    @override
    void initState() {
      super.initState();
      play_second = 30;
      play_count = 200;
      like_count = 30;
      comment = 'めっちゃ洋楽!!';
      username = 'isseimunetomo ';
      post_created_date = '2日前';
      playlist_title = 'イギリスロックまとめ';
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

    _launchURL(String imageUrl) async {
      String url = 'instagram://library?LocalIdentifier=$imageUrl';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    Widget _buildPlayer() => new Container(
          child: new Column(mainAxisSize: MainAxisSize.min, children: [
            new Row(mainAxisSize: MainAxisSize.min, children: [
              new IconButton(
                  onPressed: isPlaying || isPaused ? () => stop() : null,
                  iconSize: 60.0,
                  icon: new Icon(IconData(0xe045, fontFamily: 'MaterialIcons')),
                  color: Colors.black),
              new IconButton(
                  onPressed: isPlaying ? () =>pause() : () => play(),
                  iconSize: 60.0,
                  icon: isPlaying ? new Icon(IconData(0xe035, fontFamily: 'MaterialIcons')): new Icon(IconData(0xe038, fontFamily: 'MaterialIcons')),
                  color: Colors.black),
              new IconButton(
                  onPressed: isPlaying || isPaused ? () => stop() : null,
                  iconSize: 60.0,
                  icon: new Icon(IconData(0xe044, fontFamily: 'MaterialIcons')),
                  color: Colors.black),
            ]),
          Padding(
            padding: EdgeInsets.only(left:0.0),
            child:
              new Row(mainAxisSize: MainAxisSize.min, children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child:
                  new Text(
                  position != null
                      ? "${positionText ?? ''}"
                      : duration != null ? durationText : '',
                  style: new TextStyle(fontSize: 12.0))
                ),
                duration == null
                    ? new Container()
                    : new Slider(
                        value: position?.inMilliseconds?.toDouble() ?? 0.0,
                        onChanged: (double value) =>
                            audioPlayer.seek((value / 1000).roundToDouble()),
                        min: 0.0,
                        max: duration.inMilliseconds.toDouble()),
                Align(
                  alignment: Alignment.centerRight,
                  child:
                  new Text(
                  position != null
                      ? "${durationText ?? ''}"
                      : duration != null ? durationText : '',
                  style: new TextStyle(fontSize: 12.0))
                ),
              ])
            ),
          ]));

    @override
    Widget build(BuildContext context) {
      return new Scaffold(
            body: new CustomScrollView(slivers: <Widget>[
          new SliverAppBar(
            pinned: true,
            expandedHeight: _kFlexibleSpaceMaxHeight,
            flexibleSpace: new FlexibleSpaceBar(
              title: new Text('Top Lakes'),
              background:
                  new MusicThubnail(
                    animation: kAlwaysDismissedAnimation,
                    play_count: play_count,
                    play_second: play_second,
                    like_count: like_count,
                    post_created_date:post_created_date,
                    playlist_title:playlist_title,
                    playlist :playlist,
                  ),        
              ),
          ),          new SliverList(
              delegate: new SliverChildListDelegate(<Widget>[
                Container(
                  decoration: BoxDecoration(color: Colors.black),
                  child:Container(height: 50.0,
                    child:Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Icon(IconData(0xe039, fontFamily: 'MaterialIcons'),color: Colors.white),
                              Padding(padding: EdgeInsets.all(5.0)),
                              Text(
                                this.play_count.toString() + "回",
                                style: new TextStyle(fontSize:14.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w200,
                                fontFamily: "Roboto"),
                              ),
                            ]
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child:Text(
                            this.playlist_title,
                            textAlign: TextAlign.center,
                            style: new TextStyle(fontSize:18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Roboto"),
                          ),
                        ),
                        // インスタ投稿用アイコン
                        // Padding(
                        //   padding: EdgeInsets.only(right:1.0),
                        //   child:IconButton(
                        //     icon: Icon(IconData(0xe0e2, fontFamily: 'MaterialIcons'),color: Colors.white),
                        //     onPressed: () { shareThirdPArty(); },
                        //   ),
                        // ),
                      ]
                    ),
                  ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.black),
              child:Container(height: 50.0,
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            this.comment,
                            style: new TextStyle(fontSize:14.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Roboto"),
                          ),
                          Padding(padding: EdgeInsets.all(5.0)),
                          new Icon(IconData(0xe87d,fontFamily: 'MaterialIcons'),color: Colors.red[800]),
                          Padding(padding: EdgeInsets.all(2.0)),
                          Text(
                            "いいね " + this.like_count.toString() + "件",
                            style: new TextStyle(fontSize:12.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w200,
                            fontFamily: "Roboto"),
                          ),
                        ]
                      ),
                    ),
            ),
            Container(
            decoration: BoxDecoration(color: Colors.white),
                  child:Container(height: 150.0,
                  child:Padding(
                    padding: new EdgeInsets.only(left:8.0,top:8.0,right:8.0,),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                            child: new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 20.0,
                                child: new ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: new List.generate(hashtags.length, (int index) {
                                    return new 
                                      Text(hashtags[index],
                                        style: TextStyle(fontSize: 12.0,color: Colors.red,
                                        fontWeight: FontWeight.w200,
                                        fontFamily: "Roboto"),
                                        textAlign: TextAlign.left
                                      );
                                  }),
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(10.0)),
                              Text(playlist[_play_index]['title'],
                                style: TextStyle(fontSize: 25.0,color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Roboto"),
                                textAlign: TextAlign.left
                              ),
                              Padding(padding: EdgeInsets.all(10.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[ 
                                  IconButton(
                                    icon: Icon(IconData(0xe0e2, fontFamily: 'MaterialIcons')),
                                    onPressed: () { shareThirdPArty(); },
                                  ),
                                  Text(
                                    "シェア",
                                    style: new TextStyle(fontSize:14.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: "Roboto"),
                                  ),
                                  IconButton(
                                    icon: Icon(IconData(0xe838, fontFamily: 'MaterialIcons')),
                                    onPressed: () { shareThirdPArty(); },
                                  ),
                                  Text(
                                    "お気に入り",
                                    style: new TextStyle(fontSize:14.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w200,
                                    fontFamily: "Roboto"),
                                  ),
                                ]
                              ),
                            ]
                          ),
                        ),
                      ]
                    ),
                  ),
                ),
            ),
            new Divider(
                    color: Colors.black
            ),
            Container(
            decoration: BoxDecoration(color: Colors.white),
                  child:Container(height: 120.0,
                  child:Center(
                  child: new Container(
                    child: _buildPlayer(),
                    ),
                ),
            )),
            new Divider(
                    color: Colors.black
            ),
            Container(
            decoration: BoxDecoration(color: Colors.white),
                  child:Container(height: 200.0,
                    child:CustomScrollView(
                    shrinkWrap: true,
                    slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.all(20.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            <Widget>[
                              const Text('I\'m dedicating every day to you'),
                              const Text('Domestic life was never quite my style'),
                              const Text('When you smile, you knock me out, I fall apart'),
                              const Text('And I thought I was so smart'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            )),
          ])),
        ]));
    }
}

const double _kFlexibleSpaceMaxHeight = 170.0;

class _BackgroundLayer {
  _BackgroundLayer({int level, double parallax})
      : assetName = '',
        parallaxTween = new Tween<double>(begin: 0.0, end: parallax);
  final String assetName;
  final Tween<double> parallaxTween;
}

final List<_BackgroundLayer> _kBackgroundLayers = <_BackgroundLayer>[
  new _BackgroundLayer(level: 0, parallax: _kFlexibleSpaceMaxHeight),
  new _BackgroundLayer(level: 1, parallax: _kFlexibleSpaceMaxHeight),
  new _BackgroundLayer(level: 2, parallax: _kFlexibleSpaceMaxHeight / 2.0),
  new _BackgroundLayer(level: 3, parallax: _kFlexibleSpaceMaxHeight / 4.0),
  new _BackgroundLayer(level: 4, parallax: _kFlexibleSpaceMaxHeight / 2.0),
  new _BackgroundLayer(level: 5, parallax: _kFlexibleSpaceMaxHeight)
];

class MusicThubnail extends StatefulWidget {
  final Animation<double> animation;
  int play_count;
  int play_second;
  int like_count;
  String post_created_date;
  String playlist_title;
  String comment;
  String username;
  List playlist;
  String localFilePath;

  MusicThubnail({Key key, 
    this.animation,
    this.play_count,
    this.play_second,
    this.like_count,
    this.post_created_date,
    this.playlist_title,
    this.playlist,
  }) : super(key: key);

  @override
  _MusicThubnailState createState() => new _MusicThubnailState();
}

class _MusicThubnailState extends State<MusicThubnail> {

  List<Widget> createPLayListText() {
    List<Widget> childrenTexts = List<Widget>();
    for (int i = 0; i < widget.playlist.length; i++) {
      childrenTexts.add(new Align(
        alignment: Alignment.centerLeft,
        child:
        Padding(
          padding: EdgeInsets.only(left:10.0),
          child:
          Text(widget.playlist[i]['title'],
          style: TextStyle(fontSize: 20.0,color: Colors.red,
          fontWeight: FontWeight.w600,
          fontFamily: "Roboto"),
          textAlign: TextAlign.left),
        ),
      ));
    }
    return childrenTexts;
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
        animation: widget.animation,
        builder: (BuildContext context, Widget child) {
          return new Stack(
              children: _kBackgroundLayers.map((_BackgroundLayer layer) {
            return new Positioned(
                top: -layer.parallaxTween.evaluate(widget.animation),
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                  child: new Container(
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                        image: NetworkImage(
                          'https://is5-ssl.mzstatic.com/image/thumb/Music4/v4/a1/5c/8d/a15c8df1-e964-997b-63eb-c4f9d2d8c280/825646212682.jpg/1200x630bb.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                ),
            );
          }).toList());
        });
  }
}