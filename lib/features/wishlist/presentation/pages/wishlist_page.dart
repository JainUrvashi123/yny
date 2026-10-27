import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../bloc/wishlist_cubit.dart';
import '../widgets/wishlist_card.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/bloc/theme_bloc.dart';
import '../../data/datasources/wishlist_remote_datasource.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../diamond/presentation/bloc/diamond_bloc.dart';
import '../../../diamond/presentation/bloc/diamond_event.dart';
import '../../../diamond/data/models/diamond_model.dart';
import '../../../diamond/presentation/pages/diamond_detail_page.dart';
import 'package:shimmer/shimmer.dart';
class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final Set<String> _optimisticallyAdded = {};
  final Set<String> _loadingItems = {};

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final backgroundColor = isDark ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor;
          final surfaceColor = isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
          final textColor = Theme.of(context).colorScheme.onSurface;
          final textMuted = isDark ? AppConstants.textMuted : AppConstants.lightTextMuted;
          final textSecondary = isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary;

          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'My Wishlist',
                style: GoogleFonts.nunito(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              iconTheme: IconThemeData(color: textColor),
              actions: [
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: textColor,
                  ),
                  onPressed: () {
                    context.read<ThemeBloc>().add(const ThemeToggleRequested());
                  },
                ),
                const SizedBox(width: AppConstants.spaceSM),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    backgroundColor,
                    surfaceColor,
                  ],
                ),
              ),
              child: BlocBuilder<WishlistCubit, WishlistState>(
                builder: (context, state) {
                  if (state is WishlistLoading) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.spaceMD),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppConstants.spaceMD),
                          height: 150,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight, width: 1),
                          ),
                          child: Shimmer.fromColors(
                            baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is WishlistError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: AppConstants.errorColor, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: TextStyle(color: textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<WishlistCubit>().fetchWishlist(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is WishlistLoaded) {
                    if (state.items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 80,
                              color: textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: AppConstants.spaceLG),
                            Text(
                              'Your Wishlist is Empty',
                              style: GoogleFonts.nunito(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spaceSM),
                            Text(
                              'Save items you love to view them later.',
                              style: GoogleFonts.nunito(
                                color: textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return BlocBuilder<CartBloc, CartState>(
                      builder: (context, cartState) {
                        final cartItems = cartState is CartLoaded ? cartState.cartItems : [];
                        return ListView.builder(
                          padding: const EdgeInsets.all(AppConstants.spaceMD),
                          physics: const BouncingScrollPhysics(),
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            final isInCart = cartItems.any((c) => c.stockId == item.stockId) || _optimisticallyAdded.contains(item.stockId);
                            final isLoading = _loadingItems.contains(item.stockId);
                            
                            return WishlistCard(
                              item: item,
                              onTap: () async {
                                if (_loadingItems.contains(item.stockId)) return;
                                
                                setState(() {
                                  _loadingItems.add(item.stockId);
                                });
                                
                                try {
                                  final repo = context.read<DiamondBloc>().repository;
                                  final response = await repo.getDiamondList(stock: item.stockId);
                                  
                                  if (mounted) {
                                    setState(() {
                                      _loadingItems.remove(item.stockId);
                                    });
                                    
                                    if (response.data.isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DiamondDetailPage(diamond: response.data.first),
                                        ),
                                      );
                                      return;
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() {
                                      _loadingItems.remove(item.stockId);
                                    });
                                  }
                                }
                                
                                if (!mounted) return;
                                
                                final desc = item.description;
                                final parts = desc.split(',').map((e) => e.trim()).toList();
                                DiamondModel diamond;
                                
                                if (parts.length >= 13) {
                                  diamond = DiamondModel(
                                    diamondId: item.diamondId,
                                    stockId: item.stockId,
                                    shape: parts[0],
                                    cut: parts[1],
                                    color: parts[2],
                                    grade: parts[3],
                                    weight: parts[4],
                                    polish: parts[5],
                                    symmetry: parts[6],
                                    fluorescenceInt: parts[7],
                                    ratio: parts[8],
                                    measurements: parts[9],
                                    depth: parts[10],
                                    tableD: parts[11],
                                    lab: parts[12],
                                    totalPrice: item.price,
                                    diamondImage: item.image,
                                    diamondVideo: item.diamondVideo,
                                    reportFilename: item.reportFilename,
                                    reportNo: item.reportNo,
                                    availability: item.availability,
                                    rapnet: item.rapnet,
                                    costCarat: item.costCarat,
                                    eyeClean: item.eyeClean,
                                    keytosymb: item.keytosymb,
                                    country: item.country,
                                  );
                                } else if (parts.length == 12) {
                                  diamond = DiamondModel(
                                    diamondId: item.diamondId,
                                    stockId: item.stockId,
                                    shape: parts[0],
                                    cut: parts[1],
                                    color: parts[2],
                                    grade: parts[3],
                                    weight: parts[4],
                                    polish: parts[5],
                                    symmetry: parts[6],
                                    fluorescenceInt: parts[7],
                                    ratio: parts[8],
                                    measurements: parts[9],
                                    depth: parts[10],
                                    tableD: parts[11],
                                    totalPrice: item.price,
                                    diamondImage: item.image,
                                    diamondVideo: item.diamondVideo,
                                    reportFilename: item.reportFilename,
                                    reportNo: item.reportNo,
                                    availability: item.availability,
                                    rapnet: item.rapnet,
                                    costCarat: item.costCarat,
                                    eyeClean: item.eyeClean,
                                    keytosymb: item.keytosymb,
                                    country: item.country,
                                  );
                                } else if (parts.length == 5) {
                                   diamond = DiamondModel(
                                     diamondId: item.diamondId,
                                     stockId: item.stockId,
                                     shape: parts[0],
                                     cut: parts[2].replaceAll('-cut', '').trim(),
                                     color: parts[3].replaceAll('-color', '').trim(),
                                     grade: parts[4].replaceAll('-clarity diamond', '').replaceAll('-clarity', '').trim(),
                                     weight: parts[1].replaceAll('-weight', '').trim(),
                                     totalPrice: item.price,
                                     diamondImage: item.image,
                                     diamondVideo: item.diamondVideo,
                                     reportFilename: item.reportFilename,
                                     reportNo: item.reportNo,
                                     availability: item.availability,
                                     rapnet: item.rapnet,
                                     costCarat: item.costCarat,
                                     eyeClean: item.eyeClean,
                                     keytosymb: item.keytosymb,
                                     country: item.country,
                                   );
                                 } else {
                                  diamond = DiamondModel(
                                    diamondId: item.diamondId,
                                    stockId: item.stockId,
                                    totalPrice: item.price,
                                    diamondImage: item.image,
                                    diamondVideo: item.diamondVideo,
                                    reportFilename: item.reportFilename,
                                    reportNo: item.reportNo,
                                    availability: item.availability,
                                    rapnet: item.rapnet,
                                    costCarat: item.costCarat,
                                    eyeClean: item.eyeClean,
                                    keytosymb: item.keytosymb,
                                    country: item.country,
                                  );
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DiamondDetailPage(diamond: diamond),
                                  ),
                                );
                              },
                              isInCart: isInCart,
                              isLoading: isLoading,
                              onRemove: () {
                                context.read<WishlistCubit>().removeWishlist(item.wishlistId);
                              },
                              onAddToCart: () async {
                                if (isInCart) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Item is already in cart'),
                                      backgroundColor: AppConstants.warningColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                
                                setState(() {
                                  _loadingItems.add(item.stockId);
                                });
                                
                                final repo = context.read<DiamondBloc>().repository;
                                await repo.addToCart(stock: item.stockId);
                                
                                if (mounted) {
                                  setState(() {
                                    _loadingItems.remove(item.stockId);
                                    _optimisticallyAdded.add(item.stockId);
                                  });
                                  
                                  context.read<CartBloc>().add(FetchCart());
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${item.name} added to cart!'),
                                      backgroundColor: AppConstants.successColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          );
        }
      );
  }
}
