import 'package:equatable/equatable.dart';

class Seat extends Equatable {
  final String id;
  final bool isBooked;
  final bool isSelected;

  const Seat({
    required this.id,
    this.isBooked = false,
    this.isSelected = false,
  });

  Seat copyWith({
    String? id,
    bool? isBooked,
    bool? isSelected,
  }) {
    return Seat(
      id: id ?? this.id,
      isBooked: isBooked ?? this.isBooked,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [id, isBooked, isSelected];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isBooked': isBooked,
      'isSelected': isSelected,
    };
  }

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'],
      isBooked: json['isBooked'] ?? false,
      isSelected: json['isSelected'] ?? false,
    );
  }
}