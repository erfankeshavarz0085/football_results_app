class ErrorMessages {
  static String fromException(Object error) {
    final rawMessage = error.toString();
    final message = rawMessage.toLowerCase();

    if (message.contains('api is disabled')) {
      return 'API Safe Mode is enabled. Turn API_ENABLED on in .env to load real data.';
    }

    if (message.contains('suspended')) {
      return 'Your API-Football account is suspended. Check the dashboard or use a new API key.';
    }

    if (message.contains('free plan') ||
        message.contains('free plans') ||
        message.contains('not available on the free plan')) {
      return 'This date or season is not available on your free API plan. Try another nearby date.';
    }

    if (message.contains('timeout')) {
      return 'The request timed out. Check your internet connection and try again.';
    }

    if (message.contains('failed to fetch') ||
        message.contains('socketexception') ||
        message.contains('network')) {
      return 'Could not connect to the football API. Check your connection and try again.';
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
}
