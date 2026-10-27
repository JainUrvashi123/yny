import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SubmitContactUseCase implements UseCase<String, SubmitContactParams> {
  final AuthRepository repository;

  SubmitContactUseCase(this.repository);

  @override
  Future<String> call(SubmitContactParams params) async {
    return await repository.submitContactForm(
      fullName: params.fullName,
      email: params.email,
      mobile: params.mobile,
      message: params.message,
    );
  }
}

class SubmitContactParams extends Equatable {
  final String fullName;
  final String email;
  final String mobile;
  final String message;

  const SubmitContactParams({
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.message,
  });

  @override
  List<Object?> get props => [fullName, email, mobile, message];
}
