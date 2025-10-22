import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/seat.dart';
import '../models/bus_type.dart';

class SeatRepository {
  static const String _regularSeatsKey = 'regular_seats';
  static const String _expressSeatsKey = 'express_seats';
  static const String _regularRevenueKey = 'regular_revenue';
  static const String _expressRevenueKey = 'express_revenue';
  static const String _bookingHistoryKey = 'booking_history';

  Future<List<Seat>> loadSeats(BusType busType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = busType == BusType.regular ? _regularSeatsKey : _expressSeatsKey;
    final seatsJson = prefs.getString(key);

    if (seatsJson == null) {
      return _generateDefaultSeats(busType);
    }

    final List<dynamic> decoded = json.decode(seatsJson);
    return decoded.map((json) => Seat.fromJson(json)).toList();
  }

  Future<void> saveSeats(BusType busType, List<Seat> seats) async {
    final prefs = await SharedPreferences.getInstance();
    final key = busType == BusType.regular ? _regularSeatsKey : _expressSeatsKey;
    final seatsJson = json.encode(seats.map((s) => s.toJson()).toList());
    await prefs.setString(key, seatsJson);
  }

  Future<void> resetSeats(BusType busType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = busType == BusType.regular ? _regularSeatsKey : _expressSeatsKey;
    await prefs.remove(key);
  }

  Future<int> getTotalRevenue(BusType busType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = busType == BusType.regular ? _regularRevenueKey : _expressRevenueKey;
    return prefs.getInt(key) ?? 0;
  }

  Future<void> addRevenue(BusType busType, int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final key = busType == BusType.regular ? _regularRevenueKey : _expressRevenueKey;
    final currentRevenue = await getTotalRevenue(busType);
    await prefs.setInt(key, currentRevenue + amount);
  }

  Future<void> saveBookingHistory(String busTypeName, List<String> seatIds, int totalPrice) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_bookingHistoryKey);
    
    List<dynamic> history = [];
    if (historyJson != null) {
      history = json.decode(historyJson);
    }

    history.insert(0, {
      'busType': busTypeName,
      'seats': seatIds,
      'totalPrice': totalPrice,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await prefs.setString(_bookingHistoryKey, json.encode(history));
  }

  Future<List<Map<String, dynamic>>> getBookingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_bookingHistoryKey);
    
    if (historyJson == null) {
      return [];
    }

    final List<dynamic> decoded = json.decode(historyJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  List<Seat> _generateDefaultSeats(BusType busType) {
    final numberOfRows = busType == BusType.regular ? 5 : 3;
    final rows = ['A', 'B', 'C', 'D', 'E'];
    const seatsPerRow = 4;
    
    List<Seat> seats = [];
    
    for (int i = 0; i < numberOfRows; i++) {
      for (int j = 1; j <= seatsPerRow; j++) {
        seats.add(Seat(id: '${rows[i]}$j'));
      }
    }
    
    return seats;
  }
}