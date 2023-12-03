import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tiger/screens/bonus/bonus_screen.dart';
import 'package:tiger/screens/slots/slots_screen.dart';
import 'package:tiger/screens/wheel/wheel_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loaded = false;
  bool onb = false;
  String? bonus;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF620000),
      ),
      home: OnBoardingScreen(),
    );
  }
}

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(flex: 2),
          Image.asset(
            'assets/onb/onb_image.png',
            height: MediaQuery.of(context).size.height * 0.4,
          ),
          const Spacer(),
          Center(
            child: Image.asset(
              'assets/onb/onb_text.png',
              width: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              final db = await SharedPreferences.getInstance();
              await db.setBool('onb', true);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainScreen(),
                ),
              );
            },
            child: Image.asset(
              'assets/onb/onb_button.png',
              width: MediaQuery.of(context).size.width * 0.5,
            ),
          ),
          const Spacer(),
          const Text(
            'Terms of Use  |  Privacy Policy',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xff775959),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFfde600),
              ),
              height: MediaQuery.of(context).size.width * 0.7,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          Center(
            child: Image.asset(
              'assets/load_image.png',
              fit: BoxFit.fitWidth,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ],
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Image.asset(
              'assets/main_top_image.png',
              fit: BoxFit.fitWidth,
            ),
            Spacer(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: PageView(
                children: [
                  GestureDetector(
                      onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WheelScreen(),
                            ),
                          ),
                      child: Image.asset('assets/main_wheel.png')),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SlotsScreen(),
                      ),
                    ),
                    child: Image.asset('assets/main_slots.png'),
                  ),
                  GestureDetector(
                      onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BonusScreen(),
                            ),
                          ),
                      child: Image.asset('assets/main_gifts.png')),
                ],
                onPageChanged: (value) {
                  setState(() {
                    _page = value;
                  });
                },
              ),
            ),
            Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => Container(
                  margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _page
                        ? const Color(0xFFFDE602)
                        : Colors.white.withOpacity(0.36),
                  ),
                  height: 8,
                  width: 8,
                ),
              ),
            ),
            Spacer(),
            InkWell(
              onTap: _onTap,
              child: Image.asset(
                'assets/main_button.png',
                width: MediaQuery.of(context).size.width * 0.5,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  void _onTap() {
    switch (_page) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WheelScreen(),
          ),
        );
        return;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SlotsScreen(),
          ),
        );
        return;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BonusScreen(),
          ),
        );
        return;
    }
  }
}
