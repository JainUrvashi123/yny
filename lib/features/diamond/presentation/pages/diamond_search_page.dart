import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../widgets/diamond_share_dialog.dart';
import '../../../../core/bloc/theme_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../wishlist/presentation/pages/wishlist_page.dart';
import '../../../../features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import '../../../../features/wishlist/presentation/bloc/wishlist_cubit.dart';
import '../../data/models/diamond_model.dart';
import '../../../dashboard/presentation/widgets/app_drawer.dart';
import '../bloc/diamond_bloc.dart';
import '../bloc/diamond_event.dart';
import '../bloc/diamond_state.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'diamond_detail_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../../core/services/inventory_sync_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DiamondSearchPage extends StatefulWidget {
  final int currentCartCount;
  final ValueChanged<int> onCartUpdated;
  final String userId;
  final String userName;
  final String userEmail;

  const DiamondSearchPage({
    super.key,
    required this.currentCartCount,
    required this.onCartUpdated,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<DiamondSearchPage> createState() => _DiamondSearchPageState();
}

class _DiamondSearchPageState extends State<DiamondSearchPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // State variables for filter values
  bool _isAdvanceExpanded = false;
  int _currentFilteredCount = 0;
  Timer? _debounce;
  bool _isGridView = false;
  final Set<DiamondModel> _selectedDiamonds = {};
  
  final List<String> _selectedShapes = [];

  // Controllers for basic ranges (Carat & Price From/To)
  final TextEditingController _caratFromController = TextEditingController(text: '0.10');
  final TextEditingController _caratToController = TextEditingController(text: '10.00');
  final TextEditingController _priceFromController = TextEditingController(text: '0');
  final TextEditingController _priceToController = TextEditingController(text: '100000');

  // Controllers for advanced filters (Depth %, Table %, Cert No)
  final TextEditingController _depthMinController = TextEditingController();
  final TextEditingController _depthMaxController = TextEditingController();
  final TextEditingController _tableMinController = TextEditingController();
  final TextEditingController _tableMaxController = TextEditingController();
  final TextEditingController _stockNoController = TextEditingController();
  
  final TextEditingController _ratioFromController = TextEditingController();
  final TextEditingController _ratioToController = TextEditingController();
  final TextEditingController _crAngleFromController = TextEditingController();
  final TextEditingController _crAngleToController = TextEditingController();
  final TextEditingController _crHeightFromController = TextEditingController();
  final TextEditingController _crHeightToController = TextEditingController();
  final TextEditingController _pavAngleFromController = TextEditingController();
  final TextEditingController _pavAngleToController = TextEditingController();
  final TextEditingController _pavHeightFromController = TextEditingController();
  final TextEditingController _pavHeightToController = TextEditingController();
  final TextEditingController _girdleFromController = TextEditingController();
  final TextEditingController _girdleToController = TextEditingController();
  final TextEditingController _starLengthFromController = TextEditingController();
  final TextEditingController _starLengthToController = TextEditingController();
  final TextEditingController _lengthFromController = TextEditingController();
  final TextEditingController _lengthToController = TextEditingController();
  final TextEditingController _widthFromController = TextEditingController();
  final TextEditingController _widthToController = TextEditingController();

  // Hourly sync state
  Timer? _hourlySyncTimer;
  StreamSubscription? _hourlySyncSub;
  String _lastSyncFormatted = 'Syncing...';

  // Multi-select Lists for basic specifications
  final List<String> _selectedColors = [];
  final List<String> _selectedFancyColors = [];
  final List<String> _selectedClarities = [];
  final List<String> _selectedCuts = [];
  final List<String> _selectedPolishes = [];
  final List<String> _selectedSymmetries = [];
  final List<String> _selectedLabs = [];
  final List<String> _selectedFluorescences = [];
  final List<String> _selectedMakes = [];
  final List<String> _selectedCulets = [];
  // final List<String> _selectedAvailable = [];


  // State cart counter
  late int _localCartCount;

  // Filter lists matching the user's desktop dashboard catalog screenshot exactly
  final List<String> _shapes = [
    'Round', 'Princess', 'Cushion', 'Emerald', 'Oval', 
    'Radiant', 'Asscher', 'Marquise', 'Heart', 'Pear', 
    'briolette', 'lozenge', 'octagonal', 'pentagonal', 'rose', 
    'shield', 'sqrad', 'square', 'tapbag', 'triangular', 'Other'
  ];
  final List<String> _colors = ['D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M-', 'FANCY'];
  final List<String> _fancyColors = ['blue', 'green', 'yellow', 'pink', 'purple', 'red', 'orange', 'black', 'brown'];
  final List<String> _clarities = ['FL', 'IF', 'VVS1', 'VVS2', 'VS1', 'VS2', 'SI1', 'SI2', 'I1-'];
  final List<String> _cuts = ['BX', 'I', 'EX', 'VG', 'G', 'F'];
  final List<String> _polishes = ['EX', 'VG', 'G', 'F'];
  final List<String> _symmetries = ['EX', 'VG', 'G', 'F'];
  final List<String> _labs = ['IGI', 'GIA', 'AGS'];
  final List<String> _fluorescences = ['None', 'Faint', 'Medium', 'Strong', 'Very Strong'];
  final List<String> _makes = ['3EX', '3VG+', '3EX-NONE'];
  final List<String> _culets = ['N', 'VSM', 'SML', 'MED', 'LARGE'];

  // Lists for advanced dropdown values
  final List<String> _yesNoOptions = ['All', 'Yes', 'No'];
  final List<String> _shades = ['All', 'White', 'Brown', 'Yellow', 'Other'];
  final List<String> _milkOptions = ['All', 'None', 'M0', 'M1', 'M2', 'M3'];
  final List<String> _lusterOptions = ['All', 'Excellent', 'Very Good', 'Good'];
  final List<String> _bgmOptions = ['All', 'None', 'Brown', 'Green', 'Milky'];
  final List<String> _inclusions = ['All', 'None', 'Center', 'Edge'];
  final List<String> _locations = ['All', 'India', 'USA', 'Belgium', 'Israel'];

  @override
  void initState() {
    super.initState();
    _localCartCount = widget.currentCartCount;
    _initHourlySync();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
      context.read<CartBloc>().add(FetchCart()); // Fetch cart to get accurate total quantity
    });
  }

  void _initHourlySync() async {
    final formatted = await InventorySyncService().getLastRefreshFormatted();
    if (mounted) {
      setState(() {
        _lastSyncFormatted = formatted;
      });
    }

    // Check periodically every minute if >= 1 hour has elapsed since last refresh
    _hourlySyncTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final isNeeded = await InventorySyncService().isHourlyRefreshNeeded();
      if (isNeeded && mounted) {
        _applyFilters();
      }
    });

    // Listen to background broadcast triggers
    _hourlySyncSub = InventorySyncService().onHourlySyncTriggered.listen((_) {
      if (mounted) {
        _applyFilters();
      }
    });
  }

  void _onDataLoaded() async {
    await InventorySyncService().recordRefresh();
    final formatted = await InventorySyncService().getLastRefreshFormatted();
    if (mounted) {
      setState(() {
        _lastSyncFormatted = formatted;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _hourlySyncTimer?.cancel();
    _hourlySyncSub?.cancel();
    _caratFromController.dispose();
    _caratToController.dispose();
    _priceFromController.dispose();
    _priceToController.dispose();
    _depthMinController.dispose();
    _depthMaxController.dispose();
    _tableMinController.dispose();
    _tableMaxController.dispose();
    _stockNoController.dispose();
    _ratioFromController.dispose();
    _ratioToController.dispose();
    _crAngleFromController.dispose();
    _crAngleToController.dispose();
    _crHeightFromController.dispose();
    _crHeightToController.dispose();
    _pavAngleFromController.dispose();
    _pavAngleToController.dispose();
    _pavHeightFromController.dispose();
    _pavHeightToController.dispose();
    _girdleFromController.dispose();
    _girdleToController.dispose();
    _starLengthFromController.dispose();
    _starLengthToController.dispose();
    _lengthFromController.dispose();
    _lengthToController.dispose();
    _widthFromController.dispose();
    _widthToController.dispose();
    super.dispose();
  }


  void _addToCart(DiamondModel diamond) {
    context.read<DiamondBloc>().add(AddToCartEvent(
      stock: diamond.stockId ?? "",
    ));

    setState(() {
      _localCartCount++; // Optimistic local update
    });
    widget.onCartUpdated(_localCartCount);
    
    // Fetch actual cart to sync total quantity
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        context.read<CartBloc>().add(FetchCart());
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${diamond.weight ?? ""} ct ${diamond.shape ?? ""} to cart!'),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _hasActiveFilters() {
    final hasCaratFilter = (_caratFromController.text.isNotEmpty && _caratFromController.text != '0.10' && _caratFromController.text != '0') ||
        (_caratToController.text.isNotEmpty && _caratToController.text != '10.00' && _caratToController.text != '10');
    final hasPriceFilter = (_priceFromController.text.isNotEmpty && _priceFromController.text != '0') ||
        (_priceToController.text.isNotEmpty && _priceToController.text != '100000');

    return _stockNoController.text.isNotEmpty ||
        _selectedShapes.isNotEmpty ||
        _selectedColors.isNotEmpty ||
        _selectedFancyColors.isNotEmpty ||
        _selectedClarities.isNotEmpty ||
        _selectedCuts.isNotEmpty ||
        _selectedPolishes.isNotEmpty ||
        _selectedSymmetries.isNotEmpty ||
        _selectedLabs.isNotEmpty ||
        _selectedFluorescences.isNotEmpty ||
        _selectedMakes.isNotEmpty ||
        _selectedCulets.isNotEmpty ||
        hasCaratFilter ||
        hasPriceFilter ||
        _ratioFromController.text.isNotEmpty ||
        _ratioToController.text.isNotEmpty ||
        _depthMinController.text.isNotEmpty ||
        _depthMaxController.text.isNotEmpty ||
        _tableMinController.text.isNotEmpty ||
        _tableMaxController.text.isNotEmpty ||
        _crAngleFromController.text.isNotEmpty ||
        _crAngleToController.text.isNotEmpty ||
        _crHeightFromController.text.isNotEmpty ||
        _crHeightToController.text.isNotEmpty ||
        _pavAngleFromController.text.isNotEmpty ||
        _pavAngleToController.text.isNotEmpty ||
        _pavHeightFromController.text.isNotEmpty ||
        _pavHeightToController.text.isNotEmpty ||
        _girdleFromController.text.isNotEmpty ||
        _girdleToController.text.isNotEmpty ||
        _starLengthFromController.text.isNotEmpty ||
        _starLengthToController.text.isNotEmpty ||
        _lengthFromController.text.isNotEmpty ||
        _lengthToController.text.isNotEmpty ||
        _widthFromController.text.isNotEmpty ||
        _widthToController.text.isNotEmpty;
  }

  String _getShapeAsset(String shape) {
    final lower = shape.toLowerCase();
    switch (lower) {
      case 'asscher':
      case 'cushion':
      case 'emerald':
      case 'heart':
      case 'marquise':
      case 'other':
      case 'oval':
      case 'pear':
      case 'princess':
      case 'radiant':
      case 'round':
        return 'assets/images/$lower-grey.png';
      default:
        return 'assets/images/$lower.png';
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedShapes.clear();
      _caratFromController.text = '0.10';
      _caratToController.text = '10.00';
      _priceFromController.text = '0';
      _priceToController.text = '100000';
      _selectedColors.clear();
      _selectedClarities.clear();
      _selectedCuts.clear();
      _selectedPolishes.clear();
      _selectedSymmetries.clear();
      _selectedLabs.clear();
      _selectedFluorescences.clear();
      _selectedMakes.clear();
      _selectedCulets.clear();
      // _selectedAvailable.clear();

      // Advanced resets
      _depthMinController.clear();
      _depthMaxController.clear();
      _tableMinController.clear();
      _tableMaxController.clear();
      _stockNoController.clear();
      _ratioFromController.clear();
      _ratioToController.clear();
      _crAngleFromController.clear();
      _crAngleToController.clear();
      _crHeightFromController.clear();
      _crHeightToController.clear();
      _pavAngleFromController.clear();
      _pavAngleToController.clear();
      _pavHeightFromController.clear();
      _pavHeightToController.clear();
      _girdleFromController.clear();
      _girdleToController.clear();
      _starLengthFromController.clear();
      _starLengthToController.clear();
      _lengthFromController.clear();
      _lengthToController.clear();
      _widthFromController.clear();
      _widthToController.clear();
    });
    _applyFilters();
  }

  void _applyFilters() {
    context.read<DiamondBloc>().add(FetchDiamonds(
      isRefresh: true,
      stock: _stockNoController.text,
      shapes: _selectedShapes.isEmpty ? null : _selectedShapes.map((s) => s.toUpperCase()).toList(),
      colors: _selectedColors,
      fancyColors: _selectedFancyColors,
      clarities: _selectedClarities,
      cuts: _selectedCuts,
      polishes: _selectedPolishes,
      symmetries: _selectedSymmetries,
      labs: _selectedLabs,
      fluorescences: _selectedFluorescences,
      makes: _selectedMakes,
      culets: _selectedCulets,
      // available: _selectedAvailable,
      caratFrom: _caratFromController.text,
      caratTo: _caratToController.text,
      priceFrom: _priceFromController.text,
      priceTo: _priceToController.text,
      ratioFrom: _ratioFromController.text,
      ratioTo: _ratioToController.text,
      depthFrom: _depthMinController.text,
      depthTo: _depthMaxController.text,
      tableFrom: _tableMinController.text,
      tableTo: _tableMaxController.text,
      crAngleFrom: _crAngleFromController.text,
      crAngleTo: _crAngleToController.text,
      crHeightFrom: _crHeightFromController.text,
      crHeightTo: _crHeightToController.text,
      pavAngleFrom: _pavAngleFromController.text,
      pavAngleTo: _pavAngleToController.text,
      pavHeightFrom: _pavHeightFromController.text,
      pavHeightTo: _pavHeightToController.text,
      girdleFrom: _girdleFromController.text,
      girdleTo: _girdleToController.text,
      starLengthFrom: _starLengthFromController.text,
      starLengthTo: _starLengthToController.text,
      lengthFrom: _lengthFromController.text.trim().isEmpty ? null : _lengthFromController.text.trim(),
      lengthTo: _lengthToController.text.trim().isEmpty ? null : _lengthToController.text.trim(),
      widthFrom: _widthFromController.text.trim().isEmpty ? null : _widthFromController.text.trim(),
      widthTo: _widthToController.text.trim().isEmpty ? null : _widthToController.text.trim(),
    ));
  }

  void _onFilterChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _applyFilters();
      }
    });
  }

  void _loadMore() {
    context.read<DiamondBloc>().add(FetchDiamonds(
      isRefresh: false,
      stock: _stockNoController.text,
      shapes: _selectedShapes.isEmpty ? null : _selectedShapes.map((s) => s.toUpperCase()).toList(),
      colors: _selectedColors,
      fancyColors: _selectedFancyColors,
      clarities: _selectedClarities,
      cuts: _selectedCuts,
      polishes: _selectedPolishes,
      symmetries: _selectedSymmetries,
      labs: _selectedLabs,
      fluorescences: _selectedFluorescences,
      makes: _selectedMakes,
      culets: _selectedCulets,
      caratFrom: _caratFromController.text,
      caratTo: _caratToController.text,
      priceFrom: _priceFromController.text,
      priceTo: _priceToController.text,
      ratioFrom: _ratioFromController.text,
      ratioTo: _ratioToController.text,
      depthFrom: _depthMinController.text,
      depthTo: _depthMaxController.text,
      tableFrom: _tableMinController.text,
      tableTo: _tableMaxController.text,
      crAngleFrom: _crAngleFromController.text,
      crAngleTo: _crAngleToController.text,
      crHeightFrom: _crHeightFromController.text,
      crHeightTo: _crHeightToController.text,
      pavAngleFrom: _pavAngleFromController.text,
      pavAngleTo: _pavAngleToController.text,
      pavHeightFrom: _pavHeightFromController.text,
      pavHeightTo: _pavHeightToController.text,
      girdleFrom: _girdleFromController.text,
      girdleTo: _girdleToController.text,
      starLengthFrom: _starLengthFromController.text,
      starLengthTo: _starLengthToController.text,
      lengthFrom: _lengthFromController.text.trim().isEmpty ? null : _lengthFromController.text.trim(),
      lengthTo: _lengthToController.text.trim().isEmpty ? null : _lengthToController.text.trim(),
      widthFrom: _widthFromController.text.trim().isEmpty ? null : _widthFromController.text.trim(),
      widthTo: _widthToController.text.trim().isEmpty ? null : _widthToController.text.trim(),
    ));
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        currentPage: 'search',
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),
      bottomNavigationBar: _selectedDiamonds.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Theme.of(context).scaffoldBackgroundColor,
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
                    Text(
                      '${_selectedDiamonds.length} Selected',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.green),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => DiamondShareDialog(diamonds: _selectedDiamonds.toList()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    BlocBuilder<CartBloc, CartState>(
                      builder: (context, cartState) {
                        bool allAdded = false;
                        if (cartState is CartLoaded && _selectedDiamonds.isNotEmpty) {
                          final cartStockIds = cartState.cartItems.map((item) => item.stockId).toSet();
                          allAdded = _selectedDiamonds.every((d) => cartStockIds.contains(d.stockId));
                        }

                        if (allAdded) {
                          return ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedDiamonds.clear();
                              });
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: const Text('Already Added'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.successColor.withOpacity(0.1),
                              foregroundColor: AppConstants.successColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: AppConstants.successColor.withOpacity(0.5)),
                              ),
                              elevation: 0,
                            ),
                          );
                        }

                        return ElevatedButton.icon(
                          onPressed: () {
                            for (var d in _selectedDiamonds) {
                              bool isAdded = false;
                              if (cartState is CartLoaded) {
                                isAdded = cartState.cartItems.any((item) => item.stockId == d.stockId);
                              }
                              if (!isAdded) {
                                _addToCart(d);
                              }
                            }
                            setState(() {
                              _selectedDiamonds.clear();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Selected diamonds added to cart')),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_rounded, size: 18),
                          label: const Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    ),
                  ],
                ),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:IconButton(
          icon: Icon(Icons.menu_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).cardTheme.color ?? AppConstants.surfaceColor,
            side: BorderSide(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        centerTitle: true,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark ? AppConstants.borderLight : AppConstants.lightBorderLight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: Theme.of(context).brightness == Brightness.dark ? AppConstants.textSecondary : AppConstants.lightTextSecondary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _stockNoController,
                  textAlignVertical: TextAlignVertical.center,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by Stock No...',
                    hintStyle: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onSubmitted: (val) {
                    _applyFilters();
                  },
                  onChanged: (val) {
                    setState((){});
                  },
                ),
              ),
              if (_stockNoController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _stockNoController.clear();
                    });
                    _applyFilters();
                  },
                  child: Icon(Icons.close_rounded, color: Theme.of(context).brightness == Brightness.dark ? AppConstants.textSecondary : AppConstants.lightTextSecondary, size: 16),
                ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () {
              context.read<ThemeBloc>().add(const ThemeToggleRequested());
            },
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).cardTheme.color ?? AppConstants.surfaceColor,
              side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? AppConstants.borderLight : AppConstants.lightBorderLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          IconButton(
            icon: Icon(Icons.favorite_border_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistPage()));
            },
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).cardTheme.color ?? AppConstants.surfaceColor,
              side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? AppConstants.borderLight : AppConstants.lightBorderLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.spaceMD, left: AppConstants.spaceSM),
            child: Center(
              child: BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
                  int totalQty = 0;
                  if (cartState is CartLoaded) {
                    for (var item in cartState.cartItems) {
                      totalQty += int.tryParse(item.quantity ?? '1') ?? 1;
                    }
                  } else {
                    totalQty = _localCartCount;
                  }

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).colorScheme.onSurface, size: 20),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).cardTheme.color ?? AppConstants.surfaceColor,
                          side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      if (totalQty > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppConstants.accentSecondary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$totalQty',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                }
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<DiamondBloc, DiamondState>(
        builder: (context, state) {
          int listLength = 0;
          List<DiamondModel> diamondList = [];
          if (state is DiamondLoaded) {
            final bool hasCustomFilter = _hasActiveFilters();
            listLength = (hasCustomFilter || state.unfilteredTotalCount == 0)
                ? state.totalRecords
                : state.unfilteredTotalCount;
            diamondList = state.diamonds;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _currentFilteredCount = listLength;
                });
                _onDataLoaded();
              }
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          // 2. Search Summary Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD + 4, vertical: AppConstants.spaceSM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppConstants.successColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$listLength Stones Found',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.sync_rounded,
                          size: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppConstants.textSecondary
                              : AppConstants.lightTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hourly Sync: $_lastSyncFormatted',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppConstants.textSecondary
                                : AppConstants.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _applyFilters();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Theme.of(context).brightness == Brightness.dark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                        ),
                        child: Icon(
                          _isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
                          color: Theme.of(context).brightness == Brightness.dark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _openFilterBottomSheet(context),
                      child: Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Theme.of(context).brightness == Brightness.dark ? AppConstants.accentColorDark : AppConstants.accentColor, (Theme.of(context).brightness == Brightness.dark ? AppConstants.accentColorDark : AppConstants.accentColor).withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: (Theme.of(context).brightness == Brightness.dark ? AppConstants.accentColorDark : AppConstants.accentColor).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: state is DiamondLoading
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.spaceMD),
                        child: Shimmer.fromColors(
                          baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : state is DiamondError
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.spaceMD),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppConstants.errorColor, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _applyFilters,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : diamondList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'No Diamonds match your criteria.',
                                  style: GoogleFonts.nunito(color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                    : RefreshIndicator(
                        color: accentColor,
                        onRefresh: () async {
                          _applyFilters();
                        },
                        child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                            if (state is DiamondLoaded && !state.hasReachedMax) {
                              _loadMore();
                            }
                          }
                          return false;
                        },
                        child: _isGridView 
                          ? GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
                              physics: const BouncingScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: diamondList.length + (state is DiamondLoaded && state.hasReachedMax ? 0 : 1),
                              itemBuilder: (context, index) {
                                if (index >= diamondList.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(color: accentColor),
                                    ),
                                  );
                                }
                                final stone = diamondList[index];
                                final isSelected = _selectedDiamonds.contains(stone);
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DiamondDetailPage(diamond: stone),
                                      ),
                                    );
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedDiamonds.remove(stone);
                                      } else {
                                        _selectedDiamonds.add(stone);
                                      }
                                    });
                                  },
                                  child: _DiamondCard(
                                    diamond: stone,
                                    onAddToCart: () => _addToCart(stone),
                                    isGrid: true,
                                    isSelected: isSelected,
                                    isSelectionMode: _selectedDiamonds.isNotEmpty,
                                    onSelect: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedDiamonds.add(stone);
                                        } else {
                                          _selectedDiamonds.remove(stone);
                                        }
                                      });
                                    },
                                    userId: widget.userId,
                                  ),
                                );
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
                              physics: const BouncingScrollPhysics(),
                              itemCount: diamondList.length + (state is DiamondLoaded && state.hasReachedMax ? 0 : 1),
                              itemBuilder: (context, index) {
                                if (index >= diamondList.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(color: accentColor),
                                    ),
                                  );
                                }
                                final stone = diamondList[index];
                                final isSelected = _selectedDiamonds.contains(stone);
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DiamondDetailPage(diamond: stone),
                                      ),
                                    );
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedDiamonds.remove(stone);
                                      } else {
                                        _selectedDiamonds.add(stone);
                                      }
                                    });
                                  },
                                  child: _DiamondCard(
                                    diamond: stone,
                                    onAddToCart: () => _addToCart(stone),
                                    isGrid: false,
                                    isSelected: isSelected,
                                    isSelectionMode: _selectedDiamonds.isNotEmpty,
                                    onSelect: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedDiamonds.add(stone);
                                        } else {
                                          _selectedDiamonds.remove(stone);
                                        }
                                      });
                                    },
                                    userId: widget.userId,
                                  ),
                                );
                              },
                            ),
                      ),
                    ),
          ),
        ],
      );
        },
      ),
    );
  }

  TextStyle _filterLabelStyle(BuildContext context) {
    return GoogleFonts.nunito(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );
  }

  // --- NEW MOBILE DRAWER FILTERS ---
  void _openFilterBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final mediaQuery = MediaQuery.of(context);
            final bottomInset = mediaQuery.viewInsets.bottom;
            final isKeyboardOpen = bottomInset > 0;
            final availableHeight = mediaQuery.size.height - bottomInset - mediaQuery.padding.top;
            final sheetHeight = isKeyboardOpen
                ? (availableHeight * 0.96).clamp(240.0, availableHeight)
                : mediaQuery.size.height * 0.88;

            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: sheetHeight,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F0F12) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
                    border: Border.all(
                      color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Pull Handle
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Header Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.tune_rounded, color: accentColor, size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  'Filter Diamonds',
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 22),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Divider(height: 1),

                      // Scrollable parameters content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.all(AppConstants.spaceLG),
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // A. Diamond Shape Selector
                          Text('Diamond Shape', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          SizedBox(
                            height: 98, // Increased height to accommodate larger icon + text centering
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _shapes.length,
                              itemBuilder: (context, index) {
                                final shape = _shapes[index];
                                final isSelected = _selectedShapes.contains(shape);
                                final isOval = shape.toLowerCase() == 'oval';
                                final imgSize = isOval ? 44.0 : 34.0;

                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      if (_selectedShapes.contains(shape)) {
                                        _selectedShapes.remove(shape);
                                      } else {
                                        _selectedShapes.add(shape);
                                      }
                                    });
                                    setState(() {});
                                    _onFilterChanged();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: AppConstants.spaceMD),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Shape Icon Container
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: isSelected 
                                                ? accentColor.withValues(alpha: 0.1) 
                                                : (isDark ? AppConstants.surfaceLightColor : AppConstants.lightSurfaceLightColor),
                                            border: Border.all(
                                              color: isSelected 
                                                  ? accentColor 
                                                  : (isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            _getShapeAsset(shape),
                                            width: imgSize,
                                            height: imgSize,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              // Fallback if image doesn't exist
                                              return Icon(
                                                Icons.diamond_outlined,
                                                color: isSelected ? accentColor : (isDark ? Colors.white70 : Colors.black54),
                                                size: 30,
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // Shape Label
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            shape,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.nunito(
                                              fontSize: 10,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                              color: isSelected ? accentColor : (isDark ? Colors.white70 : Colors.black87),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          // B. Carat & Price Inputs
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Carat (Ct.)', style: _filterLabelStyle(context)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildModalInputBox(
                                            controller: _caratFromController,
                                            hint: 'Min ct',
                                            setModalState: setModalState,
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4),
                                          child: Text('to', style: TextStyle(fontSize: 11)),
                                        ),
                                        Expanded(
                                          child: _buildModalInputBox(
                                            controller: _caratToController,
                                            hint: 'Max ct',
                                            setModalState: setModalState,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.userId != 'guest') ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Price (\$)', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _priceFromController,
                                              hint: 'Min \$',
                                              setModalState: setModalState,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4),
                                            child: Text('to', style: TextStyle(fontSize: 11)),
                                          ),
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _priceToController,
                                              hint: 'Max \$',
                                              setModalState: setModalState,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          // C. Color Grade Multi-selector
                          Text('Color Grade', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _colors,
                            selectedItems: _selectedColors,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedColors.contains(item)) {
                                  _selectedColors.remove(item);
                                } else {
                                  _selectedColors.add(item);
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          // C.2 Fancy Color Multi-selector
                          if (_selectedColors.contains('FANCY')) ...[
                            Text('Fancy Color', style: _filterLabelStyle(context)),
                            const SizedBox(height: AppConstants.spaceSM),
                            SizedBox(
                              height: 48,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _fancyColors.length,
                                itemBuilder: (context, index) {
                                  final color = _fancyColors[index];
                                  final isSelected = _selectedFancyColors.contains(color);
                                  return GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        if (_selectedFancyColors.contains(color)) {
                                          _selectedFancyColors.remove(color);
                                        } else {
                                          _selectedFancyColors.add(color);
                                        }
                                      });
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: AppConstants.spaceSM),
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected ? accentColor : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: isSelected ? [
                                            BoxShadow(
                                              color: accentColor.withValues(alpha: 0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ] : null,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/images/$color.png',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error_outline, size: 20),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: AppConstants.spaceMD),
                          ],

                          // D. Clarity Grade Multi-selector
                          Text('Clarity Grade', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _clarities,
                            selectedItems: _selectedClarities,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedClarities.contains(item)) {
                                  _selectedClarities.remove(item);
                                } else {
                                  _selectedClarities.add(item);
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          Text('Make', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _makes,
                            selectedItems: _selectedMakes,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedMakes.contains(item)) {
                                  _selectedMakes.remove(item);
                                  
                                  // Remove on unselect
                                  if (item == '3EX') {
                                    _selectedCuts.remove('EX');
                                    _selectedPolishes.remove('EX');
                                    _selectedSymmetries.remove('EX');
                                  } else if (item == '3VG+') {
                                    _selectedCuts.remove('VG');
                                    _selectedPolishes.remove('VG');
                                    _selectedSymmetries.remove('VG');
                                  } else if (item == '3EX-NONE') {
                                    _selectedCuts.remove('EX');
                                    _selectedPolishes.remove('EX');
                                    _selectedSymmetries.remove('EX');
                                    _selectedFluorescences.remove('None');
                                  }
                                } else {
                                  // Don't do multiple selection for Make
                                  _selectedMakes.clear();
                                  _selectedMakes.add(item);
                                  
                                  if (item == '3EX') {
                                    _selectedCuts.clear(); _selectedCuts.add('EX');
                                    _selectedPolishes.clear(); _selectedPolishes.add('EX');
                                    _selectedSymmetries.clear(); _selectedSymmetries.add('EX');
                                  } else if (item == '3VG+') {
                                    _selectedCuts.clear(); _selectedCuts.add('VG');
                                    _selectedPolishes.clear(); _selectedPolishes.add('VG');
                                    _selectedSymmetries.clear(); _selectedSymmetries.add('VG');
                                  } else if (item == '3EX-NONE') {
                                    _selectedCuts.clear(); _selectedCuts.add('EX');
                                    _selectedPolishes.clear(); _selectedPolishes.add('EX');
                                    _selectedSymmetries.clear(); _selectedSymmetries.add('EX');
                                    _selectedFluorescences.clear(); _selectedFluorescences.add('None');
                                  }
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          // E. Fluorescence Multi-selector
                          Text('Fluorescence', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _fluorescences,
                            selectedItems: _selectedFluorescences,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedFluorescences.contains(item)) {
                                  _selectedFluorescences.remove(item);
                                } else {
                                  _selectedFluorescences.add(item);
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          // F. Quality Filters (Cut, Polish, Symmetry, Lab)
                          Text('Cut Grade', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _cuts,
                            selectedItems: _selectedCuts,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedCuts.contains(item)) {
                                  _selectedCuts.remove(item);
                                } else {
                                  _selectedCuts.add(item);
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          Text('Polish', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _polishes,
                            selectedItems: _selectedPolishes,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedPolishes.contains(item)) {
                                  _selectedPolishes.remove(item);
                                } else {
                                  _selectedPolishes.add(item);
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          Text('Symmetry', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _symmetries,
                            selectedItems: _selectedSymmetries,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedSymmetries.contains(item)) {
                                  _selectedSymmetries.remove(item);
                                } else {
                                  _selectedSymmetries.add(item);
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          // Text('Available', style: _filterLabelStyle(context)),
                          // const SizedBox(height: AppConstants.spaceSM),
                          // _buildModalMultiSelectRow(
                          //   items: const ['Yes', 'No'],
                          //   selectedItems: _selectedAvailable,
                          //   onTap: (item) {
                          //     setModalState(() {
                          //       if (_selectedAvailable.contains(item)) {
                          //         _selectedAvailable.remove(item);
                          //       } else {
                          //         _selectedAvailable.add(item);
                          //       }
                          //     });
                          //     setState(() {});
                          //   },
                          // ),

                          const SizedBox(height: AppConstants.spaceMD),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('LAB', style: _filterLabelStyle(context)),
                              const SizedBox(height: AppConstants.spaceSM),
                              _buildModalMultiSelectRow(
                                items: _labs,
                                selectedItems: _selectedLabs,
                                onTap: (item) {
                                  setModalState(() {
                                    if (_selectedLabs.contains(item)) {
                                      _selectedLabs.remove(item);
                                    } else {
                                      _selectedLabs.add(item);
                                    }
                                  });
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spaceMD),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('STOCK NO', style: _filterLabelStyle(context)),
                              const SizedBox(height: AppConstants.spaceSM),
                              _buildModalInputBox(
                                controller: _stockNoController,
                                hint: '',
                                keyboardType: TextInputType.text,
                                setModalState: setModalState,
                              ),
                            ],
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          // G. Toggle Advanced Search Button
                          InkWell(
                            onTap: () {
                              setModalState(() {
                                _isAdvanceExpanded = !_isAdvanceExpanded;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppConstants.surfaceLightColor
                                    : AppConstants.lightSurfaceLightColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isAdvanceExpanded
                                        ? Icons.remove_circle_outline_rounded
                                        : Icons.add_circle_outline_rounded,
                                    color: accentColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isAdvanceExpanded ? 'HIDE ADVANCE SEARCH' : 'SHOW ADVANCE SEARCH',
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: accentColor,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // H. Advanced Search Section
                          if (_isAdvanceExpanded) ...[
                            const SizedBox(height: AppConstants.spaceMD),
                            const Divider(color: AppConstants.borderLight),
                            const SizedBox(height: AppConstants.spaceSM),

                            // Culet Multi-selector
                            Text('Culet', style: _filterLabelStyle(context)),
                            const SizedBox(height: AppConstants.spaceSM),
                            _buildModalMultiSelectRow(
                              items: _culets,
                              selectedItems: _selectedCulets,
                              onTap: (item) {
                                setModalState(() {
                                  if (_selectedCulets.contains(item)) {
                                    _selectedCulets.remove(item);
                                  } else {
                                    _selectedCulets.add(item);
                                  }
                                });
                                setState(() {});
                              },
                            ),

                            const SizedBox(height: AppConstants.spaceMD),

                            // Depth & Table Inputs
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Depth %', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _depthMinController,
                                              hint: 'Min %',
                                              setModalState: setModalState,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4),
                                            child: Text('to', style: TextStyle(fontSize: 11)),
                                          ),
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _depthMaxController,
                                              hint: 'Max %',
                                              setModalState: setModalState,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Table %', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _tableMinController,
                                              hint: 'Min %',
                                              setModalState: setModalState,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4),
                                            child: Text('to', style: TextStyle(fontSize: 11)),
                                          ),
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _tableMaxController,
                                              hint: 'Max %',
                                              setModalState: setModalState,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.spaceMD),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Ratio', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _ratioFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _ratioToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Girdle %', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _girdleFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _girdleToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.spaceMD),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Cr. Angle', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _crAngleFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _crAngleToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Cr. Height', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _crHeightFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _crHeightToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.spaceMD),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Pav. Angle', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _pavAngleFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _pavAngleToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Pav. Height', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _pavHeightFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _pavHeightToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.spaceMD),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Star Length', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _starLengthFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _starLengthToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: SizedBox()),
                              ],
                            ),

                            const SizedBox(height: AppConstants.spaceMD),

                            // Length & Width Filter Inputs
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Length (mm)', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _lengthFromController,
                                              hint: 'From',
                                              setModalState: setModalState,
                                              textInputAction: TextInputAction.next,
                                            ),
                                          ),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _lengthToController,
                                              hint: 'To',
                                              setModalState: setModalState,
                                              textInputAction: TextInputAction.next,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Width (mm)', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _widthFromController,
                                              hint: 'From',
                                              setModalState: setModalState,
                                              textInputAction: TextInputAction.next,
                                            ),
                                          ),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _widthToController,
                                              hint: 'To',
                                              setModalState: setModalState,
                                              textInputAction: TextInputAction.done,
                                              onEditingComplete: () => FocusScope.of(context).unfocus(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                          ],
                          // Generous bottom spacing ensuring fields at the end of the scrollview scroll well above the sticky bottom buttons
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),

                  // Sticky Bottom Drawer Action Row
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spaceLG),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextButton.icon(
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Reset'),
                            onPressed: () {
                              setModalState(() {
                                _resetFilters();
                              });
                              setState(() {});
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppConstants.errorColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: BlocBuilder<DiamondBloc, DiamondState>(
                            builder: (context, blocState) {
                              return ElevatedButton(
                                onPressed: () {
                                  _applyFilters();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                ),
                                child: Text(
                                  blocState is DiamondLoading
                                      ? 'Loading...'
                                      : 'Show ${blocState is DiamondLoaded ? ((_hasActiveFilters() || blocState.unfilteredTotalCount == 0) ? blocState.totalRecords : blocState.unfilteredTotalCount) : 0} Diamonds',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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

  Widget _buildModalInputBox({
    required TextEditingController controller,
    required String hint,
    required StateSetter setModalState,
    TextInputType keyboardType = const TextInputType.numberWithOptions(decimal: true),
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onEditingComplete,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onEditingComplete: onEditingComplete,
        scrollPadding: const EdgeInsets.only(bottom: 120, top: 40),
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.nunito(fontSize: 11, color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (_) {
          setModalState(() {});
          setState(() {});
          _onFilterChanged();
        },
      ),
    );
  }

  Widget _buildModalMultiSelectRow({
    required List<String> items,
    required List<String> selectedItems,
    required ValueChanged<String> onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;
    
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedItems.contains(item);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (val) {
                onTap(item);
                _onFilterChanged();
              },
              selectedColor: accentColor.withOpacity(0.15),
              backgroundColor: Colors.transparent,
              labelStyle: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? accentColor : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: isSelected ? accentColor : (isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildModalDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: _filterLabelStyle(context)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceSM),
          decoration: BoxDecoration(
            color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: isDark ? AppConstants.surfaceColor : Colors.white,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary, size: 20),
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _DiamondCard extends StatefulWidget {
  final DiamondModel diamond;
  final VoidCallback onAddToCart;
  final bool isGrid;
  final bool isSelected;
  final bool isSelectionMode;
  final ValueChanged<bool?>? onSelect;
  final String userId;

  const _DiamondCard({
    required this.diamond,
    required this.onAddToCart,
    this.isGrid = false,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onSelect,
    required this.userId,
  });

  @override
  State<_DiamondCard> createState() => _DiamondCardState();
}

class _DiamondCardState extends State<_DiamondCard> {
  bool _isWishlisted = false;

  @override
  Widget build(BuildContext context) {
    final diamond = widget.diamond;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

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

        if (widget.isGrid) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? AppConstants.surfaceColor,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
              ),
              boxShadow: AppConstants.glassShadow,
            ),
            padding: const EdgeInsets.all(AppConstants.spaceSM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: widget.isSelected,
                        onChanged: widget.onSelect,
                        activeColor: AppConstants.accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${diamond.stockId ?? ""}',
                        style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.userId == 'guest') {
                          DialogUtils.showLoginRequiredDialog(context);
                          return;
                        }
                        if (isWishlisted && wishlistId != null) {
                          context.read<WishlistCubit>().removeWishlist(wishlistId);
                        } else {
                          context.read<WishlistCubit>().addToWishlist(diamond.stockId ?? '');
                        }
                      },
                      child: Icon(
                        isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: accentColor,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Center(
                    child: diamond.diamondImage != null && diamond.diamondImage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: diamond.diamondImage!,
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/round-grey.png',
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                        )
                      : Image.asset(
                          'assets/images/round-grey.png',
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(double.tryParse(diamond.weight ?? "0") ?? 0.0).toStringAsFixed(2)} Ct ${diamond.shape ?? ""}',
                  style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${diamond.color ?? ""}, ${diamond.grade ?? ""}${diamond.parsedLength != null && diamond.parsedWidth != null ? ' • ${diamond.parsedLength!.toStringAsFixed(1)}x${diamond.parsedWidth!.toStringAsFixed(1)}' : ''}',
                  style: GoogleFonts.nunito(fontSize: 10, color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: diamond.availabilityDisplay.toLowerCase() == 'on memo'
                            ? Colors.orange.withOpacity(0.15)
                            : AppConstants.successColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        diamond.availabilityDisplay.toUpperCase(),
                        style: TextStyle(
                          color: diamond.availabilityDisplay.toLowerCase() == 'on memo'
                              ? Colors.orange
                              : AppConstants.successColor,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (diamond.locationDisplay.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_outlined, size: 8, color: accentColor),
                            const SizedBox(width: 2),
                            Text(
                              diamond.locationDisplay,
                              style: TextStyle(
                                color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                widget.userId == 'guest'
                     ? Text(
                         'Login for price',
                         style: GoogleFonts.nunito(
                           fontSize: 11,
                           fontWeight: FontWeight.bold,
                           color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                         ),
                         textAlign: TextAlign.center,
                         maxLines: 1,
                       )
                     : FittedBox(
                         fit: BoxFit.scaleDown,
                         child: Text(
                           PriceFormatter.formatRoundPrice(diamond.totalPrice),
                           style: GoogleFonts.nunito(
                             fontSize: 14,
                             fontWeight: FontWeight.w900,
                             color: AppConstants.successColor,
                           ),
                           textAlign: TextAlign.center,
                         ),
                       ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spaceMD),
          decoration: BoxDecoration(
            color: isDark ? AppConstants.surfaceLightColor : AppConstants.lightSurfaceLightColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight, width: 1),
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
                          color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                        ),
                        child: (diamond.diamondImage != null && diamond.diamondImage!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: diamond.diamondImage!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(child: CircularProgressIndicator(color: accentColor)),
                                errorWidget: (context, url, error) => Icon(Icons.diamond_outlined, color: accentColor.withOpacity(0.5), size: 40),
                              )
                            : Icon(Icons.diamond_outlined, color: accentColor.withOpacity(0.5), size: 40),
                      ),
                      
                      // Details Section
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.spaceMD),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${diamond.weight ?? ""} Ct ${diamond.shape ?? ""}'.toUpperCase(),
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      if (widget.userId == 'guest') {
                                        DialogUtils.showLoginRequiredDialog(context);
                                        return;
                                      }
                                      if (isWishlisted && wishlistId != null) {
                                        context.read<WishlistCubit>().removeWishlist(wishlistId);
                                      } else {
                                        context.read<WishlistCubit>().addToWishlist(diamond.stockId ?? '');
                                      }
                                    },
                                    child: Icon(
                                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                                      color: isWishlisted ? AppConstants.errorColor : (isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppConstants.spaceXS),
                              
                              // Spec Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight, width: 0.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildSpecItemCol('CARAT', diamond.weight ?? '', isDark, Theme.of(context).colorScheme.onSurface),
                                    _buildSpecItemCol('COLOR', diamond.color ?? '', isDark, Theme.of(context).colorScheme.onSurface),
                                    _buildSpecItemCol('CLARITY', diamond.grade ?? '', isDark, Theme.of(context).colorScheme.onSurface),
                                    _buildSpecItemCol('CUT', diamond.cut ?? '', isDark, Theme.of(context).colorScheme.onSurface),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppConstants.spaceSM),
                              
                              // Stock ID, Stone Availability & Dimensions
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: accentColor.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      'Stock: ${diamond.stockId ?? ""}',
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  // Stone Availability Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: diamond.availabilityDisplay.toLowerCase() == 'on memo'
                                          ? Colors.orange.withOpacity(0.15)
                                          : AppConstants.successColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: diamond.availabilityDisplay.toLowerCase() == 'on memo'
                                            ? Colors.orange
                                            : AppConstants.successColor,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      diamond.availabilityDisplay.toUpperCase(),
                                      style: TextStyle(
                                        color: diamond.availabilityDisplay.toLowerCase() == 'on memo'
                                            ? Colors.orange
                                            : AppConstants.successColor,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  // Location Badge
                                  if (diamond.locationDisplay.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight, width: 0.5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.location_on_outlined, size: 10, color: accentColor),
                                          const SizedBox(width: 2),
                                          Text(
                                            diamond.locationDisplay,
                                            style: TextStyle(
                                              color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Dimensions (Length x Width)
                                  if (diamond.parsedLength != null && diamond.parsedWidth != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight, width: 0.5),
                                      ),
                                      child: Text(
                                        '${diamond.parsedLength!.toStringAsFixed(2)} × ${diamond.parsedWidth!.toStringAsFixed(2)} mm',
                                        style: TextStyle(
                                          color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppConstants.spaceMD),
                              
                              // Price & Action
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: widget.userId == 'guest'
                                        ? Text(
                                            'Login for price',
                                            style: GoogleFonts.nunito(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : Align(
                                            alignment: Alignment.centerLeft,
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                PriceFormatter.formatRoundPrice(diamond.totalPrice),
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
                                  BlocBuilder<CartBloc, CartState>(
                                    builder: (context, state) {
                                      bool isAdded = false;
                                      if (state is CartLoaded) {
                                        isAdded = state.cartItems.any((item) => item.stockId == diamond.stockId);
                                      }
                                      return GestureDetector(
                                        onTap: () {
                                          if (widget.userId == 'guest') {
                                            DialogUtils.showLoginRequiredDialog(context);
                                            return;
                                          }
                                          if (isAdded) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text('This diamond is already in your cart!'),
                                                duration: const Duration(seconds: 1),
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                backgroundColor: AppConstants.successColor,
                                              ),
                                            );
                                          } else {
                                            widget.onAddToCart();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Added ${diamond.weight ?? ""} ct ${diamond.shape ?? ""} to cart!'),
                                                duration: const Duration(seconds: 1),
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                backgroundColor: AppConstants.successColor,
                                              ),
                                            );
                                          }
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isAdded ? (isDark ? Colors.green.withOpacity(0.2) : Colors.green.shade50) : accentColor,
                                            borderRadius: BorderRadius.circular(20),
                                            border: isAdded ? Border.all(color: Colors.green) : null,
                                            boxShadow: isAdded ? [] : [
                                              BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isAdded ? Icons.check_circle_rounded : Icons.shopping_cart_outlined,
                                                color: isAdded ? Colors.green : Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                isAdded ? 'ADDED' : 'ADD TO CART',
                                                style: TextStyle(
                                                  color: isAdded ? Colors.green : Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
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
                
                // Checkbox (Top Left) over image
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.surfaceLightColor.withOpacity(0.8) : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: widget.isSelected,
                      onChanged: widget.onSelect,
                      activeColor: AppConstants.accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecItemCol(String label, String value, bool isDark, Color textColor) {
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
          value.isNotEmpty ? value : '-',
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
