import 'dart:developer';
import 'package:flutter/material.dart';
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
  List<int> album_idx = []; //앨범으로 곡을 나열할 때 인덱스로 사용할 리스트
  List<int> artist_idx = []; //아티스트로 곡을 나열할 때 인덱스로 사용할 리스트
  List<String> title_list = []; //검색기능에 사용할 리스트
  bool _isCheck = true; //곡 title을 한번만 저장하기 위해 사용할 bool값
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
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  showSearch(context: context, delegate: Search(title_list, songModel_search, _audioPlayer, _isCheck));
                },
                icon: Icon(Icons.search),
              )
            ],
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
                    //Title로 곡을 나열
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
                                    //곡 검색 기능에 사용할 리스트
                                    if (_isCheck == true) {
                                      for (int i = 0; i<item.data!.length; i++) {
                                        title_list.add(item.data![i].title);
                                      }
                                      _isCheck = false;
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
                                              item.data![index].artist ?? 'Unknown Artist',
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
                                                      audioPlayer: _audioPlayer,
                                                    )
                                                )
                                            );
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
                    //Album으로 곡을 나열
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
                                                  for (int i=0; i<item.data!.length; i++) {
                                                    for (int j=0; j<songModel_search!.length; j++) {
                                                      if (songModel_search![j].album == item.data![i].album) {
                                                        album_idx.add(j);
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
                                                            audioPlayer: _audioPlayer,
                                                          )
                                                      )
                                                  );
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
                    //Artist로 곡을 나열
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
                                                item.data![index].artist ?? 'Unknown Artist',
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
                                              for (int i = 0; i < item.data!.length; i++) {
                                                for (int j = 0; j<songModel_search!.length; j++) {
                                                  if (songModel_search![j].artist == item.data![i].artist) {
                                                    artist_idx.add(j);
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
                                                        audioPlayer: _audioPlayer,
                                                      )
                                                  )
                                              );
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

class Search extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton( //검색창 비우기
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      )
    ];
    throw UnimplementedError();
  }
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    throw UnimplementedError();
  }
  String selectedResult = "";
  @override
  Widget buildResults(BuildContext context) {
    return Container(
        child: Center(
          child: Text(selectedResult),
        )
    );
    throw UnimplementedError();
  }
  List<String> title_list = [];
  List<SongModel>? songModel_search;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isCheck;
  int sel_idx = -1;
  Search(this.title_list, this.songModel_search, this._audioPlayer, this._isCheck);
  List<String> recentList = ["비트코인", "이더리움", "리플"];
  List<String> emptyList = [];
  @override
  Widget buildSuggestions(BuildContext context) {
    if (_isCheck == true) {
      for (int i=0; i<songModel_search!.length; i++) {
        title_list.add(songModel_search![i].title);
      }
    }
    print(title_list);
    List<String> suggestionList = [];
    query.isEmpty
        ? suggestionList = emptyList //In the true case
        : suggestionList.addAll(title_list.where(

          (element) => element.toLowerCase().contains(query),
    ));
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(
              suggestionList[index],
            ),
            leading: query.isEmpty ? Icon(Icons.access_time) : SizedBox(),
            onTap: () {
              selectedResult = suggestionList[index];
              for (int i = 0; i<songModel_search!.length; i++) {
                if (songModel_search![i].title == selectedResult) {
                  sel_idx = i;
                  break;
                }
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => playing_screen(
                        item: songModel_search,
                        idx: sel_idx,
                        audioPlayer: _audioPlayer,
                      )
                  )
              );
            }
        );
      },
    );
  }
}