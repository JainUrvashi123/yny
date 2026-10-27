import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../data/models/wishlist_model.dart';

class WishlistCard extends StatelessWidget {
  final WishlistItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;
  final VoidCallback? onTap;
  final bool isInCart;
  final bool isLoading;

  const WishlistCard({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onAddToCart,
    this.onTap,
    this.isInCart = false,
    this.isLoading = false,
  }) : super(key: key);

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
                  child: CachedNetworkImage(
                    imageUrl: item.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(color: accentColor),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.diamond_outlined,
                      color: accentColor.withValues(alpha: 0.5),
                      size: 40,
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
                          item.name.toUpperCase(),
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
                        _buildDetailsSection(item.description, isDark, textColor, imageBgColor),
                        const SizedBox(height: AppConstants.spaceSM),
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
                                'Stock: ${item.stockId}',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                    PriceFormatter.formatRoundPrice(item.price),
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
                            GestureDetector(
                              onTap: onAddToCart,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isInCart 
                                    ? (isDark ? Colors.green.withValues(alpha: 0.2) : Colors.green.shade50) 
                                    : accentColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: isInCart ? Border.all(color: Colors.green) : null,
                                  boxShadow: isInCart ? [] : [
                                    BoxShadow(
                                      color: accentColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isLoading)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    else
                                      Icon(
                                        isInCart ? Icons.check_circle_rounded : Icons.shopping_cart_outlined,
                                        color: isInCart ? Colors.green : Colors.white,
                                        size: 16,
                                      ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isLoading ? 'ADDING...' : (isInCart ? 'ADDED' : 'ADD TO CART'),
                                      style: TextStyle(
                                        color: isInCart && !isLoading ? Colors.green : Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
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
            
            // Remove Button
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
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
    } else if (parts.length == 5) {
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
                _buildSpecItem('CARAT', parts[1].replaceAll('-weight', '').trim(), isDark, textColor),
                _buildSpecItem('COLOR', parts[3].replaceAll('-color', '').trim(), isDark, textColor),
                _buildSpecItem('CLARITY', parts[4].replaceAll('-clarity diamond', '').replaceAll('-clarity', '').trim(), isDark, textColor),
                _buildSpecItem('CUT', parts[2].replaceAll('-cut', '').trim(), isDark, textColor),
              ],
            ),
          ],
        ),
      );
    } else {
      return Text(
        description,
        style: TextStyle(
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
          style: TextStyle(
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
          style: TextStyle(
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
}

