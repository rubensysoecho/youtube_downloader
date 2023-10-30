// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class DownloadsDrawer extends StatefulWidget {
  DownloadsDrawer(
      {required this.listaVideosEnDescarga, required this.listaDescargados});

  List<Video> listaVideosEnDescarga;
  List<Video> listaDescargados;

  @override
  State<DownloadsDrawer> createState() => _DownloadsDrawerState();
}

class _DownloadsDrawerState extends State<DownloadsDrawer> {
  Future<void> abrirDireccion() async {
    final String path = (await getTemporaryDirectory()).path;
    OpenFile.open('$path\\');
  }

  void borrarDescargado(int index) {
    widget.listaDescargados.remove(widget.listaDescargados[index]);
    setState(() {
      widget.listaDescargados = widget.listaDescargados;
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
              itemCount: widget.listaVideosEnDescarga.length,
              itemBuilder: (context, index) {
                Video v = widget.listaVideosEnDescarga[index];
                return Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: ListTile(
                        //leading: Image(
                        //  image: NetworkImage(v.thumbnails.highResUrl),
                        //),
                        tileColor: Colors.red[200],
                        title: Text(v.title),
                        subtitle: Text(v.author),
                        trailing: ElevatedButton(
                          onPressed: () {
                            abrirDireccion();
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
              itemCount: widget.listaDescargados.length,
              itemBuilder: (context, index) {
                Video v = widget.listaDescargados[index];

                return Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: ListTile(
                      tileColor: Colors.green,
                      leading: ElevatedButton(
                        onPressed: () {
                          borrarDescargado(index);
                        },
                        child: Icon(Icons.close),
                      ),
                      title: Text(v.title),
                      subtitle: Text(v.author),
                      trailing: ElevatedButton(
                        onPressed: () {
                          abrirDireccion();
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
