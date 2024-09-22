import 'package:app_ia/config/api.dart';
import 'package:app_ia/controller/recorder_controller.dart';
import 'package:app_ia/controller/request_controller.dart';
import 'package:app_ia/pages/content_page.dart';
import 'package:app_ia/provider/record_provider.dart';
import 'package:app_ia/provider/request_provider.dart';
import 'package:app_ia/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';

class IndexPage extends ConsumerStatefulWidget {
  const IndexPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IndexPageState();
}

class _IndexPageState extends ConsumerState<IndexPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.sizeOf(context);
    bool conditionResponsive = query.width > 470;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: Column(
                  children: [
                    const Expanded(
                      child: ContentIA(),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ButtonUploadFile(
                            icon: const Icon(Icons.audio_file_rounded),
                            isQuery: conditionResponsive,
                            title: "Subir Audio",
                            subtitle: "Formatos compatibles (.wav, .mp3, .m4a)",
                            onTap: () =>
                                ActionsController(context: context, ref: ref)
                                    .uploadFileAudio(),
                          ),
                          ButtonUploadFile(
                            icon: const Icon(Icons.video_file_rounded),
                            isQuery: conditionResponsive,
                            title: "Subir Video",
                            subtitle: "Formatos compatibles (.mp4)",
                            onTap: () =>
                                ActionsController(context: context, ref: ref)
                                    .uploadFileVideo(),
                          ),
                          ButtonUploadFile(
                            icon: const Icon(Icons.video_file_rounded),
                            isQuery: conditionResponsive,
                            title: "Análisis - Descargar Word",
                            subtitle: "Se requiere un archivo de word",
                            onTap: () =>
                                ActionsController(context: context, ref: ref)
                                    .downloadWordAnalysis(true),
                          ),
                          ButtonUploadFile(
                            icon: const Icon(Icons.video_file_rounded),
                            isQuery: conditionResponsive,
                            title: "Resumen - Descargar Word",
                            subtitle: "Se requiere un archivo de word",
                            onTap: () =>
                                ActionsController(context: context, ref: ref)
                                    .downloadWordAnalysis(false),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const ButtonsRecorder(),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

class ContentIA extends ConsumerStatefulWidget {
  const ContentIA({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContentIAState();
}

class _ContentIAState extends ConsumerState<ContentIA> {
  @override
  Widget build(BuildContext context) {
    // final stateRecord = ref.watch(statusCounterProvider);
    // final audioResponse = ref.watch(responseAudioProvider);
    // final isLoadingIA = ref.watch(isLoadingConvertAudioProvider);

    final query = MediaQuery.sizeOf(context);
    // print(query.width);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: false,
            toolbarHeight: 80,
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: const Text(
                "Transcriptor de voz a texto",
                maxLines: 2,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const _DialogConfig();
                    },
                  );
                },
                icon: const Icon(Icons.settings_rounded),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: query.width > 470
                    ? Row(
                        children: [
                          const Expanded(
                            child: ContentViewIA(),
                          ),
                          SizedBox(
                            // width: 200,
                            width: query.width * 0.35,
                            child: const AnalisisIAView(),
                          )
                        ],
                      )
                    : const ContentViewIA(),
              ),
              //Barra de opciones
              const BarraOpcionesContent(),
            ],
          )),
    );
  }
}

class _DialogConfig extends StatefulWidget {
  const _DialogConfig({
    super.key,
  });

  @override
  State<_DialogConfig> createState() => _DialogConfigState();
}

