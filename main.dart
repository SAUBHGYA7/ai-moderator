import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;

// Global state for Hackathon Demo
bool globalAiModerationEnabled = true;

void main() {
  runApp(const PeerspaceApp());
}

class PeerspaceApp extends StatelessWidget {
  const PeerspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PEERSPACE',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0E15),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE947F5), // Purplish Pink
          secondary: Color(0xFF2F4BA2), // Deep Blue
          surface: Color(0xFF161824),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==========================================
// 0. PAPER-TO-CUBE FOLDING LOGO
// ==========================================
class CubeFoldingLogo extends StatefulWidget {
  final double size;
  final Color color;
  const CubeFoldingLogo(
      {super.key, this.size = 50, this.color = const Color(0xFFE947F5)});

  @override
  State<CubeFoldingLogo> createState() => _CubeFoldingLogoState();
}

class _CubeFoldingLogoState extends State<CubeFoldingLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double progress = Curves.easeInOutCubic.transform(_controller.value);
          return CustomPaint(
            painter: FoldableCubePainter(progress, widget.color),
          );
        },
      ),
    );
  }
}

class FoldableCubePainter extends CustomPainter {
  final double progress;
  final Color color;

  FoldableCubePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.2;

    final topPath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.5)
      ..lineTo(center.dx + radius * 0.866, center.dy - radius * 0.1)
      ..lineTo(center.dx, center.dy + radius * 0.3)
      ..lineTo(center.dx - radius * 0.866, center.dy - radius * 0.1)
      ..close();

    final leftPath = Path()
      ..moveTo(center.dx, center.dy + radius * 0.3)
      ..lineTo(center.dx - radius * 0.866, center.dy - radius * 0.1)
      ..lineTo(center.dx - radius * 0.866,
          center.dy + radius * (0.8 * progress - 0.1))
      ..lineTo(center.dx, center.dy + radius * (0.3 + 0.8 * progress))
      ..close();

    final rightPath = Path()
      ..moveTo(center.dx, center.dy + radius * 0.3)
      ..lineTo(center.dx + radius * 0.866, center.dy - radius * 0.1)
      ..lineTo(center.dx + radius * 0.866,
          center.dy + radius * (0.8 * progress - 0.1))
      ..lineTo(center.dx, center.dy + radius * (0.3 + 0.8 * progress))
      ..close();

    final paintTop = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    final paintLeft = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    final paintRight = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * math.pi);
    canvas.scale(0.6 + progress * 0.4);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawPath(topPath, paintTop);
    if (progress > 0.01) {
      canvas.drawPath(leftPath, paintLeft);
      canvas.drawPath(rightPath, paintRight);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FoldableCubePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ==========================================
// 1. BACKGROUNDS: FLOATING LINES & DARK VEIL
// ==========================================

class FloatingLinesBackground extends StatefulWidget {
  final Widget child;
  const FloatingLinesBackground({super.key, required this.child});

  @override
  State<FloatingLinesBackground> createState() =>
      _FloatingLinesBackgroundState();
}

class _FloatingLinesBackgroundState extends State<FloatingLinesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFF05050A)),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _FloatingLinesPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _FloatingLinesPainter extends CustomPainter {
  final double time;
  _FloatingLinesPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final Color pink = const Color(0xFFE947F5);
    final Color blue = const Color(0xFF2F4BA2);
    final Rect rect = Offset.zero & size;
    final Gradient gradient = LinearGradient(
      colors: [blue.withOpacity(0.8), pink.withOpacity(0.8)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    _drawWaveGroup(canvas, size, paint,
        waveOffset: 0.3, waveHeight: 0.15, speedMulti: 1.0, lines: 6);
    _drawWaveGroup(canvas, size, paint,
        waveOffset: 0.6, waveHeight: 0.20, speedMulti: -0.8, lines: 4);
    _drawWaveGroup(canvas, size, paint,
        waveOffset: 0.8, waveHeight: 0.10, speedMulti: 1.2, lines: 5);
  }

  void _drawWaveGroup(Canvas canvas, Size size, Paint paint,
      {required double waveOffset,
      required double waveHeight,
      required double speedMulti,
      required int lines}) {
    for (int i = 0; i < lines; i++) {
      final path = Path();
      final baseY = size.height * waveOffset + (i * 25);
      final frequency = 0.002 + (i * 0.0002);
      final amplitude = size.height * waveHeight + (i * 5);
      final phaseShift = (time * math.pi * 2 * speedMulti) + (i * 0.4);

      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 5) {
        final y = baseY + math.sin((x * frequency) + phaseShift) * amplitude;
        path.lineTo(x, y);
      }
      paint.maskFilter = MaskFilter.blur(BlurStyle.solid, 1.5 + (i * 0.5));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingLinesPainter oldDelegate) =>
      oldDelegate.time != time;
}

// THE NEW DARK VEIL BACKGROUND FOR MAIN CHATS
class DarkVeilBackground extends StatefulWidget {
  final Widget child;
  const DarkVeilBackground({super.key, required this.child});

