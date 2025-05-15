class CommonResponse<T> {
  final T data;
  final int statusCode;
  final String message;
  final bool success;

  CommonResponse({
    required this.data,
    required this.statusCode,
    required this.message,
    required this.success,
  });

  factory CommonResponse.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return CommonResponse<T>(
      data: fromJsonT(json['data']),
      statusCode: json['statusCode'],
      message: json['message'],
      success: json['success'],
    );
  }
}
