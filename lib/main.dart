import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calling',
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const DialingScreen(),
    );
  }
}

class DialingScreen extends StatefulWidget {
  const DialingScreen({super.key});

  @override
  State<DialingScreen> createState() => _DialingScreenState();
}

class _DialingScreenState extends State<DialingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildAction(IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
            ],
          ),
          child: Icon(icon, color: Colors.grey.shade800, size: 26),
        ),
        const SizedBox(height: 10),
        Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffF3FBFF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Text(
                  "Dialing",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),

                const Spacer(),

                SizedBox(
                  width: width * .45,
                  height: width * .45,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ScaleTransition(
                        scale: Tween(begin: .90, end: 1.08).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Container(
                          width: width * .45,
                          height: width * .45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.lightBlue.withOpacity(.12),
                          ),
                        ),
                      ),

                      ScaleTransition(
                        scale: Tween(begin: .95, end: 1.03).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Container(
                          width: width * .34,
                          height: width * .34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.lightBlue.withOpacity(.28),
                          ),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.15),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 55,
                          backgroundImage: AssetImage("assets/images/bird.jpg"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Little Sparrow",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  "+476-229-9449",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                ),

                const SizedBox(height: 10),

                Text(
                  "Calling...",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                ),

                const SizedBox(height: 40),

                const Divider(),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildAction(Icons.mic_off, "Mute"),
                    buildAction(Icons.bluetooth, "Bluetooth"),
                    buildAction(Icons.pause, "Hold"),
                  ],
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.dialpad, color: Colors.black87),
                    ),

                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(.35),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),

                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.volume_up, color: Colors.black87),
                    ),
                  ],
                ),

                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
