import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sindcelma_app/components/camera/FotoArquivo.dart';
import 'package:sindcelma_app/components/camera/SelfieComDoc.dart';
import 'package:sindcelma_app/components/camera/SelfieSemDoc.dart';
import 'package:sindcelma_app/model/Request.dart';
import 'package:path/path.dart' as path;
import 'camera/SendingImageLoading.dart';

enum ImageType {
  selfieSemDoc,
  selfieComDoc,
  fotoArquivo
}

class CameraFile extends StatefulWidget {

  final Function(bool status, bool refresh) onRespose;
  final Function? onBack;
  final ImageType type;
  final bool loading;

  const CameraFile({Key? key, this.loading = true,  this.onBack, required this.onRespose, required this.type}) : super(key: key);

  @override
  State<CameraFile> createState() => _CameraFileState();

}

class _CameraFileState extends State<CameraFile> {

  bool onloading = false;

  String getType(){
    switch(widget.type){
      case ImageType.selfieSemDoc: return "nodoc";
      case ImageType.selfieComDoc: return "doc";
      case ImageType.fotoArquivo:
      default:
      return "fav";
    }
  }

  void onFile(File file) async {

    String ext = path.extension(file.path).split('.')[1];

    List<int> imageBytes = file.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    // muda o estado para loading
    if(widget.loading){
      setState(() {
        onloading = true;
      });
    }

    // upload do arquivo aqui

    var createGhostRequest = Request();
    await createGhostRequest.post('/files/create', {
      "ext": ext,
      "type": getType()
    });
    
    if(createGhostRequest.code() != 200) {
      setState(() {
        onloading = false;
      });
      widget.onRespose(false, createGhostRequest.code() == 403);
      return;
    }

    String slug = createGhostRequest.response()['message']['slug'];

    int limit = 5000 * 16;
    int atual = 0;
    int total = base64Image.length;

    while(atual < total){

      int parteFinal = atual + limit;

      if(parteFinal > total - 1) {
        parteFinal = total - 1;
      }

      String dataS = base64Image.substring(atual, parteFinal);

      var appendFile = Request();
      await appendFile.post('/files/append', {
        "data":dataS,
        "slug":slug
      });

      if(appendFile.code() != 200){
        setState(() {
          onloading = false;
        });
        widget.onRespose(false, appendFile.code() == 403);
      }

      atual += limit;

    }

    var commitRequest = Request();
    await commitRequest.post('/files/commit', {
      "slug":slug
    });

    if(widget.loading){
      setState(() {
        onloading = false;
      });
    }

    widget.onRespose(commitRequest.code() == 200, false);

  }

  Widget factoryCamera(){

    if(onloading){
      return const SendingImageLoading();
    }

    switch(widget.type){
      case ImageType.selfieComDoc: return SelfieComDoc(onFile);
      case ImageType.selfieSemDoc: return SelfieSemDoc(onFile);
      case ImageType.fotoArquivo:
      default:
        return FotoArquivo(onFile, onBack: widget.onBack,);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: factoryCamera(),
    );
  }
}
