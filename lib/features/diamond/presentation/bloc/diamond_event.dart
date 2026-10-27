import 'package:equatable/equatable.dart';

abstract class DiamondEvent extends Equatable {
  const DiamondEvent();

  @override
  List<Object?> get props => [];
}

class FetchDiamonds extends DiamondEvent {
  final bool isRefresh;
  final String stock;
  final List<String>? shapes;
  final List<String>? colors;
  final List<String>? fancyColors;
  final List<String>? clarities;
  final List<String>? cuts;
  final List<String>? polishes;
  final List<String>? symmetries;
  final List<String>? labs;
  final List<String>? fluorescences;
  final List<String>? makes;
  final List<String>? culets;
  final List<String>? available;

  
  // Ranged filters
  final String? caratFrom;
  final String? caratTo;
  final String? priceFrom;
  final String? priceTo;
  final String? ratioFrom;
  final String? ratioTo;
  final String? depthFrom;
  final String? depthTo;
  final String? tableFrom;
  final String? tableTo;
  final String? crAngleFrom;
  final String? crAngleTo;
  final String? crHeightFrom;
  final String? crHeightTo;
  final String? pavAngleFrom;
  final String? pavAngleTo;
  final String? pavHeightFrom;
  final String? pavHeightTo;
  final String? girdleFrom;
  final String? girdleTo;
  final String? starLengthFrom;
  final String? starLengthTo;
  final String? lengthFrom;
  final String? lengthTo;
  final String? widthFrom;
  final String? widthTo;

  const FetchDiamonds({
    this.isRefresh = false,
    this.stock = '',
    this.shapes,
    this.colors,
    this.fancyColors,
    this.clarities,
    this.cuts,
    this.polishes,
    this.symmetries,
    this.labs,
    this.fluorescences,
    this.makes,
    this.culets,
    this.available,
    this.caratFrom,
    this.caratTo,
    this.priceFrom,
    this.priceTo,
    this.ratioFrom,
    this.ratioTo,
    this.depthFrom,
    this.depthTo,
    this.tableFrom,
    this.tableTo,
    this.crAngleFrom,
    this.crAngleTo,
    this.crHeightFrom,
    this.crHeightTo,
    this.pavAngleFrom,
    this.pavAngleTo,
    this.pavHeightFrom,
    this.pavHeightTo,
    this.girdleFrom,
    this.girdleTo,
    this.starLengthFrom,
    this.starLengthTo,
    this.lengthFrom,
    this.lengthTo,
    this.widthFrom,
    this.widthTo,
  });

  @override
  List<Object?> get props => [
        isRefresh, stock, shapes, colors, fancyColors, clarities, cuts, polishes, symmetries, labs, fluorescences,
        makes, culets, available, caratFrom, caratTo, priceFrom, priceTo, ratioFrom, ratioTo, depthFrom, depthTo, tableFrom, tableTo,
        crAngleFrom, crAngleTo, crHeightFrom, crHeightTo, pavAngleFrom, pavAngleTo, pavHeightFrom, pavHeightTo, girdleFrom, girdleTo, starLengthFrom, starLengthTo,
        lengthFrom, lengthTo, widthFrom, widthTo,
      ];
}

class AddToCartEvent extends DiamondEvent {
  final String stock;

  const AddToCartEvent({
    required this.stock,
  });

  @override
  List<Object?> get props => [stock];
}

