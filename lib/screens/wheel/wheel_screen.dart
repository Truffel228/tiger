import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bet = 30;

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen>
    with SingleTickerProviderStateMixin {
  final StreamController<int> selected = StreamController.broadcast();

  int _gems = 0;
  Duration? timeLeft;
  bool _spin = false;
  late final SharedPreferences _bd;

  double _angle = 0;
  double _current = 0;
  late AnimationController _ctrl;
  late Animation _ani;
  List<Luck> _items = [
    Luck(20, Color(0xFFfe7c01)),
    Luck(25, Color(0xFFe32900)),
    Luck(30, Color(0xFFfe7c01)),
    Luck(35, Color(0xFFe32900)),
    Luck(40, Color(0xFFfe7c01)),
    Luck(45, Color(0xFFe32900)),
    Luck(50, Color(0xFFfe7c01)),
    Luck(100, Color(0xFFe32900)),
    Luck(150, Color(0xFFfe7c01)),
    Luck(5, Color(0xFFe32900)),
    Luck(10, Color(0xFFfe7c01)),
    Luck(15, Color(0xFFe32900)),
  ];

  @override
  void initState() {
    super.initState();
    var duration = const Duration(milliseconds: 5000);
    _ctrl = AnimationController(vsync: this, duration: duration);
    _ani = CurvedAnimation(parent: _ctrl, curve: Curves.fastLinearToSlowEaseIn);
    _init();
  }

  void _init() async {
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
                      child: AnimatedBuilder(
                          animation: _ani,
                          builder: (context, child) {
                            final _value = _ani.value;
                            final _angle = _value * this._angle;
                            return Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                BoardView(
                                    items: _items,
                                    current: _current,
                                    angle: _angle),
                              ],
                            );
                          }),
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
    // setState(() {
    //   _gems = 1000;
    // });
    // _bd.setInt('gems', _gems);
    // return;
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
    if (!_ctrl.isAnimating) {
      var _random = Random().nextDouble();
      _angle = 20 + Random().nextInt(5) + _random;
      _ctrl.forward(from: 0.0).then((_) {
        _current = (_current + _random);
        _current = _current - _current ~/ 1;
        _ctrl.reset();
      });
    }
    await Future.delayed(const Duration(seconds: 5));
    final result = _result(_ani.value);
    final win = result;
    setState(() {
      _gems += win;
    });

    _bd.setInt('gems', _gems);
    _spin = false;
  }

  int _calIndex(value) {
    var _base = (2 * pi / _items.length / 2) / (2 * pi);
    return (((_base + value) % 1) * _items.length).floor();
  }

  int _result(_value) {
    var _index = _calIndex(_value * _angle + _current);
    int value = _items[_index].value;
    return value;
  }
}

// class WheelScreen extends StatefulWidget {
//   const WheelScreen({super.key});

//   @override
//   State<WheelScreen> createState() => _WheelScreenState();
// }

// class _WheelScreenState extends State<WheelScreen>
//     with SingleTickerProviderStateMixin {
//   double _angle = 0;
//   double _current = 0;
//   late AnimationController _ctrl;
//   late Animation _ani;
//   List<Luck> _items = [
//     Luck(20, Colors.green),
//     Luck(25, Colors.red),
//     Luck(30, Colors.green),
//     Luck(35, Colors.red),
//     Luck(40, Colors.green),
//     Luck(45, Colors.red),
//     Luck(50, Colors.green),
//     Luck(100, Colors.red),
//     Luck(150, Colors.red),
//     Luck(5, Colors.red),
//     Luck(10, Colors.red),
//     Luck(15, Colors.red),
//   ];

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     var _duration = Duration(milliseconds: 5000);
//     _ctrl = AnimationController(vsync: this, duration: _duration);
//     _ani = CurvedAnimation(parent: _ctrl, curve: Curves.fastLinearToSlowEaseIn);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.green, Colors.blue.withOpacity(0.2)])),
//         child: AnimatedBuilder(
//             animation: _ani,
//             builder: (context, child) {
//               final _value = _ani.value;
//               final _angle = _value * this._angle;
//               return Stack(
//                 alignment: Alignment.center,
//                 children: <Widget>[
//                   BoardView(items: _items, current: _current, angle: _angle),
//                   _buildGo(),
//                   _buildResult(_value),
//                 ],
//               );
//             }),
//       ),
//     );
//   }

