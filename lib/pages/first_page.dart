// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, avoid_print

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:youtube_downloader/utils/formats.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/DownloadsDrawer.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final myController = TextEditingController();

  List videosList = [];
  List<Video> videosListOnDownload = [];
  List<Video> downloadedList = [];
  bool btnVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  void executeSearchVideos(url) async {
    videosList = await searchVideos(url);
  }
  void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }
  @override
  void disponse() {
    myController.dispose();
    super.dispose();
  }

  // Youtube related functions
  Future<List> searchVideos(url) async { 
    btnVisible = btnVisible;
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    videosList.clear();

    var yt = YoutubeExplode();
    var playlist = await yt.playlists.get(url);

    await for (var video in yt.playlists.getVideos(playlist.id)) {
      videosList.add(video);
    }

    if (videosList.isNotEmpty) {
      setState(() {
        videosList = videosList;
        btnVisible = true;
      });
      print('Videos names added to list ✅');
    } else {
      print('Empty list ❌');
    }

    Navigator.of(context).pop();
    yt.close();
    return videosList;
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getDownloadsDirectory();
      } else if (Platform.isMacOS) {
        directory = await getDownloadsDirectory();
      } else if (Platform.isAndroid) {
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

  Future<void> downloadVideo(int index, Format format) async {
    Video v = videosList[index];
    final yt = YoutubeExplode();
    final streamInfo = await yt.videos.streamsClient.getManifest(v.id);
    final tempDir = await getTemporaryDirectory();
    var mediaInfo;
    var media;
    Stream<List<int>> mediaStream;

    if (format == Format.mp3)  {
      mediaInfo = streamInfo.audioOnly;
      media = mediaInfo.first;
      mediaStream = yt.videos.streamsClient.get(media);
    } else if (format == Format.mp4) {
      mediaInfo = streamInfo.muxed;
      media = mediaInfo.bestQuality;
      mediaStream = yt.videos.streamsClient.get(media);
    } else  {
      mediaInfo = streamInfo.muxed;
      media = mediaInfo.bestQuality;
      mediaStream = yt.videos.streamsClient.get(media);
    }

    File file;
    String fileName = '${v.title}.'
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', '');
    
    String f = format.toString();

    if (Platform.isWindows) {
      file = File('$tempDir/$fileName.$f');
    } else if (Platform.isMacOS)  {
      String? downloadsDir = await getDownloadPath();
      file = File('$downloadsDir/$fileName.$f');
    } else  {
      String? downloadsDir = await getDownloadPath();
      file = File('$downloadsDir/$fileName.$f');
    }

    if (file.existsSync()) {
      file.deleteSync();
    }

    if (streamInfo != null) {
      var info = streamInfo.audioOnly.withHighestBitrate();
      var stream = yt.videos.streamsClient.get(info);
      var fileStream = file.openWrite(mode: FileMode.writeOnlyAppend);

      try {
        videosListOnDownload.add(v);
        print('${v.title} descargandose...');

        setState(() {
          videosListOnDownload = videosListOnDownload;
        });

        final countController = StreamController<int>();
        final len = media.size.totalBytes;
        var count = 0;
        await for (final data in mediaStream) {
          //Calcular Progreso - Mirar en GitHub
          count += data.length;
          final progress = ((count / len) * 100).ceil();
          print(progress.toStringAsFixed(2));
          fileStream.add(data);
        }
        
        await stream.pipe(fileStream);
        await fileStream.flush();
        await fileStream.close();

        videosListOnDownload.remove(v);
        downloadedList.add(v);

        setState(() {
          downloadedList = downloadedList;
        });

        countController.close();
        print('${v.title} terminó de descargarse✅');
      } catch (e) {
        print('Error 😒: ' + e.toString());
      }
    }

    yt.close();
  }

  Future<void> downloadPlaylist() async {
    int numVideos = videosList.length;
    for (int i = 0; i < numVideos; i++) {
      print(i);
      downloadVideo(i, Format.mp3);
    }
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
                downloadPlaylist();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Youtube Downloader')),
      drawer: DownloadsDrawer(
        videosListOnDownload: videosListOnDownload,
        downloadedList: downloadedList,
      ),
      
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
                executeSearchVideos(value);
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
                width: 300,
                child: Visibility(
                  visible: btnVisible,
                  child: ElevatedButton(
                    onPressed: () {
                      _mostrarDialogo();
                    },
                    child: Text(
                      'Download All (${videosList.length} videos)',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: btnVisible,
              child: Divider(
                indent: 100,
                endIndent: 100,
                height: 30,
                color: Colors.red,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: videosList.length,
                itemBuilder: (context, index) {
                  Video v = videosList[index];

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
                          flex: 4,
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
                                Text('Duration: ${v.duration.toString()}  min'),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    downloadVideo(index, Format.mp3);
                                    openDrawer(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Text('MP3'),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    downloadVideo(index, Format.mp4);
                                    openDrawer(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Text('MP4'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
