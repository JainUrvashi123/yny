import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/diamond_repository.dart';
import 'diamond_event.dart';
import 'diamond_state.dart';

class DiamondBloc extends Bloc<DiamondEvent, DiamondState> {
  final DiamondRepository repository;
  
  static const int _perPage = 50;
  int _unfilteredTotalCount = 0;

  DiamondBloc({required this.repository}) : super(DiamondInitial()) {
    on<FetchDiamonds>(_onFetchDiamonds);
    on<AddToCartEvent>(_onAddToCartEvent);
  }

  Future<void> _onFetchDiamonds(FetchDiamonds event, Emitter<DiamondState> emit) async {
    try {
      int currentPage = 0;
      
      if (event.isRefresh) {
        emit(DiamondLoading());
      } else if (state is DiamondLoaded) {
        final currentState = state as DiamondLoaded;
        if (currentState.hasReachedMax) return;
        currentPage = currentState.page + 1;
      } else {
        emit(DiamondLoading());
      }

      final response = await repository.getDiamondList(
        page: currentPage,
        perPage: _perPage,
        stock: event.stock,
        shapes: event.shapes,
        colors: event.colors,
        fancyColors: event.fancyColors,
        clarities: event.clarities,
        cuts: event.cuts,
        polishes: event.polishes,
        symmetries: event.symmetries,
        labs: event.labs,
        fluorescences: event.fluorescences,
        makes: event.makes,
        culets: event.culets,
        available: event.available,
        caratFrom: event.caratFrom,
        caratTo: event.caratTo,
        priceFrom: event.priceFrom,
        priceTo: event.priceTo,
        ratioFrom: event.ratioFrom,
        ratioTo: event.ratioTo,
        depthFrom: event.depthFrom,
        depthTo: event.depthTo,
        tableFrom: event.tableFrom,
        tableTo: event.tableTo,
        crAngleFrom: event.crAngleFrom,
        crAngleTo: event.crAngleTo,
        crHeightFrom: event.crHeightFrom,
        crHeightTo: event.crHeightTo,
        pavAngleFrom: event.pavAngleFrom,
        pavAngleTo: event.pavAngleTo,
        pavHeightFrom: event.pavHeightFrom,
        pavHeightTo: event.pavHeightTo,
        girdleFrom: event.girdleFrom,
        girdleTo: event.girdleTo,
        starLengthFrom: event.starLengthFrom,
        starLengthTo: event.starLengthTo,
        lengthFrom: event.lengthFrom,
        lengthTo: event.lengthTo,
        widthFrom: event.widthFrom,
        widthTo: event.widthTo,
      );

      final totalRecords = int.tryParse(response.totalRecords) ?? 0;
      final newDiamonds = response.data;
      final hasReachedMax = newDiamonds.length < _perPage;

      final isDefaultCarat = event.caratFrom == null || event.caratFrom == '0.10' || event.caratFrom == '0';
      final isDefaultCaratTo = event.caratTo == null || event.caratTo == '10.00' || event.caratTo == '10';
      final isDefaultPrice = event.priceFrom == null || event.priceFrom == '0';
      final isDefaultPriceTo = event.priceTo == null || event.priceTo == '100000';

      final isUnfiltered = event.stock.isEmpty &&
          (event.shapes == null || event.shapes!.isEmpty) &&
          (event.colors == null || event.colors!.isEmpty) &&
          (event.fancyColors == null || event.fancyColors!.isEmpty) &&
          (event.clarities == null || event.clarities!.isEmpty) &&
          (event.cuts == null || event.cuts!.isEmpty) &&
          (event.polishes == null || event.polishes!.isEmpty) &&
          (event.symmetries == null || event.symmetries!.isEmpty) &&
          (event.labs == null || event.labs!.isEmpty) &&
          (event.fluorescences == null || event.fluorescences!.isEmpty) &&
          (event.makes == null || event.makes!.isEmpty) &&
          (event.culets == null || event.culets!.isEmpty) &&
          (event.available == null || event.available!.isEmpty) &&
          isDefaultCarat && isDefaultCaratTo &&
          isDefaultPrice && isDefaultPriceTo &&
          event.ratioFrom == null && event.ratioTo == null &&
          event.depthFrom == null && event.depthTo == null &&
          event.tableFrom == null && event.tableTo == null &&
          event.crAngleFrom == null && event.crAngleTo == null &&
          event.crHeightFrom == null && event.crHeightTo == null &&
          event.pavAngleFrom == null && event.pavAngleTo == null &&
          event.pavHeightFrom == null && event.pavHeightTo == null &&
          event.girdleFrom == null && event.girdleTo == null &&
          event.starLengthFrom == null && event.starLengthTo == null &&
          event.lengthFrom == null && event.lengthTo == null &&
          event.widthFrom == null && event.widthTo == null;

      if (isUnfiltered || _unfilteredTotalCount == 0) {
        _unfilteredTotalCount = totalRecords;
      }

      if (event.isRefresh || state is! DiamondLoaded) {
        emit(DiamondLoaded(
          diamonds: newDiamonds,
          totalRecords: totalRecords,
          page: currentPage,
          hasReachedMax: hasReachedMax,
          unfilteredTotalCount: _unfilteredTotalCount,
        ));
      } else {
        final currentState = state as DiamondLoaded;
        emit(currentState.copyWith(
          diamonds: List.of(currentState.diamonds)..addAll(newDiamonds),
          totalRecords: totalRecords,
          page: currentPage,
          hasReachedMax: hasReachedMax,
          unfilteredTotalCount: _unfilteredTotalCount,
        ));
      }
    } catch (e) {
      if (state is! DiamondLoaded) {
        emit(DiamondError(e.toString()));
      }
    }
  }

  Future<void> _onAddToCartEvent(AddToCartEvent event, Emitter<DiamondState> emit) async {
    try {
      final success = await repository.addToCart(
        stock: event.stock,
      );
      // We don't change state since this is just adding to cart.
      // A separate bloc or callback handles UI notification.
    } catch (e) {
      // Silently fail or log
    }
  }
}

