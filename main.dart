import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/services.dart'; // Required for RawKeyboardListener

// Global state for Hackathon Demo
bool globalAiModerationEnabled = true;
String globalUsername = "Khushal Jangid";
String globalProfilePic = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"; // Default

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

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeIn));

    _entranceController.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const ProfileLoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
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
      body: Center(
        child: FadeTransition(
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
                      colors: const [Color(0xFFE947F5), Color(0xFF2F4BA2), Color(0xFFE947F5)],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment(-2.0 + (_gradientController.value * 2), 0),
                      end: Alignment(0.0 + (_gradientController.value * 2), 0),
                    ).createShader(bounds);
                  },
                  child: const Text("PEERSPACE", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 2)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// --- 1. FLOATING LINES BACKGROUND ---
class FloatingLinesBackground extends StatefulWidget {
  final Widget child;
  const FloatingLinesBackground({super.key, required this.child});

  @override
  State<FloatingLinesBackground> createState() => _FloatingLinesBackgroundState();
}

class _FloatingLinesBackgroundState extends State<FloatingLinesBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
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
            return CustomPaint(painter: _FloatingLinesPainter(_controller.value), size: Size.infinite);
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
    final paint = Paint()
      ..shader = LinearGradient(colors: [blue.withOpacity(0.8), pink.withOpacity(0.8)]).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    _drawWaveGroup(canvas, size, paint, waveOffset: 0.3, waveHeight: 0.15, speedMulti: 1.0, lines: 6);
    _drawWaveGroup(canvas, size, paint, waveOffset: 0.6, waveHeight: 0.20, speedMulti: -0.8, lines: 4);
  }

  void _drawWaveGroup(Canvas canvas, Size size, Paint paint, {required double waveOffset, required double waveHeight, required double speedMulti, required int lines}) {
    for (int i = 0; i < lines; i++) {
      final path = Path();
      final baseY = size.height * waveOffset + (i * 25);
      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 5) {
        final y = baseY + math.sin((x * 0.002) + (time * math.pi * 2 * speedMulti) + (i * 0.4)) * (size.height * waveHeight);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingLinesPainter oldDelegate) => true;
}

// --- 2. LOGIN SCREEN ---
class ProfileLoginScreen extends StatefulWidget {
  const ProfileLoginScreen({super.key});

  @override
  State<ProfileLoginScreen> createState() => _ProfileLoginScreenState();
}

class _ProfileLoginScreenState extends State<ProfileLoginScreen> {
  bool _otpSent = false;
  void _verifyLogin() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ChatRoomsScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingLinesBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("PEERSPACE", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFFE947F5))),
                const SizedBox(height: 56),
                TextField(decoration: _inputDecoration("Phone Number").copyWith(prefixIcon: const Icon(Icons.phone, color: Color(0xFFE947F5)))),
                if (_otpSent) ...[
                  const SizedBox(height: 24),
                  TextField(decoration: _inputDecoration("Enter OTP").copyWith(prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2F4BA2)))),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F4BA2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _otpSent ? _verifyLogin : () => setState(() => _otpSent = true),
                    child: Text(_otpSent ? 'Authenticate' : 'Request Code'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );
}

// --- 3. CHAT ROOMS SCREEN (SYNCED HEADER) ---
class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("PEERSPACE", style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          Row(
            children: [
              Text(globalUsername, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePictureScreen())).then((_) => setState(() {})),
                child: CircleAvatar(radius: 16, backgroundImage: NetworkImage(globalProfilePic)),
              ),
              const SizedBox(width: 16),
            ],
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _chatTile("General Discussion", "Welcome to Peerspace!", "10:00 AM"),
        ],
      ),
    );
  }

  Widget _chatTile(String title, String msg, String time) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(msg, style: const TextStyle(color: Colors.white54)),
      trailing: Text(time),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PeerspaceChatScreen(roomName: title))),
    );
  }
}

// --- 4. PROFILE SCREEN (EDITABLE) ---
class ProfilePictureScreen extends StatefulWidget {
  const ProfilePictureScreen({super.key});

  @override
  State<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  double xRotation = 0;
  double yRotation = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: globalUsername);
  }

  void _saveProfile() {
    setState(() {
      globalUsername = _nameController.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
  }

  void _changePic() {
    // Simulating changing pic by cycling a few demo URLs
    List<String> avatars = [
      "https://i.scdn.co/image/ab67616d0000b273d9985092cd88bffd97653b58",
      "https://api.dicebear.com/7.x/avataaars/png?seed=Felix",
      "https://api.dicebear.com/7.x/avataaars/png?seed=Aneka"
    ];
    setState(() {
      globalProfilePic = avatars[math.Random().nextInt(avatars.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 3D Tilt Card
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  yRotation += details.delta.dx * 0.01;
                  xRotation -= details.delta.dy * 0.01;
                });
              },
              onPanEnd: (_) => setState(() { xRotation = 0; yRotation = 0; }),
              child: Transform(
                transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(xRotation)..rotateY(yRotation),
                alignment: FractionalOffset.center,
                child: Container(
                  width: 250, height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(image: NetworkImage(globalProfilePic), fit: BoxFit.cover),
                    boxShadow: [BoxShadow(color: const Color(0xFFE947F5).withOpacity(0.3), blurRadius: 30)],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(onPressed: _changePic, icon: const Icon(Icons.image), label: const Text("Change Photo")),
            const SizedBox(height: 40),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Username", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(onPressed: _saveProfile, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE947F5)), child: const Text("Save Changes")),
            )
          ],
        ),
      ),
    );
  }
}

// --- 5. SETTINGS SCREEN ---
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Settings")));
}

// --- 6. CHAT SCREEN (KEYBOARD LOGIC) ---
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

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({"text": _controller.text.trim(), "isMe": true});
      _controller.clear();
    });
    // Refocus after sending
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.roomName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) => Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: const Color(0xFF2F4BA2), borderRadius: BorderRadius.circular(12)),
                  child: Text(_messages[i]["text"]),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF161824),
            child: Row(
              children: [
                Expanded(
                  child: RawKeyboardListener(
                    focusNode: FocusNode(), // Dummy node for listener
                    onKey: (RawKeyEvent event) {
                      // Check for Enter key specifically
                      if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                        if (!event.isShiftPressed) {
                          _handleSend();
                        }
                      }
                    },
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null, // Allows expansion
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: "Enter to send, Shift+Enter for newline",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Color(0xFFE947F5)), onPressed: _handleSend),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