  @override
  State<DarkVeilBackground> createState() => _DarkVeilBackgroundState();
}

class _DarkVeilBackgroundState extends State<DarkVeilBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFF0D0E15)), 
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _DarkVeilPainter(_controller.value * math.pi * 2),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _DarkVeilPainter extends CustomPainter {
  final double time;
  _DarkVeilPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120); // Extreme blur

    // Deep Blue Blob
    double x1 = size.width * (0.5 + 0.4 * math.sin(time * 0.7));
    double y1 = size.height * (0.5 + 0.3 * math.cos(time * 0.5));
    paint.color = const Color(0xFF2F4BA2).withOpacity(0.4);
    canvas.drawCircle(Offset(x1, y1), size.width * 0.6, paint);

    // Neon Pink Blob
    double x2 = size.width * (0.5 + 0.3 * math.cos(time * 0.4));
    double y2 = size.height * (0.5 + 0.4 * math.sin(time * 0.6));
    paint.color = const Color(0xFFE947F5).withOpacity(0.3);
    canvas.drawCircle(Offset(x2, y2), size.width * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant _DarkVeilPainter oldDelegate) =>
      oldDelegate.time != time;
}

// ==========================================
// 2. SHINY HOVER TEXT WIDGET
// ==========================================

class ShinyHoverText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ShinyHoverText({super.key, required this.text, required this.style});

  @override
  State<ShinyHoverText> createState() => _ShinyHoverTextState();
}

class _ShinyHoverTextState extends State<ShinyHoverText>
    with SingleTickerProviderStateMixin {
  late AnimationController _shinyController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _shinyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _shinyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _shinyController.repeat();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _shinyController.stop();
        _shinyController.reset();
      },
      child: AnimatedBuilder(
        animation: _shinyController,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              if (!_isHovered) {
                return LinearGradient(colors: [
                  widget.style.color ?? Colors.white,
                  widget.style.color ?? Colors.white
                ]).createShader(bounds);
              }
              return LinearGradient(
                colors: [
                  widget.style.color ?? Colors.white,
                  Colors.white, // The shiny highlight
                  widget.style.color ?? Colors.white,
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment(-2.0 + (_shinyController.value * 4), 0),
                end: Alignment(0.0 + (_shinyController.value * 4), 0),
              ).createShader(bounds);
            },
            child: Text(widget.text, style: widget.style),
          );
        },
      ),
    );
  }
}

// ==========================================
// 3. SPLASH & LOGIN SCREENS
// ==========================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _gradientController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _entranceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entranceController, curve: Curves.easeIn));

    _entranceController.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ProfileLoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090E),
      body: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CubeFoldingLogo(size: 100),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileLoginScreen extends StatefulWidget {
  const ProfileLoginScreen({super.key});

  @override
  State<ProfileLoginScreen> createState() => _ProfileLoginScreenState();
}

class _ProfileLoginScreenState extends State<ProfileLoginScreen> {
  bool _otpSent = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _selectedLanguage = 'English';
  String _selectedCountry = 'India';

