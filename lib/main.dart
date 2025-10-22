import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/seat_booking_bloc.dart';
import 'bloc/seat_booking_event.dart';
import 'models/bus_type.dart';
import 'repositories/seat_repository.dart';
import 'screens/seat_booking_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Seat Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => SeatBookingBloc(
          repository: SeatRepository(),
        )..add(const LoadSeats(BusType.regular)),
        child: const SeatBookingScreen(),
      ),
    );
  }
}