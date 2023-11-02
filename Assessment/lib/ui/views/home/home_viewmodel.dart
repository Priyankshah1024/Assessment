import 'dart:async';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../locator.dart';
import '../../../main.dart';

class HomeViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();

  HomeViewModel() {}
  void navigateToSchedule() {
    _navigationService.navigateTo('schedule');
  }
  FutureOr<void> navigateToScheduleScreen() async {
    await _navigationService.navigateTo(Routes.scheduleView);
  }
}
