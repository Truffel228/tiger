import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as _math;

const bet = 30;

final List<int> items = [20, 25, 30, 35, 40, 45, 50, 100, 150, 5, 10, 15];

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  final StreamController<int> selected = StreamController.broadcast();

  int _gems = 0;
  Duration? timeLeft;
  bool _spin = false;
  late final SharedPreferences _bd;
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async{
    _bd = await SharedPreferences.getInstance();
    setState(() {
      _gems = _bd.getInt('gems') ?? 0;
    });

    final cachedTime = _bd.getString('lastGift') ?? '';

    final dateTime = DateTime.tryParse(cachedTime) ?? DateTime(2000);

    if (DateTime.now().difference(dateTime).inSeconds < 60 * 60 * 24) {
      final nextGift = dateTime.add(Duration(days: 1));

      setState(() {
        timeLeft = nextGift.difference(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/main_top_image.png',
                  fit: BoxFit.fitWidth,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => _spin ? null : Navigator.of(context).pop(),
                    child: Image.asset(
                      'assets/close.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/slots/blast.png',
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      'assets/slots/shine.png',
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: FortuneWheel(
                          duration: const Duration(seconds: 5),
                          animateFirst: false,
                          selected: selected.stream,
                          indicators: const [
                            FortuneIndicator(
                              alignment: Alignment.topCenter,
                              child: Tria(),
                            ),
                          ],
                          items: [
                            for (var it in items)
                              FortuneItem(
                                style: FortuneItemStyle(
                                  color: items.indexOf(it) % 2 == 0
                                      ? const Color(0xFFe32900)
                                      : const Color(0xFFfe7c01),
                                  borderColor: const Color(0xFF490505),
                                  borderWidth: 2,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 60),
                                  child: Text(
                                    it.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: _onTap,
                      child: Image.asset(
                        'assets/slots/slots_button.png',
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/diamond.png',
                            width: 32,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Color(0xFFffba36),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Text(
                              _gems.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      timeLeft != null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: const Color(0xFFffba36),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  child: Text(
                                    '${timeLeft!.inHours} hours',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Image.asset(
                                  'assets/gift.png',
                                  width: 32,
                                ),
                              ],
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap() async {
    if (_gems < bet) {
      return;
    }
    if (_spin) {
      return;
    }
    setState(() {
      _gems -= bet;
    });

    _bd.setInt('gems', _gems);

    _spin = true;
    final got = Random().nextInt(items.length);
    selected.add(got);
    await Future.delayed(const Duration(seconds: 5));
    final win = items[got];
    setState(() {
      _gems += win;
    });

    _bd.setInt('gems', _gems);
    _spin = false;
  }
}

class Tria extends StatelessWidget {
  const Tria({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -10),
      child: Transform.rotate(
        angle: _math.pi,
        child: SizedBox(
            width: 36,
            height: 36,
            child: Transform.rotate(
              angle: 3.14159265,
              child: Image.asset('assets/wheel/arrow.png'),
            )),
      ),
    );
  }
}
