import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class DeleteAccountUseCase implements UseCase<String, DeleteAccountParams> {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  @override
  Future<String> call(DeleteAccountParams params) async {
    return await repository.deleteAccount(userId: params.userId);
  }
}

class DeleteAccountParams extends Equatable {
  final String userId;

  const DeleteAccountParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
