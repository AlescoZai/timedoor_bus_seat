import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/seat_booking_bloc.dart';
import '../bloc/seat_booking_event.dart';
import '../bloc/seat_booking_state.dart';
import '../models/bus_type.dart';
import '../models/seat.dart';

class SeatBookingScreen extends StatelessWidget {
  const SeatBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Bus Seat Booking',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black87),
            onPressed: () => _showBookingHistory(context),
          ),
        ],
      ),
      body: BlocBuilder<SeatBookingBloc, SeatBookingState>(
        builder: (context, state) {
          if (state is SeatBookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SeatBookingError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is SeatBookingLoaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBusTypeSelector(context, state),
                    const SizedBox(height: 24),
                    _buildSeatGrid(context, state),
                    const SizedBox(height: 24),
                    _buildPriceInfo(state),
                    const SizedBox(height: 16),
                    _buildConfirmButton(context, state),
                    const SizedBox(height: 16),
                    _buildLegend(),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildBusTypeSelector(BuildContext context, SeatBookingLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRadioOption(
              context,
              'Regular',
              BusType.regular,
              state.busType,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildRadioOption(
              context,
              'Express',
              BusType.express,
              state.busType,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(
    BuildContext context,
    String label,
    BusType value,
    BusType groupValue,
  ) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () {
        if (value != groupValue) {
          context.read<SeatBookingBloc>().add(ChangeBusType(value));
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF112D4E) : const Color(0xFF3F72AF),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? const Color(0xFF112D4E).withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF112D4E) : Colors.grey[400]!,
                  width: 2,
                ),
                color: Colors.white,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF112D4E),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF112D4E) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatGrid(BuildContext context, SeatBookingLoaded state) {
    // Group seats by row (A, B, C, D, E)
    final seatsByRow = <String, List<Seat>>{};
    for (var seat in state.seats) {
      final rowLetter = seat.id[0];
      if (!seatsByRow.containsKey(rowLetter)) {
        seatsByRow[rowLetter] = [];
      }
      seatsByRow[rowLetter]!.add(seat);
    }

    final sortedRows = seatsByRow.keys.toList()..sort();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final seatWidth = (constraints.maxWidth / 8).clamp(50.0, 70.0);
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var rowLetter in sortedRows) ...[
                _buildSeatRow(context, seatsByRow[rowLetter]!, state.busType, seatWidth),
                if (rowLetter != sortedRows.last) const SizedBox(height: 6),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSeatRow(
    BuildContext context, 
    List<Seat> rowSeats, 
    BusType busType,
    double seatWidth,
  ) {
    // Sort seats by number (1, 2, 3, 4)
    rowSeats.sort((a, b) {
      final numA = int.parse(a.id.substring(1));
      final numB = int.parse(b.id.substring(1));
      return numA.compareTo(numB);
    });

    final spacing = seatWidth * 0.15;
    final aisleWidth = seatWidth * 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSeatButton(context, rowSeats[0], busType, seatWidth), // A1
        SizedBox(width: spacing),
        _buildSeatButton(context, rowSeats[1], busType, seatWidth), // A2
        SizedBox(width: aisleWidth),
        _buildSeatButton(context, rowSeats[2], busType, seatWidth), // A3
        SizedBox(width: spacing),
        _buildSeatButton(context, rowSeats[3], busType, seatWidth), // A4
      ],
    );
  }

  Widget _buildSeatButton(BuildContext context, Seat seat, BusType busType, double seatWidth) {
    final width = busType == BusType.regular ? 70.0 : 70.0;
    final height = busType == BusType.regular ? 70.0 : 140.0;
    
    Color backgroundColor;
    Color textColor;
    
    if (seat.isBooked) {
      backgroundColor = const Color(0xFF3F72AF);
      textColor = Colors.white;
    } else if (seat.isSelected) {
      backgroundColor = const Color(0xFF112D4E);
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.grey[200]!;
      textColor = Colors.grey[700]!;
    }

    return InkWell(
      onTap: seat.isBooked
          ? null
          : () {
              context.read<SeatBookingBloc>().add(ToggleSeatSelection(seat.id));
            },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            seat.id,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceInfo(SeatBookingLoaded state) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Price',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            formatter.format(state.totalPrice),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF112D4E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, SeatBookingLoaded state) {
    final hasSelection = state.selectedSeatsCount > 0;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: hasSelection
            ? () {
                context.read<SeatBookingBloc>().add(ConfirmBooking());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Successfully booked ${state.selectedSeatsCount} seat(s)!',
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF112D4E),
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Confirm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: hasSelection ? Colors.white : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('Available', Colors.grey[200]!),
          _buildLegendItem('Selected', const Color(0xFF112D4E)),
          _buildLegendItem('Booked', const Color(0xFF3F72AF)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _showBookingHistory(BuildContext context) {
    final bloc = context.read<SeatBookingBloc>();
    bloc.add(LoadBookingHistory());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BlocProvider.value(
        value: bloc,
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return BlocBuilder<SeatBookingBloc, SeatBookingState>(
              builder: (context, state) {
                if (state is! SeatBookingLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final formatter = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp. ',
                  decimalDigits: 0,
                );

                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 16),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Booking History',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Total: ${formatter.format(state.totalRevenue)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: state.bookingHistory.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 64,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No booking history yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: state.bookingHistory.length,
                              itemBuilder: (context, index) {
                                final booking = state.bookingHistory[index];
                                final dateTime = DateTime.parse(booking['timestamp']);
                                final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF112D4E),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              booking['busType'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            formatter.format(booking['totalPrice']),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF112D4E),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Seats: ${(booking['seats'] as List).join(', ')}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateFormat.format(dateTime),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}