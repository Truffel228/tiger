import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BonusScreen extends StatefulWidget {
  const BonusScreen({super.key});

  @override
  State<BonusScreen> createState() => _BonusScreenState();
}

class _BonusScreenState extends State<BonusScreen> {
  late final SharedPreferences _bd;
  Duration? timeLeft;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _bd = await SharedPreferences.getInstance();

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
                    onTap: () => Navigator.of(context).pop(),
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              'assets/bonus/bonus_card.png',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          Align(
                            alignment: Alignment(0, 0.28),
                            child: Text(
                              timeLeft == null
                                  ? 'Your bonus is 100 gems'
                                  : '${timeLeft!.inHours} hours left for the next gift',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: InkWell(
                  onTap: () async {
                    if (timeLeft == null) {
                      int gems = _bd.getInt('gems') ?? 0;
                      gems += 100;
                      await _bd.setInt('gems', gems);
                      await _bd.setString(
                        'lastGift',
                        DateTime.now().toString(),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    'assets/bonus/ok_button.png',
                    width: MediaQuery.of(context).size.width * .5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
