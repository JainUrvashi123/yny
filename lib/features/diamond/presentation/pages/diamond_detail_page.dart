import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../widgets/diamond_share_dialog.dart';
import '../../../../core/bloc/theme_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../data/models/diamond_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/diamond_bloc.dart';
import '../bloc/diamond_event.dart';
import '../../../../features/wishlist/presentation/bloc/wishlist_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class DiamondDetailPage extends StatefulWidget {
  final DiamondModel diamond;

  const DiamondDetailPage({super.key, required this.diamond});

  @override
  State<DiamondDetailPage> createState() => _DiamondDetailPageState();
}

class _DiamondDetailPageState extends State<DiamondDetailPage> {
  bool _isWishlisted = false;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _checkGuestStatus();
  }

  Future<void> _checkGuestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    if (userId == 'guest') {
      setState(() {
        _isGuest = true;
      });
    }
  }

  String _generateWhatsAppMessage(DiamondModel diamond) {
    final sb = StringBuffer();
    sb.writeln('💎 *Diamond Details - Stock No: ${diamond.stockId ?? "N/A"}* 💎');
    sb.writeln('===============================');
    sb.writeln('*${diamond.weight ?? "0.00"} ct ${diamond.shape ?? "Diamond"}*');
    sb.writeln();
    
    sb.writeln('*Key Characteristics:*');
    if (diamond.lab != null && diamond.lab!.trim().isNotEmpty) {
      sb.writeln('• *Lab:* ${diamond.lab}');
    }
    if (diamond.reportNo != null && diamond.reportNo!.trim().isNotEmpty) {
      sb.writeln('• *Report No:* ${diamond.reportNo}');
    }
    if ((diamond.color != null && diamond.color!.trim().isNotEmpty) || 
        (diamond.grade != null && diamond.grade!.trim().isNotEmpty)) {
      sb.writeln('• *Color/Clarity:* ${diamond.color ?? "-"} / ${diamond.grade ?? "-"}');
    }
    if ((diamond.cut != null && diamond.cut!.trim().isNotEmpty) || 
        (diamond.polish != null && diamond.polish!.trim().isNotEmpty) || 
        (diamond.symmetry != null && diamond.symmetry!.trim().isNotEmpty)) {
      sb.writeln('• *Cut/Pol/Sym:* ${diamond.cut ?? "-"} / ${diamond.polish ?? "-"} / ${diamond.symmetry ?? "-"}');
    }
    if (diamond.fluorescenceInt != null && diamond.fluorescenceInt!.trim().isNotEmpty) {
      sb.writeln('• *Fluorescence:* ${diamond.fluorescenceInt}');
    }
    if (diamond.measurements != null && diamond.measurements!.trim().isNotEmpty) {
      sb.writeln('• *Measurements:* ${diamond.measurements}');
    }
    sb.writeln();
    
    if (!_isGuest) {
      sb.writeln('*Pricing:*');
      if (diamond.rapnet != null && diamond.rapnet != '0' && diamond.rapnet!.trim().isNotEmpty) {
        sb.writeln('• *Rapnet Price:* \$${diamond.rapnet}');
      }
      if (diamond.newDiscount != null && diamond.newDiscount!.trim().isNotEmpty) {
        sb.writeln('• *Discount:* ${diamond.newDiscount}%');
      }
      if (diamond.totalPrice != null && diamond.totalPrice != '0' && diamond.totalPrice!.trim().isNotEmpty) {
        sb.writeln('• *Total Price:* \$${diamond.totalPrice}');
      }
      sb.writeln();
    }

    if ((diamond.diamondVideo != null && diamond.diamondVideo!.trim().isNotEmpty) ||
        (diamond.reportFilename != null && diamond.reportFilename!.trim().isNotEmpty) ||
        (diamond.diamondImage != null && diamond.diamondImage!.trim().isNotEmpty)) {
      sb.writeln('*Media & Documents:*');
      if (diamond.diamondVideo != null && diamond.diamondVideo!.trim().isNotEmpty) {
        sb.writeln('• 🎬 *360° Video:* ${diamond.diamondVideo}');
      }
      if (diamond.reportFilename != null && diamond.reportFilename!.trim().isNotEmpty) {
        sb.writeln('• 📄 *Certificate:* ${diamond.reportFilename}');
      }
      if (diamond.diamondImage != null && diamond.diamondImage!.trim().isNotEmpty) {
        sb.writeln('• 🖼️ *Image:* ${diamond.diamondImage}');
      }
      sb.writeln();
    }
    
    sb.write('Sent via YNY App');
    return sb.toString();
  }

  Future<void> _shareOnWhatsApp({String? phone, required String message}) async {
    final String encodedMessage = Uri.encodeComponent(message);
    final String? formattedPhone = phone != null && phone.trim().isNotEmpty
        ? phone.replaceAll(RegExp(r'\D'), '')
        : null;
        
    final String urlStr = formattedPhone != null
        ? 'https://wa.me/$formattedPhone?text=$encodedMessage'
        : 'https://wa.me/?text=$encodedMessage';
        
    final Uri url = Uri.parse(urlStr);
    
    try {
      final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw 'Could not launch WhatsApp url';
      }
    } catch (e) {
      try {
        final String fallbackUrlStr = formattedPhone != null
            ? 'whatsapp://send?phone=$formattedPhone&text=$encodedMessage'
            : 'whatsapp://send?text=$encodedMessage';
        await launchUrl(Uri.parse(fallbackUrlStr), mode: LaunchMode.externalApplication);
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open WhatsApp: $err'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final diamond = widget.diamond;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;
    final surfaceColor = isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final backgroundColor = isDark ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, wishlistState) {
        bool isWishlisted = false;
        String? wishlistId;
        if (wishlistState is WishlistLoaded) {
          try {
            final item = wishlistState.items.firstWhere((i) => i.stockId == diamond.stockId);
            isWishlisted = true;
            wishlistId = item.wishlistId;
          } catch (_) {}
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text(
              'Diamond Details',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () async {
                  if (_isGuest) {
                    DialogUtils.showLoginRequiredDialog(context);
                    return;
                  }
                  if (diamond.stockId == null) return;
                  
                  if (isWishlisted && wishlistId != null) {
                    context.read<WishlistCubit>().removeWishlist(wishlistId);
                  } else {
                    context.read<WishlistCubit>().addToWishlist(diamond.stockId!);
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(!isWishlisted 
                            ? 'Added ${diamond.weight ?? ""} ct ${diamond.shape ?? ""} to wishlist!'
                            : 'Removed from wishlist!'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: accentColor,
                      ),
                    );
                  }
                },
                icon: Icon(isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                color: accentColor,
              ),
          IconButton(
            icon: Icon(
              Icons.share_rounded,
              color: accentColor,
            ),
            tooltip: 'Share on WhatsApp',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => DiamondShareDialog(diamonds: [diamond]),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              context.read<ThemeBloc>().add(const ThemeToggleRequested());
            },
          ),
          const SizedBox(width: AppConstants.spaceSM),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Image Area
            if (diamond.diamondImage != null && diamond.diamondImage!.isNotEmpty && Uri.tryParse(diamond.diamondImage!)?.hasAbsolutePath == true)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppConstants.glassShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: diamond.diamondImage!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    memCacheWidth: 800,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                      child: Container(
                        height: 250,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 250,
                      color: isDark ? AppConstants.surfaceLightColor : AppConstants.lightSurfaceLightColor,
                      child: Icon(Icons.image_not_supported_rounded, color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted, size: 60),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 250,
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
                decoration: BoxDecoration(
                  color: isDark ? AppConstants.surfaceLightColor : AppConstants.lightSurfaceLightColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppConstants.glassShadow,
                ),
                child: Icon(Icons.diamond_outlined, size: 80, color: accentColor.withValues(alpha: 0.3)),
              ),

            // Video and Certificate Buttons (if available)
            if ((diamond.diamondVideo != null && diamond.diamondVideo!.isNotEmpty) ||
                (diamond.reportFilename != null && diamond.reportFilename!.isNotEmpty)) ...[
              const SizedBox(height: AppConstants.spaceMD),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
                child: Row(
                  children: [
                    if (diamond.diamondVideo != null && diamond.diamondVideo!.isNotEmpty)
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                          label: Text(
                            '360° Video',
                            style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          onPressed: () async {
                            final urlStr = diamond.diamondVideo!;
                            final Uri url = urlStr.startsWith('http') ? Uri.parse(urlStr) : Uri.parse('https://$urlStr');
                            
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Could not open video link'),
                                    backgroundColor: AppConstants.errorColor,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: surfaceColor,
                            foregroundColor: accentColor,
                            elevation: 0,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: accentColor.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (diamond.diamondVideo != null && diamond.diamondVideo!.isNotEmpty &&
                        diamond.reportFilename != null && diamond.reportFilename!.isNotEmpty)
                      const SizedBox(width: AppConstants.spaceMD),
                    if (diamond.reportFilename != null && diamond.reportFilename!.isNotEmpty)
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.card_membership_rounded, size: 20),
                          label: Text(
                            'Certificate',
                            style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          onPressed: () async {
                            final urlStr = diamond.reportFilename!;
                            final Uri url = urlStr.startsWith('http') ? Uri.parse(urlStr) : Uri.parse('https://$urlStr');
                            
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Could not open certificate link'),
                                    backgroundColor: AppConstants.errorColor,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: surfaceColor,
                            foregroundColor: accentColor,
                            elevation: 0,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: accentColor.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppConstants.spaceLG),

            // Title & Core Details Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
              padding: const EdgeInsets.all(AppConstants.spaceLG),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                boxShadow: AppConstants.glassShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${(double.tryParse(diamond.weight ?? "0") ?? 0.0).toStringAsFixed(2)} Carat ${diamond.shape ?? ""}',
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppConstants.surfaceLightColor : AppConstants.lightSurfaceLightColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                        ),
                        child: Text(
                          diamond.lab?.toString() ?? '',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceSM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock No: ${diamond.stockId ?? ""}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          if (diamond.locationDisplay.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? AppConstants.surfaceLightColor : AppConstants.lightSurfaceLightColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on_outlined, size: 12, color: accentColor),
                                  const SizedBox(width: 3),
                                  Text(
                                    diamond.locationDisplay,
                                    style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: diamond.availabilityDisplay.toLowerCase() == 'on memo'
                                  ? Colors.orange.withOpacity(0.15)
                                  : AppConstants.successColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: diamond.availabilityDisplay.toLowerCase() == 'on memo'
                                    ? Colors.orange
                                    : AppConstants.successColor,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              diamond.availabilityDisplay.toUpperCase(),
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: diamond.availabilityDisplay.toLowerCase() == 'on memo'
                                    ? Colors.orange
                                    : AppConstants.successColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Grading & Characteristics
            _buildSection(
              context: context,
              title: 'Grading & Characteristics',
              items: [
                {'label': 'Shape', 'value': diamond.shape ?? ''},
                {'label': 'Color', 'value': diamond.color ?? ''},
                {'label': 'Clarity', 'value': diamond.grade ?? ''},
                {'label': 'Cut', 'value': diamond.cut ?? ''},
                {'label': 'Polish', 'value': diamond.polish ?? ''},
                {'label': 'Symmetry', 'value': diamond.symmetry ?? ''},
                {'label': 'Fluorescence', 'value': diamond.fluorescenceInt ?? ''},
                {'label': 'Shade', 'value': diamond.shade ?? ''},
                {'label': 'Eye Clean', 'value': diamond.eyeClean ?? ''},
                {'label': 'Report No.', 'value': diamond.reportNo ?? ''},
              ],
              isDark: isDark,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),

            // Proportions & Measurements
            _buildSection(
              context: context,
              title: 'Measurements & Proportions',
              items: [
                {'label': 'Measurements', 'value': diamond.measurements ?? '', 'fullWidth': true},
                {'label': 'Ratio', 'value': (diamond.ratio != null && diamond.ratio != '0.00' && diamond.ratio != '0') ? diamond.ratio : ''},
                {'label': 'Depth %', 'value': (diamond.depth != null && diamond.depth != '0.00' && diamond.depth != '0' && diamond.depth!.isNotEmpty) ? '${diamond.depth}%' : ''},
                {'label': 'Table %', 'value': (diamond.tableD != null && diamond.tableD != '0.00' && diamond.tableD != '0' && diamond.tableD!.isNotEmpty) ? '${diamond.tableD}%' : ''},
                {'label': 'Crown Angle', 'value': (diamond.crownAngle != null && diamond.crownAngle != '0.00' && diamond.crownAngle != '0' && diamond.crownAngle!.isNotEmpty) ? '${diamond.crownAngle}°' : ''},
                {'label': 'Crown Height', 'value': (diamond.crownHt != null && diamond.crownHt != '0.00' && diamond.crownHt != '0' && diamond.crownHt!.isNotEmpty) ? '${diamond.crownHt}%' : ''},
                {'label': 'Pav. Angle', 'value': (diamond.pavillionAngle != null && diamond.pavillionAngle != '0.00' && diamond.pavillionAngle != '0' && diamond.pavillionAngle!.isNotEmpty) ? '${diamond.pavillionAngle}°' : ''},
                {'label': 'Pav. Depth', 'value': (diamond.pavillionDepth != null && diamond.pavillionDepth != '0.00' && diamond.pavillionDepth != '0' && diamond.pavillionDepth!.isNotEmpty) ? '${diamond.pavillionDepth}%' : ''},
                {'label': 'Culet', 'value': diamond.culet ?? ''},
                {'label': 'Length (mm)', 'value': diamond.mLength?.trim().isNotEmpty == true ? diamond.mLength!.trim() : (diamond.parsedLength != null ? diamond.parsedLength!.toStringAsFixed(2) : '')},
                {'label': 'Width (mm)', 'value': diamond.mWidth?.trim().isNotEmpty == true ? diamond.mWidth!.trim() : (diamond.parsedWidth != null ? diamond.parsedWidth!.toStringAsFixed(2) : '')},
              ],
              isDark: isDark,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),

            // Pricing Details
            _isGuest
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD, vertical: AppConstants.spaceSM),
                    padding: const EdgeInsets.all(AppConstants.spaceLG),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                      boxShadow: AppConstants.glassShadow,
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.lock_outline_rounded, color: accentColor, size: 40),
                        const SizedBox(height: AppConstants.spaceSM),
                        Text(
                          'Pricing details are hidden for guests',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Please login to view pricing, discount, and submit request.',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spaceMD),
                        ElevatedButton(
                          onPressed: () => DialogUtils.showLoginRequiredDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Login / Sign Up'),
                        ),
                      ],
                    ),
                  )
                : _buildSection(
                    context: context,
                    title: 'Pricing Details',
                    items: [
                      {'label': 'Rapnet (\$)', 'value': (diamond.rapnet != null && diamond.rapnet != '0' && diamond.rapnet!.isNotEmpty) ? PriceFormatter.formatRoundPrice(diamond.rapnet) : ''},
                      {'label': 'Discount', 'value': (diamond.newDiscount != null && diamond.newDiscount!.isNotEmpty) ? '${diamond.newDiscount}%' : ''},
                      {'label': '\$/Carat', 'value': (diamond.costCarat != null && diamond.costCarat != '0' && diamond.costCarat!.isNotEmpty) ? PriceFormatter.formatRoundPrice(diamond.costCarat) : ''},
                      {'label': 'Total Price', 'value': (diamond.totalPrice != null && diamond.totalPrice != '0' && diamond.totalPrice!.isNotEmpty) ? PriceFormatter.formatRoundPrice(diamond.totalPrice) : '', 'valueColor': AppConstants.successColor, 'isLarge': true},
                    ],
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textColor: textColor,
                  ),

            // Additional Information
            _buildSection(
              context: context,
              title: 'Additional Information',
              items: [
                {'label': 'Location', 'value': diamond.locationDisplay.isNotEmpty ? diamond.locationDisplay : (diamond.country ?? '')},
                {'label': 'Availability', 'value': diamond.availabilityDisplay},
                {'label': 'Key to Symbols', 'value': diamond.keytosymb ?? '', 'fullWidth': true},
              ],
              isDark: isDark,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),

            const SizedBox(height: 120), // padding for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(
            top: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => DiamondShareDialog(diamonds: [diamond]),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: surfaceColor,
                  foregroundColor: accentColor,
                  minimumSize: const Size(48, 48),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: accentColor.withValues(alpha: 0.5),
                    ),
                  ),
                  elevation: 0,
                ),
                child: const Icon(Icons.share_rounded, size: 24),
              ),
              const SizedBox(width: AppConstants.spaceMD),
              Expanded(
                child: BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    bool isAdded = false;
                    if (state is CartLoaded) {
                      isAdded = state.cartItems.any((item) => item.stockId == diamond.stockId);
                    }

                    if (isAdded) {
                      return ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_rounded, size: 20),
                        label: Text(
                          'ALREADY ADDED',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('This diamond is already in your cart!'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: AppConstants.successColor,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppConstants.surfaceLightColor : AppConstants.lightSurfaceLightColor,
                          foregroundColor: AppConstants.successColor,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: AppConstants.successColor.withValues(alpha: 0.5)),
                          ),
                          elevation: 0,
                        ),
                      );
                    }

                    return ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                      label: Text(
                        'ADD TO CART',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onPressed: () {
                        if (_isGuest) {
                          DialogUtils.showLoginRequiredDialog(context);
                          return;
                        }
                        context.read<DiamondBloc>().add(AddToCartEvent(
                          stock: diamond.stockId ?? "",
                        ));
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${diamond.weight ?? ""} ct ${diamond.shape ?? ""} to cart!'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: AppConstants.successColor,
                          ),
                        );
                        Navigator.pop(context); // Optional: close detail page after adding
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    },
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD + 4, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> items,
    required bool isDark,
    required Color surfaceColor,
    required Color textColor,
  }) {
    final validItems = items.where((item) {
      final val = item['value']?.toString() ?? '';
      return val.trim().isNotEmpty && val != '-' && val != '0' && val != '\$0' && val != '0%' && val != '0°';
    }).toList();

    if (validItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(title, textColor),
        _buildDetailCard(context, items, isDark, surfaceColor),
        const SizedBox(height: AppConstants.spaceLG),
      ],
    );
  }

  Widget _buildDetailCard(BuildContext context, List<Map<String, dynamic>> items, bool isDark, Color surfaceColor) {
    // Filter out empty items
    final validItems = items.where((item) {
      final val = item['value'].toString();
      return val.trim().isNotEmpty && val != '-' && val != '0' && val != '\$0' && val != '0%' && val != '0°';
    }).toList();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
        boxShadow: AppConstants.glassShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final halfWidth = (constraints.maxWidth - 16) / 2;
          
          List<Widget> rows = [];
          for (int i = 0; i < validItems.length; i++) {
            final item = validItems[i];
            final bool isFullWidth = item['fullWidth'] == true;
            
            if (isFullWidth) {
              rows.add(_buildGridItemWidget(item, constraints.maxWidth, isDark, context));
              rows.add(const SizedBox(height: 16));
            } else {
              // Try to pair with next item if next item is also not fullWidth
              if (i + 1 < validItems.length && validItems[i + 1]['fullWidth'] != true) {
                final nextItem = validItems[i + 1];
                rows.add(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGridItemWidget(item, halfWidth, isDark, context),
                      _buildGridItemWidget(nextItem, halfWidth, isDark, context),
                    ],
                  )
                );
                rows.add(const SizedBox(height: 16));
                i++; // skip next item since we placed it
              } else {
                // Standalone half-width item
                rows.add(_buildGridItemWidget(item, halfWidth, isDark, context));
                rows.add(const SizedBox(height: 16));
              }
            }
          }
          if (rows.isNotEmpty) rows.removeLast(); // Remove trailing SizedBox
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rows,
          );
        }
      ),
    );
  }

  Widget _buildGridItemWidget(Map<String, dynamic> item, double width, bool isDark, BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceLightColor.withValues(alpha: 0.5) : AppConstants.lightSurfaceLightColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['label'].toString().toUpperCase(),
            style: GoogleFonts.nunito(
              fontSize: 10,
              color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              item['value'].toString(),
              style: GoogleFonts.nunito(
                fontSize: item['isLarge'] == true ? 18 : 14,
                color: item['valueColor'] ?? Theme.of(context).colorScheme.onSurface,
                fontWeight: item['isLarge'] == true ? FontWeight.w900 : FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
