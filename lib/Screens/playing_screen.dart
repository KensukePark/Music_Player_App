import 'package:flutter/material.dart';

class playing_screen extends StatefulWidget {
  const playing_screen({Key? key}) : super(key: key);

  @override
  State<playing_screen> createState() => _playing_screenState();
}

class _playing_screenState extends State<playing_screen> {
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
                    CircleAvatar(
                      radius: 100.0,
                      child: Icon(Icons.music_note, size: 80,)
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Text("Song Name",
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
                    Text("Artist Name",
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(
                      height: 100.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("0.0"),
                        Expanded(
                            child: Slider(
                                value: 0.0,
                              onChanged: (value){},
                              thumbColor: Colors.white,
                              activeColor: Colors.grey,
                              inactiveColor: Colors.grey,
                            )
                        ),
                        Text("0.0"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(onPressed: (){}, icon: Icon(Icons.skip_previous, size: 30.0,),),
                        IconButton(onPressed: (){}, icon: Icon(Icons.pause, size: 30.0, color: Colors.orangeAccent,),),
                        IconButton(onPressed: (){}, icon: Icon(Icons.skip_next, size: 30.0,),),

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
