import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_orders_screen.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool loading = false;
  bool isOwnerSignup = false;

  Future<void> submit() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final newUser = FirebaseAuth.instance.currentUser;
        if (newUser != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(newUser.uid)
              .set({
            'email': newUser.email,
            'role': isOwnerSignup ? 'owner' : 'customer',
          }, SetOptions(merge: true));
        }
      }

      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;

if (user != null) {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!mounted) return;

  if (doc.exists && doc.data()?['role'] == 'admin') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminOrdersScreen(),
      ),
    );
    return;
  }
}

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      isLogin
          ? 'Logged in as ${FirebaseAuth.instance.currentUser?.email ?? ''}'
          : 'Account created. You are logged in as ${FirebaseAuth.instance.currentUser?.email ?? ''}',
    ),
  ),
);

Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email';
      } else if (e.code == 'weak-password') {
        message = 'Password should be at least 6 characters';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      appBar: AppBar(
        title: Text(isLogin ? 'Customer Login' : 'Create Account'),
        backgroundColor: const Color(0xFFF8F5EF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Icon(
              Icons.person_outline,
              size: 80,
              color: Color(0xFF1E3B32),
            ),
            const SizedBox(height: 20),
            Text(
              isLogin ? 'Welcome Back!' : 'Create Your Account',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3B32),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            if (!isLogin) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black12),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF1E3B32),
                  value: isOwnerSignup,
                  onChanged: loading
                      ? null
                      : (val) {
                          setState(() => isOwnerSignup = val);
                        },
                  title: const Text(
                    'Register as Restaurant / Home Kitchen Owner',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3B32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      isLogin ? 'Login' : 'Create Account',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: loading
                  ? null
                  : () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
              child: Text(
                isLogin
                    ? 'New customer? Create an account'
                    : 'Already have an account? Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
