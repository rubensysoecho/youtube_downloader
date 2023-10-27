// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadsDrawer extends StatefulWidget {
  DownloadsDrawer({required this.listaVideosEnDescarga});

  List<Video> listaVideosEnDescarga;

  @override
  State<DownloadsDrawer> createState() => _DownloadsDrawerState();
}

class _DownloadsDrawerState extends State<DownloadsDrawer> {
  @override
  Widget build(BuildContext context) {
      return Drawer(
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
                itemCount: widget.listaVideosEnDescarga.length,
                itemBuilder: (context, index) {
                  Video v = widget.listaVideosEnDescarga[index];
            
                  return ListTile(
                    //leading: Image(
                    //  image: NetworkImage(v.thumbnails.highResUrl),
                    //),
                    trailing: Icon(Icons.abc)
                  );
                },
              ),
          ],
        ),
      );
    }
}
