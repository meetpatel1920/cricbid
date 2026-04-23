import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/button_widget.dart';
import '../auth/auth_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _authCtrl = Get.find<AuthController>();
  final _nameCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  bool _needsName = false;
  bool _otpComplete = false;

  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _otpCtrl.dispose();
    _nameFocus.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _verify(String pin) {
    if (pin.length < 6) return;
    _authCtrl.verifyOtp(
      pin,
      displayName: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // OTP Box themes
    final defaultPin = PinTheme(
      width: 52,
      height: 58,
      textStyle: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
    );
    final focusedPin = defaultPin.copyWith(
      decoration: BoxDecoration(
        color: AppColors.cyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cyan, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
    );
    final submittedPin = defaultPin.copyWith(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.5)),
      ),
    );
    final errorPin = defaultPin.copyWith(
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withOpacity(0.6)),
      ),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF04071A), Color(0xFF0C1842), Color(0xFF1A3A8F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white70, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height * 0.03),

                          // Icon
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.cyan.withOpacity(0.25),
                              ),
                            ),
                            child: const Icon(Icons.sms_outlined,
                                color: AppColors.cyan, size: 26),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            'Verify OTP',
                            style: AppTextStyles.displaySmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => RichText(
                                text: TextSpan(
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white54,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Code sent to '),
                                    TextSpan(
                                      text: '+91 ${_authCtrl.phone}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.cyan,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.gold.withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              '🔐 Demo OTP: 123456',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.gold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // OTP Input
                          Center(
                            child: Obx(() {
                              final hasError = _authCtrl.errorMessage.value.isNotEmpty;
                              return Pinput(
                                controller: _otpCtrl,
                                length: 6,
                                defaultPinTheme: defaultPin,
                                focusedPinTheme: focusedPin,
                                submittedPinTheme: submittedPin,
                                errorPinTheme: errorPin,
                                forceErrorState: hasError,
                                onChanged: (v) {
                                  if (_authCtrl.errorMessage.value.isNotEmpty) {
                                    _authCtrl.errorMessage.value = '';
                                  }
                                  setState(() => _otpComplete = v.length == 6);
                                },
                                onCompleted: (pin) {
                                  setState(() => _otpComplete = true);
                                  if (!_needsName) _verify(pin);
                                },
                                separatorBuilder: (i) =>
                                    const SizedBox(width: 8),
                                hapticFeedbackType:
                                    HapticFeedbackType.lightImpact,
                              );
                            }),
                          ),

                          const SizedBox(height: 28),

                          // Name field (for new users)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            child: _needsName
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your Name',
                                        style: AppTextStyles.labelMedium
                                            .copyWith(color: Colors.white60),
                                      ),
                                      const SizedBox(height: 8),
                                      _GlassInput(
                                        controller: _nameCtrl,
                                        focusNode: _nameFocus,
                                        hint: 'Enter your full name',
                                        textInputAction: TextInputAction.done,
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),

                          // Resend timer
                          Center(
                            child: Obx(() {
                              final secs = _authCtrl.resendSeconds.value;
                              if (secs > 0) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.timer_outlined,
                                        size: 14,
                                        color: Colors.white38),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Resend in ${secs}s',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return TextButton(
                                onPressed: () {
                                  _otpCtrl.clear();
                                  _authCtrl.sendOtp(_authCtrl.phone);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.cyan,
                                ),
                                child: Text(
                                  'Resend OTP',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.cyan,
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 24),

                          // Verify button
                          Obx(() => AppButton(
                                label: 'Verify & Login',
                                width: double.infinity,
                                isLoading: _authCtrl.isLoading.value,
                                onTap: _otpComplete
                                    ? () => _verify(_otpCtrl.text)
                                    : null,
                              )),

                          // Error
                          Obx(() {
                            final err = _authCtrl.errorMessage.value;
                            if (err.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.error.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded,
                                        color: Color(0xFFFF6B6B), size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        err,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: const Color(0xFFFF6B6B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hint;
  final TextInputAction? textInputAction;

  const _GlassInput({
    required this.controller,
    this.focusNode,
    this.hint,
    this.textInputAction,
  });

  @override
  State<_GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<_GlassInput> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_focused ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused
              ? AppColors.cyan.withOpacity(0.6)
              : Colors.white.withOpacity(0.12),
          width: _focused ? 1.5 : 1,
        ),
      ),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white24),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }
}
