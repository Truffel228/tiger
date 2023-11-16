import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiger/widgets/roll_slot/roll_slot.dart';
import 'package:tiger/widgets/roll_slot/roll_slot_controller.dart';

const bet = 20;

final List<List<String>> items = [
  [
    'assets/slots/item_1.png',
    'assets/slots/item_2.png',
    'assets/slots/item_3.png',
    'assets/slots/item_1.png',
    'assets/slots/item_2.png',
    'assets/slots/item_3.png',
    'assets/slots/item_1.png',
    'assets/slots/item_2.png',
    'assets/slots/item_3.png',
    'assets/slots/item_3.png',
  ],
  [
    'assets/slots/item_2.png',
    'assets/slots/item_1.png',
    'assets/slots/item_2.png',
    'assets/slots/item_1.png',
    'assets/slots/item_3.png',
    'assets/slots/item_1.png',
    'assets/slots/item_3.png',
    'assets/slots/item_2.png',
    'assets/slots/item_3.png',
    'assets/slots/item_3.png',
  ],
  [
    'assets/slots/item_3.png',
    'assets/slots/item_2.png',
    'assets/slots/item_3.png',
    'assets/slots/item_2.png',
    'assets/slots/item_3.png',
    'assets/slots/item_1.png',
    'assets/slots/item_2.png',
    'assets/slots/item_1.png',
    'assets/slots/item_3.png',
    'assets/slots/item_1.png',
  ],
];

class SlotsScreen extends StatefulWidget {
  const SlotsScreen({super.key});

  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen> {
  int _gems = 0;
  late final SharedPreferences _bd;
  bool _spin = false;
  Duration? timeLeft;

  final _controller = RollSlotController(secondsBeforeStop: 3);
  final _controller1 = RollSlotController(secondsBeforeStop: 3);
  final _controller2 = RollSlotController(secondsBeforeStop: 3);

  @override
  void initState() {
    super.initState();
    _init();
    _controller.addListener(() {
      setState(() {});
    });
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
                    onTap: () => _spin ? null: Navigator.of(context).pop(),
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
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Stack(
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/slots/slots_bg.png',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          Align(
                            alignment: Alignment(0, 0.05),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * .1,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.08),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: IgnorePointer(
                                        child: RollSlot(
                                          itemExtend: 80,
                                          rollSlotController: _controller,
                                          children: items[0]
                                              .map(
                                                (e) => Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                  child: Image.asset(
                                                    e,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: IgnorePointer(
                                        child: RollSlot(
                                          itemExtend: 80,
                                          rollSlotController: _controller1,
                                          children: items[1]
                                              .map(
                                                (e) => Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                  child: Image.asset(e),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: IgnorePointer(
                                        child: RollSlot(
                                          itemExtend: 80,
                                          rollSlotController: _controller2,
                                          children: items[2]
                                              .map(
                                                (e) => Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                  child: Image.asset(e),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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

    final gotItems = List.generate(3, (index) => Random().nextInt(10));
    //win
    // final gotItems = [
    //   0,
    //   1,
    //   4,
    // ];

    _controller.animateRandomly(
      topIndex: Random().nextInt(10),
      centerIndex: gotItems[0],
      bottomIndex: Random().nextInt(10),
    );
    _controller1.animateRandomly(
      topIndex: Random().nextInt(10),
      centerIndex: gotItems[1],
      bottomIndex: Random().nextInt(10),
    );
    _controller2.animateRandomly(
      topIndex: Random().nextInt(10),
      centerIndex: gotItems[2],
      bottomIndex: Random().nextInt(10),
    );

    await Future.delayed(const Duration(seconds: 7));

    final List<String> gotItemsAssets = [];

    for (var i = 0; i < items.length; i++) {
      final item = gotItems[i];
      gotItemsAssets.add(items[i][item]);
    }

    int item1 = 0;
    int item2 = 0;
    int item3 = 0;

    for (var i = 0; i < gotItemsAssets.length; i++) {
      final itemAsset = gotItemsAssets[i];
      switch (itemAsset) {
        case 'assets/slots/item_1.png':
          item1++;
          break;
        case 'assets/slots/item_2.png':
          item2++;
          break;
        case 'assets/slots/item_3.png':
          item3++;
          break;
      }
    }
    _spin = false;

    if (item1 == 3 || item2 == 3 || item3 == 3) {
      winGems(100);

      return;
    }

    if (item1 == 2 || item2 == 2 || item3 == 2) {
      winGems(50);

      return;
    }
  }

  Future<void> winGems(int amount) async {
    setState(() {
      _gems += amount;
    });
    await _bd.setInt('coins', _gems);
  }
}
