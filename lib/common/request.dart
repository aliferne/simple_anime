import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:simple_anime/conf.dart';

class Request {
  // based on Dio to send request
  static late final Dio _dio;
  // get base url
  static final baseUrl = getAppBaseUrl();

  static Dio get dio => _dio;

  /// Initialize request
  ///
  /// WARN: must be called before `runApp`, in `main` function
  static void init() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
  }

  /// GET method
  ///
  /// [url] URL of request, if use `baseUri` in the class(`isInOrigin` is `true`), only relative path is needed
  /// e.g. `/api/v1/user`, then get method will send request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user`
  /// @see [baseUrl], [getAppBaseUrl], and env file for more details.
  ///
  /// [isInOrigin] Whether the request is in the origin, if set to `false`, the request will not be added to the base url
  ///
  /// [options] The options of a request
  ///
  /// [queryParameters] Query parameters of request, if set, it will be added to the request url
  /// e.g. `{"name": "John", "age": 20}`, then get method will request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user?name=John&age=20`
  ///
  /// @see [baseUrl], [getAppBaseUrl], and env file for more details.
  static Future<Response?> get(
    String url, {
    bool isInOrigin = true,
    Options? options,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken, // support cancel request
  }) async {
    return _sendHTTPRequest(
      url,
      isInOrigin: isInOrigin,
      options: options,
      dioFunction: _dio.get,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }

  /// POST method
  ///
  /// [url] URL of request, if use `baseUri` in the class(`isInOrigin` is `true`), only relative path is needed
  /// e.g. `/api/v1/user`, then get method will send request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user`
  /// @see [baseUrl], [getAppBaseUrl], and env file for more details.
  ///
  /// [isInOrigin] Whether the request is in the origin, if set to `false`, the request will not be sent to the base url
  ///
  /// [options] The options of a request
  ///
  /// [queryParameters] Query parameters of request, if set, it will be added to the request url
  /// e.g. `{"name": "John", "age": 20}`, then get method will request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user?name=John&age=20`
  ///
  /// [postData] Post Data of request, if set, it will be added to the request body
  /// e.g. `{"name": "John", "age": 20}`, then post method will request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user`
  ///
  /// @see [baseUrl], [getAppBaseUrl], and env file for more details.
  static Future<Response?> post(
    String url, {
    bool isInOrigin = true,
    Options? options,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? postData,
    CancelToken? cancelToken, // support cancel request
  }) async {
    return _sendHTTPRequest(
      url,
      isInOrigin: isInOrigin,
      options: options,
      dioFunction: _dio.post,
      queryParameters: queryParameters,
      queryData: postData,
      cancelToken: cancelToken,
    );
  }

  /// PUT method
  ///
  /// [url] URL of request, if use `baseUri` in the class(`isInOrigin` is `true`), only relative path is needed
  /// e.g. `/api/v1/user`, then get method will send request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user`
  /// @see [baseUrl], [getAppBaseUrl], and env file for more details.
  ///
  /// [isInOrigin] Whether the request is in the origin, if set to `false`, the request will
  /// not be sent to the base url
  ///
  /// [options] The options of a request
  ///
  /// [putData] Put Data of request, if set, it will be added to the request body
  /// e.g. assuming that in `APP_SCHEME://APP_HOST:APP_IP/api/v1/user`,
  /// at first is: `{"name": "John", "age": 20}`,
  /// if you send `{"name": "Tom", "age": 10}`, then the request will be sent to
  /// `APP_SCHEME://APP_HOST:APP_IP/api/v1/user`
  /// with data: `{"name": "Tom", "age": 10}`
  /// and then the response will be: `{"name": "Tom", "age": 10}`
  ///
  /// [queryParameters] Query parameters of request, if set, it will be added to the request url
  /// e.g. `{"name": "John", "age": 20}`, then get method will request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user?name=John&age=20`
  ///
  /// @see [baseUrl], [getAppBaseUrl], and env file for more details.
  ///
  /// WARN: PUT Method is for full update, if you want to update part of the data, use PATCH method
  static Future<Response?> put(
    String url, {
    bool isInOrigin = true,
    Options? options,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? putData,
    CancelToken? cancelToken, // support cancel request
  }) async {
    return _sendHTTPRequest(
      url,
      isInOrigin: isInOrigin,
      options: options,
      dioFunction: _dio.post,
      queryParameters: queryParameters,
      queryData: putData,
      cancelToken: cancelToken,
    );
  }

  /// PATCH method
  ///
  /// [url] URL of request, if use `baseUri` in the class(`isInOrigin` is `true`), only relative path is needed
  /// e.g. `/api/v1/user`, then get method will send request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user`
  /// @see [baseUrl], [getAppBaseUrl], and env file for more details.
  ///
  /// [isInOrigin] Whether the request is in the origin, if set to `false`, the request will
  /// not be sent to the base url
  ///
  /// [options] The options of a request
  ///
  /// [patchData] Patch Data of request, if set, it will be added to the request body
  /// e.g. assuming that in `APP_SCHEME://APP_HOST:APP_IP/api/v1/user`,
  /// at first is: `{"name": "John", "age": 20}`,
  /// if you send `{"name": "Tom"}`, then the request will be sent to
  /// `APP_SCHEME://APP_HOST:APP_IP/api/v1/user`
  /// with data: `{"name": "Tom"}`
  /// and then the response will be: `{"name": "Tom", "age": 20}`
  ///
  /// [queryParameters] Query parameters of request, if set, it will be added to the request url
  /// e.g. `{"name": "John", "age": 20}`, then get method will request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user?name=John&age=20`
  ///
  /// @see [baseUrl], [getAppBaseUrl], and env file for more details.
  ///
  /// WARN: PATCH Method is for partly update, if you want to update all of the data, use PUT method
  static Future<Response?> patch(
    String url, {
    bool isInOrigin = true,
    Options? options,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? patchData,
    CancelToken? cancelToken, // support cancel request
  }) async {
    return _sendHTTPRequest(
      url,
      isInOrigin: isInOrigin,
      options: options,
      dioFunction: _dio.patch,
      queryParameters: queryParameters,
      queryData: patchData,
      cancelToken: cancelToken,
    );
  }

  /// DELETE method
  ///
  /// [url] URL of request, if use `baseUri` in the class(`isInOrigin` is `true`), only relative path is needed
  /// e.g. `/api/v1/user`, then get method will send request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user`
  /// @see [baseUrl], [getAppBaseUrl], and env file for more details.
  ///
  /// [isInOrigin] Whether the request is in the origin, if set to `false`, the request will
  /// not be sent to the base url
  ///
  /// [options] The options of a request
  ///
  /// [queryParameters] Query parameters of request, if set, it will be added to the request url
  /// e.g. `{"name": "John", "age": 20}`, then get method will request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user?name=John&age=20`
  ///
  /// @see [baseUrl], [getAppBaseUrl], and env file for more details.
  static Future<Response?> delete(
    String url, {
    bool isInOrigin = true,
    Options? options,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken, // support cancel request
  }) async {
    return _sendHTTPRequest(
      url,
      isInOrigin: isInOrigin,
      options: options,
      dioFunction: _dio.delete,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }

  /// send http request
  ///
  /// [url] URL of request, if use `baseUri` in the class(`isInOrigin` is `true`), only relative path is needed
  /// e.g. `/api/v1/user`, then get method will send request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user`
  /// @see [baseUrl], [getAppBaseUrl], and env file for more details.
  ///
  /// [isInOrigin] Whether the request is in the origin, if set to `false`, the request will not be sent to the base url
  ///
  /// [dioFunction] requires value in [_dio.get], [_dio.post], [_dio.put], [_dio.delete], [_dio.patch]
  ///
  /// [options] The options of a request
  ///
  /// [queryParameters] Query parameters of request, if set, it will be added to the request url
  /// e.g. `{"name": "John", "age": 20}`, then get method will request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user?name=John&age=20`
  ///
  /// [queryData] Post/Put/Patch Data of request, if set, it will be added to the request body
  /// e.g. `{"name": "John", "age": 20}`, then post method will request to `APP_SCHEME://APP_HOST:APP_IP/api/v1/user`
  ///
  /// @see [baseUrl], [getAppBaseUrl], and env file for more details.
  static Future<Response?> _sendHTTPRequest(
    String url, {
    bool isInOrigin = true,
    required Function dioFunction,
    Options? options,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? queryData,
    CancelToken? cancelToken, // support cancel request
  }) async {
    // assert if dioFunction is valid
    assert(
      [
        _dio.get,
        _dio.post,
        _dio.put,
        _dio.delete,
        _dio.patch,
      ].contains(dioFunction),
      "dioFunction should be one of [dio.get, dio.post, dio.put, dio.delete, dio.patch]",
    );
    // get request type
    final methods = _checkRequestType(dioFunction);

    // concat url
    if (isInOrigin) {
      url = concatUri(
        baseUri: baseUrl,
        path: url,
        queryParameters: queryParameters,
      );
    }

    try {
      final response = await dioFunction(
        url,
        options: options,
        queryParameters: queryParameters,
        data: queryData,
        cancelToken: cancelToken,
      );
      // if not status.ok, log a warn message
      if (response.statusCode != 200) {
        final errorType = _getRequestErrorTypeFromStatusCode(
          response.statusCode!,
        );

        logger.w(
          "Something may go wrong, status code: ${response.statusCode}, response: ${response.data}",
        );
        throw RequestException(errorType: errorType, message: response.data);
      }
      // return response
      return response;
    } on DioException catch (e) {
      _onHTTPRequestError(
        methods,
        errorType: e.type,
        e: e.error.toString(),
        url: url,
      );
    } catch (otherError) {
      throw RequestException(
        errorType: RequestErrorType.other,
        message: otherError.toString(),
      );
    }
    return null;
  }

  /// handle http request error
  ///
  /// [method] HTTP method of request, e.g. GET, POST, PUT, DELETE, PATCH
  ///
  /// [errorType] Error type of request, if not set, it will be set to `RequestErrorType.other`
  ///
  /// [url] URL of request
  ///
  /// [e] Error of request, this function is usually called in `catch` block, so it is ok to directly pass the error
  static void _onHTTPRequestError(
    String method, {
    required DioExceptionType errorType,
    required String url,
    required Object e,
  }) {
    // if just cancel a request
    if (e is DioException && e.type == DioExceptionType.cancel) {
      // showMessageBySnackBar("<$method> Request canceled", context: context);
      logger.i("<$method> Request canceled: $url");
    }

    throw RequestException(errorType: errorType, message: e.toString());
  }

  /// get error type from status code
  ///
  /// [statusCode] Status code of request
  static RequestErrorType _getRequestErrorTypeFromStatusCode(int statusCode) {
    final errorType = statusCode >= 500
        ? RequestErrorType.serverError
        : RequestErrorType.clientError;
    return errorType;
  }

  /// get request type from dio function
  ///
  /// [method] Dio function, e.g. dio.get, dio.post, dio.put, dio.delete, dio.patch
  static String _checkRequestType(Function dioFunction) {
    String methods = "GET";
    if (dioFunction == _dio.get) {
      methods = "GET";
    } else if (dioFunction == _dio.post) {
      methods = "POST";
    } else if (dioFunction == _dio.put) {
      methods = "PUT";
    } else if (dioFunction == _dio.delete) {
      methods = "DELETE";
    } else if (dioFunction == _dio.patch) {
      methods = "PATCH";
    }
    return methods;
  }
}

/// Errors of Request
enum RequestErrorType {
  networkError,
  serverError,
  clientError,
  requestError,
  timeout,
  other,
}

/// Request Exception
class RequestException implements Exception {
  // please ensure that is an errorType, not other messages
  final dynamic errorType;
  final String message;
  final int? statusCode;

  RequestException({
    required this.errorType,
    required this.message,
    this.statusCode,
  });

  @override
  String toString() {
    return "RequestException(\n\terrorType: $errorType,\n\tmessage: $message,\n\tstatusCode: $statusCode\n)";
  }
}

/// Concantenate URI and return it as String
///
/// [useBaseUri] Whether to use base uri, default is true
///
/// [baseUri] Base uri, e.g. http://localhost:8080/
///
/// [scheme] Scheme of uri, default is http
///
/// [host] Host of uri
///
/// [port] Port of uri
///
/// [path] Path of uri
///
/// [queryParameters] Query parameters of uri
///
/// NOTE: if useBaseUri is true, scheme, host and port will be ignored
String concatUri({
  // since cross origin seldom happens
  bool useBaseUri = true,
  String? baseUri,
  String? scheme,
  String? host,
  int? port,
  String? path,
  Map<String, dynamic>? queryParameters,
}) {
  final Uri base;

  // when use base uri, parse it
  if (useBaseUri) {
    base = Uri.parse(baseUri!);
  } else {
    base = Uri(scheme: scheme, host: host, port: port);
  }
  // save the original path
  // e.g. http://localhost:8080/shema => http://localhost:8080/shema/api
  String finalPath = base.path;

  if (path != null && path.isNotEmpty) {
    // remove trailing slash
    if (finalPath.endsWith('/')) {
      finalPath = finalPath.substring(0, finalPath.length - 1);
    }

    // ensure starts with slash
    if (!path.startsWith('/')) {
      finalPath += '/$path';
    } else {
      finalPath += path;
    }
  }

  // replace params
  return base
      .replace(path: finalPath, queryParameters: queryParameters)
      .toString();
}

/// Concatenate scheme, host and port to get the base url of app
String getAppBaseUrl() {
  final appScheme = FileConf.appScheme;
  final appHost = FileConf.appHost;
  final appIP = FileConf.appIP;

  // null check
  if (appScheme == null || appScheme.isEmpty) {
    throw Exception(
      "Invalid APP_SCHEME value: $appScheme, please check your env file",
    );
  }

  if (appHost == null || appHost.isEmpty) {
    throw Exception(
      "Invalid APP_HOST value: $appHost, please check your env file",
    );
  }

  if (appIP == null || appHost.isEmpty) {
    throw Exception("Invalid APP_IP value: $appIP, please check your env file");
  }

  return concatUri(
    useBaseUri: false,
    scheme: appScheme,
    host: appHost,
    port: int.parse(appIP),
  );
}

/// Create response
///
/// [status] Status, it can be only "success" or "failed"
///
/// [statusCode] Status code, it can be one of the http status code
///
/// [data] Response Data
String createResponse({
  String? status,
  int? statusCode,
  required Map<String, dynamic> data,
}) {
  if (status == null && statusCode == null) {
    throw Exception("Status or status_code must be provided");
  }

  if (!(["success", "failed"].contains(status))) {
    throw Exception("Status must be 'success' or 'failed'");
  }

  // if status is null, use statusCode, otherwise status
  return jsonEncode({"status": status ?? statusCode, "data": data});
}


// NOTE: How to use? Try it in home.dart
// /// this is used for retrying a request that may be failed
// /// 
// /// this function will take a request function and a retry count as parameters
// /// if the request fails, it will retry the request up to the retry count
// ///
// /// [request] is the function that will be called to make the request
// ///
// /// [retryCount] is the number of times the request will be retried if it fails
// dynamic requestWithRetry({
//   required Function request,
//   int retryCount = 3,
// }) async {
//   try {
//     return await request();
//   } catch (e) {
//     if (retryCount > 0) {
//       return await requestWithRetry(
//         request: request,
//         retryCount: retryCount - 1,
//       );
//     }

//     throw e;
//   }
// }
