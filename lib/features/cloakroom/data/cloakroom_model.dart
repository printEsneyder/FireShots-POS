class CloakroomItem {
  final String id;
  final String ticketNumber;
  final String itemType;
  final String customerName;
  final String observations;
  final String receivedBy;
  final bool isReturned;
  final DateTime createdAt;

  const CloakroomItem({
    required this.id,
    required this.ticketNumber,
    required this.itemType,
    required this.customerName,
    this.observations = '',
    required this.receivedBy,
    this.isReturned = false,
    required this.createdAt,
  });

  factory CloakroomItem.fromMap(String id, Map<String, dynamic> map) {
    return CloakroomItem(
      id: id,
      ticketNumber: map['ticketNumber'] as String? ?? '',
      itemType: map['itemType'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      observations: map['observations'] as String? ?? '',
      receivedBy: map['receivedBy'] as String? ?? '',
      isReturned: map['isReturned'] as bool? ?? false,
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticketNumber': ticketNumber,
      'itemType': itemType,
      'customerName': customerName,
      'observations': observations,
      'receivedBy': receivedBy,
      'isReturned': isReturned,
      'createdAt': createdAt,
    };
  }

  CloakroomItem copyWith({
    String? id,
    String? ticketNumber,
    String? itemType,
    String? customerName,
    String? observations,
    String? receivedBy,
    bool? isReturned,
    DateTime? createdAt,
  }) {
    return CloakroomItem(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      itemType: itemType ?? this.itemType,
      customerName: customerName ?? this.customerName,
      observations: observations ?? this.observations,
      receivedBy: receivedBy ?? this.receivedBy,
      isReturned: isReturned ?? this.isReturned,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
