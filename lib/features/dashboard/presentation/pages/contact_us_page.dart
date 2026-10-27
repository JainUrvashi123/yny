import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/bloc/theme_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/auth_button.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../widgets/app_drawer.dart';

class ContactUsPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const ContactUsPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  late final WebViewController _mapController;
  bool _isMapLoading = true;

  @override
  void initState() {
    super.initState();

    // 1. Pre-fill basic details from passed session parameters immediately
    _nameController.text = widget.userName;
    _emailController.text = widget.userEmail;

    // 2. Fetch full profile details to pre-fill mobile numbers
    context.read<AuthBloc>().add(AuthGetProfileRequested(userId: widget.userId));

    // 3. Initialize Google Maps WebViewController
    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                _isMapLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            // Allow the embedded map and internal iframe URLs to load inside the WebView
            if (url.contains('google.com/maps/embed') || url.contains('maps/embed') || url.startsWith('data:')) {
              return NavigationDecision.navigate;
            }

            // Intercept any external map navigation/redirection links (e.g., "View larger map", "Directions", Terms of Use)
            if (url.startsWith('http://') || url.startsWith('https://')) {
              final Uri uri = Uri.parse(url);
              try {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              } catch (e) {
                debugPrint('Could not launch map URL: $e');
                // Copy address to clipboard as a premium fallback
                await Clipboard.setData(
                  const ClipboardData(text: '48 W 48th St suite # 605, New York, NY 10036'),
                );
                if (mounted) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Map app unavailable. Address copied to clipboard!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: isDark ? AppConstants.accentColorDark : AppConstants.accentColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      action: SnackBarAction(
                        label: 'OK',
                        textColor: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  );
                }
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString('''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <style>
            body, html {
              margin: 0;
              padding: 0;
              width: 100%;
              height: 100%;
              overflow: hidden;
              background-color: transparent;
            }
            iframe {
              width: 100%;
              height: 100%;
              border: 0;
            }
          </style>
        </head>
        <body>
          <iframe 
            src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3022.183007941976!2d-73.98298952345714!3d40.75799943479754!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89c258ff1c793f81%3A0x569c96cab5a52e36!2s48%20W%2048th%20St%20suite%20%23%20605%2C%20New%20York%2C%20NY%2010036%2C%20USA!5e0!3m2!1sen!2sin!4v1724924336044!5m2!1sen!2sin" 
            allowfullscreen="" 
            loading="lazy" 
            referrerpolicy="no-referrer-when-downgrade">
          </iframe>
        </body>
        </html>
      ''');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthContactSubmitRequested(
              fullName: _nameController.text.trim(),
              email: _emailController.text.trim(),
              mobile: _phoneController.text.trim(),
              message: _messageController.text.trim(),
            ),
          );
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      debugPrint('Error launching phone: $e');
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open dialer. Copied $phone to clipboard!'),
            backgroundColor: isDark ? AppConstants.accentColorDark : AppConstants.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      await Clipboard.setData(ClipboardData(text: phone));
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email?subject=Inquiry from YNY App');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open mail app. Copied $email to clipboard!'),
            backgroundColor: isDark ? AppConstants.accentColorDark : AppConstants.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      await Clipboard.setData(ClipboardData(text: email));
    }
  }

  Future<void> _launchMap() async {
    final Uri uri = Uri.parse('https://maps.google.com/maps?daddr=48+W+48+St+Suite+605+New+York+NY+10036');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
      await Clipboard.setData(
        const ClipboardData(text: '48 W 48th St suite # 605, New York, NY 10036'),
      );
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Map app unavailable. Address copied to clipboard!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: isDark ? AppConstants.accentColorDark : AppConstants.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
      drawer: AppDrawer(
        currentPage: 'contact_us',
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8.0),
          child: IconButton(
            icon: Icon(Icons.menu_rounded, color: Theme.of(context).colorScheme.onSurface, size: 24),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
              side: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Contact Us',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 8.0),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              onPressed: () {
                context.read<ThemeBloc>().add(const ThemeToggleRequested());
              },
              style: IconButton.styleFrom(
                backgroundColor: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                side: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthProfileLoadSuccess) {
            // Auto-populate full profile details when fetched
            final profile = state.profile;
            final fName = profile['firstname']?.toString() ?? '';
            final lName = profile['lastname']?.toString() ?? '';
            if (fName.isNotEmpty || lName.isNotEmpty) {
              _nameController.text = '$fName $lName'.trim();
            }
            _emailController.text = profile['email']?.toString() ?? widget.userEmail;
            _phoneController.text = profile['phone']?.toString() ?? profile['mobile']?.toString() ?? '';
          } else if (state is AuthProfileLoadFailure) {
            if (state.errorMessage.contains('User not found') || state.errorMessage.contains('not found')) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading profile: ${state.errorMessage}'),
                  backgroundColor: AppConstants.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          } else if (state is AuthContactSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppConstants.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            _messageController.clear(); // Clear message box upon successful submit
          } else if (state is AuthContactSubmitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppConstants.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is AuthContactSubmitInProgress;

          return Stack(
            children: [
              // Atmospheric Glow Blobs
              Positioned(
                top: -150,
                right: -100,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -150,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.accentSecondary.withOpacity(0.03),
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Elegant Header
                      _buildHeader(context, isDark, accentColor),
                      const SizedBox(height: AppConstants.spaceLG),

                      // 2. Quick Action Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              context: context,
                              icon: Icons.call_rounded,
                              title: 'Call Us',
                              subtitle: '+1 212 302 3130',
                              onTap: () => _launchPhone('+12123023130'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              context: context,
                              icon: Icons.mail_outline_rounded,
                              title: 'Email Us',
                              subtitle: 'yny@ynyjewels.com',
                              onTap: () => _launchEmail('yny@ynyjewels.com'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildQuickActionCard(
                        context: context,
                        icon: Icons.location_on_outlined,
                        title: 'New York Office',
                        subtitle: '48 W 48th Street, Suite #605, New York, NY 10036, USA',
                        isFullWidth: true,
                        onTap: _launchMap,
                      ),
                      const SizedBox(height: AppConstants.spaceLG),

                      // 3. Google Map Premium framed box
                      _buildMapSection(context, isDark, accentColor),
                      const SizedBox(height: AppConstants.spaceLG),

                      // 4. Premium Glassmorphic Form Card
                      _buildFormCard(context, isDark, accentColor, isSubmitting),
                      const SizedBox(height: AppConstants.spaceLG),

                      // // 5. Clean Footer Socials
                      // _buildFooterSocials(context, isDark),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.spaceSM),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'GET IN TOUCH',
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: accentColor,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Let's Start a\nConversation",
          style: GoogleFonts.nunito(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "We'd love to hear from you. Get in touch with our team instantly via direct links or send a message below.",
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isFullWidth = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? AppConstants.surfaceColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppConstants.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                      ),
                      maxLines: isFullWidth ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, bool isDark, Color accentColor) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23.0),
        child: Stack(
          children: [
            WebViewWidget(controller: _mapController),
            if (_isMapLoading)
              Container(
                color: isDark ? AppConstants.surfaceColor : Colors.white,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            // Positioned(
            //   bottom: 12,
            //   right: 12,
            //   child: Material(
            //     color: Colors.transparent,
            //     child: InkWell(
            //       onTap: _launchMap,
            //       borderRadius: BorderRadius.circular(30),
            //       child: Container(
            //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            //         decoration: BoxDecoration(
            //           color: isDark ? AppConstants.backgroundColor.withOpacity(0.9) : Colors.white.withOpacity(0.9),
            //           borderRadius: BorderRadius.circular(30),
            //           border: Border.all(
            //             color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
            //           ),
            //           boxShadow: [
            //             BoxShadow(
            //               color: Colors.black.withOpacity(0.2),
            //               blurRadius: 10,
            //               offset: const Offset(0, 4),
            //             )
            //           ],
            //         ),
            //         child: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             Icon(Icons.map_rounded, size: 14, color: accentColor),
            //             const SizedBox(width: 6),
            //             Text(
            //               'Open in Maps',
            //               style: GoogleFonts.nunito(
            //                 fontSize: 12,
            //                 fontWeight: FontWeight.w800,
            //                 color: isDark ? Colors.white : AppConstants.lightTextPrimary,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, bool isDark, Color accentColor, bool isSubmitting) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLG),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF141419).withOpacity(0.8) 
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF141419), const Color(0xFF0F0F14)]
              : [Colors.white, const Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Send a Message',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppConstants.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Have a custom inquiry or feedback? Drop us a note below.',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceLG),
            CustomTextField(
              controller: _nameController,
              labelText: 'Your Name',
              hintText: 'John Doe',
              prefixIcon: Icons.person_outline_rounded,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spaceMD),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email Address',
              hintText: 'john@example.com',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!val.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spaceMD),
            CustomTextField(
              controller: _phoneController,
              labelText: 'Phone Number',
              hintText: '9876543212',
              prefixIcon: Icons.call_rounded,
              keyboardType: TextInputType.phone,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spaceMD),
            
            // Multiline Message Box
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
              decoration: const InputDecoration(
                labelText: 'Your message',
                hintText: 'Describe how we can help you...',
                alignLabelWithHint: true,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your message';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spaceLG),

            AuthButton(
              text: 'SUBMIT MESSAGE',
              isLoading: isSubmitting,
              onTap: _onSubmitPressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSocials(BuildContext context, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: AppConstants.spaceLG),
        Text(
          'Follow Us on Social Media',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppConstants.spaceMD),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(context, Icons.facebook_rounded),
            const SizedBox(width: AppConstants.spaceLG),
            _buildSocialIcon(context, Icons.camera_alt_outlined), // Instagram rep
            const SizedBox(width: AppConstants.spaceLG),
            _buildSocialIcon(context, Icons.business_rounded), // LinkedIn rep
          ],
        ),
        const SizedBox(height: AppConstants.spaceXXL),
      ],
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppConstants.surfaceLightColor : AppConstants.lightSurfaceLightColor,
        border: Border.all(
          color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
        ),
      ),
      child: Icon(
        icon,
        color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
        size: 20,
      ),
    );
  }
}
