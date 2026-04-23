import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/button_widget.dart';
import '../login/login_screen.dart'; // GlassTextField
import './otp_controller.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpController>();
    final size = MediaQuery.of(context).size;

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
          BoxShadow(color: AppColors.cyan.withOpacity(0.25), blurRadius: 12),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.03),

                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cyan.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.sms_outlined,
                            color: AppColors.cyan, size: 26),
                      ),

                      const SizedBox(height: 20),

                      Text('Verify OTP',
                          style: AppTextStyles.displaySmall
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 8),

                      Obx(() => RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: Colors.white54),
                              children: [
                                const TextSpan(text: 'Code sent to '),
                                TextSpan(
                                  text: '+91 ${controller.phone}',
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
                              color: AppColors.gold.withOpacity(0.25)),
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

                      // OTP Boxes
                      Center(
                        child: Obx(() {
                          final hasError =
                              controller.errorMessage.value.isNotEmpty;
                          return Pinput(
                            controller: controller.otpController,
                            length: 6,
                            defaultPinTheme: defaultPin,
                            focusedPinTheme: focusedPin,
                            submittedPinTheme: submittedPin,
                            errorPinTheme: errorPin,
                            forceErrorState: hasError,
                            onChanged: controller.onOtpChanged,
                            separatorBuilder: (_) => const SizedBox(width: 8),
                            hapticFeedbackType:
                                HapticFeedbackType.lightImpact,
                          );
                        }),
                      ),

                      const SizedBox(height: 28),

                      // Name field for new users
                      GlassTextField(
                        controller: controller.nameController,
                        hint: 'Your name (optional for new users)',
                        label: 'Display Name',
                        textInputAction: TextInputAction.done,
                      ),

                      const SizedBox(height: 20),

                      // Resend
                      Center(
                        child: Obx(() {
                          final secs = controller.resendSeconds.value;
                          if (secs > 0) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer_outlined,
                                    size: 14, color: Colors.white38),
                                const SizedBox(width: 4),
                                Text('Resend in ${secs}s',
                                    style: AppTextStyles.bodySmall
                                        .copyWith(color: Colors.white38)),
                              ],
                            );
                          }
                          return TextButton(
                            onPressed: controller.resendOtp,
                            child: Text('Resend OTP',
                                style: AppTextStyles.labelMedium
                                    .copyWith(color: AppColors.cyan)),
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      Obx(() => AppButton(
                            label: 'Verify & Login',
                            width: double.infinity,
                            isLoading: controller.isLoading.value,
                            onTap: controller.otpComplete.value
                                ? () => controller
                                    .verify(controller.otpController.text)
                                : null,
                          )),

                      Obx(() {
                        final err = controller.errorMessage.value;
                        if (err.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: Color(0xFFFF6B6B), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(err,
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color: const Color(0xFFFF6B6B))),
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
            ],
          ),
        ),
      ),
    );
  }
}
