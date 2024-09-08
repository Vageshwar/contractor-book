import 'package:contractor_book/models/contractor.dart';
import 'package:contractor_book/screens/homepage.dart';
import 'package:contractor_book/screens/register.dart';
import 'package:contractor_book/services/db_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contractor Book',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final DatabaseService dbService = DatabaseService();
  double _opacity = 0.0;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  Future<void> _checkUser() async {
    Contractor user = await dbService.getCurrentUser();
    print(
      "User $user",
    );
    // Check if user exists
    if (user.contractorId != 0) {
      // Navigate to Homepage if user exists
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Navigate to RegisterPage if no user found
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
      );
    }
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Change opacity to 1.0 to start the animation
      });
    });

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Tween for sliding from bottom to original position
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Start from off-screen (bottom)
      end: const Offset(0.0, 0.0), // End at the bottom of the screen
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    // Start the slide animation after a slight delay
    Future.delayed(const Duration(milliseconds: 700), () {
      _slideController.forward();
    });

    // Add a status listener to check when the animation is completed
    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkUser();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose(); // Dispose the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Column(
              children: [
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(seconds: 1),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 300.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SlideTransition(
              position: _slideAnimation,
              child: const Column(
                children: [
                  SizedBox(height: 20.0),
                  Text(
                    'A Product by',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'FellowRise',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 40.0),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
