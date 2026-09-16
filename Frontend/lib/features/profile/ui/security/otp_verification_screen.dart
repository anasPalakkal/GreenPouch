import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/core/services/api_config.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  bool isLoading = false;

  String getOtp() => controllers.map((e) => e.text).join();

  @override
  void initState() {
    super.initState();
    // auto-paste when any box gains focus and clipboard has 6 digits
    for (int i = 0; i < 6; i++) {
      focusNodes[i].addListener(() => _onFocusChange(i));
    }
  }

  void _onFocusChange(int index) async {
    if (!focusNodes[index].hasFocus) return;
    final data = await Clipboard.getData('text/plain');
    if (data == null || data.text == null) return;
    final text = data.text!.trim();
    if (text.length == 6 && RegExp(r'^\d{6}$').hasMatch(text)) {
      _pasteOtp(text);
    }
  }

  // fill all 6 boxes and auto-verify
  void _pasteOtp(String otp) {
    for (int i = 0; i < 6; i++) {
      controllers[i].text = otp[i];
    }
    focusNodes[5].requestFocus();
    setState(() {});
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) verifyOtp();
    });
  }

  Future<void> verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await AuthStorage.getToken();

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/otp/verify/private"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"otp": getOtp(), "purpose": "reset_password"}),
      );

      final data = jsonDecode(response.body);

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final resetToken = data["resetToken"];
        Navigator.pushReplacementNamed(
          context,
          "/resetPassword",
          arguments: resetToken,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "OTP failed")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error. Please try again.")),
      );
    }
  }

  Future<void> resendOtp() async {
    final token = await AuthStorage.getToken();

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/user/forgot-password"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (var c in controllers) {
          c.clear();
        }
        focusNodes.first.requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "New OTP sent")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Unable to resend OTP")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error. Please try again.")),
      );
    }
  }

  Widget otpBox(int index, ThemeData theme) {
    final color = theme.colorScheme;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) {
            // handle physical/hardware backspace key
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              if (controllers[index].text.isEmpty && index > 0) {
                controllers[index - 1].clear();
                focusNodes[index - 1].requestFocus();
              }
            }
          },
          child: TextFormField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color.onSurface,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: color.surfaceVariant.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: color.outline.withOpacity(0.3), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color.error, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            validator: (value) {
              if (getOtp().length < 6) return "Invalid OTP";
              return null;
            },
            onChanged: (value) {
              // handle paste via onChanged (some Android keyboards deliver full string here)
              if (value.length == 6 && RegExp(r'^\d{6}$').hasMatch(value)) {
                _pasteOtp(value);
                return;
              }

              // truncate if somehow more than 1 digit slips through
              if (value.length > 1) {
                controllers[index].text = value[0];
                controllers[index].selection = TextSelection.fromPosition(
                  TextPosition(offset: controllers[index].text.length),
                );
              }

              if (value.isNotEmpty && index < 5) {
                // advance to next box
                focusNodes[index + 1].requestFocus();
              }

              if (value.isEmpty && index > 0) {
                // go back to previous box
                focusNodes[index - 1].requestFocus();
              }

              // auto-verify when all 6 filled
              if (getOtp().length == 6) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) verifyOtp();
                });
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        backgroundColor: color.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: color.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "OTP Verification",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── Icon ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 40,
                  color: color.primary,
                ),
              ),

              const SizedBox(height: 20),

              // ─── Title ───────────────────────────────────────────
              Text(
                "Check your email",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Enter the 6-digit OTP sent to your email",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // ─── OTP Boxes ───────────────────────────────────────
              Row(
                children: List.generate(6, (index) => otpBox(index, theme)),
              ),

              const SizedBox(height: 12),

              // ─── Resend ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the OTP? ",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.onSurface.withOpacity(0.5),
                    ),
                  ),
                  GestureDetector(
                    onTap: resendOtp,
                    child: Text(
                      "Resend",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ─── Verify Button ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.primary,
                    foregroundColor: color.onPrimary,
                    elevation: 2,
                    shadowColor: color.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: color.onPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Verify OTP",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: color.onPrimary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // ─── Back Button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color.onSurface,
                    side: BorderSide(
                        color: color.outline.withOpacity(0.4), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Go Back",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: color.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
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
