import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';

class EmailVerifyScreen extends ConsumerStatefulWidget {
  const EmailVerifyScreen({super.key});

  @override
  ConsumerState<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends ConsumerState<EmailVerifyScreen> {
  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);
    try {
      final verified =
          await ref.read(authRepositoryProvider).checkEmailVerified();
      if (verified && mounted) {
        context.go('/map');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('아직 인증이 완료되지 않았습니다')),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    try {
      await ref.read(authRepositoryProvider).resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증 메일을 다시 보냈습니다')),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                '이메일 인증',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              const Text(
                '학교 이메일로 인증 메일을 보냈습니다.\n메일함을 확인해주세요.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isChecking ? null : _checkVerification,
                child: _isChecking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('인증 완료 확인'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isResending ? null : _resendEmail,
                child: const Text('인증 메일 다시 보내기'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (mounted) context.go('/login');
                },
                child: const Text('다른 계정으로 로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
