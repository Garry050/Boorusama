// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:socks5_proxy/socks.dart' as socks;

// Project imports:
import '../../../boorus/booru/booru.dart';
import '../../../foundation/loggers.dart';
import '../../../foundation/platform.dart';
import '../../../proxy/proxy.dart';
import '../../../router.dart';
import '../cloudflare_challenge_interceptor.dart';
import '../http_utils.dart';
import '../network_protocol.dart';
import 'dio_ext.dart';
import 'dio_image_deduplicate_interceptor.dart';
import 'dio_logger_interceptor.dart';
import 'dio_options.dart';

// List of HTTP status codes where cached data should NOT be shown
const List<int> nonCacheableStatusCodes = [
  // Authentication and Authorization Errors
  401, // Unauthorized: User credentials are missing, invalid, or expired.
  403, // Forbidden: User doesn't have permission to access the resource.

  // Client-Side Errors
  400, // Bad Request: Malformed request (e.g., invalid query parameters).
  405, // Method Not Allowed: Invalid request method for the resource.
  406, // Not Acceptable: Response format incompatible with client's "Accept" header.

  // Server Errors Indicating Instability
  500, // Internal Server Error: Generic server error; data might be unreliable.
  502, // Bad Gateway: Intermediary issue (e.g., reverse proxy failure).
  503, // Service Unavailable: Temporary server unavailability (e.g., maintenance).
  504, // Gateway Timeout: Timeout while waiting for an upstream server.

  // Content Delivery Issues
  409, // Conflict: Conflicting changes to a resource (e.g., version control).
  417, // Expectation Failed: Failed "Expect" header condition.
  422, // Unprocessable Entity: Semantic issues with the request payload.

  // Legal and Rate Limiting Issues
  451, // Unavailable For Legal Reasons: Resource restricted due to legal policies.
];

Dio newGenericDio({
  required String baseUrl,
  String? userAgent,
  Directory? cacheDir,
  Logger? logger,
  bool? supportsHttp2,
  Map<String, dynamic>? headers,
  ProxySettings? proxySettings,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        if (userAgent != null) AppHttpHeaders.userAgentHeader: userAgent,
        ...?headers,
      },
    ),
  )..httpClientAdapter = _createHttpClientAdapter(
      logger: logger,
      userAgent: userAgent,
      supportsHttp2: supportsHttp2,
      proxy: proxySettings,
    );

  if (cacheDir != null) {
    dio.interceptors.add(
      DioCacheInterceptor(
        options: CacheOptions(
          store: HiveCacheStore(cacheDir.path),
          maxStale: const Duration(days: 7),
          hitCacheOnErrorExcept: nonCacheableStatusCodes,
        ),
      ),
    );
  }

  dio.interceptors.add(ImageRequestDeduplicateInterceptor());

  if (logger != null) {
    dio.interceptors.add(
      LoggingInterceptor(
        logger: logger,
      ),
    );
  }

  return dio;
}

Dio newDio({required DioOptions options}) {
  final booruConfig = options.authConfig;
  final booruFactory = options.booruFactory;
  final baseUrl = options.baseUrl;

  final booru = booruFactory.getBooruFromUrl(baseUrl) ??
      booruFactory.getBooruFromId(booruConfig.booruId);
  final supportsHttp2 =
      booru?.getSiteProtocol(baseUrl) == NetworkProtocol.https_2_0;
  final apiUrl = booru?.getApiUrl(baseUrl) ?? baseUrl;

  final dio = newGenericDio(
    baseUrl: _cleanUrl(apiUrl),
    userAgent: options.userAgent,
    cacheDir: options.cacheDir,
    logger: options.loggerService,
    supportsHttp2: supportsHttp2,
    proxySettings: options.proxySettings,
  );

  final context = navigatorKey.currentContext;
  if (context != null) {
    dio.interceptors.add(
      CloudflareChallengeInterceptor(
        cookieJar: options.cookieJar,
        context: context,
      ),
    );
  }

  return dio;
}

HttpClientAdapter _createHttpClientAdapter({
  Logger? logger,
  String? userAgent,
  bool? supportsHttp2,
  ProxySettings? proxy,
}) {
  final proxySettings = proxy != null
      ? proxy.enable
          ? proxy
          : null
      : null;
  final proxyAddress = proxySettings?.getProxyAddress();
  final hasHttp2Support = supportsHttp2 ?? false;

  if ((isAndroid() || isIOS() || isMacOS()) && proxySettings == null) {
    logger?.logI('Network', 'Using native adapter');
    return newNativeAdapter(
      userAgent: userAgent,
    );
  } else if (hasHttp2Support && proxySettings == null) {
    logger?.logI(
      'Network',
      'Using HTTP2 adapter',
    );

    return Http2Adapter(
      ConnectionManager(
        idleTimeout: const Duration(seconds: 30),
      ),
    );
  } else {
    logger?.logI('Network', 'Using default adapter');
    return IOHttpClientAdapter(
      createHttpClient: proxySettings != null && proxyAddress != null
          ? () {
              final client = HttpClient();
              final username = proxySettings.username;
              final password = proxySettings.password;
              final port = proxySettings.port;
              final host = proxySettings.host;

              logger?.logI(
                'Network',
                'Using proxy: ${proxySettings.type.name.toUpperCase()} $host:$port',
              );

              if (proxySettings.type == ProxyType.socks5) {
                socks.SocksTCPClient.assignToHttpClient(
                  client,
                  [
                    socks.ProxySettings(
                      InternetAddress(host),
                      port,
                      username: username,
                      password: password,
                    ),
                  ],
                );
              } else {
                final credentials = username != null && password != null
                    ? HttpClientBasicCredentials(username, password)
                    : null;

                client
                  ..badCertificateCallback = (cert, host, port) {
                    return true;
                  }
                  ..findProxy = (uri) {
                    final address = '$host:$port';

                    return 'PROXY $address';
                  };

                if (credentials != null) {
                  client.addProxyCredentials(host, port, 'main', credentials);
                }
              }

              return client;
            }
          : null,
    );
  }
}

// Some user might input the url with /index.php/ or /index.php so we need to clean it
String _cleanUrl(String url) {
  // if /index.php/ or /index.php is present, remove it
  if (url.endsWith('/index.php/')) {
    return url.replaceAll('/index.php/', '/');
  } else if (url.endsWith('/index.php')) {
    return url.replaceAll('/index.php', '/');
  } else {
    return url;
  }
}
