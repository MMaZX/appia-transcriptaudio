import 'package:app_ia/model/request_model.dart';
import 'package:app_ia/pages/content_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// PROVIDER PARA GUARDAR EL AUDIO CREADO Y GENERADO POR LA IA
final responseAudioProvider = StateProvider<AudioResponseModel>((ref) {
  return AudioResponseModel(model: "", transcription: "", message: "");
});

//AQUI SE GUARDA EL TEXTO QUE CREA lo ANALIZE
final analizarAudioProvider = StateProvider<AudioResponseModel>((ref) {
  return AudioResponseModel(model: "", transcription: "", message: "");
});

final resumenAudioProvider = StateProvider<AudioResponseModel>((ref) {
  return AudioResponseModel(model: "", transcription: "", message: "");
});

final indexTabBarProvider = StateProvider<int>((ref) {
  return indexTabBarList.first.index;
});

// CONDICIONES
final isLoadingConvertAudioProvider = StateProvider<bool>((ref) {
  return false;
});

final isLoadingProcessAnalyzeProvider = StateProvider<bool>((ref) {
  return false;
});

final isLoadingProcessSummaryProvider = StateProvider<bool>((ref) {
  return false;
});
