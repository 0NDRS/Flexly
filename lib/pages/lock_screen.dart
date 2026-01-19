import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class LockScreen extends StatefulWidget {
  final bool biometricsEnabled;
  final LocalAuthentication localAuth;

  const LockScreen({
    super.key,
    required this.biometricsEnabled,
    required this.localAuth,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _input = '';
  String _error = '';
  int _requiredLength = 4;
  bool _authInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadPasscode();
    if (widget.biometricsEnabled) {
      Future.microtask(_tryBiometric);
    }
  }

  Future<void> _loadPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('privacy_passcode_code');
    if (stored != null && stored.isNotEmpty) {
      setState(() {
        _requiredLength = stored.length.clamp(4, 8);
      });
    }
  }

  Future<void> _tryBiometric() async {
    if (_authInProgress) return;
    _authInProgress = true;
    try {
      final available = await widget.localAuth.canCheckBiometrics ||
          await widget.localAuth.isDeviceSupported();
      if (!available) return;
      final bioms = await widget.localAuth.getAvailableBiometrics();
      if (bioms.isEmpty) return;
      final ok = await widget.localAuth.authenticate(
        localizedReason: 'Unlock Flexly',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (ok && mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      _authInProgress = false;
    }
  }

  Future<void> _submit() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('privacy_passcode_code');
    if (stored == null || stored.isEmpty) {
      if (mounted) Navigator.pop(context, true);
      return;
    }
    if (_input.length != stored.length) return;
    if (_input == stored) {
      if (mounted) Navigator.pop(context, true);
    } else {
      setState(() {
        _error = 'Incorrect passcode';
        _input = '';
      });
    }
  }

  void _tapDigit(String d) {
    if (_input.length >= 8) return;
    setState(() {
      _input += d;
      _error = '';
    });
    if (_input.length >= _requiredLength) {
      _submit();
    }
  }

  void _backspace() {
    if (_input.isEmpty) return;
    setState(() {
      _input = _input.substring(0, _input.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(34),
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Your body\nkeeps score',
                              style: AppTextStyles.h1.copyWith(
                                fontSize: 28,
                                color: AppColors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Make it count.',
                              style: AppTextStyles.h1.copyWith(
                                fontSize: 28,
                                color: AppColors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Powered by Flex Intelligence™',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.grayLight,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 80),
                    Text(
                      'Enter passcode',
                      style: AppTextStyles.h2.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_requiredLength, (index) {
                        final filled = index < _input.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled ? AppColors.primary : AppColors.gray,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    if (_error.isNotEmpty)
                      Text(
                        _error,
                        style: AppTextStyles.caption1.copyWith(color: Colors.redAccent),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  _buildRow(['1', '2', '3']),
                  const SizedBox(height: 14),
                  _buildRow(['4', '5', '6']),
                  const SizedBox(height: 14),
                  _buildRow(['7', '8', '9']),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.biometricsEnabled) ...[
                        _buildKey(
                          'bio',
                          icon: Icons.fingerprint,
                          onTap: _tryBiometric,
                          enabled: true,
                        ),
                        const SizedBox(width: 20),
                      ] else
                        const SizedBox(width: 96),
                      _buildKey('0'),
                      const SizedBox(width: 20),
                      _buildKey('←', onTap: _backspace),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits
          .map((d) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _buildKey(d),
              ))
          .toList(),
    );
  }

  Widget _buildKey(String digit,
      {VoidCallback? onTap, bool enabled = true, IconData? icon}) {
    final isBackspace = digit == '←';
    final tapHandler = onTap ?? () => _tapDigit(digit);
    final canTap = enabled && (digit.isNotEmpty);
    return GestureDetector(
      onTap: canTap ? tapHandler : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.grayDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gray, width: 1),
        ),
        alignment: Alignment.center,
        child: isBackspace
            ? const Icon(Icons.backspace_outlined, color: Colors.white)
            : (icon != null
                ? Icon(icon,
                    color: enabled ? Colors.white : AppColors.gray,
                    size: 28)
                : Text(
                    digit,
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.white,
                      fontSize: 28,
                    ),
                  )),
      ),
    );
  }
}