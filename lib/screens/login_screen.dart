import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/build_context_ext.dart';
import '../blocs/garage_bloc.dart';
import '../blocs/garage_event.dart';
import '../blocs/garage_state.dart';
import '../widgets/glass_widget.dart';
import '../gen/assets.gen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  void _submit() {
    final username = _usernameController.text;
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) return;

    if (_isLogin) {
      context.read<GarageBloc>().add(LoginUser(username, password));
    } else {
      context.read<GarageBloc>().add(RegisterUser(username, password));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: GlassWidget(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.appIcon.image(width: 80, height: 80),
                const SizedBox(height: 16),
                Text(
                  _isLogin ? l10n.login : l10n.register,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: l10n.username,
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 32),
                BlocConsumer<GarageBloc, GarageState>(
                  listener: (context, state) {
                    if (state.errorMessage != null && state.status == GarageStatus.failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.status == GarageStatus.authenticating) {
                      return const CircularProgressIndicator();
                    }
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(_isLogin ? l10n.login : l10n.register),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(_isLogin ? l10n.register : l10n.login),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
