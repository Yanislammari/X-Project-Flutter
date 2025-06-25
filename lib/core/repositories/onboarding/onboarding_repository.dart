import '../../models/user.dart';
import 'onboarding_data_source.dart';

class OnBoardingRepository {
  final OnboardingDataSource onboardingDataSource;

  OnBoardingRepository({required this.onboardingDataSource});

  Future<void> registerUser(UserFromBloc user) async{
    return await onboardingDataSource.registerUser(user);
  }
}