import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:app_ia/config/api.dart';
import 'package:app_ia/controller/request_controller.dart';
import 'package:app_ia/model/request_model.dart';
import 'package:app_ia/provider/permission_provider.dart';
import 'package:app_ia/provider/record_provider.dart';
import 'package:app_ia/provider/request_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

class AudioRecorderController {
  final BuildContext context;
  final WidgetRef ref;
  final AudioRecorder recorder;
  AudioRecorderController(
      {required this.context, required this.ref, required this.recorder});

  Future<void> startRecording() async {
    ref.invalidate(analizarAudioProvider);
    ref.invalidate(resumenAudioProvider);

    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: 44100,
      bitRate: 128000,
    );

    try {
      await ref.read(permissionProvider.notifier).requestMicrophoneAccess();
      await ref.read(permissionProvider.notifier).requestStorageAccess();
      if (await recorder.hasPermission()) {
        // Obtener el directorio adecuado para almacenamiento
        final Directory directory = await getApplicationDocumentsDirectory();
        final String recordingsDirPath =
            path.join(directory.path, 'recordings');
        // Crear el directorio si no existe
        final Directory recordingsDir = Directory(recordingsDirPath);
        if (!await recordingsDir.exists()) {
          await recordingsDir.create(recursive: true);
        }
        // Crear el nombre del archivo basado en la fecha
        String filename = 'record_${DateTime.now().millisecondsSinceEpoch}.m4a';
        String fullPath = path.join(recordingsDir.path, filename);
        // Iniciar la grabación al archivo
        await recorder.start(config, path: fullPath);
        log("Recording started at: $fullPath");
        // Actualizar estado
        ref.read(isRecordingProvider.notifier).update((state) => true);
      }
    } catch (e) {
      LogManager.logException(e);
      dialogExceptionFile(context, e);
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await recorder.stop();
      if (path == null) {
        throw Exception(
            "Ha ocurrido un problema al momento de terminar la grabación.");
      }
      await ActionsController(context: context, ref: ref)
          .sendAudioRecorder(path.toString());
      ref.read(isRecordingProvider.notifier).update((state) => false);
      log("_filepathSTOPED : $path");
    } catch (e) {
      LogManager.logException(e);
      dialogExceptionFile(context, e);
    }
  }
}

class ActionsController {
  final BuildContext context;
  final WidgetRef ref;

  ActionsController({required this.context, required this.ref});

  Future<void> uploadFileAudio() async {
    try {
      File response = await RequestController().pickFile(context);
      ref.invalidate(analizarAudioProvider);
      ref.invalidate(resumenAudioProvider);
      ref.read(isLoadingConvertAudioProvider.notifier).update((state) => true);
      AudioResponseModel? request =
          await RequestController().uploadAudio(response);
      if (request == null) {
        dialogExceptionFile(context, request);
        return;
      }
      ref.read(responseAudioProvider.notifier).update((state) => request);
    } catch (e) {
      LogManager.logException(e);
    }
    ref.read(isLoadingConvertAudioProvider.notifier).update((state) => false);
  }

  Future<void> uploadFileVideo() async {
    showDialog(
      context: context,
      builder: (context) {
        return const _DialogProcess();
      },
    );
    try {
      var process = await Process.start(
          'powershell', ['-File', 'scripts/install_chocolatey.ps1']);
      // Lee la salida estándar del proceso
      process.stdout.transform(utf8.decoder).listen((line) {
        sendTerminalMessage(line);
      });

      // Lee los errores estándar del proceso
      process.stderr.transform(utf8.decoder).listen((String line) {
        log(line.toString());
      });

      // Espera el código de salida del proceso
      var exitCode = await process.exitCode;
      if (exitCode != 0) {
        sendTerminalMessage("Ha ocurrido un error : $exitCode");
      } else {
        sendTerminalMessage("Se instalo correctamente la libreria ffmpeg");
      }
      //AHORA SI PICK FILE RCTMRE
    } catch (e) {
      LogManager.logException(e);
    } finally {
      await extractAudioFromVideo();
      ref.read(isLoadingConvertAudioProvider.notifier).update((state) => false);
    }
  }

