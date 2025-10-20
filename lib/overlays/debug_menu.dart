import 'package:flutter/material.dart';
import 'package:juanhooter_camera/game.dart';

class DebugMenu extends StatefulWidget {
  final MyGame game;

  const DebugMenu({required this.game, super.key});

  @override
  State<DebugMenu> createState() => _DebugMenuState();
}

class _DebugMenuState extends State<DebugMenu> {
  bool _isDrawerOpen = true;
  double _currentZoom = 1.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: Row(
        children: [
          // Icono del menú (siempre visible)
          _buildMenuIcon(),

          // Drawer desplegable
          if (_isDrawerOpen) _buildDebugDrawer(),
        ],
      ),
    );
  }

  Widget _buildMenuIcon() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDrawerOpen = !_isDrawerOpen;
        });
      },
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.cyan, width: 1),
        ),
        child: const Icon(Icons.settings, color: Colors.cyan, size: 24),
      ),
    );
  }

  Widget _buildDebugDrawer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25, // 1/4 de la pantalla
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 20),

            // Fast Mode Toggle
            _buildFastModeToggle(),
            const SizedBox(height: 16),

            // Zoom Controls
            _buildZoomControls(),
            const SizedBox(height: 16),

            // Espacio para futuros botones
            _buildPlaceholderButton('God Mode'),
            const SizedBox(height: 8),
            _buildPlaceholderButton('Spawn Enemy'),
            const SizedBox(height: 8),
            _buildPlaceholderButton('Reset Level'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Icon(Icons.bug_report, color: Colors.cyan, size: 24),
        SizedBox(width: 8),
        Text(
          'DEBUG MENU',
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Megatrans',
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFastModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.game.player.isFastMode ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.rocket_launch,
          color: widget.game.player.isFastMode ? Colors.green : Colors.red,
        ),
        title: Text(
          widget.game.player.isFastMode ? 'FAST MODE ON' : 'FAST MODE OFF',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Megatrans',
          ),
        ),
        trailing: Switch(
          value: widget.game.player.isFastMode,
          activeColor: Colors.green,
          inactiveThumbColor: Colors.red,
          onChanged: (value) {
            setState(() {
              widget.game.player.isFastMode = value;
              widget.game.player.currentSpeed = value ? 250 : 50;
            });
          },
        ),
        onTap: () {
          setState(() {
            widget.game.player.isFastMode = !widget.game.player.isFastMode;
            widget.game.player.currentSpeed = widget.game.player.isFastMode
                ? 250
                : 50;
          });
        },
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del zoom
          Row(
            children: [
              const Icon(Icons.zoom_in, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'ZOOM LEVEL',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Megatrans',
                ),
              ),
              const Spacer(),
              Text(
                '${_currentZoom.toStringAsFixed(1)}x',
                style: const TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Controles de zoom
          Row(
            children: [
              // Botón -
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.remove, size: 16),
                  label: const Text('ZOOM OUT'),
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom - 0.1).clamp(0.5, 3.0);
                      _applyZoom();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Botón +
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('ZOOM IN'),
                  onPressed: () {
                    setState(() {
                      _currentZoom = (_currentZoom + 0.1).clamp(0.5, 3.0);
                      _applyZoom();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),

          // Slider de zoom (opcional)
          const SizedBox(height: 12),
          Slider(
            value: _currentZoom,
            min: 0.5,
            max: 3.0,
            divisions: 25,
            label: _currentZoom.toStringAsFixed(1),
            activeColor: Colors.cyan,
            inactiveColor: Colors.grey[600],
            onChanged: (value) {
              setState(() {
                _currentZoom = value;
                _applyZoom();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderButton(String text) {
    return ElevatedButton(
      onPressed: () {
        // Placeholder para futuras funcionalidades
        print('$text pressed');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Megatrans',
        ),
      ),
    );
  }

  void _applyZoom() {
    // Aquí implementarás la lógica del zoom en tu cámara
    // Por ejemplo:
    // widget.game.camera.zoom = _currentZoom;
    print('Zoom cambiado a: ${_currentZoom}x');
  }
}
