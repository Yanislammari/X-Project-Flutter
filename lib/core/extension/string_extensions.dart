extension StringExtensions on String {
  String deleteException() {
    String errorMessage;
    const prefix = "Exception: ";
    if (startsWith(prefix)) {
      errorMessage = substring(prefix.length);
    } else {
      errorMessage = this;
    }
    return errorMessage;
  }
}