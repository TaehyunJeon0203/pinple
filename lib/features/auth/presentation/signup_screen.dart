import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/utils/validators.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final email = '${_studentIdController.text.trim()}@smail.kongju.ac.kr';
      await ref.read(authRepositoryProvider).signUp(
            email: email,
            password: _passwordController.text,
            nickname: _nicknameController.text.trim(),
          );
      if (mounted) {
        context.go('/verify-email');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: '학번',
                  hintText: '202012345',
                  prefixIcon: Icon(Icons.badge_outlined),
                  suffixText: '@smail.kongju.ac.kr',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return '학번을 입력해주세요';
                  if (!RegExp(r'^\d+$').hasMatch(value)) return '숫자만 입력해주세요';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  hintText: '2~10자',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                validator: validateNickname,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  hintText: '6자 이상',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                obscureText: true,
                validator: validatePassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
