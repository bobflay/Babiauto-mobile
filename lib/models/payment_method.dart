import '../util/json.dart';

class PaymentMethod {
  final int? id;
  final String type; // cash | mobile | card
  final String label;
  final String? provider;
  final String? last4;
  final bool isDefault;

  const PaymentMethod({
    this.id,
    required this.type,
    this.label = '',
    this.provider,
    this.last4,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> j) => PaymentMethod(
        id: asIntOrNull(j['id']),
        type: asString(j['type']),
        label: asString(j['label']),
        provider: asStringOrNull(j['provider']),
        last4: asStringOrNull(j['last4']),
        isDefault: asBool(j['is_default']),
      );
}
