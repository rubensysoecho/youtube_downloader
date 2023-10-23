// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final myController = TextEditingController();

  List listaVideos = [];

  Future<List> buscarVideos(url) async {
    listaVideos.clear();
    var yt = YoutubeExplode();
    var playlist = await yt.playlists.get(url);

    await for (var video in yt.playlists.getVideos(playlist.id)) {
      listaVideos.add(video);
    }

    if (listaVideos.isNotEmpty) {
      setState(() {
        listaVideos = listaVideos;
      });
      print('Nombres de videos añadidos a lista✅');
    } else {
      print('Lista vacia ❌');
    }

    return listaVideos;
  }

  void ejecutarBuscarVideos(url) async {
    listaVideos = await buscarVideos(url);
  }

  @override
  void disponse() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Youtube Downloader')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'YOUTUBE DOWNLOADER',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
            ),
            TextField(
              controller: myController,
              onSubmitted: (value) {
                ejecutarBuscarVideos(value);
              },
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(90)),
                  hintText: 'Introduzca su URL',
                  suffixIcon: Icon(Icons.search)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: listaVideos.length,
                itemBuilder: (context, index) {
                  Video v = listaVideos[index];
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Card(
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey, width: 0.5),
                            borderRadius: BorderRadius.circular(5)),
                        leading: Image(
                          image: NetworkImage(v.thumbnails.highResUrl),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          v.title,
                          style: TextStyle(fontSize: 24),
                        ),
                        subtitle: Text(
                          v.author,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
