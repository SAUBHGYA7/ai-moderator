import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// --- GLOBAL STATE ---
bool globalAiModerationEnabled = true;
String globalUsername = "Ansh Pathak";
String globalProfilePicture =
    "https://i.scdn.co/image/ab67616d0000b273d9985092cd88bffd97653b58";
Uint8List? globalProfileImageBytes;

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
          primary: Color(0xFFE947F5),
          secondary: Color(0xFF2F4BA2),
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
              painter: FoldableCubePainter(progress, widget.color));
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
// 1. BACKGROUNDS
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
          builder: (context, child) => CustomPaint(
              painter: _FloatingLinesPainter(_controller.value),
              size: Size.infinite),
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
      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 5) {
        path.lineTo(
            x,
            baseY +
                math.sin((x * (0.002 + (i * 0.0002))) +
                        ((time * math.pi * 2 * speedMulti) + (i * 0.4))) *
                    (size.height * waveHeight + (i * 5)));
      }
      paint.maskFilter = MaskFilter.blur(BlurStyle.solid, 1.5 + (i * 0.5));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingLinesPainter oldDelegate) =>
      oldDelegate.time != time;
}

class DarkVeilBackground extends StatefulWidget {
  final Widget child;
  final bool isLight;
  const DarkVeilBackground(
      {super.key, required this.child, this.isLight = false});

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
        Container(
            color: widget.isLight
                ? const Color(0xFF1A1C29)
                : const Color(0xFF0D0E15)),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => CustomPaint(
              painter: _DarkVeilPainter(
                  _controller.value * math.pi * 2, widget.isLight),
              size: Size.infinite),
        ),
        widget.child,
      ],
    );
  }
}

class _DarkVeilPainter extends CustomPainter {
  final double time;
  final bool isLight;
  _DarkVeilPainter(this.time, this.isLight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isLight ? 150 : 120);

    double x1 = size.width * (0.5 + 0.4 * math.sin(time * 0.7));
    double y1 = size.height * (0.5 + 0.3 * math.cos(time * 0.5));
    paint.color = const Color(0xFF2F4BA2).withOpacity(isLight ? 0.2 : 0.4);
    canvas.drawCircle(Offset(x1, y1), size.width * 0.6, paint);