  void _verifyLogin() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const ChatRoomsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingLinesBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CubeFoldingLogo(size: 80),
                ),
                const SizedBox(height: 32),
                ShinyHoverText(
                  text: "PEERSPACE",
                  style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Color(0xFFE947F5)),
                ),
                const SizedBox(height: 8),
                const Text("AI-Powered Communities.",
                    style: TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedLanguage,
                        dropdownColor: const Color(0xFF161824),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Language"),
                        items: ['English', 'Spanish', 'French', 'Hindi']
                            .map((String val) =>
                                DropdownMenuItem(value: val, child: Text(val)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedLanguage = val!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        dropdownColor: const Color(0xFF161824),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration("Country"),
                        items: ['India', 'USA', 'UK', 'Canada']
                            .map((String val) =>
                                DropdownMenuItem(value: val, child: Text(val)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCountry = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Phone Number").copyWith(
                      prefixIcon:
                          const Icon(Icons.phone, color: Color(0xFFE947F5))),
                ),
                const SizedBox(height: 24),
                if (_otpSent) ...[
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Enter 6-digit OTP").copyWith(
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: Color(0xFF2F4BA2))),
                  ),
                  const SizedBox(height: 32),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4BA2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 8,
                      shadowColor: const Color(0xFF2F4BA2).withOpacity(0.5),
                    ),
                    onPressed: _otpSent
                        ? _verifyLogin
                        : () => setState(() => _otpSent = true),
                    child: Text(_otpSent ? 'Authenticate' : 'Request Code',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE947F5))),
    );
  }
}

// ==========================================
// 4. MAIN CHAT ROOMS SCREEN
// ==========================================

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  final List<Map<String, dynamic>> _rooms = [
    {
      "title": "System Architecture",
      "msg": "Let's review the PostgreSQL schema.",
      "time": "12:00 PM",
      "tags": ["Tech", "Study"]
    },
    {
      "title": "Global Events",
      "msg": "Crazy news from last night's rally.",
      "time": "10:45 AM",
      "tags": ["Politics", "Casual"]
    },
  ];

  final List<String> _availableTags = [
    'Study', 'Politics', 'Tech', 'Casual', 'Entertainment'
  ];

  void _showProfileMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Menu",
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.topRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 100, right: 16),
              width: 220,
              decoration: BoxDecoration(
                  color: const Color(0xFF161824).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF2F4BA2).withOpacity(0.3))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline,
                        color: Color(0xFFE947F5)),
                    title: const Text('View Profile',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ProfilePictureScreen()));
                    },
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined,
                        color: Color(0xFF2F4BA2)),
                    title: const Text('Settings',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()));
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _createNewRoom() {
    final TextEditingController newRoomController = TextEditingController();
    List<String> selectedTags = [];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161824),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text("Create New Space",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: newRoomController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter space name...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Select Topics (Tags):",
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _availableTags.map((tag) {
                      final isSelected = selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag,
                            style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                                fontSize: 12)),
                        selected: isSelected,
                        selectedColor: const Color(0xFFE947F5).withOpacity(0.4),
                        backgroundColor: Colors.white.withOpacity(0.05),
                        checkmarkColor: Colors.white,
                        onSelected: (bool selected) {
                          setStateDialog(() {
                            if (selected) {
                              selectedTags.add(tag);
                            } else {
                              selectedTags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE947F5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (newRoomController.text.trim().isNotEmpty) {
                      setState(() {
                        _rooms.insert(0, {
                          "title": newRoomController.text.trim(),
                          "msg": "Space created! Start chatting.",
                          "time": "Just now",
                          "tags": List.from(selectedTags)
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Create",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // DARK VEIL FLUID BACKGROUND APPLIED HERE
      body: DarkVeilBackground(
        child: Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.only(
                  top: 120, left: 16, right: 16, bottom: 100),
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                final accentColor = index % 2 == 0
                    ? const Color(0xFFE947F5)
                    : const Color(0xFF2F4BA2);
                return _chatTile(context, room["title"], room["msg"],
                    room["time"], room["tags"] ?? [], accentColor);
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 2)
                            ]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CubeFoldingLogo(size: 30),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.shield_outlined,
                                    size: 16, color: Colors.white54),
                                const SizedBox(width: 4),
                                Switch(
                                  value: globalAiModerationEnabled,
                                  onChanged: (val) {
                                    setState(
                                        () => globalAiModerationEnabled = val);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(val
                                          ? "AI Moderation Enabled"
                                          : "AI Moderation Disabled"),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: const Color(0xFF2F4BA2),
                                    ));
                                  },
                                  activeColor: const Color(0xFFE947F5),
                                  activeTrackColor:
                                      const Color(0xFFE947F5).withOpacity(0.4),
                                  inactiveThumbColor: Colors.grey[500],
                                  inactiveTrackColor: Colors.grey[800],
                                ),
                                const SizedBox(width: 8),
                                const Text("Ansh",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                                const SizedBox(width: 12),
                                // SUPERCHARGED PROFILE GLOW
                                GestureDetector(
                                  onTap: () => _showProfileMenu(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(colors: [
                                        Color(0xFFE947F5),
                                        Color(0xFF2F4BA2)
                                      ]),
                                      boxShadow: [
                                        // Outer Pink Glow
                                        BoxShadow(
                                          color: const Color(0xFFE947F5).withOpacity(0.6),
                                          blurRadius: 15,
                                          spreadRadius: 3,
                                        ),
                                        // Outer Blue Glow
                                        BoxShadow(
                                          color: const Color(0xFF2F4BA2).withOpacity(0.6),
                                          blurRadius: 15,
                                          spreadRadius: 1,
                                          offset: const Offset(-2, 2)
                                        ),
                                      ]
                                    ),
                                    child: const CircleAvatar(
                                      radius: 16,
                                      backgroundImage: NetworkImage(
                                          'https://i.scdn.co/image/ab67616d0000b273d9985092cd88bffd97653b58'),
                                    ),
                                  ),
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
            ),
            // GLASSMORPHED PLUS SIGN
            Positioned(
              bottom: 30,
              right: 20,
              child: GestureDetector(
                onTap: _createNewRoom,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                    child: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatTile(BuildContext context, String title, String msg, String time,
      List<String> tags, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: -5,
                  )
                ]),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                    child: Text(title.isNotEmpty ? title[0].toUpperCase() : "?",
                        style: TextStyle(
                            color: accentColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800))),
              ),
              // SHINY HOVER APPLIED TO TITLE
              title: ShinyHoverText(
                  text: title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(msg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54, fontSize: 14)),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                        spacing: 6,
                        children: tags
                            .map((t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(t,
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white70)),
                                ))
                            .toList())
                  ]
                ],
              ),
              trailing: Text(time,
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PeerspaceChatScreen(roomName: title, tags: tags))),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. INDIVIDUAL CHAT SCREEN (DARK VEIL)
// ==========================================

