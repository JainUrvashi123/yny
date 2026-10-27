import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../data/models/cart_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartItemCard extends StatelessWidget {
  final CartModel cartItem;
  final VoidCallback onRemove;
  final ValueChanged<int>? onUpdateQuantity;
  final VoidCallback? onTap;
  final bool isUpdating;
  final bool isChecked;
  final ValueChanged<bool?>? onCheckedChanged;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onRemove,
    this.onUpdateQuantity,
    this.onTap,
    this.isUpdating = false,
    this.isChecked = false,
    this.onCheckedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppConstants.surfaceLightColor : AppConstants.lightSurfaceLightColor;
    final imageBgColor = isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final borderColor = isDark ? AppConstants.borderLight : AppConstants.lightBorderLight;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final accentColor = Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spaceMD),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: AppConstants.glassShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Section
                    Container(
                      width: 120,
                      decoration: BoxDecoration(
                        color: imageBgColor,
                      ),
                      child: ClipRRect(
                        child: (cartItem.image != null && cartItem.image!.isNotEmpty && Uri.tryParse(cartItem.image!)?.hasAbsolutePath == true)
                            ? CachedNetworkImage(
                                imageUrl: cartItem.image!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(color: accentColor),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.diamond_outlined,
                                  color: accentColor.withValues(alpha: 0.5),
                                  size: 40,
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.diamond_outlined,
                                  color: accentColor.withValues(alpha: 0.5),
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                    
                    // Details Section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spaceMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (cartItem.name ?? "Premium Diamond").toUpperCase(),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppConstants.spaceXS),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    'Stock: ${cartItem.stockId ?? "-"}',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spaceSM),
                            _buildDetailsSection(cartItem.description, isDark, textColor, imageBgColor),
                            const SizedBox(height: AppConstants.spaceMD),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        PriceFormatter.formatRoundPrice(cartItem.totalPrice),
                                        style: GoogleFonts.nunito(
                                          color: AppConstants.successColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildQtyButton(
                                        icon: Icons.remove_rounded,
                                        onPressed: isUpdating ? null : () {
                                          int currentQty = int.tryParse(cartItem.quantity ?? '1') ?? 1;
                                          if (currentQty > 1 && onUpdateQuantity != null) {
                                            onUpdateQuantity!(currentQty - 1);
                                          }
                                        },
                                        color: textColor,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: isUpdating 
                                          ? SizedBox(
                                              width: 10, 
                                              height: 10, 
                                              child: CircularProgressIndicator(strokeWidth: 1.5, color: accentColor),
                                            )
                                          : Text(
                                              cartItem.quantity ?? "1",
                                              style: GoogleFonts.nunito(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: textColor,
                                              ),
                                            ),
                                      ),
                                      _buildQtyButton(
                                        icon: Icons.add_rounded,
                                        onPressed: isUpdating ? null : () {
                                          int currentQty = int.tryParse(cartItem.quantity ?? '1') ?? 1;
                                          if (onUpdateQuantity != null) {
                                            onUpdateQuantity!(currentQty + 1);
                                          }
                                        },
                                        color: textColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Custom Circular Checkbox Overlay on top-left of image card
              if (onCheckedChanged != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () {
                      if (onCheckedChanged != null) {
                        onCheckedChanged!(!isChecked);
                      }
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isChecked ? accentColor : Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isChecked ? Colors.transparent : Colors.white.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                      ),
                      child: isChecked
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),

              // Floating close button removed from top-right
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(String? description, bool isDark, Color textColor, Color imageBgColor) {
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    final parts = description.split(',').map((e) => e.trim()).toList();

    if (parts.length >= 13) {
      // parts: 0:Shape, 1:Cut, 2:Color, 3:Clarity, 4:Cts, 5:Pol, 6:Sym, 7:Flr, 8:Ratio, 9:Meas, 10:Depth, 11:Table, 12:Lab
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: imageBgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSpecItem('CARAT', parts[4], isDark, textColor),
                _buildSpecItem('COLOR', parts[2], isDark, textColor),
                _buildSpecItem('CLARITY', parts[3], isDark, textColor),
                _buildSpecItem('CUT', parts[1], isDark, textColor),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSpecItem('POL', parts[5], isDark, textColor),
                _buildSpecItem('SYM', parts[6], isDark, textColor),
                _buildSpecItem('FLOUR', parts[7], isDark, textColor),
                _buildSpecItem('LAB', parts[12], isDark, textColor),
              ],
            ),
          ],
        ),
      );
    } else {
      return Text(
        description,
        style: GoogleFonts.nunito(
          fontSize: 12,
          color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
          height: 1.4,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildSpecItem(String label, String value, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor.withOpacity(0.9),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback? onPressed, required Color color}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Icon(
          icon, 
          size: 14, 
          color: onPressed == null ? color.withOpacity(0.2) : color.withOpacity(0.6),
        ),
      ),
    );
  }
}
