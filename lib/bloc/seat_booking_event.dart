import 'package:equatable/equatable.dart';
import '../models/bus_type.dart';

abstract class SeatBookingEvent extends Equatable {
  const SeatBookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadSeats extends SeatBookingEvent {
  final BusType busType;

  const LoadSeats(this.busType);

  @override
  List<Object?> get props => [busType];
}

class ChangeBusType extends SeatBookingEvent {
  final BusType busType;

  const ChangeBusType(this.busType);

  @override
  List<Object?> get props => [busType];
}

class ToggleSeatSelection extends SeatBookingEvent {
  final String seatId;

  const ToggleSeatSelection(this.seatId);

  @override
  List<Object?> get props => [seatId];
}

class ConfirmBooking extends SeatBookingEvent {}

class LoadBookingHistory extends SeatBookingEvent {}