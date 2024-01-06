import 'dart:io';
import 'package:splitwise_pro/util/internet_connection_checker/internet_connection_checker_client.dart';

class InternetConnectionCheckerMobileClient
    implements InternetConnectionCheckerClient {
  @override
  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

InternetConnectionCheckerClient getInternetConnectionChecker() =>
    InternetConnectionCheckerMobileClient();
