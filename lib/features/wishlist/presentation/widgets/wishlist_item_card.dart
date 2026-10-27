import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../diamond/data/models/diamond_model.dart';

class WishlistItemCard extends StatelessWidget {
  final DiamondModel diamond;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const WishlistItemCard({
    super.key,
    required this.diamond,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final borderColor = isDark ? AppConstants.borderLight : AppConstants.lightBorderLight;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final mutedColor = isDark ? AppConstants.textMuted : AppConstants.lightTextMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spaceMD),
        padding: const EdgeInsets.all(AppConstants.spaceSM),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: AppConstants.glassShadow,
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppConstants.surfaceLightColor : AppConstants.lightSurfaceLightColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (diamond.diamondImage != null && diamond.diamondImage!.isNotEmpty && Uri.tryParse(diamond.diamondImage!)?.hasAbsolutePath == true)
                  ? Image.network(
                      diamond.diamondImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.favorite_border, color: mutedColor),
                    )
                  : Icon(Icons.favorite_border, color: mutedColor, size: 30),
            ),
          ),
          const SizedBox(width: AppConstants.spaceMD),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${diamond.weight ?? "0.0"} Carat ${diamond.shape ?? ""}',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppConstants.errorColor,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    )
                  ],
                ),
                const SizedBox(height: AppConstants.spaceXS),
                Text(
                  'Color: ${diamond.color ?? "-"} | Clarity: ${diamond.grade ?? "-"}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceSM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stock: ${diamond.stockId ?? "-"}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: mutedColor,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            PriceFormatter.formatRoundPrice(diamond.totalPrice),
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