//   _buildGo() {
//     return Material(
//       color: Colors.white,
//       shape: CircleBorder(),
//       child: InkWell(
//         customBorder: CircleBorder(),
//         child: Container(
//           alignment: Alignment.center,
//           height: 72,
//           width: 72,
//           child: Text(
//             "GO",
//             style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
//           ),
//         ),
//         onTap: _animation,
//       ),
//     );
//   }

//   _animation() {
//     if (!_ctrl.isAnimating) {
//       var _random = Random().nextDouble();
//       _angle = 20 + Random().nextInt(5) + _random;
//       _ctrl.forward(from: 0.0).then((_) {
//         _current = (_current + _random);
//         _current = _current - _current ~/ 1;
//         _ctrl.reset();
//       });
//     }
//   }

//   int _calIndex(value) {
//     var _base = (2 * pi / _items.length / 2) / (2 * pi);
//     return (((_base + value) % 1) * _items.length).floor();
//   }

//   _buildResult(_value) {
//     var _index = _calIndex(_value * _angle + _current);
//     int value = _items[_index].value;
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 16.0),
//       child: Align(
//         alignment: Alignment.bottomCenter,
//         child: Text(value.toString()),
//       ),
//     );
//   }
// }

class BoardView extends StatefulWidget {
  final double angle;
  final double current;
  final List<Luck> items;

  const BoardView({
    Key? key,
    required this.angle,
    required this.current,
    required this.items,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BoardViewState();
  }
}

class _BoardViewState extends State<BoardView> {
  Size get size => Size(MediaQuery.of(context).size.width * 0.8,
      MediaQuery.of(context).size.width * 0.8);

  double _rotote(int index) => (index / widget.items.length) * 2 * pi;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        //shadow
        Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black38)]),
        ),
        Transform.rotate(
          angle: -(widget.current + widget.angle) * 2 * pi,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              for (var luck in widget.items) ...[_buildCard(luck)],
              for (var luck in widget.items) ...[_buildImage(luck)],
            ],
          ),
        ),
        Container(
          height: size.height,
          width: size.width,
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: const Offset(0, -10),
            child: Image.asset(
              'assets/wheel/arrow.png',
              height: 36,
            ),
          ),
        ),
        // Container(
        //   height: size.height,
        //   width: size.width,
        //   child: ArrowView(),
        // ),
      ],
    );
  }

  _buildCard(Luck luck) {
    var _rotate = _rotote(widget.items.indexOf(luck));
    var _angle = 2 * pi / widget.items.length;
    return Transform.rotate(
      angle: _rotate,
      child: ClipPath(
        clipper: _LuckPath(_angle),
        child: Container(
          height: size.height,
          width: size.width,
          color: luck.color,
        ),
      ),
    );
  }

  _buildImage(Luck luck) {
    var _rotate = _rotote(widget.items.indexOf(luck));
    return Transform.rotate(
      angle: _rotate,
      child: Container(
        height: size.height,
        width: size.width,
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(
              height: size.height / 3, width: size.width / 6),
          child: Transform.translate(
            offset: Offset(12, -size.width / 6),
            child: Text(
              luck.value.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LuckPath extends CustomClipper<Path> {
  final double angle;

  _LuckPath(this.angle);

  @override
  Path getClip(Size size) {
    Path _path = Path();
    Offset _center = size.center(Offset.zero);
    Rect _rect = Rect.fromCircle(center: _center, radius: size.width / 2);
    _path.moveTo(_center.dx, _center.dy);
    _path.arcTo(_rect, -pi / 2 - angle / 2, angle, false);
    _path.close();
    return _path;
  }

  @override
  bool shouldReclip(_LuckPath oldClipper) {
    return angle != oldClipper.angle;
  }
}

class ArrowView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: pi,
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: ClipPath(
            clipper: _ArrowClipper(),
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black12, Colors.black])),
              height: 40,
              width: 40,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path _path = Path();
    Offset _center = size.center(Offset.zero);
    _path.lineTo(_center.dx, size.height);
    _path.lineTo(size.width, 0);
    _path.lineTo(_center.dx, _center.dy);
    _path.close();
    return _path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class Luck {
  final int value;
  final Color color;

  Luck(this.value, this.color);
}
