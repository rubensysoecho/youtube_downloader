// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class DownloadsDrawer extends StatefulWidget {
  DownloadsDrawer({required this.videosListOnDownload, required this.downloadedList});

  List<Video> videosListOnDownload;
  List<Video> downloadedList;

  @override
  State<DownloadsDrawer> createState() => _DownloadsDrawerState();
}

class _DownloadsDrawerState extends State<DownloadsDrawer> {

  Future<void> openDirection() async {
    final path;

    if (Platform.isWindows) {
      path = (await getTemporaryDirectory()).path;
      OpenFile.open('$path\\');
    } else if (Platform.isMacOS)  {
      path = await getDownloadsDirectory();
      OpenFile.open('$path\\');
    } else  {
      path = (await getTemporaryDirectory()).path;
      OpenFile.open('$path\\');
    }
  }

  void deleteDownloaded(int index) {
    widget.downloadedList.remove(widget.downloadedList[index]);
    setState(() {
      widget.downloadedList = widget.downloadedList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      child: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Center(
                child: Text(
                  'Downloads',
                  style: TextStyle(fontSize: 28),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.videosListOnDownload.length,
              itemBuilder: (context, index) {
                Video v = widget.videosListOnDownload[index];
                return Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: ListTile(
                        tileColor: Colors.red[200],
                        title: Text(v.title),
                        subtitle: Text(v.author),
                        trailing: ElevatedButton(
                          onPressed: () {
                            openDirection();
                          },
                          child: Icon(
                            Icons.folder,
                          ),
                        )),
                  );
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.downloadedList.length,
              itemBuilder: (context, index) {
                Video v = widget.downloadedList[index];

                return Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: ListTile(
                      tileColor: Colors.green,
                      leading: ElevatedButton(
                        onPressed: () {
                          deleteDownloaded(index);
                        },
                        child: Icon(Icons.close),
                      ),
                      title: Text(v.title),
                      subtitle: Text(v.author),
                      trailing: ElevatedButton(
                        onPressed: () {
                          openDirection();
                        },
                        child: Icon(
                          Icons.folder,
                        ),
                      )
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
