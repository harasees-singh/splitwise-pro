import 'package:splitwise_pro/util/internet_connection_checker/internet_connection_checker_client.dart';
import 'dart:html' as html;

class InternetConnectionCheckerWebClient
    implements InternetConnectionCheckerClient {
  @override
  Future<bool> isConnected() {
    return Future.value(html.window.navigator.onLine ?? false);
  }
}

InternetConnectionCheckerClient getInternetConnectionChecker() =>
    InternetConnectionCheckerWebClient();
