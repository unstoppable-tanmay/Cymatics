import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Player extends StatefulWidget {
  const Player(
      {super.key,
      required this.Song,
      required this.audioPlayer,
      this.index,
      this.position,
      required this.setIndex,
      required this.setPosition});

  final List<SongModel> Song;
  final AudioPlayer audioPlayer;
  final index;
  final position;
  final Function setIndex;
  final Function setPosition;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  double sliderValue = 0;
  Duration _duration = Duration();
  Duration _position = Duration();
  double seekPosition = 0;
  List<AudioSource> AddedSongs = []; // For parsing the songs to sudio player

  var currentindex;

  InitStateSeeaker() {
    try {
      for (var ele in widget.Song) {
        AddedSongs.add(AudioSource.uri(
          Uri.parse(ele.uri.toString()),
          tag: MediaItem(
            id: ele.id.toString(),
            album: ele.album,
            title: ele.title,
            artUri: Uri.parse(ele.uri.toString()),
          ),
        ));
      }
      widget.audioPlayer.setAudioSource(
          ConcatenatingAudioSource(children: AddedSongs),
          initialIndex: widget.index,
          initialPosition: widget.position);
      widget.audioPlayer.currentIndexStream.listen((event) {
        currentindex = event;
      });
      widget.audioPlayer.play();
      widget.audioPlayer.durationStream.listen((d) {
        _duration = d!;
        setState(() {});
      });
      widget.audioPlayer.positionStream.listen((p) {
        _position = p;
        sliderValue =
            (_position.inMilliseconds / _duration.inMilliseconds) * 100;
        setState(() {});
      });
    } on Exception {
      log("Error in Playing Audio");
    }
  }

  void changeToSeconds(int time) {
    Duration duration = Duration(seconds: time);
    widget.audioPlayer.seek(duration);
  }

  @override
  void initState() {
    currentindex = widget.index ?? 5;
    _position = widget.position ?? Duration.zero;
    InitStateSeeaker();
    super.initState();
  }

  @override
  void dispose() {
    widget.setIndex(currentindex);
    widget.setPosition(_position);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPlaying = widget.audioPlayer.playing;
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
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(CupertinoIcons.chevron_back, size: 30)),
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
        body: Container(
          height: screenHeight * 1.3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Hero(
                tag: "Image",
                child: Material(
                  animationDuration: Duration(milliseconds: 600),
                  type: MaterialType.transparency,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Material(
                        elevation: 20,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(500),
                            bottomRight: Radius.circular(500)),
                        child: Container(
                          width: screenWidth * .7,
                          height: screenHeight * .7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(500),
                                bottomRight: Radius.circular(500)),
                          ),
                          child: ClipRRect(
                            child: QueryArtworkWidget(
                              id: widget.Song[widget.index].id,
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
                        bottom: screenHeight * .07,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: screenWidth * .5,
                              child: Text(
                                "${widget.Song[currentindex].title.replaceAll(RegExp("[^A-Za-z0-9]"), " ").trim().toUpperCase().split(' ').take(3).join(' ')}",
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
                              "${widget.Song[currentindex].artist.toString().replaceAll(RegExp("[^A-Za-z0-9]"), " ").trim().toUpperCase().split(' ').take(1).join(' ')}",
                              // "dgvaeg",
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
                            Text(
                              "${currentindex}",
                              style: TextStyle(
                                  color: Colors.white.withAlpha(110),
                                  overflow: TextOverflow.clip,
                                  letterSpacing: 1.3,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -35,
                        child: Transform(
                          transform: Matrix4.rotationY(3.14),
                          origin: Offset(screenWidth * .43, 0),
                          child: SleekCircularSlider(
                            min: Duration(microseconds: 0).inSeconds.toDouble(),
                            max: _duration.inSeconds.toDouble(),
                            initialValue: _position.inSeconds.toDouble(),
                            innerWidget: (context) => SizedBox(),
                            onChangeEnd: (value) {
                              changeToSeconds(value.toInt());
                              value = value;
                            },
                            appearance: CircularSliderAppearance(
                                animationEnabled: false,
                                startAngle: 10,
                                angleRange: 160,
                                customWidths: CustomSliderWidths(
                                    trackWidth: 7,
                                    progressBarWidth: 7,
                                    handlerSize: 10),
                                size: screenWidth * .86,
                                customColors: CustomSliderColors(
                                  dotColor: Colors.white,
                                  hideShadow: true,
                                  trackColor: Colors.black12,
                                  progressBarColor: Colors.black,
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("${_position.toString().substring(2, 7)}",
                    // "ksnkfnkan",
                    style: TextStyle(fontSize: 16)),
              ),
              Container(
                  padding: EdgeInsets.only(bottom: 40, top: 10),
                  child: Hero(
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
                            iconSize: 23,
                          ),
                          Stack(alignment: Alignment.center, children: [
                            Container(
                              width: 160,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    widget.audioPlayer.seekToPrevious();
                                    widget.audioPlayer.play();
                                  },
                                  icon: Icon(Icons.skip_previous_rounded),
                                  iconSize: 28,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Material(
                                  elevation: 15,
                                  borderRadius: BorderRadius.circular(30),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black,
                                    radius: 30,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: IconButton(
                                        onPressed: () {
                                          if (isPlaying) {
                                            widget.audioPlayer.pause();
                                            isPlaying = false;
                                          } else {
                                            widget.audioPlayer.play();
                                            isPlaying = true;
                                          }
                                          ;
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          isPlaying
                                              ? CupertinoIcons.pause_solid
                                              : CupertinoIcons.play_arrow_solid,
                                        ),
                                        color: Colors.white,
                                        iconSize: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                IconButton(
                                  onPressed: () {
                                    widget.audioPlayer.seekToNext();
                                    widget.audioPlayer.play();
                                  },
                                  icon: Icon(Icons.skip_next_rounded),
                                  iconSize: 28,
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            ),
                          ]),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(CupertinoIcons.repeat),
                            iconSize: 23,
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ));
  }
}
