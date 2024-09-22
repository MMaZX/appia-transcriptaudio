import 'dart:ui';
import 'package:app_ia/config/skeleton.dart';
import 'package:app_ia/controller/recorder_controller.dart';
import 'package:app_ia/model/request_model.dart';
import 'package:app_ia/provider/index_provider.dart';
import 'package:app_ia/provider/record_provider.dart';
import 'package:app_ia/provider/request_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ContentViewIA extends ConsumerStatefulWidget {
  const ContentViewIA({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContentViewIAState();
}

class _ContentViewIAState extends ConsumerState<ContentViewIA> {
  final ScrollController _scrollController = ScrollController();
  BorderRadius borderRadiusDefault = BorderRadius.circular(15);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

//
  @override
  Widget build(BuildContext context) {
    final stateRecord = ref.watch(statusCounterProvider);
    final audioResponse = ref.watch(responseAudioProvider);
    final isLoadingIA = ref.watch(isLoadingConvertAudioProvider);
    final query = MediaQuery.sizeOf(context);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              isLoadingIA
                  ? const LoadingPrompt()
                  : audioResponse.transcription.toString().isEmpty
                      ? const ListTile(
                          title: Text("¿Qué deseas hacer?"),
                          subtitle: Opacity(
                              opacity: 0.7,
                              child: Text(
                                  "Puedes subir un archivo de voz, puedes escribir un archivo de audi0. ¡Intentalo!")),
                        )
                      : ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            "Chat IA ${audioResponse.model.isEmpty ? '' : '[${audioResponse.model}]'}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Opacity(
                              opacity: 0.7,
                              child: Text(
                                  audioResponse.transcription.toString(),
                                  textAlign: TextAlign.justify)))
            ],
          ),
        ),
      ],
    );
  }
}

class BarraOpcionesContent extends ConsumerStatefulWidget {
  const BarraOpcionesContent({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BarraOpcionesContentState();
}

class _BarraOpcionesContentState extends ConsumerState<BarraOpcionesContent> {
  final ScrollController _scrollController = ScrollController();
  BorderRadius borderRadiusDefault = BorderRadius.circular(15);

  @override
  Widget build(BuildContext context) {
    int indexTabBar = ref.watch(indexTabBarProvider);
    final stateRecord = ref.watch(statusCounterProvider);
    final audioResponse = ref.watch(responseAudioProvider);
    final query = MediaQuery.sizeOf(context);
    final isLoadingRequest = ref.watch(isLoadingConvertAudioProvider);
    final isLoadingAnalizado = ref.watch(isLoadingProcessAnalyzeProvider);
    final isLoadingResumido = ref.watch(isLoadingProcessSummaryProvider);

    final isRecordingAudio = ref.watch(isRecordingProvider);

    bool isActivePrompt = (isLoadingRequest ||
        isLoadingAnalizado ||
        isLoadingResumido ||
        isRecordingAudio ||
        audioResponse.transcription.toString().isEmpty);
    return SizedBox(
      height: 60,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        children: [
          query.width <= 470
              ? ButtonColoredCustom(
                  title: "Ver más ...",
                  isActivePrompt: isActivePrompt,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                            padding: const EdgeInsets.all(20),
                            child: const AnalisisIAView());
                      },
                    );
                  },
                  colorsFalse: [
                    Colors.blueAccent.shade700,
                    Colors.black87,
                  ],
                )
              : const SizedBox.shrink(),
          query.width <= 470
              ? const SizedBox(width: 15)
              : const SizedBox.shrink(),
          IconButton(
            tooltip: "Copiar contenido",
            onPressed: () => ActionsController(context: context, ref: ref)
                .copyClipboard(audioResponse.transcription.toString()),
            icon: const Icon(Icons.copy_rounded),
          ),
          const SizedBox(width: 15),
          ButtonColoredCustom(
            title: "Analizar audio",
            isActivePrompt: isActivePrompt,
            colorsFalse: [
              Colors.amber,
              Colors.purpleAccent.shade400,
            ],
            onPressed: () async {
              isIndexState(ref, indexTabBar: indexTabBar, value: 1);
              try {
                ref
                    .read(isLoadingProcessAnalyzeProvider.notifier)
                    .update((state) => true);
                await ActionsController(context: context, ref: ref)
                    .createAnalyzeTransaction();
              } catch (e) {
                print(e);
                ref
                    .read(isLoadingProcessAnalyzeProvider.notifier)
                    .update((state) => false);
              }
            },
          ),
          const SizedBox(width: 15),
          ButtonColoredCustom(
            title: "Resumir audio",
            isActivePrompt: isActivePrompt,
            colorsFalse: [
              Colors.greenAccent.shade700,
              Colors.blueAccent.shade400,
            ],
            onPressed: () async {
              isIndexState(ref, indexTabBar: indexTabBar, value: 2);
              try {
                ref
                    .read(isLoadingProcessSummaryProvider.notifier)
                    .update((state) => true);
                await ActionsController(context: context, ref: ref)
                    .createResumenTransaction();
              } catch (e) {
                print(e);
                ref
                    .read(isLoadingProcessSummaryProvider.notifier)
                    .update((state) => false);
              }
            },
          ),
//
        ],
      ),
    );
  }
}

