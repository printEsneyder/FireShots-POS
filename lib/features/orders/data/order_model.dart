class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  double get subtotal => price * quantity;
}

class OrderModel {
  final String id;
  final String? customerName;
  final int tableNumber;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String? servedBy;
  final String? paymentMethod;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    this.customerName,
    required this.tableNumber,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.servedBy,
    this.paymentMethod,
    required this.createdAt,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    final itemsList = (map['items'] as List<dynamic>?)
            ?.map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    return OrderModel(
      id: id,
      customerName: map['customerName'] as String?,
      tableNumber: (map['tableNumber'] as num?)?.toInt() ?? 0,
      items: itemsList,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'pending',
      servedBy: map['servedBy'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'tableNumber': tableNumber,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'servedBy': servedBy,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt,
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerName,
    int? tableNumber,
    List<OrderItem>? items,
    double? totalAmount,
    String? status,
    String? servedBy,
    String? paymentMethod,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      tableNumber: tableNumber ?? this.tableNumber,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      servedBy: servedBy ?? this.servedBy,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