  Future<void> extractAudioFromVideo() async {
    isBackReturn(context);
    try {
      // Obtener el directorio adecuado para almacenamiento
      final Directory directory = await getApplicationDocumentsDirectory();
      final String recordingsDirPath = path.join(directory.path, 'recordings');

      // Crear el directorio si no existe
      final Directory recordingsDir = Directory(recordingsDirPath);
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      // Crear el nombre del archivo basado en la fecha
      String filename = 'video_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final String outputFilePath = path.join(recordingsDirPath, filename);
      isBackReturn(context);
      // Seleccionar el archivo de entrada
      File videoFile = await RequestController().pickFileVideo(context);
      final String inputFilePath = videoFile.path;
      String scriptPath = 'scripts/convert_video_to_audio.ps1';
      // Ejecutar el script PowerShell
      final ProcessResult result = await Process.run(
        'powershell',
        [
          '-File',
          scriptPath,
          '-inputFile',
          inputFilePath,
          '-outputFile',
          outputFilePath
        ],
      );
      sendTerminalMessage(result.stdout.toString());
      if (result.exitCode != 0) {
        sendTerminalMessage(result.stderr.toString());
      }
      ref.invalidate(analizarAudioProvider);
      ref.invalidate(resumenAudioProvider);
      ref.read(isLoadingConvertAudioProvider.notifier).update((state) => true);
      AudioResponseModel? request =
          await RequestController().uploadAudio(videoFile);
      if (request == null) {
        dialogExceptionFile(context, request);
        return;
      }
      ref.read(responseAudioProvider.notifier).update((state) => request);
    } catch (e) {
      LogManager.logException(e);
      sendTerminalMessage(e.toString());
    }
  }

  Future<void> createAnalyzeTransaction() async {
    try {
      final audioResponseModel = ref.watch(responseAudioProvider);
      AudioResponseModel? request = await RequestController()
          .analyseMessagePrompt(audioResponseModel.transcription.toString());
      if (request == null) {
        dialogExceptionFile(context, request);
        return;
      }
      ref.read(analizarAudioProvider.notifier).update((state) => request);
    } catch (e) {
      LogManager.logException(e);
    }
    ref.read(isLoadingProcessAnalyzeProvider.notifier).update((state) => false);
  }

  Future<void> createResumenTransaction() async {
    try {
      final audioResponseModel = ref.watch(responseAudioProvider);
      AudioResponseModel? request = await RequestController()
          .summaryMessagePrompt(audioResponseModel.transcription.toString());
      if (request == null) {
        dialogExceptionFile(context, request);
        return;
      }
      ref.read(resumenAudioProvider.notifier).update((state) => request);
    } catch (e) {
      LogManager.logException(e);
    }
    ref.read(isLoadingProcessSummaryProvider.notifier).update((state) => false);
  }

  Future<void> sendAudioRecorder(String filePath) async {
    try {
      File response = File(filePath);
      ref.read(isLoadingConvertAudioProvider.notifier).update((state) => true);
      AudioResponseModel? request =
          await RequestController().uploadAudio(response);
      if (request == null) {
        dialogExceptionFile(context, request);
        return;
      }
      ref.read(responseAudioProvider.notifier).update((state) => request);
    } catch (e) {
      LogManager.logException(e);
    }
    ref.read(isLoadingConvertAudioProvider.notifier).update((state) => false);
  }

  Future<void> copyClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  void sendTerminalMessage(String process) {
    ref.read(terminalSalidaProvider.notifier).addMessage(process);
  }

  Dio dio = Dio();
  Future<void> downloadWordAnalysis(bool isData) async {
    StateProvider<AudioResponseModel> dataModel;
    // AudioResponseModel analisis = ref.watch(analizarAudioProvider);
    // AudioResponseModel resumen = ref.watch(resumenAudioProvider);
    if (isData) {
      dataModel = analizarAudioProvider;
    } else {
      dataModel = resumenAudioProvider;
    }
    final message = ref.watch(dataModel).message;
    if (message == null) {
      throw Exception("No se ha encontrado un mensaje para analizar");
    }

    String path = await API().getPath(ContentAPI.downloadWordAnalysis);
    try {
      print(path);
      final Map<String, dynamic> data = {
        "text": message,
      };

      final response = await dio.post(path, data: data);
      print(response.data);
      String files = response.data['filePath'];
      await openFile(files);
    } on DioException catch (e) {
      dialogExceptionFile(context, e);
    }
  }
}

class _DialogProcess extends ConsumerWidget {
  const _DialogProcess({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mensaje = ref.watch(terminalSalidaProvider);
    return CupertinoAlertDialog(
      title: Text("Estado"),
      content: SizedBox(
        height: 350,
        child: ListView.builder(
          itemCount: mensaje.length,
          itemBuilder: (context, index) {
            final item = mensaje[index];
            return Text(
              item.toString(),
              textAlign: TextAlign.start,
            );
          },
        ),
      ),
    );
  }
}

final terminalSalidaProvider =
    StateNotifierProvider<TerminalStateNotifier, List<String>>(
  (ref) => TerminalStateNotifier(),
);

class TerminalStateNotifier extends StateNotifier<List<String>> {
  TerminalStateNotifier() : super([]);

  void addMessage(String message) {
    state = [...state, message];
  }
}

Future<void> openFile(String filePath) async {
  final Uri fileUri = Uri.file(filePath);

  try {
    await canLaunchUrl(fileUri);
  } catch (e) {
    print(e);
  }
}