void isIndexState(WidgetRef ref,
    {required int indexTabBar, required int value}) {
  if (indexTabBar != value) {
    ref.read(indexTabBarProvider.notifier).update((state) => value);
  }
}

class LoadingPrompt extends StatelessWidget {
  const LoadingPrompt({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: const Skeleton(height: 30, width: 30),
      ),
      title: const Row(
        children: [
          Expanded(child: Skeleton(height: 20, width: 100)),
          Skeleton(height: 20, width: 100),
          Skeleton(height: 20, width: 50),
        ],
      ),
      subtitle: const Opacity(
        opacity: 0.3,
        child: Row(
          children: [
            Skeleton(height: 20, width: 100),
            Expanded(child: Skeleton(height: 20, width: 100)),
            Skeleton(height: 20, width: 50),
          ],
        ),
      ),
    );
  }
}

class IndexTabBar {
  final int index;
  final String title;
  final StateProvider<AudioResponseModel> provider;
  final StateProvider<bool> providerLoading;

  IndexTabBar({
    required this.index,
    required this.title,
    required this.provider,
    required this.providerLoading,
  });
}

List<IndexTabBar> indexTabBarList = [
  IndexTabBar(
      index: 1,
      title: "Análisis",
      provider: analizarAudioProvider,
      providerLoading: isLoadingProcessAnalyzeProvider),
  IndexTabBar(
      index: 2,
      title: "Resumen",
      provider: resumenAudioProvider,
      providerLoading: isLoadingProcessSummaryProvider),
];

class AnalisisIAView extends ConsumerStatefulWidget {
  const AnalisisIAView({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnalisisIAViewState();
}

class _AnalisisIAViewState extends ConsumerState<AnalisisIAView> {
  IndexTabBar getIndexTabBarByIndex(List<IndexTabBar> list, int index) {
    return list.firstWhere((element) => element.index == index);
  }

  @override
  Widget build(BuildContext context) {
    final loadingPreview = ref.watch(isLoadingProcessAnalyzeProvider);
    int indexTabBar = ref.watch(indexTabBarProvider);
    IndexTabBar indexTabBarItem =
        getIndexTabBarByIndex(indexTabBarList, indexTabBar);
    final responseAudio = ref.watch(indexTabBarItem.provider);
    final isLoadingResponse = ref.watch(indexTabBarItem.providerLoading);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 35,
          child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(
                indexTabBarList.length,
                (index) {
                  IndexTabBar item = indexTabBarList[index];

                  return TextCustomPressed(
                    text: item.title,
                    onTap: () {
                      ref
                          .read(indexTabBarProvider.notifier)
                          .update((state) => item.index);
                    },
                    isActive: indexTabBar == item.index,
                  );
                },
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side:
                    BorderSide(color: Colors.grey.withOpacity(0.5), width: 2)),
            title: const Text(
              "Modelo",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: isLoadingResponse
                ? const Skeleton(height: 20, width: double.maxFinite)
                : Opacity(
                    opacity: 0.7,
                    child: Text(responseAudio.model.isEmpty
                        ? '...'
                        : responseAudio.model),
                  ),
          ),
        ),
        const Divider(color: Colors.grey),
        Expanded(
          child: isLoadingResponse
              ? const Skeleton(height: 20, width: double.maxFinite)
              : Markdown(
                  padding: EdgeInsets.zero,
                  selectable: true,
                  data: responseAudio.message.toString(),
                  styleSheet: MarkdownStyleSheet(
                    textAlign: WrapAlignment.start,
                    code: const TextStyle(color: Colors.white),
                    codeblockPadding: const EdgeInsets.all(15),
                    codeblockDecoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    h2: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                    p: const TextStyle(fontSize: 16, height: 1.5),
                    listBullet: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
        )

        //

        //
      ],
    );
  }
}

class TextCustomPressed extends ConsumerWidget {
  final String text;
  final Function()? onTap;
  final bool isActive;
  const TextCustomPressed({
    super.key,
    required this.text,
    required this.onTap,
    this.isActive = false,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Opacity(
          opacity: isActive ? 1 : 0.5,
          child: Text(
            text,
            style: isActive
                ? const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )
                : const TextStyle(
                    fontSize: 18,
                  ),
          ),
        ),
      ),
    );
  }
}

