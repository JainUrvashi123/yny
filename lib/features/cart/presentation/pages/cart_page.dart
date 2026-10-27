import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/bloc/theme_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/price_formatter.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_card.dart';
import '../../../../features/diamond/data/models/diamond_model.dart';
import '../../../../features/diamond/presentation/pages/diamond_detail_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Set<String> _selectedCartIds = {};
  final TextEditingController _emailNameController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _emailMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(FetchCart());
  }

  @override
  void dispose() {
    _emailNameController.dispose();
    _emailAddressController.dispose();
    _emailMessageController.dispose();
    super.dispose();
  }

  void _removeItem(String cartId) {
    context.read<CartBloc>().add(RemoveFromCart(cartId: cartId));
  }

  void _updateQuantity(String cartId, int newQty) {
    context.read<CartBloc>().add(UpdateCartQuantity(cartId: cartId, quantity: newQty));
  }

  double _calculateTotal(CartLoaded state) {
    double total = 0;
    for (var item in state.cartItems) {
      if (_selectedCartIds.contains(item.cartId)) {
        total += double.tryParse(item.totalPrice ?? "0") ?? 0;
      }
    }
    return total;
  }

  Future<void> _submitOrder(String name, String email, String message) async {
    final repo = context.read<CartBloc>().repository;
    bool success = await repo.sendOrder(_selectedCartIds.toList(), name: name, email: email, message: message);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order sent successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        setState(() {
          _selectedCartIds.clear();
          _emailNameController.clear();
          _emailAddressController.clear();
          _emailMessageController.clear();
        });
        context.read<CartBloc>().add(FetchCart());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send order. Please try again.'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _showSendEmailDialog() {
    if (_selectedCartIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one item to proceed.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final nameController = _emailNameController;
        final emailController = _emailAddressController;
        final messageController = _emailMessageController;
        bool isSubmitting = false;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = Theme.of(context).colorScheme.onSurface;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              titlePadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.all(24.0),
              backgroundColor: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                ),
              ),
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                decoration: BoxDecoration(
                  color: isDark ? AppConstants.surfaceLightColor : const Color(0xFF0F3F70).withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Send Email',
                      style: GoogleFonts.nunito(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, color: textColor.withOpacity(0.6), size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You have selected diamond(s). Your recipient will receive the details of your selected diamond(s).',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          color: isDark ? AppConstants.accentColorDark : const Color(0xFF0F3F70),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: isDark ? AppConstants.borderLight : const Color(0xFFB0C4DE)),
                      const SizedBox(height: 16),
                      Text(
                        'Name',
                        style: GoogleFonts.nunito(
                          color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        style: GoogleFonts.nunito(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Name',
                          hintStyle: GoogleFonts.nunito(color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted, fontSize: 14),
                          filled: true,
                          fillColor: isDark ? AppConstants.surfaceLightColor : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? AppConstants.accentColorDark : const Color(0xFF0F3F70), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Email',
                        style: GoogleFonts.nunito(
                          color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.nunito(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: GoogleFonts.nunito(color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted, fontSize: 14),
                          filled: true,
                          fillColor: isDark ? AppConstants.surfaceLightColor : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? AppConstants.accentColorDark : const Color(0xFF0F3F70), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Message',
                        style: GoogleFonts.nunito(
                          color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: messageController,
                        maxLines: 4,
                        style: GoogleFonts.nunito(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Type your message here...',
                          hintStyle: GoogleFonts.nunito(color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted, fontSize: 14),
                          filled: true,
                          fillColor: isDark ? AppConstants.surfaceLightColor : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? AppConstants.accentColorDark : const Color(0xFF0F3F70), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    setStateDialog(() => isSubmitting = true);
                                    await _submitOrder(nameController.text, emailController.text, messageController.text);
                                    if (mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppConstants.accentColorDark : const Color(0xFF0F3F70),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(
                                    'Send Details',
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
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
          },
        );
      },
    );
  }

  void _confirmClearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppConstants.surfaceColor
            : AppConstants.lightSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppConstants.borderLight
                : AppConstants.lightBorderLight,
          ),
        ),
        title: Text(
          'Clear Cart',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.nunito(color: AppConstants.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(ClearCart());
              Navigator.pop(ctx);
            },
            child: Text(
              'CLEAR ALL',
              style: GoogleFonts.nunito(color: AppConstants.errorColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppConstants.surfaceColor
            : AppConstants.lightSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppConstants.borderLight
                : AppConstants.lightBorderLight,
          ),
        ),
        title: Text(
          'Delete Selected',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove the selected items from your cart?',
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.nunito(color: AppConstants.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(RemoveSelectedFromCart(cartIds: _selectedCartIds.toList()));
              setState(() {
                _selectedCartIds.clear();
              });
              Navigator.pop(ctx);
            },
            child: Text(
              'DELETE',
              style: GoogleFonts.nunito(color: AppConstants.errorColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor;
    final surfaceColor = isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cartItems.isNotEmpty) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedCartIds.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, color: AppConstants.errorColor),
                        tooltip: 'Delete Selected',
                        onPressed: () => _confirmDeleteSelected(context),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, color: AppConstants.errorColor),
                      tooltip: 'Clear Cart',
                      onPressed: () => _confirmClearCart(context),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
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
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
          if (state is CartLoading) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          } else if (state is CartError) {
            return Center(child: Text(state.message, style: TextStyle(color: AppConstants.errorColor)));
          } else if (state is CartLoaded) {
            final cartItems = state.cartItems;
            
            if (cartItems.isEmpty) {
              return _buildEmptyCart(isDark);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CartBloc>().add(FetchCart());
              },
              color: accentColor,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.only(
                  left: AppConstants.spaceMD,
                  right: AppConstants.spaceMD,
                  top: AppConstants.spaceSM,
                  bottom: AppConstants.spaceLG, 
                ),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  final itemId = item.cartId ?? '';
                  return CartItemCard(
                    cartItem: item,
                    isChecked: _selectedCartIds.contains(itemId),
                    onCheckedChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedCartIds.add(itemId);
                        } else {
                          _selectedCartIds.remove(itemId);
                        }
                      });
                    },
                    isUpdating: state is CartLoaded && state.isUpdating && state.updatingCartId == item.cartId,
                    onRemove: () => _removeItem(itemId),
                    onUpdateQuantity: (qty) => _updateQuantity(itemId, qty),
                    onTap: () {
                      final desc = item.description ?? '';
                      final parts = desc.split(',').map((e) => e.trim()).toList();
                      DiamondModel diamond;
                      
                      if (parts.length >= 13) {
                        diamond = DiamondModel(
                          diamondId: item.productId ?? '',
                          stockId: item.stockId ?? '',
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
                          diamondId: item.productId ?? '',
                          stockId: item.stockId ?? '',
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
                      } else {
                        diamond = DiamondModel(
                          diamondId: item.productId ?? '',
                          stockId: item.stockId ?? '',
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
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded && state.cartItems.isNotEmpty) {
            final total = _calculateTotal(state);
            if (total > 0) {
              return _buildBottomCheckoutBar(context, surfaceColor, isDark, textColor, total);
            }
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyCart(bool isDark) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final textMuted = isDark ? AppConstants.textMuted : AppConstants.lightTextMuted;
    final textSecondary = isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary;
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spaceLG),
          Text(
            'Your Cart is Empty',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSM),
          Text(
            'Add some brilliant diamonds to get started.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceLG),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Continue Shopping',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar(BuildContext context, Color surfaceColor, bool isDark, Color textColor, double totalCartPrice) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          top: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total estimated price',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        PriceFormatter.formatRoundPrice(totalCartPrice),
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMD),
            ElevatedButton(
              onPressed: _showSendEmailDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: AppConstants.accentGlowColor,
              ),
              child: Text(
                      'PROCEED TO CHECKOUT',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}




