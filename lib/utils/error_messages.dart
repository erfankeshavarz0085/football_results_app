class ErrorMessages {
  static String fromException(Object error) {
    final rawMessage = error.toString();
    final message = rawMessage.toLowerCase();

    if (message.contains('api is disabled')) {
      return 'API Safe Mode is enabled. Turn API_ENABLED=true in .env when you want to use real API requests.';
    }

    if (message.contains('suspended')) {
      return 'Your API-Football account is suspended. Check the API dashboard or replace the API key.';
    }

    if (message.contains('free plan') ||
        message.contains('free plans') ||
        message.contains('not available on the free plan') ||
        message.contains('not have access')) {
      return 'This date or season is not available on the free API plan. Try a supported date or season.';
    }

    if (message.contains('timeout')) {
      return 'The request timed out. Check your connection, then try again.';
    }

    if (message.contains('failed to fetch') ||
        message.contains('socketexception') ||
        message.contains('clientexception') ||
        message.contains('network')) {
      return 'Could not reach the football API. Check your connection, CORS/browser access, or try again.';
    }

    if (message.contains('api key is missing')) {
      return 'API key is missing. Add API_KEY to your .env file.';
    }

    if (message.contains('401') || message.contains('403')) {
      return 'The API key is not authorized. Check your API key and plan.';
    }

    if (message.contains('429') || message.contains('rate')) {
      return 'API request limit reached. Please wait before trying again.';
    }

    return 'Something went wrong while loading football data. Please try again.';
  }

  static bool isApiError(String message) {
    final normalized = message.toLowerCase();

    return normalized.contains('api') ||
        normalized.contains('connect') ||
        normalized.contains('connection') ||
        normalized.contains('timeout') ||
        normalized.contains('request') ||
        normalized.contains('key') ||
        normalized.contains('plan') ||
        normalized.contains('suspended') ||
        normalized.contains('fetch');
  }
}
