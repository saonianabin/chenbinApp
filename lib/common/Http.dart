import '../common/SPUtil.dart';
import 'package:dio/dio.dart';
import 'dart:developer';

class Http {

  static final BaseOptions _options = BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    contentType: Headers.jsonContentType,
  );



  static final Dio _dio = Dio(_options);

  static Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    final token = SPUtil.getString('token') ?? '';
    var ip = SPUtil.getString('IP');
    var port = SPUtil.getString('PORT');
    var url = 'http://$ip:$port$path';
    Options options = Options(
      headers: {
        'X-Auth-Token': '$token',
        'Content-Type': 'application/json',
      },
    );

    log('get参数: $queryParameters');
    log('get请求地址: $url');

    final response = await _dio.get(url,options: options,queryParameters: queryParameters);
    return response.data as T;
  }

  static Future<T> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {


    final token = SPUtil.getString('token') ?? '';
    var ip = SPUtil.getString('IP');
    var port = SPUtil.getString('PORT');
    var url = 'http://$ip:$port$path';
    Options options = Options(
      headers: {
        'X-Auth-Token': '$token',
        'Content-Type': 'application/json',
      },
    );
    log('post参数: $queryParameters');
    log('post请求地址: $url');
    //log('post请求地址2: http://${server.address.host}:${server.port}');
    final response = await _dio.post(url,options: options, data: data, queryParameters: queryParameters);
    return response.data as T;
  }

  static Future<T> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {

    final token = SPUtil.getString('token') ?? '';
    var ip = SPUtil.getString('IP');
    var port = SPUtil.getString('PORT');
    var url = 'http://$ip:$port$path';
    Options options = Options(
      headers: {
        'X-Auth-Token': '$token',
        'Content-Type': 'application/json',
      },
    );
    log('put参数: $queryParameters');
    log('put请求地址: $url');
    final response = await _dio.put(url,options: options, data: data, queryParameters: queryParameters);
    return response.data as T;
  }

  static Future<T> delete<T>(String path, {Map<String, dynamic>? queryParameters}) async {

    final token = SPUtil.getString('token') ?? '';
    var ip = SPUtil.getString('IP');
    var port = SPUtil.getString('PORT');
    var url = 'http://$ip:$port$path';
    Options options = Options(
      headers: {
        'X-Auth-Token': '$token',
        'Content-Type': 'application/json',
      },
    );

    log('delete参数: $queryParameters');
    log('delete请求地址: $url');
    final response = await _dio.delete(url,options: options, queryParameters: queryParameters);
    return response.data as T;
  }


  static Future<T> patch<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final token = SPUtil.getString('token') ?? '';
    var ip = SPUtil.getString('IP');
    var port = SPUtil.getString('PORT');
    var url = 'http://$ip:$port$path';
    Options options = Options(
      headers: {
        'X-Auth-Token': '$token',
        'Content-Type': 'application/json',
      },
    );

    log('patch参数: $queryParameters');
    log('patch请求地址: $url');

    final response = await _dio.patch(url, options: options, data: data, queryParameters: queryParameters);
    return response.data as T;
  }



}
