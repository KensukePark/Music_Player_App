import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Screens/playing_screen.dart';
import '../Screens/playing_screen_not_Title.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({Key? key}) : super(key: key);
  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> with TickerProviderStateMixin{
  TabController? _tabController;
  int i = 0;
  int time = 0;
  List<int> album_idx = [];
  List<int> artist_idx = [];
  @override
  void initState() {
    super.initState();
    requestPermission();
    _tabController = TabController(
      length: 3,
      vsync: this,  //vsync에 this 형태로 전달해야 애니메이션이 정상 처리됨
    );
  }
  void requestPermission(){
    Permission.storage.request();
  }
  final _audioQuery = new OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  playSong(String? uri) {
    try {
      _audioPlayer.setAudioSource(
          AudioSource.uri(
              Uri.parse(uri!)
          )
      );
    } on Exception {
      log("Error parsing song");
    }
  }
  @override
  Widget build(BuildContext context) {
    List<SongModel>? songModel_search;
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Music Player'),
          ),
          bottomNavigationBar: Material(
            color: Color(0xff646464),
            child: TabBar(
              tabs: [
                Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note,),
                      Text('Song'),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.library_music,),
                      Text('Album'),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.person,),
                      Text('Artist'),
                    ],
                  ),
                ),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              controller: _tabController,
            ),
          ),
          body: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Container(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: ScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FutureBuilder<List<SongModel>> (
                                  future: _audioQuery.querySongs(
                                    sortType: null,
                                    orderType: OrderType.ASC_OR_SMALLER,
                                    uriType: UriType.EXTERNAL,
                                    ignoreCase: true,
                                  ),
                                  builder: (context, item) {
                                    songModel_search = item.data!;
                                    if(item.data == null) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (item.data!.isEmpty) {
                                      return Center(child: Text('Nothing found!'));
                                    }
                                    return ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) => ListTile(
                                          title: Text(
                                              item.data![index].title,
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                          ),
                                          subtitle: Text(
                                              '${item.data![index].artist}',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                          ),
                                          leading: QueryArtworkWidget(
                                            id: item.data![index].id,
                                            type: ArtworkType.AUDIO,
                                            artworkBorder: BorderRadius.circular(15),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => playing_screen(
                                                      item: item.data,
                                                      idx: index,
                                                      //next_songModel: item.data![index == item.data?.length ? 0 : ++index],
                                                      audioPlayer: _audioPlayer,)));
                                            //playSong(item.data![index].uri);
                                          }
                                      ),  itemCount: item.data!.length,
                                    );
                                  }
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),

                    Container(
                        child: Center(
                          child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 15),
                                FutureBuilder<List<AlbumModel>> (
                                    future: _audioQuery.queryAlbums(
                                      sortType: null,
                                      orderType: OrderType.ASC_OR_SMALLER,
                                      uriType: UriType.EXTERNAL,
                                      ignoreCase: true,
                                    ),
                                    builder: (context, item) {
                                      if(item.data == null) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (item.data!.isEmpty) {
                                        return Center(child: Text('Nothing found!'));
                                      }
                                      return GridView.builder(
                                        itemCount: item.data!.length,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 1 / 1,
                                          mainAxisSpacing: 10, //수평 Padding
                                          crossAxisSpacing: 10, //수직 Padding
                                        ),
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            child: InkWell(
                                                onTap: () {
                                                  while (time < item.data!.length) {
                                                    i = 0;
                                                    for (i; i<songModel_search!.length; i++) {
                                                      if (songModel_search![i].album == item.data![time].album) {
                                                        time++;
                                                        album_idx.add(i);
                                                        break;
                                                      }
                                                    }
                                                  }
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => playing_screen_not_Title(
                                                            item: songModel_search,
                                                            idx: index,
                                                            list_idx: album_idx,
                                                            audioPlayer: _audioPlayer,)));
                                                  //playSong(item.data![index].uri);
                                                },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: (MediaQuery.of(context).size.width - 32)/2.3,
                                                    width: (MediaQuery.of(context).size.width - 32)/2.3,
                                                    child:QueryArtworkWidget(
                                                      id: item.data![index].id,
                                                      type: ArtworkType.ALBUM,
                                                      artworkHeight: (MediaQuery.of(context).size.width - 32)/2.3,
                                                      artworkWidth: (MediaQuery.of(context).size.width - 32)/2.3,
                                                      artworkBorder: BorderRadius.circular(25),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 30,
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        item.data![index].album,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          );
                                        },
                                      );
                                    }
                                ),
                              ],
                            ),
                          ),
                        )
                    ),
                    Container(
                      //padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 10),
                                FutureBuilder<List<ArtistModel>> (
                                    future: _audioQuery.queryArtists(
                                      sortType: null,
                                      orderType: OrderType.ASC_OR_SMALLER,
                                      uriType: UriType.EXTERNAL,
                                      ignoreCase: true,
                                    ),
                                    builder: (context, item) {
                                      if(item.data == null) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (item.data!.isEmpty) {
                                        return Center(child: Text('Nothing found!'));
                                      }
                                      return ListView.separated(
                                        physics: NeverScrollableScrollPhysics(),
                                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) => ListTile(
                                            title: Text(
                                                item.data![index].artist ?? "Unknown Artist",
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white,
                                                )
                                            ),
                                            leading: QueryArtworkWidget(
                                              id: item.data![index].id,
                                              type: ArtworkType.ARTIST,
                                              artworkBorder: BorderRadius.circular(15),
                                            ),
                                            onTap: () {
                                              while (time < item.data!.length) {
                                                i = 0;
                                                for (i; i<songModel_search!.length; i++) {
                                                  if (songModel_search![i].artist == item.data![time].artist) {
                                                    time++;
                                                    artist_idx.add(i);
                                                    break;
                                                  }
                                                }
                                              }
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => playing_screen_not_Title(
                                                        item: songModel_search,
                                                        idx: index,
                                                        list_idx: artist_idx,
                                                        audioPlayer: _audioPlayer,)));
                                              //playSong(item.data![index].uri);
                                            }
                                        ),  itemCount: item.data!.length,
                                      );
                                    }
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        )

                    ),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}
