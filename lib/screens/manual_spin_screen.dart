import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/options_provider.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

class ManualSpinScreen extends StatefulWidget {
  const ManualSpinScreen({Key? key}) : super(key: key);

  @override
  State<ManualSpinScreen> createState() => _ManualSpinScreenState();
}

class _ManualSpinScreenState extends State<ManualSpinScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _selectedIndex;
  bool _isSpinning = false;
  String? _lastResult;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
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
    _controller.dispose();
    _animationController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _spinWheel(List<String> options) async {
    if (options.isEmpty || _isSpinning) return;
    setState(() => _isSpinning = true);
    final random = Random();
    final selected = random.nextInt(options.length);
    final spins = 5 + random.nextInt(3); // 5-7 full spins
    final anglePerOption = 2 * pi / options.length;

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
      _lastResult = options[selected];
      _isSpinning = false;
    });
    // Show confetti
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final options = context.watch<OptionsProvider>().options;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFF4D),
      body: SafeArea(
        child: Stack(
          children: [
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
                          painter: _WheelPainter(
                            options: options,
                            angle: _animation.value,
                          ),
                          child: SizedBox(
                            width: 360,
                            height: 360,
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
                          backgroundColor: const Color(0xFFFF5FCF),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                          textStyle: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
                          elevation: 8,
                          shadowColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ).copyWith(
                          elevation: MaterialStateProperty.all(8),
                        ),
                        onPressed: _isSpinning || options.isEmpty ? null : () => _spinWheel(options),
                      ),
                    ),
                  ),
                  if (_lastResult != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
                      child: Center(
                        child: Transform.rotate(
                          angle: -0.05,
                          child: Container(
                            width: 320,
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
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.22,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB347),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade700,
                              offset: const Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('YOUR OPTIONS (${options.length})',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                )),
                            const SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: options.length,
                              itemBuilder: (context, idx) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.black, width: 2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: ListTile(
                                    title: Text(options[idx],
                                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Color(0xFFFF5FCF)),
                                      onPressed: () => context.read<OptionsProvider>().removeOption(idx),
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3DDCFF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade700,
                            offset: const Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ADD FOOD OPTION',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              )),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  decoration: InputDecoration(
                                    hintText: 'Enter food option...',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(color: Colors.black, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  onSubmitted: (val) => _addOption(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Material(
                                color: const Color(0xFF39FF6A),
                                borderRadius: BorderRadius.circular(4),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(4),
                                  onTap: () => _addOption(context),
                                  child: const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Icon(Icons.add, color: Colors.black, size: 28),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
          ],
        ),
      ),
    );
  }

  void _addOption(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<OptionsProvider>().addOption(text);
      _controller.clear();
    }
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> options;
  final double angle;
  _WheelPainter({required this.options, required this.angle});

  static const List<Color> _defaultColors = [
    Color(0xFFFFB347), // orange
    Color(0xFFFF5FCF), // pink
    Color(0xFF39FF6A), // green
    Color(0xFF3DDCFF), // blue
    Color(0xFFFFF700), // yellow
    Color(0xFFA259FF), // purple
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
      paint.color = _defaultColors[i % _defaultColors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        anglePer,
        true,
        paint,
      );
      // Draw option text
      if (options.isNotEmpty) {
        // Dynamically scale font size based on option length
        double baseFontSize = 18;
        double fontSize = baseFontSize;
        if (options[i].length > 14) {
          fontSize = baseFontSize - (options[i].length - 14) * 0.7;
          if (fontSize < 10) fontSize = 10;
        }
        final textPainter = TextPainter(
          text: TextSpan(
            text: options[i],
            style: GoogleFonts.montserrat(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          maxLines: 2,
          ellipsis: '…',
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: radius * 1.3,
        );
        final textAngle = start + anglePer / 2;
        final textRadius = radius * 0.7;
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
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, borderPaint);
    // Draw pointer
    final pointerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final pointerPath = Path();
    pointerPath.moveTo(center.dx, center.dy - radius - 8);
    pointerPath.lineTo(center.dx - 16, center.dy - radius - 36);
    pointerPath.lineTo(center.dx + 16, center.dy - radius - 36);
    pointerPath.close();
    canvas.drawPath(pointerPath, pointerPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.options.length != options.length ||
        oldDelegate.angle != angle;
  }
}