    double x2 = size.width * (0.5 + 0.3 * math.cos(time * 0.4));
    double y2 = size.height * (0.5 + 0.4 * math.sin(time * 0.6));
    paint.color = const Color(0xFFE947F5).withOpacity(isLight ? 0.15 : 0.3);
    canvas.drawCircle(Offset(x2, y2), size.width * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant _DarkVeilPainter oldDelegate) =>
      oldDelegate.time != time;
}

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
        vsync: this, duration: const Duration(milliseconds: 1200));
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
              if (!_isHovered)
                return LinearGradient(colors: [
                  widget.style.color ?? Colors.white,
                  widget.style.color ?? Colors.white
                ]).createShader(bounds);
              return LinearGradient(
                colors: [
                  widget.style.color ?? Colors.white,
                  Colors.white,
                  widget.style.color ?? Colors.white
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
                      children: [
                        const CubeFoldingLogo(size: 100),
                        const SizedBox(height: 24),
                        AnimatedBuilder(
                          animation: _gradientController,
                          builder: (context, child) {
                            return ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: const [
                                    Color(0xFFE947F5),
                                    Color(0xFF2F4BA2),
                                    Color(0xFFE947F5)
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                  begin: Alignment(
                                      -2.0 + (_gradientController.value * 2),
                                      0),
                                  end: Alignment(
                                      0.0 + (_gradientController.value * 2), 0),
                                ).createShader(bounds);
                              },
                              child: const Text("PEERSPACE",
                                  style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2)),
                            );
                          },
                        ),
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
                const ShinyHoverText(
                  text: "PEERSPACE",
                  style: TextStyle(
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
      "tags": ["Tech", "Study"],
      "aiEnabled": true,
      "members": [
        {"name": globalUsername, "role": "Admin"},
        {"name": "Developer_X", "role": "Moderator"}
      ]
    },
    {
      "title": "Global Events",
      "msg": "Crazy news from last night's rally.",
      "time": "10:45 AM",
      "tags": ["Politics", "Casual"],
      "aiEnabled": false,
      "members": [
        {"name": "NewsBot", "role": "Admin"},
        {"name": globalUsername, "role": "Member"}
      ]
    },
  ];

  final List<String> _availableTags = [
    'Study',
    'Politics',
    'Tech',
    'Casual',
    'Entertainment'
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
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ProfilePictureScreen()));
                      setState(() {}); // Refresh avatar/name after returning
                    },
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined,
                        color: Color(0xFF2F4BA2)),
                    title: const Text('Settings',
                        style: TextStyle(color: Colors.white)),
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()));
                      setState(
                          () {}); // Refresh in case global settings changed
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
                          // FIX: Explicitly cast to List<String> to avoid List<dynamic> subtype error
                          "tags": List<String>.from(selectedTags),
                          "aiEnabled": true,
                          "members": [
                            {"name": globalUsername, "role": "Admin"}
                          ]
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
                return _chatTile(context, room, accentColor);
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
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
                                Text(globalUsername.split(" ")[0],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                                const SizedBox(width: 12),
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
                                          BoxShadow(
                                              color: const Color(0xFFE947F5)
                                                  .withOpacity(0.6),
                                              blurRadius: 15,
                                              spreadRadius: 3),
                                          BoxShadow(
                                              color: const Color(0xFF2F4BA2)
                                                  .withOpacity(0.6),
                                              blurRadius: 15,
                                              spreadRadius: 1,
                                              offset: const Offset(-2, 2)),
                                        ]),
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundImage:
                                          globalProfileImageBytes != null
                                              ? MemoryImage(
                                                  globalProfileImageBytes!)
                                              : NetworkImage(
                                                      globalProfilePicture)
                                                  as ImageProvider,
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
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2)
                          ]),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 28),
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

  Widget _chatTile(
      BuildContext context, Map<String, dynamic> room, Color accentColor) {
    // FIX: Safely parse tags to prevent List<dynamic> rendering crash
    List<String> tags =
        (room["tags"] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), // Premium Blur
          child: Material(
            color: Colors.white
                .withOpacity(0.08), // Slightly lighter for premium feel
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: accentColor.withOpacity(0.2),
              highlightColor: accentColor.withOpacity(0.1),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PeerspaceChatScreen(roomData: room))),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          spreadRadius: -5)
                    ]),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  leading: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16)),
                    child: Center(
                        child: Text(
                            room["title"].isNotEmpty
                                ? room["title"][0].toUpperCase()
                                : "?",
                            style: TextStyle(
                                color: accentColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w900))),
                  ),
                  title: ShinyHoverText(
                      text: room["title"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(room["msg"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                            spacing: 8,
                            children: tags
                                .map((t) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: Text(t,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500)),
                                    ))
                                .toList())
                      ]
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(room["time"],
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                      if (room["aiEnabled"] == true)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Icon(Icons.shield,
                              color: Color(0xFFE947F5), size: 14),
                        )
                    ],
                  ),
                ),
              ),
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
  final Map<String, dynamic> roomData; // Pass room data so AI toggle applies

  const PeerspaceChatScreen({super.key, required this.roomData});

  @override
  State<PeerspaceChatScreen> createState() => _PeerspaceChatScreenState();
}

