
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../enumeration/ActionMusique.dart';
import '../musique.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:core';
import 'dart:async';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  late Musique maMusiqueActuelle;
  Duration position = const Duration(seconds: 0);
  Duration duree = const Duration(seconds: 10);
  late AudioPlayer audioplayer;
  PlayerState status = PlayerState.stopped;
  int index=0;

  late StreamSubscription positionSub;
  late StreamSubscription stateSubscription;

  List<Musique> maListeDeMusique = [
    Musique("Theme Swift", "Migos", "assets/un.jpg", 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3'),
    Musique("Theme Flutter", "Migos", "assets/deux.jpeg", 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3'),
  ];


  @override
  void initState(){
    super.initState();
    maMusiqueActuelle = maListeDeMusique[index];
    ConfigurationAudioPlayer();
  }

  Widget texteAvecStyle(String data, double scale){
    return Text(
      data,
      textScaleFactor: scale,
      style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontStyle: FontStyle.italic
      ),
    );
  }

  Widget button( IconData icon, double taille, ActionMusic action){
    return IconButton(
        iconSize: taille,
        color: Colors.white,
        onPressed: () {
          switch(action){
            case ActionMusic.play:
              play();
              break;
            case ActionMusic.pause:
              pause();
              break;
            case ActionMusic.forward:
              forward();
              break;
            case ActionMusic.rewind:
              rewind();
              break;
          }
        } ,
        icon: Icon(icon)
    );
  }

  void ConfigurationAudioPlayer(){
    audioplayer =  AudioPlayer();
    positionSub = audioplayer.onPositionChanged.listen(
            (pos) => setState(() {
              position = pos;
            }
            )
    );
    stateSubscription = audioplayer.onPlayerStateChanged.listen((state) {
      if(state == PlayerState.playing){
          setState(() {
            duree = audioplayer.getDuration() as Duration;
          });
      }
      else if(state == PlayerState.stopped){
        setState(() {
          status = PlayerState.stopped;
        });
      }
    },
      onError: (message) {
      if (kDebugMode) {
        print("Error: $message");
      }
      setState(() {
        status = PlayerState.stopped;
        duree = const Duration(seconds: 0);
        position = const Duration(seconds: 0);
      });
      }
    );
  }

  Future play() async{
    await audioplayer.setSourceAsset('un.mp3');
    setState(() {
      status = PlayerState.playing;
    });
  }

  Future pause() async{
    await audioplayer.pause();
    setState(() {
      status = PlayerState.paused;
    });
  }

  void forward(){
    if(index == maListeDeMusique.length -1){
      index = 0;
    }else{
      index++;
    }
    maMusiqueActuelle = maListeDeMusique[index];
    audioplayer.stop();
    ConfigurationAudioPlayer();
    play();
  }

  String fromDuration(Duration duree){
    print(duree);
    return duree.toString().split('.').first;
  }

  void rewind(){
    if(position > const Duration(seconds: 3)){
      audioplayer.seek(0.0 as Duration);
    }else{
      if(index == 0){
          index = maListeDeMusique.length - 1;
      }
      else{
        index--;
      }
      maMusiqueActuelle = maListeDeMusique[index];
      audioplayer.stop();
      ConfigurationAudioPlayer();
      play();
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        elevation: 10,
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              elevation: 9.0,
              child: Container(
                height: MediaQuery.of(context).size.width / 1.2,
                //width: MediaQuery.of(context).size.height / 3.0,
                child: Image.asset(maMusiqueActuelle.imagePath),
              ),
            ),
            texteAvecStyle(maMusiqueActuelle.titre, 2.0),
            texteAvecStyle(maMusiqueActuelle.artiste, 1.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                button(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                button((status== PlayerState.playing) ?Icons.pause : Icons.play_arrow, 45.0, (status == PlayerState.playing) ?ActionMusic.pause :ActionMusic.play),
                button(Icons.fast_forward, 30.0, ActionMusic.forward)
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                texteAvecStyle(fromDuration(position), 0.8),
                texteAvecStyle(fromDuration(duree), 0.8),
              ],
            ),
            Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d){
                  setState(() {
                    audioplayer.seek(d as Duration);
                  });
                }
            ),
          ],
        ),
      ),
    );
  }

}


