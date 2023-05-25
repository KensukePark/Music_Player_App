import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class playing_screen extends StatefulWidget {
  const playing_screen({Key? key, required this.item, required this.idx, required this.audioPlayer}) : super(key: key);
  final List<SongModel>? item;
  final AudioPlayer audioPlayer;
  final int idx;
  @override
  State<playing_screen> createState() => _playing_screenState();
}

class _playing_screenState extends State<playing_screen> {
  Duration _dur = const Duration();
  Duration _pos = const Duration();
  bool _isPlaying = false;
  bool _volume = true;
  late int idx_play = widget.idx;
  late Timer _timer;
  var _time = 0;
  late List<bool> _bool = [true, false, false, false];
  late List<double> _speed = [1.0, 1.5, 2.0, 0.5];

  void initState() {
    super.initState();
    playSong();
  }

  //해당 인덱스의 음악 재생
  void playSong() {
    try {
      widget.audioPlayer.setAudioSource(
          AudioSource.uri(
              Uri.parse(widget.item![widget.idx].uri!)
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
    print(widget.item![idx_play].duration);
  }

  //이전 인덱스의 음악 재생
  void playPrev() {
    try { //음악 재생
      widget.audioPlayer.setAudioSource(
          AudioSource.uri(
              Uri.parse(widget.item![idx_play > 0 ? --idx_play : idx_play = (widget.item!.length-1)].uri!)
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

  //다음 인덱스의 음악 재생
  void playNext() {
    try { //음악 재생
      widget.audioPlayer.setAudioSource(
          AudioSource.uri(
              Uri.parse(widget.item![idx_play < (widget.item!.length-1) ? ++idx_play : idx_play = 0].uri!)
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

  //재생 시간대 변경
  void changeToSeconds(int seconds) {
    Duration dur = Duration(seconds: seconds);
    widget.audioPlayer.seek(dur);
  }

  //재생 속도 변경
  void changeSpeed() {
    int idx = _bool.indexOf(true);
    _bool[idx] = false;
    if (idx<3) {
      _bool[idx+1] = true;
    }
    else if (idx == 3) {
      _bool[0] = true;
    }
    widget.audioPlayer.setSpeed(_speed[_bool.indexOf(true)]);
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
                height: 50.0,
              ),
              Center(
                child: Column(
                  children: [
                    QueryArtworkWidget(
                      id: widget.item![idx_play].id,
                      type: ArtworkType.AUDIO,
                      artworkHeight: 240,
                      artworkWidth: 240,
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Text(
                        widget.item![idx_play].title,
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
                      widget.item![idx_play].artist.toString() == "<unknown>" ? "Unknown Artist" : widget.item![idx_play].artist.toString(),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(
                      height: 150.0,
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
                              if (_volume == true) {
                                widget.audioPlayer.setVolume(0);
                                _volume = false;
                              }
                              else {
                                widget.audioPlayer.setVolume(1.0);
                                _volume = true;
                              }
                            });
                          },
                          icon: Icon(_volume == true ? Icons.volume_down : Icons.volume_off, size: 30.0,),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              playPrev();
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
                              playNext();
                            });
                          },
                          icon: Icon(Icons.skip_next, size: 30.0,),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            fixedSize: const Size(50, 20),
                          ),
                          child: Text(
                              '${_speed[_bool.indexOf(true)]} x',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              )
                          ),
                          onPressed: () {
                            setState(() {
                              changeSpeed();
                            });
                          },
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
