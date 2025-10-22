import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/bus_type.dart';
import '../models/seat.dart';
import '../repositories/seat_repository.dart';
import 'seat_booking_event.dart';
import 'seat_booking_state.dart';

class SeatBookingBloc extends Bloc<SeatBookingEvent, SeatBookingState> {
  final SeatRepository repository;

  SeatBookingBloc({required this.repository}) : super(SeatBookingInitial()) {
    on<LoadSeats>(_onLoadSeats);
    on<ChangeBusType>(_onChangeBusType);
    on<ToggleSeatSelection>(_onToggleSeatSelection);
    on<ConfirmBooking>(_onConfirmBooking);
    on<LoadBookingHistory>(_onLoadBookingHistory);
  }

  Future<void> _onLoadSeats(LoadSeats event, Emitter<SeatBookingState> emit) async {
    emit(SeatBookingLoading());
    try {
      final seats = await repository.loadSeats(event.busType);
      final revenue = await repository.getTotalRevenue(event.busType);
      final history = await repository.getBookingHistory();
      
      emit(SeatBookingLoaded(
        busType: event.busType,
        seats: seats,
        totalPrice: 0,
        totalRevenue: revenue,
        bookingHistory: history,
      ));
    } catch (e) {
      emit(SeatBookingError(e.toString()));
    }
  }

  Future<void> _onChangeBusType(ChangeBusType event, Emitter<SeatBookingState> emit) async {
    emit(SeatBookingLoading());
    try {
      final seats = await repository.loadSeats(event.busType);
      final revenue = await repository.getTotalRevenue(event.busType);
      final history = await repository.getBookingHistory();
      
      emit(SeatBookingLoaded(
        busType: event.busType,
        seats: seats,
        totalPrice: 0,
        totalRevenue: revenue,
        bookingHistory: history,
      ));
    } catch (e) {
      emit(SeatBookingError(e.toString()));
    }
  }

  Future<void> _onToggleSeatSelection(
    ToggleSeatSelection event,
    Emitter<SeatBookingState> emit,
  ) async {
    if (state is SeatBookingLoaded) {
      final currentState = state as SeatBookingLoaded;
      
      final updatedSeats = currentState.seats.map((seat) {
        if (seat.id == event.seatId && !seat.isBooked) {
          return seat.copyWith(isSelected: !seat.isSelected);
        }
        return seat;
      }).toList();

      final selectedSeats = updatedSeats.where((s) => s.isSelected).length;
      final totalPrice = selectedSeats * currentState.busType.pricePerSeat;

      emit(currentState.copyWith(
        seats: updatedSeats,
        totalPrice: totalPrice,
      ));
    }
  }

  Future<void> _onConfirmBooking(
    ConfirmBooking event,
    Emitter<SeatBookingState> emit,
  ) async {
    if (state is SeatBookingLoaded) {
      final currentState = state as SeatBookingLoaded;
      
      final selectedSeats = currentState.seats.where((s) => s.isSelected).toList();
      
      if (selectedSeats.isEmpty) {
        return;
      }

      final updatedSeats = currentState.seats.map((seat) {
        if (seat.isSelected) {
          return seat.copyWith(isBooked: true, isSelected: false);
        }
        return seat;
      }).toList();

      final bookedSeatIds = selectedSeats.map((s) => s.id).toList();
      final totalPrice = currentState.totalPrice;

      await repository.saveSeats(currentState.busType, updatedSeats);
      
      await repository.addRevenue(currentState.busType, totalPrice);
      
      await repository.saveBookingHistory(
        currentState.busType.name,
        bookedSeatIds,
        totalPrice,
      );

      final allBooked = updatedSeats.every((s) => s.isBooked);
      
      List<Seat> finalSeats = updatedSeats;
      if (allBooked) {
        await repository.resetSeats(currentState.busType);
        finalSeats = await repository.loadSeats(currentState.busType);
      }

      final newRevenue = await repository.getTotalRevenue(currentState.busType);
      final history = await repository.getBookingHistory();

      emit(currentState.copyWith(
        seats: finalSeats,
        totalPrice: 0,
        totalRevenue: newRevenue,
        bookingHistory: history,
      ));
    }
  }

  Future<void> _onLoadBookingHistory(
    LoadBookingHistory event,
    Emitter<SeatBookingState> emit,
  ) async {
    if (state is SeatBookingLoaded) {
      final currentState = state as SeatBookingLoaded;
      final history = await repository.getBookingHistory();
      emit(currentState.copyWith(bookingHistory: history));
    }
  }
}