import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class UpdatePasswordUseCase implements UseCase<String, UpdatePasswordParams> {
  final AuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  @override
  Future<String> call(UpdatePasswordParams params) async {
    return await repository.updatePassword(
      userId: params.userId,
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }
}

class UpdatePasswordParams extends Equatable {
  final String userId;
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const UpdatePasswordParams({
    required this.userId,
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [userId, oldPassword, newPassword, confirmPassword];
}
