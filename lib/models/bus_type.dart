enum BusType {
  regular,
  express,
}

extension BusTypeExtension on BusType {
  int get totalSeats => this == BusType.regular ? 20 : 12;
  int get seatsPerRow => this == BusType.regular ? 2 : 3;
  int get pricePerSeat => this == BusType.regular ? 85000 : 150000;
  String get name => this == BusType.regular ? 'Regular' : 'Express';
}