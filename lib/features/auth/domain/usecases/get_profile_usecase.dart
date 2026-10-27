import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class GetProfileUseCase implements UseCase<Map<String, dynamic>, GetProfileParams> {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  @override
  Future<Map<String, dynamic>> call(GetProfileParams params) async {
    return await repository.getProfile(userId: params.userId);
  }
}

class GetProfileParams extends Equatable {
  final String userId;

  const GetProfileParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