class PeerspaceChatScreen extends StatefulWidget {
  final String roomName;
  final List<String> tags;

  const PeerspaceChatScreen(
      {super.key, required this.roomName, required this.tags});

  @override
  State<PeerspaceChatScreen> createState() => _PeerspaceChatScreenState();
}

class _PeerspaceChatScreenState extends State<PeerspaceChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(
        () => setState(() => _isTyping = _controller.text.isNotEmpty));

    _focusNode.onKeyEvent = (FocusNode node, KeyEvent event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          if (HardwareKeyboard.instance.isShiftPressed) {
            return KeyEventResult.ignored;
          } else {
            _handleSend();
            return KeyEventResult.handled;
          }
        }
      }
      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    String text = _controller.text.trim();

    if (globalAiModerationEnabled) {
      String textLower = text.toLowerCase();
      
      bool isStudyRoom = widget.tags.contains("Study");
      bool isPoliticsRoom = widget.tags.contains("Politics");

      bool isAbusive = textLower.contains("spam") || textLower.contains("badword");
      
      bool isOffTopic = false;
      String aiReason = "Off-topic discussion.";

      if (isStudyRoom && (textLower.contains("movie") || textLower.contains("cinema"))) {
        isOffTopic = true;
        aiReason = "Entertainment topics are restricted in Study spaces.";
      }
      
      if (!isPoliticsRoom && (textLower.contains("election") || textLower.contains("politics"))) {
        isOffTopic = true;
        aiReason = "Political discussions are only allowed in 'Politics' tagged spaces.";
      }

      if (isAbusive || isOffTopic) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE947F5),
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(
                      "Blocked by AI: ${isAbusive ? 'Policy violation.' : aiReason}",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
            ],
          ),
        ));
        return;
      }
    }

    setState(() => _messages.add({"text": text, "isMe": true}));
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF161824).withOpacity(0.95),
          elevation: 1,
          shadowColor: Colors.black,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.roomName,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              if (widget.tags.isNotEmpty)
                Text("Tags: ${widget.tags.join(', ')}", style: const TextStyle(fontSize: 12, color: Colors.white54)),
            ],
          )),
      body: DarkVeilBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg["isMe"]
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: msg["isMe"]
                                  ? const Color(0xFFE947F5).withOpacity(0.15)
                                  : Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: msg["isMe"]
                                      ? const Color(0xFFE947F5).withOpacity(0.4)
                                      : Colors.white.withOpacity(0.2),
                                  width: 1.2),
                            ),
                            child: Text(msg["text"],
                                style:
                                    const TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF161824).withOpacity(0.85),
                border: const Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Message ${widget.roomName}...",
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.03),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _handleSend,
                    child: Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isTyping
                            ? const Color(0xFFE947F5)
                            : Colors.white.withOpacity(0.1),
                        boxShadow: _isTyping
                            ? [
                                BoxShadow(
                                    color:
                                        const Color(0xFFE947F5).withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2)
                              ]
                            : null,
                      ),
                      child: Icon(Icons.send,
                          color: _isTyping ? Colors.white : Colors.white54,
                          size: 20),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. TILTED PROFILE PICTURE SCREEN
