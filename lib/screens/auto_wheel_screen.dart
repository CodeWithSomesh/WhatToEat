import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

class AutoWheelScreen extends StatefulWidget {
  final List<String> options;
  const AutoWheelScreen({Key? key, required this.options}) : super(key: key);

  @override
  State<AutoWheelScreen> createState() => _AutoWheelScreenState();
}

class _AutoWheelScreenState extends State<AutoWheelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _selectedIndex;
  bool _isSpinning = false;
  String? _lastResult;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late List<String> _currentOptions;

  @override
  void initState() {
    super.initState();
    _currentOptions = List<String>.from(widget.options);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _spinWheel() async {
    if (_currentOptions.isEmpty || _isSpinning) return;
    setState(() => _isSpinning = true);
    final random = Random();
    final selected = random.nextInt(_currentOptions.length);
    final spins = 5 + random.nextInt(3); // 5-7 full spins
    final anglePerOption = 2 * pi / _currentOptions.length;

    // Calculate the angle needed to position the selected option under the arrow
    // The arrow points to the top (-pi/2), so we need to rotate the wheel
    // so that the selected option is at the top position
    final selectedOptionAngle = selected * anglePerOption + anglePerOption / 2;
    final targetAngle = (spins * 2 * pi) + (2 * pi - selectedOptionAngle);

    _animation = Tween<double>(begin: 0, end: targetAngle).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );
    // Play spinning sound
    await _audioPlayer.play(AssetSource('sounds/spin.mp3'));
    await _animationController.forward(from: 0);
    await _audioPlayer.stop();
    setState(() {
      _selectedIndex = selected;
      _lastResult = _currentOptions[selected];
      _isSpinning = false;
    });
    _confettiController.play();
  }

  void _startOver() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _tryAgain() {
    setState(() {
      _selectedIndex = null;
      _lastResult = null;
    });
  }

  void _removeOption(int idx) {
    setState(() {
      _currentOptions.removeAt(idx);
      if (_currentOptions.isEmpty) {
        _selectedIndex = null;
        _lastResult = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3250), // Deep purple/blue
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                maxBlastForce: 20,
                minBlastForce: 8,
                emissionFrequency: 0.08,
                numberOfParticles: 30,
                gravity: 0.3,
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 32),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        Text(
                          'SPIN THE WHEEL!',
                          style: GoogleFonts.luckiestGuy(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _AutoWheelPainter(
                            options: _currentOptions,
                            angle: _animation.value,
                          ),
                          child: SizedBox(
                            width: 320,
                            height: 320,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      width: 180,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: Text('SPIN!', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA259FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                          textStyle: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
                          elevation: 8,
                          shadowColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ).copyWith(
                          elevation: MaterialStateProperty.all(8),
                        ),
                        onPressed: _isSpinning || _currentOptions.isEmpty ? null : _spinWheel,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // The Selected Restaurants card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.22,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A7FDB), // Card color
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              offset: const Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('THE SELECTED RESTAURANTS (${_currentOptions.length})',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: Colors.white,
                                )),
                            const SizedBox(height: 8),
                            _currentOptions.isEmpty
                                ? Text('No restaurants selected.', style: GoogleFonts.montserrat(color: Colors.white70))
                                : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _currentOptions.length,
                              itemBuilder: (context, idx) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.black, width: 2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: ListTile(
                                    title: Text(_currentOptions[idx],
                                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Color(0xFFA259FF)),
                                      onPressed: () => _removeOption(idx),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_lastResult != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Transform.rotate(
                        angle: -0.05,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF39FF6A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade700.withOpacity(0.3),
                                offset: const Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "YOU'RE EATING:",
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                _lastResult!,
                                style: GoogleFonts.luckiestGuy(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _tryAgain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5FCF),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          textStyle: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        child: const Text('TRY AGAIN'),
                      ),
                      const SizedBox(width: 18),
                      ElevatedButton(
                        onPressed: _startOver,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3DDCFF),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          textStyle: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        child: const Text('START OVER'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AutoWheelPainter extends CustomPainter {
  final List<String> options;
  final double angle;
  _AutoWheelPainter({required this.options, required this.angle});

  static const List<Color> _autoColors = [
    Color(0xFFA259FF), // purple
    Color(0xFFFF5FCF), // pink
    Color(0xFF3DDCFF), // blue
    Color(0xFFFFF700), // yellow
    Color(0xFF39FF6A), // green
    Color(0xFFFFB347), // orange
    Color(0xFFFF6A39), // red-orange
    Color(0xFF6AFFC5), // teal
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    final paint = Paint()..style = PaintingStyle.fill;
    final n = options.isEmpty ? 4 : options.length;
    final anglePer = 2 * pi / n;
    double start = -pi / 2 + angle;
    for (int i = 0; i < n; i++) {
      paint.color = _autoColors[i % _autoColors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        anglePer,
        true,
        paint,
      );
      // Draw option text
      if (options.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: options[i],
            style: GoogleFonts.montserrat(
              fontSize: n > 6 ? 12 : 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: radius * 1.1,
        );
        final textAngle = start + anglePer / 2;
        final textRadius = radius * 0.68;
        final textOffset = Offset(
          center.dx + textRadius * cos(textAngle) - textPainter.width / 2,
          center.dy + textRadius * sin(textAngle) - textPainter.height / 2,
        );
        canvas.save();
        canvas.translate(
          center.dx + textRadius * cos(textAngle),
          center.dy + textRadius * sin(textAngle),
        );
        canvas.rotate(textAngle + pi / 2);
        canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
        textPainter.paint(canvas, Offset.zero);
        canvas.restore();
      }
      start += anglePer;
    }
    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, borderPaint);
    // Draw pointer
    final pointerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final pointerPath = Path();
    pointerPath.moveTo(center.dx, center.dy - radius - 8);
    pointerPath.lineTo(center.dx - 12, center.dy - radius - 28);
    pointerPath.lineTo(center.dx + 12, center.dy - radius - 28);
    pointerPath.close();
    canvas.drawPath(pointerPath, pointerPaint);
  }

  @override
  bool shouldRepaint(covariant _AutoWheelPainter oldDelegate) {
    return oldDelegate.options.length != options.length ||
        oldDelegate.angle != angle;
  }
}