import 'dart:async';
import 'package:flutter/material.dart';

class Skeleton extends StatefulWidget {
  final double height;
  final double width;

  const Skeleton({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with TickerProviderStateMixin {
  bool showSkeleton = true;

  @override
  void initState() {
    super.initState();
    // Inicia un temporizador que cambia el estado cada 400ms
    Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (mounted) {
        setState(() {
          showSkeleton = !showSkeleton;
        });
      }
    });
  }

  late final AnimationController con = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: true);

  late final AnimationController sca = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);

  late Animation<double> scale = Tween<double>(begin: 1, end: 3).animate(
    CurvedAnimation(
      parent: sca,
      curve: Curves
          .easeInOutExpo, // Puedes cambiar a otra curva según tus necesidades
    ),
  );
  late Animation<double> scales = Tween<double>(begin: 1, end: 1).animate(
    CurvedAnimation(
      parent: sca,
      curve: Curves
          .easeInOutExpo, // Puedes cambiar a otra curva según tus necesidades
    ),
  );

  @override
  void dispose() {
    con.dispose();
    sca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: showSkeleton ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: ScaleTransition(
          scale: scales,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15)),
              height: widget.height,
              width: widget.width,
            ),
          )),
    );
  }
}

class ChargingTile extends StatelessWidget {
  const ChargingTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 2,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) =>
            const Skeleton(height: 10, width: 180));
  }
}

class LoadingSquare extends StatelessWidget {
  const LoadingSquare({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: 5,
        // scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) =>
            const Skeleton(height: 100, width: 100));
  }
}

class LoadingListTile extends StatelessWidget {
  const LoadingListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      // leading: Skeleton(height: 60, width: 60),
      title: Skeleton(height: 20, width: 50),
      subtitle: Skeleton(height: 20, width: double.infinity),
      // trailing: Skeleton(height: 60, width: 40),
    );
  }
}

class SquareTile extends StatelessWidget {
  const SquareTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.grey.shade100),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(fit: BoxFit.cover, child: Skeleton(height: 25, width: 25)),
          FittedBox(fit: BoxFit.cover, child: Skeleton(height: 20, width: 100)),
          FittedBox(fit: BoxFit.cover, child: Skeleton(height: 20, width: 100)),
        ],
      ),
    );
  }
}
