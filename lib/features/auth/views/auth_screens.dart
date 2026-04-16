import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../../../core/widgets/common/app_widgets.dart';

// ════════════════════════════════════════════════════════════
//  SPLASH SCREEN
// ════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      final auth = Get.find<AuthController>();
      if (auth.isLoggedIn) {
        auth.currentUser.value != null ? auth.resolveNavigation() : Get.offAllNamed(AppRoutes.phoneLogin);
      } else {
        Get.offAllNamed(AppRoutes.phoneLogin);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.offWhite,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.sports_cricket, color: Colors.white, size: 48),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              'CricBid',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 8),
            Text(
              'Cricket Player Auction',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 40),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  PHONE LOGIN SCREEN
// ════════════════════════════════════════════════════════════
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});
  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _authCtrl = Get.find<AuthController>();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.sports_cricket, color: Colors.white, size: 32),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 32),
                Text('Welcome to', style: theme.textTheme.bodyLarge).animate().fadeIn(delay: 100.ms),
                Text(
                  'CricBid',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 8),
                Text(
                  'Login with your mobile number to get started',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 40),
                // Phone field
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: '98XXXXXXXX',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Text(
                        '+91',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                  validator: (v) {
                    if (v == null || v.length != 10) {
                      return 'Enter valid 10-digit mobile number';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 24),
                // Submit
                Obx(() => AppButton(
                      label: 'Send OTP',
                      width: double.infinity,
                      isLoading: _authCtrl.isLoading.value,
                      onTap: _submit,
                    )).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 16),
                Obx(() {
                  if (_authCtrl.errorMessage.value.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _authCtrl.errorMessage.value,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _authCtrl.sendOtp(_phoneCtrl.text.trim());
    }
  }
}

// ════════════════════════════════════════════════════════════
//  OTP SCREEN
// ════════════════════════════════════════════════════════════
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _authCtrl = Get.find<AuthController>();
  final _nameCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _needsName = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Enter the 6-digit code',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Sent to +91 ${_authCtrl.phone}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // OTP Input
            Pinput(
              controller: _otpCtrl,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              onCompleted: (pin) {
                if (pin.length == 6) _verify(pin);
              },
            ),
            const SizedBox(height: 24),
            // Name field (for new users)
            if (_needsName) ...[
              AppTextField(
                label: 'Your Name',
                hint: 'Enter your full name',
                controller: _nameCtrl,
              ),
              const SizedBox(height: 16),
            ],
            // Resend
            Obx(() => _authCtrl.resendSeconds.value > 0
                ? Text(
                    'Resend in ${_authCtrl.resendSeconds.value}s',
                    style: theme.textTheme.bodySmall,
                  )
                : TextButton(
                    onPressed: () => _authCtrl.sendOtp(_authCtrl.phone),
                    child: const Text('Resend OTP'),
                  )),
            const SizedBox(height: 24),
            Obx(() => AppButton(
                  label: 'Verify & Login',
                  width: double.infinity,
                  isLoading: _authCtrl.isLoading.value,
                  onTap: () => _verify(_otpCtrl.text),
                )),
            const SizedBox(height: 12),
            Obx(() {
              if (_authCtrl.errorMessage.value.isNotEmpty) {
                return Text(
                  _authCtrl.errorMessage.value,
                  style: const TextStyle(color: AppColors.error),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  void _verify(String pin) {
    if (pin.length < 6) return;
    _authCtrl.verifyOtp(
      pin,
      displayName: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : null,
    );
  }
}
