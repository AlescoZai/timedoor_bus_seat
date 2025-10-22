import 'package:equatable/equatable.dart';
import '../models/bus_type.dart';
import '../models/seat.dart';

abstract class SeatBookingState extends Equatable {
  const SeatBookingState();

  @override
  List<Object?> get props => [];
}

class SeatBookingInitial extends SeatBookingState {}

class SeatBookingLoading extends SeatBookingState {}

class SeatBookingLoaded extends SeatBookingState {
  final BusType busType;
  final List<Seat> seats;
  final int totalPrice;
  final int totalRevenue;
  final List<Map<String, dynamic>> bookingHistory;

  const SeatBookingLoaded({
    required this.busType,
    required this.seats,
    required this.totalPrice,
    required this.totalRevenue,
    this.bookingHistory = const [],
  });

  int get selectedSeatsCount => seats.where((s) => s.isSelected).length;
  int get bookedSeatsCount => seats.where((s) => s.isBooked).length;
  bool get allSeatsBooked => bookedSeatsCount == busType.totalSeats;

  SeatBookingLoaded copyWith({
    BusType? busType,
    List<Seat>? seats,
    int? totalPrice,
    int? totalRevenue,
    List<Map<String, dynamic>>? bookingHistory,
  }) {
    return SeatBookingLoaded(
      busType: busType ?? this.busType,
      seats: seats ?? this.seats,
      totalPrice: totalPrice ?? this.totalPrice,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      bookingHistory: bookingHistory ?? this.bookingHistory,
    );
  }

  @override
  List<Object?> get props => [busType, seats, totalPrice, totalRevenue, bookingHistory];
}

class SeatBookingError extends SeatBookingState {
  final String message;

  const SeatBookingError(this.message);

  @override
  List<Object?> get props => [message];
}