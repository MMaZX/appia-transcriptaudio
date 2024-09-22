import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FutureCustomWidget extends StatefulWidget {
  final Future future;
  final Widget? customLoading;
  final Widget Function(BuildContext context, dynamic snapshot) widgetBuilder;
  const FutureCustomWidget(
      {super.key,
      required this.future,
      required this.widgetBuilder,
      this.customLoading});

  @override
  State<FutureCustomWidget> createState() => _FutureCustomWidgetState();
}

class _FutureCustomWidgetState extends State<FutureCustomWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.customLoading ??
              const Center(child: Text("Cargando..."));
        } else if (snapshot.hasError) {
          // print(snapshot.error);
          return Center(child: Text("Error ${snapshot.error}"));
        } else {
          // return widget;
          if (snapshot.data == null) {
            return const Text("Validando...");
          } else {
            return widget.widgetBuilder(context, snapshot);
          }
        }
      },
    );
  }
}

class TextFormCustom extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Color? color;
  final int? maxLenght;
  const TextFormCustom({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.onChanged,
    this.inputFormatters,
    this.keyboardType,
    this.maxLenght,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      maxLength: maxLenght,
      decoration: InputDecoration(
        counter: const SizedBox(),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: color ?? Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 14.0,
        ),
        // fillColor: state ? const Color(0xFF0e0e10) : Colors.white,
        // filled: true,
      ),
      onChanged: onChanged,
      obscureText: obscureText,
    );
  }
}

class ButtonUploadFile extends ConsumerWidget {
  final Function()? onTap;
  final Widget icon;
  final bool isQuery;
  final String title;
  final String subtitle;

  const ButtonUploadFile({
    super.key,
    this.onTap,
    required this.icon,
    required this.isQuery,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Tooltip(
        message: "$title\n$subtitle",
        child: MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.grey),
          ),
          onPressed: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [icon, const SizedBox(width: 7), Text(title)],
            ),
          ),
        ),
      ),
      // child: isQuery
      //     ? SizedBox(
      //         width: query * 0.5,
      //         height: 200,
      //         child: ListTile(
      //           tileColor:
      //               Theme.of(context).colorScheme.primary.withOpacity(0.1),
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(15),
      //           ),
      //           onTap: onTap,
      //           leading: icon,
      //           title: Text(
      //             title,
      //             style: const TextStyle(fontWeight: FontWeight.bold),
      //           ),
      //           subtitle: Opacity(opacity: 0.7, child: Text(subtitle)),
      //         ),
      //       )
      //     : Tooltip(
      //         message: "$title\n$subtitle",
      //         child: MaterialButton(
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(15),
      //             side: const BorderSide(color: Colors.grey),
      //           ),
      //           onPressed: onTap,
      //           child: Container(
      //             padding: const EdgeInsets.symmetric(horizontal: 15),
      //             child: Row(
      //               mainAxisSize: MainAxisSize.min,
      //               children: [icon, const SizedBox(width: 7), Text(title)],
      //             ),
      //           ),
      //         ),
      //       ),
    );
  }
}
