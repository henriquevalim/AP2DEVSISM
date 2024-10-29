import 'package:http/http.dart' as http;
import 'package:http/http.dart';

abstract interface class HttpClient<T> {
  Future<T> get({required String url});
}

class IHttpClient implements HttpClient {
  http.Client client = http.Client();

  @override
  Future<Response> get({required String url}) async {
    return await client.get(Uri.parse(url));
  }
}
