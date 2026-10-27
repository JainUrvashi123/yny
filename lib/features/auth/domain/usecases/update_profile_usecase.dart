import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<String, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<String> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      userId: params.userId,
      firstName: params.firstName,
      lastName: params.lastName,
      mobile: params.mobile,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String userId;
  final String firstName;
  final String lastName;
  final String mobile;

  const UpdateProfileParams({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.mobile,
  });

  @override
  List<Object?> get props => [userId, firstName, lastName, mobile];
}
