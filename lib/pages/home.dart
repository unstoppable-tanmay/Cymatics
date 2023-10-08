import 'dart:convert';
import 'dart:developer';

import 'package:cymatics/pages/player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

final OnAudioQuery _audioQuery = OnAudioQuery();
final AudioPlayer _audioPlayer = AudioPlayer();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<SongModel> Songs = []; // for the all songs from on audio query
  List<AudioSource> AddedSongs = []; // For parsing the songs to sudio player
  int currentSong = 0;
  Duration position = Duration.zero;
  bool isPlaying = false;

  findTime(int time) {
    String Time = (time / 60000).toStringAsFixed(2);
    return Time.length == 4 ? "0" + Time : Time;
  }

  getSong() async {
    Songs = await _audioQuery.querySongs(
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true);
    setState(() {});
  }

  setPlayingSong(currentSong, position) {
    currentSong = currentSong;
    position = position;
  }

  openPlayer(index) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Player(
          Song: Songs,
          audioPlayer: _audioPlayer,
          index: index,
          position: position,
          setIndex: setIndex,
          setPosition: setPosition,
        );
      },
      transitionsBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return Align(
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    ));
  }

  setData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('Data', jsonEncode({currentSong, position}));
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');
    print(data);
    currentSong = jsonDecode(data!).currentSong;
    position = jsonDecode(data).position;
    setState(() {});
  }

  setIndex(d) {
    currentSong = d.toInt();
  }

  setPosition(p) {
    position = p;
  }

  @override
  void initState() {
    // getData();
    getSong();
    super.initState();
  }

  @override
  void dispose() {
    setData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Color(0xffe8e8e8),
        extendBodyBehindAppBar: true,
        endDrawer: Drawer(
            width: screenWidth * .7,
            elevation: 5,
            child: Container(
              child: Text("Drawer"),
            )),
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Icon(CupertinoIcons.chevron_back, size: 30),
          ),
          actions: [
            Builder(
                builder: (context) => // Ensure Scaffold is in context
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: IconButton(
                          icon: Icon(CupertinoIcons.line_horizontal_3_decrease,
                              size: 30),
                          onPressed: () =>
                              Scaffold.of(context).openEndDrawer()),
                    )),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Hero(
              tag: "Image",
              child: Material(
                animationDuration: Duration(milliseconds: 600),
                type: MaterialType.transparency,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Material(
                      elevation: 20,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(500),
                          bottomRight: Radius.circular(500)),
                      child: Container(
                        width: screenWidth * .65,
                        height: screenHeight * .5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(500),
                              bottomRight: Radius.circular(500)),
                        ),
                        child: ClipRRect(
                          child: QueryArtworkWidget(
                            id: Songs[currentSong].id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: Image.asset(
                                'assets/images/lofi1.jpg',
                                fit: BoxFit.cover),
                                artworkFit: BoxFit.cover,
                                artworkClipBehavior: Clip.none,
                          ),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(500),
                              bottomRight: Radius.circular(500)),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: screenHeight * .04,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width: screenWidth * .5,
                            child: Text(
                              "${Songs.length != 0 ? Songs[currentSong].title.replaceAll(RegExp("[^A-Za-z0-9]"), " ").trim().toUpperCase().split(' ').take(3).join(' ') : "Hello Tanmay"}",
                              style: TextStyle(
                                  color: Colors.white,
                                  overflow: TextOverflow.clip,
                                  letterSpacing: 1.3,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "${Songs.length != 0 ? Songs[currentSong].artist.toString().replaceAll(RegExp("[^A-Za-z0-9]"), " ").trim().toUpperCase().split(' ').take(1).join(' ') : "UNKNOWN"}",
                            style: TextStyle(
                                color: Colors.white.withAlpha(110),
                                overflow: TextOverflow.clip,
                                letterSpacing: 1.3,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: ShaderMask(
                shaderCallback: (Rect rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.white
                    ],
                    stops: [0.0, 0.2, 0.8, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstOut,
                child: ListView.builder(
                  dragStartBehavior: DragStartBehavior.start,
                  padding: EdgeInsets.only(top: 40),
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: Songs.length,
                  itemBuilder: (context, index) {
                    SongModel songname = Songs[index];
                    return InkWell(
                      onTap: () {
                        currentSong = index;
                        setState(() {});
                        openPlayer(index);
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            left: screenWidth * .08,
                            right: screenWidth * .08,
                            top: 20,
                            bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 70),
                                child: Text(
                                  "${songname.title.replaceAll(RegExp("[^A-Za-z0-9]"), " ").trim().toUpperCase()}",
                                  // "uiaa",
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            Text(
                              "${findTime(songname.duration!)}",
                              // "jabkj",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.only(bottom: 10, top: 10),
                child: Column(children: [
                  IconButton(
                      onPressed: () {
                        openPlayer(currentSong);
                      },
                      icon: Icon(CupertinoIcons.chevron_up, size: 20)),
                  Hero(
                    tag: "Player",
                    child: Material(
                      animationDuration: Duration(milliseconds: 1000),
                      type: MaterialType.transparency,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(CupertinoIcons.shuffle_medium),
                            iconSize: 18,
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  currentSong = currentSong > 0
                                      ? currentSong - 1
                                      : currentSong;
                                  setState(() {});
                                  _audioPlayer.play();
                                },
                                icon: Icon(Icons.skip_previous_rounded),
                                iconSize: 23,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Material(
                                elevation: 15,
                                borderRadius: BorderRadius.circular(25),
                                child: CircleAvatar(
                                  backgroundColor: Colors.black,
                                  radius: 25,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: IconButton(
                                      onPressed: () {
                                        _audioPlayer.play();
                                      },
                                      icon:
                                          Icon(CupertinoIcons.play_arrow_solid),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              IconButton(
                                onPressed: () {
                                  currentSong = currentSong < Songs.length - 1
                                      ? currentSong + 1
                                      : currentSong;
                                  setState(() {});
                                  _audioPlayer.play();
                                },
                                icon: Icon(Icons.skip_next_rounded),
                                iconSize: 23,
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(CupertinoIcons.repeat),
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ])),
          ],
        ));
  }
}
// ed4c38 f0e3e5