class _PeerspaceChatScreenState extends State<PeerspaceChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  // Voice Typing Controller
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

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

  void _listenForVoice() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
            onResult: (val) => setState(() {
                  _controller.text = val.recognizedWords;
                }));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Voice recognition not available.")));
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    String text = _controller.text.trim();

    // Per-Group AI Moderation
    if (widget.roomData["aiEnabled"] == true) {
      String textLower = text.toLowerCase();
      List<String> tags = (widget.roomData["tags"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      bool isStudyRoom = tags.contains("Study");
      bool isPoliticsRoom = tags.contains("Politics");

      bool isAbusive = textLower.contains("spam") ||
          textLower.contains("badword") ||
          textLower.contains("abuse");
      bool isOffTopic = false;
      String aiReason = "Off-topic discussion.";

      if (isStudyRoom &&
          (textLower.contains("movie") ||
              textLower.contains("cinema") ||
              textLower.contains("entertainment"))) {
        isOffTopic = true;
        aiReason = "Entertainment topics are restricted in Study spaces.";
      }

      if (!isPoliticsRoom &&
          (textLower.contains("election") || textLower.contains("politics"))) {
        isOffTopic = true;
        aiReason =
            "Political discussions are only allowed in 'Politics' tagged spaces.";
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
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white))),
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
    List<String> tags = (widget.roomData["tags"] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF161824).withOpacity(0.95),
          elevation: 1,
          shadowColor: Colors.black,
          title: GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        GroupInfoScreen(roomData: widget.roomData))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.roomData["title"],
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.info_outline,
                        size: 14, color: Colors.white54)
                  ],
                ),
                if (tags.isNotEmpty)
                  Text("Tap for Group Info • Tags: ${tags.join(', ')}",
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
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
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16)),
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
                        hintText: "Message ${widget.roomData['title']}...",
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
                    onTap: _listenForVoice,
                    child: Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening
                              ? Colors.redAccent
                              : Colors.white.withOpacity(0.1)),
                      child: Icon(_isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                                    color: const Color(0xFFE947F5)
                                        .withOpacity(0.4),
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
// 5.1 GROUP INFO / MEMBER MANAGEMENT
// ==========================================
class GroupInfoScreen extends StatefulWidget {
  final Map<String, dynamic> roomData;
  const GroupInfoScreen({super.key, required this.roomData});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  void _addMember() {
    TextEditingController phoneController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF161824),
              title: const Text("Add Member",
                  style: TextStyle(color: Colors.white)),
              content: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      hintText: "Enter phone number",
                      hintStyle: TextStyle(color: Colors.white54))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE947F5)),
                  onPressed: () {
                    if (phoneController.text.isNotEmpty) {
                      setState(() => widget.roomData["members"].add({
                            "name":
                                "New User (${phoneController.text.substring(math.max(0, phoneController.text.length - 4))})",
                            "role": "Member"
                          }));
                      Navigator.pop(context);
                    }
                  },
                  child:
                      const Text("Add", style: TextStyle(color: Colors.white)),
                )
              ],
            ));
  }

  void _manageUser(int index) {
    var member = widget.roomData["members"][index];
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF161824),
              title: Text("Manage ${member['name']}",
                  style: const TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings,
                        color: Color(0xFFE947F5)),
                    title: const Text("Make Moderator",
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      setState(() => member['role'] = "Moderator");
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.redAccent),
                    title: const Text("Remove Member",
                        style: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      setState(
                          () => widget.roomData["members"].removeAt(index));
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    List members = widget.roomData["members"] ?? [];

    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF161824),
          title: const Text("Group Info")),
      body: DarkVeilBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Group AI Moderation",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        SizedBox(height: 4),
                        Text(
                            "Filter off-topic & abusive messages for this specific group based on its tags.",
                            style:
                                TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                  ),
                  Switch(
                    activeColor: const Color(0xFFE947F5),
                    activeTrackColor: const Color(0xFFE947F5).withOpacity(0.4),
                    value: widget.roomData["aiEnabled"] ?? false,
                    onChanged: (val) =>
                        setState(() => widget.roomData["aiEnabled"] = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Members",
                    style: TextStyle(
                        color: Color(0xFFE947F5),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    onPressed: _addMember)
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(members.length, (index) {
              return ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.white10,
                    child: Text(members[index]["name"][0])),
                title: Text(members[index]["name"],
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(members[index]["role"],
                    style: TextStyle(
                        color: members[index]["role"] == "Admin" ||
                                members[index]["role"] == "Moderator"
                            ? const Color(0xFFE947F5)
                            : Colors.white54)),
                trailing: const Icon(Icons.more_vert, color: Colors.white54),
                onTap: () => _manageUser(index),
              );
            })
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 6. TILTED PROFILE PICTURE SCREEN (FIXED NAME POSITION)
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

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        globalProfileImageBytes = bytes;
      });
    }
  }

  void _editProfile() {
    TextEditingController nameController =
        TextEditingController(text: globalUsername);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161824),
          title:
              const Text("Edit Profile", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: "Username",
                    labelStyle: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE947F5)),
              onPressed: () {
                setState(() => globalUsername = nameController.text);
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_springController.isAnimating) _springController.stop();
    double rotateAmplitude = 12.0 * (math.pi / 180.0);
    setState(() {
      xRotation = (details.localPosition.dy - 150) / 150 * -rotateAmplitude;
      yRotation = (details.localPosition.dx - 150) / 150 * rotateAmplitude;
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
      body: DarkVeilBackground(
        isLight: true,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 3D TILTED IMAGE
                LayoutBuilder(builder: (context, constraints) {
                  return GestureDetector(
                    onPanUpdate: (details) =>
                        _onPanUpdate(details, constraints),
                    onPanEnd: _onPanEnd,
                    child: Transform(
                      alignment: FractionalOffset.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(xRotation)
                        ..rotateY(yRotation),
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFFE947F5).withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 2)
                          ],
                          image: DecorationImage(
                            image: globalProfileImageBytes != null
                                ? MemoryImage(globalProfileImageBytes!)
                                : NetworkImage(globalProfilePicture)
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 30),

                // NAME PLACED BELOW THE PICTURE
                GestureDetector(
                  onTap: _editProfile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161824).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF2F4BA2).withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(globalUsername,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        const Icon(Icons.edit, size: 18, color: Colors.white54)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // UPLOAD BUTTON
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4BA2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12)),
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: const Text("Upload from PC/Mobile",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  onPressed: _pickProfileImage,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 7. SETTINGS SCREEN (LIGHTER BACKGROUND)
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
          title: const Text("Settings", style: TextStyle(fontSize: 16))),
      // Made background lighter using the new parameter
      body: DarkVeilBackground(
        isLight: true,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
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
                        Text("Global AI Moderation",
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
            _settingsItem(
                Icons.lock_outline,
                "Privacy & Security",
                const Color(0xFF2F4BA2),
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrivacySecurityScreen()))),
            _settingsItem(
                Icons.notifications_none,
                "Notifications",
                const Color(0xFFE947F5),
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsScreen()))),
            _settingsItem(
                Icons.admin_panel_settings,
                "Admin Panel",
                const Color(0xFFE947F5),
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminPanelScreen()))),
          ],
        ),
      ),
    );
  }

  Widget _settingsItem(
      IconData icon, String title, Color accent, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08), // Lighter for visibility
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(0.3), width: 1.5),
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
                              fontWeight: FontWeight.bold))),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.white70),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 8. NOTIFICATIONS SCREEN
