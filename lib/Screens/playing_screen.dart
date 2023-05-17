import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class playing_screen extends StatefulWidget {
  const playing_screen({Key? key, required this.songModel, required this.audioPlayer}) : super(key: key);
  final SongModel songModel;
  final AudioPlayer audioPlayer;

  @override
  State<playing_screen> createState() => _playing_screenState();
}

class _playing_screenState extends State<playing_screen> {
  Duration _dur = const Duration();
  Duration _pos = const Duration();
  bool _isPlaying = false;

  void initState() {
    super.initState();
    playSong();
  }
  void playSong() {
    try { //음악 재생
      widget.audioPlayer.setAudioSource(
          AudioSource.uri(
              Uri.parse(widget.songModel.uri!)
          )
      );
      widget.audioPlayer.play();
      _isPlaying = true; //bool값을 true로 재생중임을 표시
    } on Exception { //예외처리
      log("Cannot Parse Music");
    }
    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        _dur = d!;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        _pos = p;
      });
    });
  }

  void changeToSeconds(int seconds) {
    Duration dur = Duration(seconds: seconds);
    widget.audioPlayer.seek(dur);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(onPressed: () {
                Navigator.pop(context);
              },
                icon: Icon(Icons.arrow_back_ios),
              ),
              SizedBox(
                height: 30.0,
              ),
              Center(
                child: Column(
                  children: [
                    QueryArtworkWidget(
                      id: widget.songModel.id,
                      type: ArtworkType.AUDIO,
                      artworkHeight: 200,
                      artworkWidth: 200,
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Text(
                        widget.songModel.title,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30.0,
                        ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      widget.songModel.artist.toString() == "<unknown>" ? "Unknown Artist" : widget.songModel.artist.toString(),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(
                      height: 80.0,
                    ),
                    Stack(
                      children: [
                        SliderTheme(
                            data: SliderThemeData(
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                            ),
                            child: Slider(
                              min: const Duration(microseconds: 0).inSeconds.toDouble(),
                              value: _pos.inSeconds.toDouble(),
                              max: _dur.inSeconds.toDouble(),
                              onChanged: (value) {
                                setState(() {
                                  changeToSeconds(value.toInt());
                                  value = value;
                                });
                              },
                              thumbColor: Colors.white,
                              activeColor: Colors.grey,
                              inactiveColor: Colors.grey,
                            ),
                        ),
                        Positioned(
                          top: 35,
                          left: (2),
                          child: Text( '       '+
                              _pos.toString().split(".")[0].substring(2),
                            style: TextStyle(
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 35,
                          right: (2),
                          child: Text(
                              _dur.toString().split(".")[0].substring(2) + '       ',
                            style: TextStyle(
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              widget.audioPlayer.seekToPrevious();
                            });
                          },
                          icon: Icon(Icons.skip_previous, size: 30.0,),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (_isPlaying) {
                                widget.audioPlayer.pause();
                              } else {
                                widget.audioPlayer.play();
                              }
                              _isPlaying = !_isPlaying;
                            });
                          },
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 30.0,)
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              widget.audioPlayer.seekToNext();
                            });
                          },
                          icon: Icon(Icons.skip_next, size: 30.0,),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]
          )
        ),
      )
    );
  }
}