class ButtonColoredCustom extends ConsumerStatefulWidget {
  final bool isActivePrompt;

  final List<Color> colorsTrue;
  final List<Color> colorsFalse;
  final String title;
  final Function() onPressed;

  const ButtonColoredCustom({
    super.key,
    required this.isActivePrompt,
    this.colorsFalse = const [
      Colors.greenAccent,
      Colors.blueAccent,
    ],
    this.colorsTrue = const [
      Colors.redAccent,
      Colors.pinkAccent,
    ],
    this.title = "Hello",
    required this.onPressed,
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ButtonColoredCustomState();
}

class _ButtonColoredCustomState extends ConsumerState<ButtonColoredCustom> {
  BorderRadius borderRadiusDefault = BorderRadius.circular(15);
  late Alignment beginAlignment;
  late Alignment endAlignment;

  @override
  void initState() {
    super.initState();
    beginAlignment = Alignment.topLeft;
    endAlignment = Alignment.bottomRight;

    // Simulación de movimientos aleatorios
    Future.delayed(Duration.zero, _randomizeAlignments);
  }

  void _randomizeAlignments() {
    setState(() {
      beginAlignment = const Alignment(
        (0.5 - (1 * 2)) * 2, // valores aleatorios para X
        (0.5 - (1 * 2)) * 2, // valores aleatorios para Y
      );
      endAlignment = const Alignment(
        (0.5 - (1 * 2)) * 2,
        (0.5 - (1 * 2)) * 2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: AlignmentTween(begin: beginAlignment, end: endAlignment),
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      onEnd:
          _randomizeAlignments, // Llamamos a la función aleatoria cuando termine la animación
      builder: (context, alignment, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: borderRadiusDefault,
            gradient: LinearGradient(
              tileMode: TileMode.mirror,
              begin: alignment,
              end: Alignment.bottomCenter,
              colors: widget.isActivePrompt
                  ? widget.colorsTrue
                  : widget.colorsFalse,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: MaterialButton(
              padding: const EdgeInsets.symmetric(vertical: 30),
              key: ValueKey<bool>(widget.isActivePrompt),
              shape: RoundedRectangleBorder(
                borderRadius: borderRadiusDefault,
              ),
              onPressed: widget.isActivePrompt ? null : widget.onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  widget.isActivePrompt ? "..." : widget.title,
                  key: ValueKey<String>(
                      widget.isActivePrompt ? "..." : widget.title),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.6),
                        offset: const Offset(2, 2),
                        blurRadius: 7,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    // return Container(
    //   decoration: BoxDecoration(
    //     borderRadius: borderRadiusDefault,
    //     gradient: LinearGradient(
    //         tileMode: TileMode.mirror,
    //         begin: Alignment.topLeft,
    //         end: Alignment.bottomCenter,
    //         colors:
    //             widget.isActivePrompt ? widget.colorsTrue : widget.colorsFalse),
    //   ),
    //   child: AnimatedSwitcher(
    //     duration: const Duration(milliseconds: 500),
    //     transitionBuilder: (Widget child, Animation<double> animation) {
    //       return FadeTransition(opacity: animation, child: child);
    //     },
    //     child: MaterialButton(
    //       padding: const EdgeInsets.symmetric(vertical: 30),
    //       key: ValueKey<bool>(
    //           widget.isActivePrompt), // Clave para diferenciar los estados
    //       shape: RoundedRectangleBorder(
    //         borderRadius: borderRadiusDefault,
    //       ),
    //       onPressed: widget.isActivePrompt ? null : widget.onPressed,
    //       child: Container(
    //         padding: const EdgeInsets.symmetric(horizontal: 15),
    //         child: Text(
    //           widget.isActivePrompt ? "..." : widget.title,
    //           key: ValueKey<String>(widget.isActivePrompt
    //               ? "..."
    //               : widget.title), // Clave única para el texto
    //           style: TextStyle(
    //             fontWeight: FontWeight.bold,
    //             shadows: [
    //               Shadow(
    //                 color: Colors.black
    //                     .withOpacity(0.6), // Color negro con opacidad del 40%
    //                 offset: const Offset(2, 2), // Desplazamiento de la sombra
    //                 blurRadius: 7, // Desenfoque de la sombra
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
