import 'package:equatable/equatable.dart';
import '../../data/models/diamond_model.dart';

abstract class DiamondState extends Equatable {
  const DiamondState();

  @override
  List<Object?> get props => [];
}

class DiamondInitial extends DiamondState {}

class DiamondLoading extends DiamondState {}

class DiamondLoaded extends DiamondState {
  final List<DiamondModel> diamonds;
  final int totalRecords;
  final int page;
  final bool hasReachedMax;
  final int unfilteredTotalCount;

  const DiamondLoaded({
    required this.diamonds,
    required this.totalRecords,
    required this.page,
    required this.hasReachedMax,
    this.unfilteredTotalCount = 0,
  });

  @override
  List<Object?> get props => [diamonds, totalRecords, page, hasReachedMax, unfilteredTotalCount];

  DiamondLoaded copyWith({
    List<DiamondModel>? diamonds,
    int? totalRecords,
    int? page,
    bool? hasReachedMax,
    int? unfilteredTotalCount,
  }) {
    return DiamondLoaded(
      diamonds: diamonds ?? this.diamonds,
      totalRecords: totalRecords ?? this.totalRecords,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      unfilteredTotalCount: unfilteredTotalCount ?? this.unfilteredTotalCount,
    );
  }
}

class DiamondError extends DiamondState {
  final String message;

  const DiamondError(this.message);

  @override
  List<Object?> get props => [message];
}
