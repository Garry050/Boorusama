// Package imports:
import 'package:dio/dio.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../downloads/urls/sanitizer.dart';
import '../../errors/types.dart';

typedef DataFetcher<T> = Future<T> Function();

TaskEither<BooruError, T> tryFetchRemoteData<T>({
  required DataFetcher<T> fetcher,
}) => TaskEither.tryCatch(
  () => fetcher(),
  (error, stackTrace) => error is DioException
      ? error.response.toOption().fold(
          () => AppError(type: AppErrorType.cannotReachServer),
          (response) => ServerError(
            httpStatusCode: response.statusCode,
            message: response.data,
          ),
        )
      : AppError(type: AppErrorType.loadDataFromServerFailed),
);

abstract interface class AppHttpHeaders {
  static const cookieHeader = 'cookie';
  static const contentLengthHeader = 'content-length';
  static const userAgentHeader = 'user-agent';
}

const _kImageExtensions = {
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.webp',
  '.avif',
  '.svg',
};

bool defaultImageRequestChecker(Uri uri) {
  final ext = sanitizedExtension(uri.toString());

  return _kImageExtensions.contains(ext);
}

class HttpUtils {
  static bool isImageRequest(RequestOptions options) {
    return defaultImageRequestChecker(options.uri);
  }
}
