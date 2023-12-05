// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_perfect/pixel_perfect.dart';
import 'package:promodo_timer/theme/palette.dart';
import 'package:promodo_timer/timer.dart';

double getResponsiveFontSize(BuildContext context, double baseFontSize) {
  final screenWidth = MediaQuery.of(context).size.width;
  const double scalingFactor = 2000;
  return screenWidth / scalingFactor * baseFontSize;
}

void main() {
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screendize = MediaQuery.of(context).size;
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'neur'),
        home: PixelPerfect(
          scale: 1.7,
          assetPath: 'design.png',
          offset: const Offset(206, 60),
          initOpacity: 0,
          child: Scaffold(
            backgroundColor: Palette.kBackgroundColor,
            body: Center(
              child: Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        spreadRadius: 1,
                        color: Colors.black.withOpacity(0.1),
                      )
                    ],
                    border: Border.all(color: Colors.black, width: 3),
                    color: Palette.ksilverColor,
                    borderRadius: BorderRadius.circular(25)),
                height: screendize.width / 3,
                width: screendize.width / 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TimeCard(screendize.width / 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SmallCard(
                          size: screendize.width / 3,
                          title: "Break Length",
                          type: "break",
                        ),
                        SmallCard(
                          size: screendize.width / 3,
                          title: "Session Length",
                          type: "session",
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TimeCard extends ConsumerWidget {
  final double size;

  const TimeCard(this.size, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TimerModel time = ref.watch(timerProvider);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.2),
              blurRadius: 10,
              spreadRadius: 1)
        ],
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
      ),
      height: size / 2,
      width: size / 1.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time.buttonState == ButtonState.session
                ? "SESSION"
                : time.buttonState == ButtonState.breakTime
                    ? "BREAK"
                    : "PAUSED",
            style: TextStyle(fontSize: getResponsiveFontSize(context, 25)),
          ),
          Text(time.timeLeft,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: getResponsiveFontSize(context, 90))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // border around textbutton
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(10),
                  // square border
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  side: const BorderSide(color: Colors.black, width: 1),
                ),
                onPressed: () {
                  ref.read(timerProvider.notifier).start();
                },
                child: Text(
                    // if buttonstate is paused then show resume else show pause if buttonstate is null then show start
                    time.buttonState == ButtonState.paused
                        ? "Resume"
                        : time.buttonState == null
                            ? "Start"
                            : "Pause",
                    style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 25))),
              ),
              const SizedBox(
                width: 10,
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(10),
                  // square border
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  side: const BorderSide(color: Colors.black, width: 1),
                ),
                onPressed: () {
                  ref.read(timerProvider.notifier).reset();
                },
                child: Text("Reset",
                    style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 25))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SmallCard extends ConsumerWidget {
  SmallCard(
      {super.key, required this.size, required this.title, required this.type});
  final double size;
  final String title;
  final String type;
  StateProvider<int>? provider;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        type == 'break' ? breakDurationProvider : sessionDurationProvider;
    final timer = ref.watch(provider);
    return Container(
      height: size / 3,
      width: size / 2.6,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.2),
              blurRadius: 10,
              spreadRadius: 1)
        ],
        borderRadius: BorderRadius.circular(25),
        color: Palette.kDarkColor,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            color: Palette.kDarkSilverColor,
            height: size / 6,
            width: size / 2.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    if (timer > 0) {
                      ref.read(timerProvider.notifier).reset();
                      ref.read(provider.notifier).state--;
                    }
                  },
                  icon: Icon(Icons.remove,
                      size: getResponsiveFontSize(context, 40)),
                  color: Colors.white,
                ),
                Text(
                  timer.toString(),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: getResponsiveFontSize(context, 50)),
                ),
                IconButton(
                  onPressed: () {
                    ref.read(timerProvider.notifier).reset();
                    ref.read(provider.notifier).state++;
                  },
                  icon: Icon(
                    Icons.add,
                    size: getResponsiveFontSize(context, 40),
                  ),
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Text(
            title,
            style: TextStyle(
                color: Colors.white,
                fontSize: getResponsiveFontSize(context, 26)),
          ),
        ],
      ),
    );
  }
}
