import '../../models/user.dart';

abstract class OnboardingDataSource {
  Future<void> registerUser(UserFromBloc user);
}