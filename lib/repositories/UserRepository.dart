import '../common/Http.dart';
import '../common/SPUtil.dart';

class UserRepository {

  Future<String> login(String username, String password) async {
    final response = await Http.post<Map<String, dynamic>>('/auth/login', queryParameters: {
      'username': username,
      'password': password,
    });

    if (response['code'] == 200) {
      SPUtil.setString('token', response['data']['token']);
      SPUtil.setString('userName_login', username);
      SPUtil.setString('password_login', password);
      return response['data']['token'];
    }
    throw Exception(response['msg']);
  }

  Future<Map<String, dynamic>> getInfo() async {
    final response = await Http.get<Map<String, dynamic>>('/center/info');
    if (response['code'] == 200) {
      SPUtil.setString('code_login', response['data']['code']);
      SPUtil.setString('name_login', response['data']['name']);

      return response;
    }
    throw Exception(response['msg']);
  }

  Future<Map<String, dynamic>> getOrder() async {
    final response = await Http.get<Map<String, dynamic>>('/chart/order?');
    if (response['code'] == 200) {
      return response;
    }
    return {};
  }
}