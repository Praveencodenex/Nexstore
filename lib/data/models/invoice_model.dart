class InvoiceResponse {
  final bool status;
  final String message;
  final InvoiceData data;

  InvoiceResponse({
    this.status = false,
    this.message = '',
    InvoiceData? data,
  }) : data = data ?? InvoiceData();

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: InvoiceData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class InvoiceData {
  final String invoiceUrl;

  InvoiceData({this.invoiceUrl = ''});

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      invoiceUrl: json['invoice_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_url': invoiceUrl,
    };
  }
}
