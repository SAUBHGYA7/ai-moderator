import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for hardware keyboard events
import 'dart:ui';
import 'dart:math' as math;

// Global state for Hackathon Demo
bool globalAiModerationEnabled = true;
String globalUsername = "Ansh Pathak";
// Default Mystery Person Avatar
String globalProfilePicUrl =
    "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y";

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

// --- 0. SPLASH SCREEN ---
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
                    child: AnimatedBuilder(
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
                                  -2.0 + (_gradientController.value * 2), 0),
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

// --- 1. SHADCN REACT-STYLE FLOATING LINES (NATIVE FLUTTER) ---
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
  bool shouldRepaint(covariant _FloatingLinesPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

// --- 2. LOGIN SCREEN ---
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
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFE947F5), Color(0xFF2F4BA2)],
                  ).createShader(bounds),
                  child: const Text("PEERSPACE",
                      style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5)),
                ),
                const SizedBox(height: 8),
                const Text("AI-Powered Communities.",
                    style: TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 56),
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

// --- 3. CHAT ROOMS SCREEN (FLOATING GLASS HEADER) ---
class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  // Dynamic list of rooms
  final List<Map<String, dynamic>> _rooms = [
    {
      "title": "System Architecture",
      "msg": "Let's review the PostgreSQL schema.",
      "time": "12:00 PM"
    },
    {
      "title": "Frontend Development",
      "msg": "The floating glass bar looks amazing.",
      "time": "10:45 AM"
    },
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
              margin: const EdgeInsets.only(
                  top: 100, right: 16), // Adjusted for floating header
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
                      // Rebuild when returning to show updated profile name/pic
                      setState(() {});
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
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161824),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Create New Space",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            content: TextField(
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
  }

  @override
  Widget build(BuildContext context) {
    // Get just the first name for the header
    String shortName = globalUsername.split(' ').first;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      body: Stack(
        children: [
          // 1. The Scrollable List (starts underneath the glass header)
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
                  room["time"], accentColor);
            },
          ),

          // 2. The Floating Glass Header
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
                    filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.05), // Frosted glass tint
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 1)
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Glass Font for "Hi"
                          Text(
                            "Hi 👋",
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withOpacity(0.9),
                                shadows: [
                                  Shadow(
                                      color: Colors.white.withOpacity(0.6),
                                      blurRadius: 8),
                                ]),
                          ),
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
                              // Glass Font for the name
                              Text(shortName,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      shadows: [
                                        Shadow(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            blurRadius: 4)
                                      ])),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => _showProfileMenu(context),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: [
                                      Color(0xFFE947F5),
                                      Color(0xFF2F4BA2)
                                    ]),
                                  ),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundImage:
                                        NetworkImage(globalProfilePicUrl),
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

          // 3. Floating Action Button
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF2F4BA2),
              foregroundColor: Colors.white,
              elevation: 8,
              onPressed: _createNewRoom,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatTile(BuildContext context, String title, String msg, String time,
      Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.2))),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
              child: Text(title.isNotEmpty ? title[0].toUpperCase() : "?",
                  style: TextStyle(
                      color: accentColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800))),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white)),
        subtitle: Text(msg,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 14)),
        trailing: Text(time,
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PeerspaceChatScreen(roomName: title))),
      ),
    );
  }
}

// --- 4. TILTED PROFILE PICTURE SCREEN ---
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

  void _editUsername() {
    final TextEditingController controller =
        TextEditingController(text: globalUsername);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161824),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Change Username",
                style: TextStyle(color: Colors.white)),
            content: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE947F5)),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    setState(() => globalUsername = controller.text.trim());
                  }
                  Navigator.pop(context);
                },
                child: const Text("Save",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          );
        });
  }

  void _editProfilePic() {
    final TextEditingController controller =
        TextEditingController(text: globalProfilePicUrl);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161824),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Change Profile Picture",
                style: TextStyle(color: Colors.white)),
            content: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter Image URL...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F4BA2)),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    setState(
                        () => globalProfilePicUrl = controller.text.trim());
                  }
                  Navigator.pop(context);
                },
                child: const Text("Save",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Profile Details", style: TextStyle(fontSize: 16))),
      body: Column(
        children: [
          Expanded(
            child: Center(
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
                                  color:
                                      const Color(0xFFE947F5).withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: 2)
                            ],
                            image: DecorationImage(
                              image: NetworkImage(globalProfilePicUrl),
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
                                  color:
                                      const Color(0xFF2F4BA2).withOpacity(0.5)),
                            ),
                            child: Text("$globalUsername • 25brs1104",
                                style: const TextStyle(
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
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF161824),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: const Color(0xFFE947F5).withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _editUsername,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Edit Name"),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF161824),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: const Color(0xFF2F4BA2).withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _editProfilePic,
                  icon: const Icon(Icons.image, size: 18),
                  label: const Text("Edit Picture"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- 5. SETTINGS SCREEN ---
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

// --- 6. CHAT SCREEN ---
class PeerspaceChatScreen extends StatefulWidget {
  final String roomName;
  const PeerspaceChatScreen({super.key, required this.roomName});

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
      bool isAbusive = text.toLowerCase().contains("spam") ||
          text.toLowerCase().contains("badword");
      bool isOffTopic = text.toLowerCase().contains("movie") ||
          text.toLowerCase().contains("politics");

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
                      "Blocked by AI: ${isAbusive ? 'Policy violation.' : 'Off-topic discussion.'}",
                      style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ));
        return;
      }
    }

    setState(() => _messages.add({"text": text, "isMe": true}));
    _controller.clear();
    // Maintain focus on the text field after sending
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      appBar: AppBar(
          backgroundColor: const Color(0xFF161824),
          elevation: 1,
          shadowColor: Colors.black,
          title: Text(widget.roomName,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white))),
      body: Column(
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: msg["isMe"]
                          ? const LinearGradient(
                              colors: [Color(0xFF2F4BA2), Color(0xFF1D306D)])
                          : null,
                      color:
                          msg["isMe"] ? null : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: msg["isMe"]
                              ? Colors.transparent
                              : Colors.white10),
                    ),
                    child: Text(msg["text"],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xFF161824),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  // Focus widget detects keyboard events like Enter vs Shift+Enter
                  child: Focus(
                    onKeyEvent: (FocusNode node, KeyEvent event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.enter) {
                        if (HardwareKeyboard.instance.isShiftPressed) {
                          // Allow the newline to pass through to the TextField
                          return KeyEventResult.ignored;
                        } else {
                          // Send message and consume the event so it doesn't create a newline
                          _handleSend();
                          return KeyEventResult.handled;
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 5, // allows the box to grow with shift+enter
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
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(bottom: 2), // align with bottom of input box
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
    );
  }
}
