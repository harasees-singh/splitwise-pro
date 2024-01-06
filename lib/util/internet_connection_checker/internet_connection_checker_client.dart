import 'package:splitwise_pro/util/internet_connection_checker/internet_connection_checker_stub.dart'
if (dart.library.io) 'package:splitwise_pro/util/internet_connection_checker/internet_connection_checker_mobile.dart'
if (dart.library.html) 'package:splitwise_pro/util/internet_connection_checker/internet_connection_checker_web.dart';

abstract class InternetConnectionCheckerClient {
  Future<bool> isConnected();
  factory InternetConnectionCheckerClient() => getInternetConnectionChecker();
}