// ==========================================

class ProfilePictureScreen extends StatefulWidget {
  const ProfilePictureScreen({super.key});

  @override
  State<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen>
    with SingleTickerProviderStateMixin {
  double xRotation = 0;
  double yRotation = 0;
  late AnimationController _springController;
  late Animation<double> _xAnim;
  late Animation<double> _yAnim;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _springController.addListener(() {
      setState(() {
        xRotation = _xAnim.value;
        yRotation = _yAnim.value;
      });
    });
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_springController.isAnimating) _springController.stop();

    double width = 300;
    double height = 300;

    double offsetX = details.localPosition.dx - (width / 2);
    double offsetY = details.localPosition.dy - (height / 2);

    double rotateAmplitude = 12.0 * (math.pi / 180.0);

    setState(() {
      xRotation = (offsetY / (height / 2)) * -rotateAmplitude;
      yRotation = (offsetX / (width / 2)) * rotateAmplitude;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _xAnim = Tween<double>(begin: xRotation, end: 0).animate(
        CurvedAnimation(parent: _springController, curve: Curves.elasticOut));
    _yAnim = Tween<double>(begin: yRotation, end: 0).animate(
        CurvedAnimation(parent: _springController, curve: Curves.elasticOut));
    _springController.forward(from: 0);
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Profile Details", style: TextStyle(fontSize: 16))),
      body: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          return GestureDetector(
            onPanUpdate: (details) => _onPanUpdate(details, constraints),
            onPanEnd: _onPanEnd,
            child: Transform(
              alignment: FractionalOffset.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(xRotation)
                ..rotateY(yRotation),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFFE947F5).withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 2)
                      ],
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://i.scdn.co/image/ab67616d0000b273d9985092cd88bffd97653b58'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(yRotation * 50, -xRotation * 50),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161824).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF2F4BA2).withOpacity(0.5)),
                      ),
                      child: const Text("Ansh Pathak • 25brs1104",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ==========================================
// 7. SETTINGS SCREEN
// ==========================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Preferences", style: TextStyle(fontSize: 16))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: globalAiModerationEnabled
                      ? const Color(0xFFE947F5)
                      : Colors.white10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Active AI Moderation",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      SizedBox(height: 4),
                      Text("Pre-validate messages before posting.",
                          style:
                              TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
                Switch(
                  activeColor: const Color(0xFFE947F5),
                  activeTrackColor: const Color(0xFFE947F5).withOpacity(0.4),
                  value: globalAiModerationEnabled,
                  onChanged: (val) =>
                      setState(() => globalAiModerationEnabled = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _settingsItem(Icons.lock_outline, "Privacy & Security",
              const Color(0xFF2F4BA2)),
          _settingsItem(Icons.notifications_none, "Notifications",
              const Color(0xFFE947F5)),
          _settingsItem(Icons.rule_folder_outlined, "Moderation Rules",
              const Color(0xFF2F4BA2)),
        ],
      ),
    );
  }

  Widget _settingsItem(IconData icon, String title, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: 16),
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w500))),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white38),
        ],
      ),
    );
  }
}
