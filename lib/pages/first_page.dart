// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/functions/video_functions.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final myController = TextEditingController();

  List listaVideos = [];
  List listaVideosDescargando = [];

  Future<List> buscarVideos(url) async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

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

    Navigator.of(context).pop();
    yt.close();
    return listaVideos;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('cambiaron coza');
  }

  void ejecutarBuscarVideos(url) async {
    listaVideos = await buscarVideos(url);
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }

  Future<void> descargarVideoMP3(index) async {
    Video v = listaVideos[index];
    final yt = YoutubeExplode();
    final streamInfo = await yt.videos.streamsClient.getManifest(v.id);
    final tempDir = await getTemporaryDirectory();

    File file;
    String title = v.title;
    if (Platform.isWindows) {
      file = File(tempDir.path + '/' + title + '.mp3');
    } else {
      String? downloadsDir = await getDownloadPath();
      file = File(downloadsDir! + '/' + title + '.mp3');
    }

    if (streamInfo != null) {
      var info = streamInfo.audioOnly.withHighestBitrate();
      var stream = yt.videos.streamsClient.get(info);
      var fileStream = file.openWrite();

      try {
        await stream.pipe(fileStream);
        await fileStream.flush();
        await fileStream.close();
      } catch (e, stack) {
        print('Error 😒: ' + e.toString());
      }
    }

    print('Video MP3 descargado correctamente ✅');
    yt.close();
  }

  Future<void> descargarPlaylistMP3() async {
    int numVideos = listaVideos.length;
    for (int i = 0; i < numVideos; i++) {
      print(i);
      descargarVideoMP3(i);
    }
    showDialog(
      context: context,
      builder: (context) {
        return Center(
            child:
                Text('Se han descargado los $numVideos videos de la playlist'));
      },
    );
  }

  void _mostrarDialogo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Descarga de playlist'),
          content: Text('¿Seguro que quieres descargar toda la playlist?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                descargarPlaylistMP3();
              },
              child: Text('Si'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
          ],
        );
      },
    );
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                height: 100,
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    _mostrarDialogo();
                  },
                  child: Text(
                    'Download All',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: listaVideos.length,
                itemBuilder: (context, index) {
                  Video v = listaVideos[index];
                  return Card(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey, width: 0.5),
                          borderRadius: BorderRadius.circular(5)),
                      elevation: 2,
                      child: Row(
                        children: [
                          Image(
                            height: 150,
                            width: 400,
                            fit: BoxFit.cover,
                            image: NetworkImage(v.thumbnails.highResUrl),
                          ),

                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 28),
                                  ),
                                  Text(
                                    v.author,
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Expanded(child: SizedBox()),
                          
                          Padding(
                            padding: const EdgeInsets.all(30),
                            child: ElevatedButton(
                              onPressed: () {
                                descargarVideoMP3(index);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Text('MP3'),
                              ),
                            ),
                          ),
                        ],
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
