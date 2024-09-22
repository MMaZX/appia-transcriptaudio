import 'dart:developer';
import 'dart:io';

import 'package:app_ia/config/api.dart';
import 'package:app_ia/model/request_model.dart';
import 'package:app_ia/provider/record_provider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestController {
  Dio dio = Dio();

  Future<File> pickFile(context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a'],
      );

      if (result != null) {
        return File(result.files.single.path!);
      } else {
        log("No file selected");
        throw Exception("No hay ningun archivo seleccionado.");
      }
    } catch (e) {
      LogManager.logException(e);
      dialogExceptionFile(context, e);
      throw Exception("No se pudo completar la operación");
    }
  }

  Future<File> pickFileVideo(context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'vlc', 'mov'],
      );

      if (result != null) {
        return File(result.files.single.path!);
      } else {
        log("No file selected");
        throw Exception("No hay ningun archivo seleccionado.");
      }
    } catch (e) {
      LogManager.logException(e);
      dialogExceptionFile(context, e);
      throw Exception("No se pudo completar la operación");
    }
  }

  Future<AudioResponseModel?> uploadAudio(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "audio": MultipartFile.fromFileSync(file.path, filename: fileName),
      });
      final String path = await API().getPath(ContentAPI.recordSpeak);
      final response = await dio.post(path, data: formData);
      final json = response.data;
      AudioResponseModel model = AudioResponseModel.fromJson(json);
      return model;
    } on DioException catch (e) {
      LogManager.logException(e);
      throw Exception(e.response.toString());
    }
  }

  Future<AudioResponseModel?> analyseMessagePrompt(String message) async {
    Map<String, dynamic> dataModel = {
      "message": message,
    };
    try {
      final String path = await API().getPath(ContentAPI.analizarMensaje);
      final response = await dio.post(path, data: dataModel);
      final json = response.data;
      AudioResponseModel model = AudioResponseModel.fromJson(json);
      return model;
    } on DioException catch (e) {
      LogManager.logException(e);
      throw Exception(e.response.toString());
    }
  }

  Future<AudioResponseModel?> summaryMessagePrompt(String message) async {
    Map<String, dynamic> dataModel = {
      "message": message,
    };
    try {
      final String path = await API().getPath(ContentAPI.resumirMensaje);
      final response = await dio.post(path, data: dataModel);
      final json = response.data;
      AudioResponseModel model = AudioResponseModel.fromJson(json);
      return model;
    } on DioException catch (e) {
      LogManager.logException(e);
      throw Exception(e.response.toString());
    }
  }
}

void isBackReturn(context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
}

Future<void> dialogException(context, DioException e) async {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('Ha ocurrido un error.'),
        content: Text(e.toString()),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              isBackReturn(context);
            },
            child: const Text("Volver a intentar"),
          )
        ],
      );
    },
  );
}

Future<void> dialogExceptionFile(context, e) async {
  print(e.toString());
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text('Estado.'),
        content: Text(e.toString()),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              isBackReturn(context);
            },
            child: const Text("Volver a intentar"),
          )
        ],
      );
    },
  );
}
