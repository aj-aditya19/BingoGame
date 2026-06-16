import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const LandingScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFE0F2FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Live multiplayer bingo",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Play bingo with friends in a bright, animated game room.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Create a room, join a match, and track every move in real time with smooth visuals and fast interactions.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onLogin,
                    child: const Text("Login"),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onRegister,
                    child: const Text("Create Account"),
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statCard("2", "ways to start"),
                    _statCard("24/7", "browser access"),
                    _statCard("Live", "room updates"),
                  ],
                ),

                const SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(blurRadius: 10, color: Colors.black12),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Ready for the next round",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 25,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemBuilder: (context, index) {
                          final active = index % 3 == 0;

                          return Container(
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.amber.shade200
                                  : Colors.white,
                              border: Border.all(
                                color: active ? Colors.orange : Colors.blueGrey,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: active
                                ? const Center(
                                    child: CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Colors.red,
                                    ),
                                  )
                                : null,
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      const LinearProgressIndicator(value: 0.65),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: _featureCard(
                        "01",
                        "Pick a mode",
                        "Create or join a room.",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _featureCard(
                        "02",
                        "Live Sync",
                        "Boards update instantly.",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _featureCard(
                        "03",
                        "Win Together",
                        "Quick replay flow.",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _statCard(String value, String label) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  static Widget _featureCard(String number, String title, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(number, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