class _DialogConfigState extends State<_DialogConfig> {
  TextEditingController servidorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: FutureCustomWidget(
          future: SharedToken().getBaseUrl(),
          widgetBuilder: (context, snapshot) {
            String item = snapshot.data;

            servidorController = TextEditingController(text: item);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text(
                          "Dirección servidor",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: TextFormCustom(
                          controller: servidorController,
                          hintText: item,
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          try {
                            if (servidorController.text.isEmpty) {
                              throw Exception("No puede estar vacio");
                            }
                            setState(() {
                              SharedToken().setBaseUrl(servidorController.text);
                            });
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: const Text("Estado"),
                                  content: Text(e.toString()),
                                  actions: [
                                    CupertinoDialogAction(
                                        onPressed: () => isBackReturn(context),
                                        child: const Text("Aceptar"))
                                  ],
                                );
                              },
                            );
                          }
                        },
                        icon: const Icon(Icons.save_alt_rounded))
                  ],
                ),
                ListTile(
                  title: const Text(
                    "Dirección servidor (Actual)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Opacity(opacity: 0.7, child: Text(item.toString())),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ButtonsRecorder extends ConsumerStatefulWidget {
  const ButtonsRecorder({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ButtonsRecorderState();
}

class _ButtonsRecorderState extends ConsumerState<ButtonsRecorder>
    with WidgetsBindingObserver {
  int valueSquare = 100;
  final double anchor = 200;

  final _recorder = AudioRecorder();

  @override
  Widget build(BuildContext context) {
    final controller = AudioRecorderController(
        context: context, ref: ref, recorder: _recorder);
    final isRecording = ref.watch(isRecordingProvider);
    final isLoadingRequest = ref.watch(isLoadingConvertAudioProvider);
    final isLoadingAnalizado = ref.watch(isLoadingProcessAnalyzeProvider);
    final isLoadingResumido = ref.watch(isLoadingProcessSummaryProvider);

    final query = MediaQuery.sizeOf(context);

    List<Color> colors = [
      Colors.deepPurpleAccent.shade100,
      Colors.blueAccent.shade700,
    ];
    List<Color> colorsStop = [
      Colors.redAccent.shade700,
      Colors.pinkAccent.shade100,
    ];

    List<Color> colorsWaiting = [
      Colors.yellowAccent.shade700,
      Colors.purpleAccent.shade700,
    ];

    bool isLoadingAPI =
        (isLoadingRequest || isLoadingAnalizado || isLoadingResumido);

    Widget buildWidgetMicrophone(double radius, double size) {
      return IconButtonCustomCSS(
        height: size,
        width: size,
        colors:
            isLoadingAPI ? colorsWaiting : (isRecording ? colorsStop : colors),
        borderRadius: radius,
        function: isLoadingAPI
            ? null
            : isRecording
                ? () => controller.stopRecording()
                : () => controller.startRecording(),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
              begin: isRecording ? 80 : 30, end: isRecording ? 30 : 80),
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          builder: (context, radius, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(
                  begin: isLoadingAPI ? 80 : 50, end: isLoadingAPI ? 50 : 80),
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              builder: (context, size, child) {
                return buildWidgetMicrophone(radius, size);
              },
            );
          },
        ),
      ],
    );
  }
}

class IconButtonCustomCSS extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Function()? function;
  final List<Color> colors;
  const IconButtonCustomCSS(
      {super.key,
      this.width = 100,
      this.height = 100,
      this.borderRadius = 30,
      this.function,
      required this.colors});

  @override
  State<IconButtonCustomCSS> createState() => _IconButtonCustomCSSState();
}

class _IconButtonCustomCSSState extends State<IconButtonCustomCSS>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Controlador de la animación
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Animación de rotación
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.fastLinearToSlowEaseIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159265359,
                  child: Container(
                    height: widget.height,
                    width: widget.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment
                            .centerLeft, // Movimiento horizontal limitado
                        end: Alignment.centerRight, // Movimiento opuesto
                        colors: widget.colors, // Los colores del gradiente
                      ),
                      borderRadius: BorderRadius.circular(widget
                          .borderRadius), // Esquinas redondeadas del botón
                    ),
                    child: MaterialButton(
                      minWidth: widget.width,
                      onPressed: widget.function,
                      // Tamaño del botón
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        InkWell(
          onTap: widget.function,
          child: const Icon(Icons.mic_rounded, color: Colors.white),
        )
      ],
    );
  }
}
