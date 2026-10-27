import '../datasources/diamond_remote_datasource.dart';
import '../models/diamond_model.dart';

abstract class DiamondRepository {
  Future<bool> addToCart({
    required String stock,
    int qty = 1,
  });

  Future<DiamondResponseModel> getDiamondList({

    int page = 0,
    int perPage = 50,
    String stock = "",
    List<String>? shapes,
    List<String>? colors,
    List<String>? fancyColors,
    List<String>? clarities,
    List<String>? cuts,
    List<String>? polishes,
    List<String>? symmetries,
    List<String>? labs,
    List<String>? fluorescences,
    List<String>? makes,
    List<String>? culets,
    List<String>? available,
    String? caratFrom,
    String? caratTo,
    String? priceFrom,
    String? priceTo,
    String? ratioFrom,
    String? ratioTo,
    String? depthFrom,
    String? depthTo,
    String? tableFrom,
    String? tableTo,
    String? crAngleFrom,
    String? crAngleTo,
    String? crHeightFrom,
    String? crHeightTo,
    String? pavAngleFrom,
    String? pavAngleTo,
    String? pavHeightFrom,
    String? pavHeightTo,
    String? girdleFrom,
    String? girdleTo,
    String? starLengthFrom,
    String? starLengthTo,
    String? lengthFrom,
    String? lengthTo,
    String? widthFrom,
    String? widthTo,
  });
}

class DiamondRepositoryImpl implements DiamondRepository {
  final DiamondRemoteDataSource remoteDataSource;

  DiamondRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DiamondResponseModel> getDiamondList({

    int page = 0,
    int perPage = 50,
    String stock = "",
    List<String>? shapes,
    List<String>? colors,
    List<String>? fancyColors,
    List<String>? clarities,
    List<String>? cuts,
    List<String>? polishes,
    List<String>? symmetries,
    List<String>? labs,
    List<String>? fluorescences,
    List<String>? makes,
    List<String>? culets,
    List<String>? available,
    String? caratFrom,
    String? caratTo,
    String? priceFrom,
    String? priceTo,
    String? ratioFrom,
    String? ratioTo,
    String? depthFrom,
    String? depthTo,
    String? tableFrom,
    String? tableTo,
    String? crAngleFrom,
    String? crAngleTo,
    String? crHeightFrom,
    String? crHeightTo,
    String? pavAngleFrom,
    String? pavAngleTo,
    String? pavHeightFrom,
    String? pavHeightTo,
    String? girdleFrom,
    String? girdleTo,
    String? starLengthFrom,
    String? starLengthTo,
    String? lengthFrom,
    String? lengthTo,
    String? widthFrom,
    String? widthTo,
  }) async {

    final response = await remoteDataSource.getDiamondList(
      page: page,
      perPage: perPage,
      stock: stock,
      shapes: shapes,
      colors: colors,
      fancyColors: fancyColors,
      clarities: clarities,
      cuts: cuts,
      polishes: polishes,
      symmetries: symmetries,
      labs: labs,
      fluorescences: fluorescences,
      makes: makes,
      culets: culets,
      available: available,
      caratFrom: caratFrom,
      caratTo: caratTo,
      priceFrom: priceFrom,
      priceTo: priceTo,
      ratioFrom: ratioFrom,
      ratioTo: ratioTo,
      depthFrom: depthFrom,
      depthTo: depthTo,
      tableFrom: tableFrom,
      tableTo: tableTo,
      crAngleFrom: crAngleFrom,
      crAngleTo: crAngleTo,
      crHeightFrom: crHeightFrom,
      crHeightTo: crHeightTo,
      pavAngleFrom: pavAngleFrom,
      pavAngleTo: pavAngleTo,
      pavHeightFrom: pavHeightFrom,
      pavHeightTo: pavHeightTo,
      girdleFrom: girdleFrom,
      girdleTo: girdleTo,
      starLengthFrom: starLengthFrom,
      starLengthTo: starLengthTo,
      lengthFrom: lengthFrom,
      lengthTo: lengthTo,
      widthFrom: widthFrom,
      widthTo: widthTo,
    );

    final lFrom = double.tryParse(lengthFrom?.trim() ?? '');
    final lTo = double.tryParse(lengthTo?.trim() ?? '');
    final wFrom = double.tryParse(widthFrom?.trim() ?? '');
    final wTo = double.tryParse(widthTo?.trim() ?? '');

    if (lFrom != null || lTo != null || wFrom != null || wTo != null) {
      final filteredDiamonds = response.data.where((d) {
        final l = d.parsedLength;
        final w = d.parsedWidth;
        if (lFrom != null && (l == null || l < lFrom)) return false;
        if (lTo != null && (l == null || l > lTo)) return false;
        if (wFrom != null && (w == null || w < wFrom)) return false;
        if (wTo != null && (w == null || w > wTo)) return false;
        return true;
      }).toList();

      return DiamondResponseModel(
        status: response.status,
        message: response.message,
        totalRecords: filteredDiamonds.length.toString(),
        perPage: response.perPage,
        page: response.page,
        data: filteredDiamonds,
      );
    }

    return response;
  }

  @override
  Future<bool> addToCart({
    required String stock,
    int qty = 1,
  }) async {
    return await remoteDataSource.addToCart(
      stock: stock,
      qty: qty,
    );
  }
}

