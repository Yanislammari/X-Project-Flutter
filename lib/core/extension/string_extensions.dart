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

  bool isEmail() {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+"
      r"@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
    );
    return emailRegex.hasMatch(this);
  }
}

extension NullableStringUtils on String? {
  bool isEmptyOrNull() {
    return this == null || this!.isEmpty;
  }
}