// ==========================================
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final List<Map<String, String>> _notifications = const [
    {
      "title": "New Space Created",
      "body": "You successfully created 'System Architecture'.",
      "time": "2 hours ago"
    },
    {
      "title": "AI Moderation Alert",
      "body": "A message was flagged and blocked in 'Global Events'.",
      "time": "5 hours ago"
    },
    {
      "title": "Welcome to PEERSPACE",
      "body": "Your account has been verified successfully.",
      "time": "1 day ago"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Notifications", style: TextStyle(fontSize: 16))),
      body: DarkVeilBackground(
        isLight: true,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notif = _notifications[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFE947F5).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(notif["title"]!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Text(notif["time"]!,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(notif["body"]!,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==========================================
// 9. PRIVACY & SECURITY SCREEN
// ==========================================
class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _obscurePassword = true;
  final String _mockPassword = "Hackathon@VitChennai2026!";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title:
              const Text("Privacy & Security", style: TextStyle(fontSize: 16))),
      body: DarkVeilBackground(
        isLight: true,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text("Account Security",
                style: TextStyle(
                    color: Color(0xFF2F4BA2), fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.key, color: Colors.white70),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Password",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                                _obscurePassword
                                    ? "••••••••••••••••"
                                    : _mockPassword,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFFE947F5)),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text("End-to-End Encrypted Chats",
                style: TextStyle(
                    color: Color(0xFFE947F5), fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildEncryptedChatRow("System Architecture"),
            _buildEncryptedChatRow("Global Events"),
          ],
        ),
      ),
    );
  }

  Widget _buildEncryptedChatRow(String roomName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, color: Color(0xFFE947F5), size: 16),
          const SizedBox(width: 12),
          Text(roomName,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Text("Secured",
              style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
        ],
      ),
    );
  }
}

// ==========================================
// 10. ADMIN PANEL SCREEN (FLAGGED CHATS)
// ==========================================
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  final List<Map<String, String>> _flaggedMessages = const [
    {
      "sender": "User_9082",
      "space": "System Architecture",
      "msg": "Check out my new crypto trading bot link in bio!",
      "reason": "Promotional / Spam Boundaries"
    },
    {
      "sender": "Guest_441",
      "space": "Frontend Dev",
      "msg": "The elections this year are an absolute mess.",
      "reason": "Political Discussions"
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> dynamicFlags = List.from(_flaggedMessages);
    dynamicFlags.insert(1, {
      "sender": globalUsername,
      "space": "Study Group Alpha",
      "msg": "Did anyone see the new superhero movie yesterday?",
      "reason": "Entertainment boundaries in Study Space"
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Admin Moderation Panel",
              style: TextStyle(fontSize: 16))),
      body: DarkVeilBackground(
        isLight: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Intercepted Messages",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 8),
                  Text(
                      "Messages blocked by the AI Moderator before reaching the community.",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: dynamicFlags.length,
                itemBuilder: (context, index) {
                  final flag = dynamicFlags[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.redAccent.withOpacity(0.5),
                                width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Sender: ${flag['sender']}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.redAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Text("BLOCKED",
                                        style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text("Attempted in: ${flag['space']}",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child:
                                    Divider(color: Colors.white24, height: 1),
                              ),
                              Text('"${flag['msg']}"',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.security,
                                      color: Color(0xFFE947F5), size: 14),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(
                                          "Violation: ${flag['reason']}",
                                          style: const TextStyle(
                                              color: Color(0xFFE947F5),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold))),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
