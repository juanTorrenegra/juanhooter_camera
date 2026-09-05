import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juanshooter/core/di/providers.dart';
import 'package:juanshooter/game.dart';

class MainMenuButtons extends ConsumerStatefulWidget {
  const MainMenuButtons({required this.game, super.key});

  final MyGame game;

  @override
  ConsumerState<MainMenuButtons> createState() => _MainMenuButtonsState();
}

class _MenuAction {
  const _MenuAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

class _MainMenuButtonsState extends ConsumerState<MainMenuButtons> {
  static const double _width = 560;
  static const double _height = 360;
  static const int _loopOffset = 1000;
  static const List<int> _flexWeights = [1, 1, 2, 1, 1];
  static const int _centerSlot = 2;

  late final CarouselController _controller;
  int _centerIndex = 0;

  MyGame get game => widget.game;

  List<_MenuAction> get _actions => [
    _MenuAction(label: 'Jugar', onPressed: _play),
    _MenuAction(
      label: 'Ranking',
      onPressed: () => game.overlays.add('Leaderboard'),
    ),
    _MenuAction(
      label: 'Configuracion',
      onPressed: () => Flame.device.setLandscapeRightOnly(),
    ),
    _MenuAction(
      label: 'creditos',
      onPressed: () => Flame.device.setLandscapeLeftOnly(),
    ),
    _MenuAction(label: 'Cerrar sesion', onPressed: _signOut),
    _MenuAction(label: 'Salir', onPressed: _exitApp),
  ];

  @override
  void initState() {
    super.initState();
    // Start far into the infinite list so Jugar sits in the large center slot
    // (weights [1, 3, 1]) and scrolling can wrap in both directions.
    _controller = CarouselController(
      initialItem: _loopOffset * _actions.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    game.overlays.remove('MainMenu');
    game.overlays.add('HudDecoration');
    game.overlays.add('ScoreBoard');
    game.resumeEngine();
    game.resumeBgmMusic();
  }

  Future<void> _signOut() async {
    await ref.read(pilotRepositoryProvider).signOut();
    ref.invalidate(currentPilotProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión cerrada. Se creará un nuevo callsign.'),
      ),
    );
  }

  void _exitApp() {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cierra la pestaña para salir')),
      );
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final actions = _actions;
    return SizedBox(
      width: _width,
      height: _height,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
            PointerDeviceKind.trackpad,
          },
        ),
        child: CarouselView.weighted(
          controller: _controller,
          scrollDirection: Axis.vertical,
          flexWeights: _flexWeights,
          consumeMaxWeight: false,
          itemSnapping: true,
          infinite: true,
          enableSplash: false,
          itemClipBehavior: Clip.none,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: const Border(),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          onIndexChanged: (leading) {
            final length = actions.length;
            setState(() {
              _centerIndex = (leading + _centerSlot) % length;
              if (_centerIndex < 0) _centerIndex += length;
            });
          },
          onTap: (index) => actions[index % actions.length].onPressed(),
          children: [
            for (var i = 0; i < actions.length; i++)
              _MenuCarouselLabel(
                label: actions[i].label,
                selected: i == _centerIndex,
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuCarouselLabel extends StatelessWidget {
  const _MenuCarouselLabel({required this.label, required this.selected});

  final String label;
  final bool selected;

  static const List<Shadow> _whiteGlow = [
    Shadow(color: Colors.white, blurRadius: 8),
    Shadow(color: Colors.white, blurRadius: 16),
    Shadow(color: Colors.white70, blurRadius: 28),
    Shadow(color: Colors.white54, blurRadius: 40),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Megatrans',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 5,
              color: selected ? Colors.cyanAccent : Colors.white54,
              shadows: selected ? _whiteGlow : null,
            ),
          ),
        ),
      ),
    );
  }
}
