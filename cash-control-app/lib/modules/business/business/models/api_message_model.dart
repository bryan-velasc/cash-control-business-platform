class ApiMessageModel {
  final String message;
  final int? productId;
  final int? customerId;
  final int? creditId;
  final int? paymentId;

  const ApiMessageModel({
    required this.message,
    this.productId,
    this.customerId,
    this.creditId,
    this.paymentId,
  });

  factory ApiMessageModel.fromJson(Map<String, dynamic> json) {
    return ApiMessageModel(
      message: json['message']?.toString() ?? '',
      productId: _toNullableInt(json['product_id']),
      customerId: _toNullableInt(json['customer_id']),
      creditId: _toNullableInt(json['credit_id']),
      paymentId: _toNullableInt(json['payment_id']),
    );
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
