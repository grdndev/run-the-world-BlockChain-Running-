import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/sky_background.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/rtw_logo.dart';
import '../../../shared/widgets/rtw_button.dart';
import '../../../shared/widgets/rtw_text_field.dart';
import '../../../core/theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _sent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
              child: Column(
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => context.go('/login'),
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Logo
                  const RtwLogo(fontSize: 44),
                  const SizedBox(height: 40),
                  // Forgot password card
                  GlassCard(
                    child: _sent
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.goldenYellow,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Email envoyé !',
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Vérifiez votre boîte mail\npour réinitialiser votre mot de passe.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.goldenYellow,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              RtwButton(
                                text: 'Retour',
                                onPressed: () => context.go('/login'),
                              ),
                            ],
                          )
                        : Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Mot de passe oublié ?',
                                  style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Email field
                                RtwTextField(
                                  hintText: 'Email',
                                  prefixIcon: Icons.email_outlined,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer votre email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Email invalide';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                // Send button
                                RtwButton(
                                  text: 'Envoyer',
                                  isLoading: _isLoading,
                                  onPressed: _handleSend,
                                ),
                              ],
                            ),
                          ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
