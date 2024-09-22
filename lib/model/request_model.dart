class AudioResponseModel {
  final String model;
  final String? transcription;
  final String? message;

  AudioResponseModel({required this.model, this.transcription, this.message});

  factory AudioResponseModel.fromJson(Map<String, dynamic> element) {
    return AudioResponseModel(
        model: element['model'] ?? "No existe modelo asignado",
        transcription: element['transcription'] ??
            "Ha ocurrido un error al momento de generar la trasncripcion a voz",
        message:
            element['message'] ?? "Ha ocurrido un error al generar el mensaje");
  }
}
