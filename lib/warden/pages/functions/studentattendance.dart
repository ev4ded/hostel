import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StudentMonthlyAttendance extends StatefulWidget {
  final String studentId;

  const StudentMonthlyAttendance({required this.studentId, super.key});

  @override
  _StudentMonthlyAttendanceState createState() =>
      _StudentMonthlyAttendanceState();
}

class _StudentMonthlyAttendanceState extends State<StudentMonthlyAttendance> {
  Map<String, bool> _attendanceMap = {};
  bool _loading = true;
  late DateTime _today;
  
  // Track attendance statistics
  int _totalDays = 0;
  int _presentDays = 0;
  double _attendancePercentage = 0;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _fetchAttendance();
  }

 Future<void> _fetchAttendance() async {
  setState(() => _loading = true);

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.studentId)
      .get();

  // Check if the user is approved
  if (!userDoc.exists || userDoc.data()?['isApproved'] != true) {
    // You can handle unapproved user case here
    setState(() {
      _loading = false;
      _attendanceMap.clear();
      _presentDays = 0;
      _totalDays = 0;
      _attendancePercentage = 0;
    });
    return;
  }

  final dateFormat = DateFormat('yyyy-MM-dd');
  final today = DateTime.now();
  final lastDay = DateTime(today.year, today.month + 1, 0);

  final collectionRef = FirebaseFirestore.instance
      .collection('users')
      .doc(widget.studentId)
      .collection('attendance');

      

  final querySnapshot = await collectionRef.get();

  final firestoreAttendance = <String, bool>{};
  DateTime? firstAttendanceDate;

  for (var doc in querySnapshot.docs) {
    try {
      final entryDate = dateFormat.parse(doc.id);

      // Track earliest attendance date
      if (firstAttendanceDate == null || entryDate.isBefore(firstAttendanceDate)) {
        firstAttendanceDate = entryDate;
      }

      final isPresent = (doc.data())['present'] == true;
      firestoreAttendance[doc.id] = isPresent;
    } catch (e) {
      // Skip if format issue
    }
  }

  // If no attendance at all, default to today to avoid false absents
  firstAttendanceDate ??= today;

  final firstDayOfMonth = DateTime(today.year, today.month, 1);
  final attendanceStartDate = firstAttendanceDate.isAfter(firstDayOfMonth)
      ? firstAttendanceDate
      : firstDayOfMonth;

  _attendanceMap.clear();
  _presentDays = 0;

  for (int day = 1; day <= lastDay.day; day++) {
    final date = DateTime(today.year, today.month, day);
    final formatted = dateFormat.format(date);

    if (date.isBefore(attendanceStartDate) || date.isAfter(today)) continue;

    if (firestoreAttendance.containsKey(formatted)) {
      final isPresent = firestoreAttendance[formatted]!;
      _attendanceMap[formatted] = isPresent;
      if (isPresent) _presentDays++;
    } else {
      _attendanceMap[formatted] = false; // Mark as absent
    }
  }

  _totalDays = _attendanceMap.length;
  _attendancePercentage = _totalDays > 0
      ? (_presentDays / _totalDays) * 100
      : 0;

  setState(() => _loading = false);
}


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
      appBar: AppBar(
        title:  Text("Monthly Attendance",style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Colors.indigo,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loading = true;
                  _attendanceMap = {};
                  _presentDays = 0;
                  _totalDays = 0;
                });
                await _fetchAttendance();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month header with attendance percentage
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade600, Colors.blue.shade800],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 2, 9, 14).withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('MMMM').format(_today),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('yyyy').format(_today),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: _attendancePercentage.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: "%",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildStatBox(
                                  "${_totalDays}",
                                  "Total Days",
                                  Colors.white.withOpacity(0.2),
                                  Colors.white,
                                ),
                                const SizedBox(width: 12),
                                _buildStatBox(
                                  "${_presentDays}",
                                  "Present",
                                  Colors.white.withOpacity(0.2),
                                  Colors.white,
                                ),
                                const SizedBox(width: 12),
                                _buildStatBox(
                                  "${_totalDays - _presentDays}",
                                  "Absent",
                                  Colors.white.withOpacity(0.2),
                                  Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Calendar Title
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Attendance Calendar",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                               // color: Colors.grey.shade800,
                              ),
                            ),
                            Row(
                              children: [
                                _buildLegendItem("Present", Colors.green),
                                const SizedBox(width: 12),
                                _buildLegendItem("Absent", Colors.red),

                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Monthly Calendar View
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                         boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 2, 9, 14).withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Weekday headers
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
                              ].map((day) => Expanded(
                                child: Center(
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )).toList(),
                            ),
                            const SizedBox(height: 16),
                            
                            // Calendar grid
                            _buildCalendarGrid(),
                          ],
                        ),
                      ),      
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_today.year, _today.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_today.year, _today.month, 1);
    final firstWeekdayOfMonth = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    // Calculate how many rows we need (weeks)
    final totalDaysToShow = firstWeekdayOfMonth - 1 + daysInMonth;
    final totalWeeks = (totalDaysToShow / 7).ceil();
    
    List<Widget> weeks = [];
    int dayCounter = 1;
    
    for (int week = 0; week < totalWeeks; week++) {
      List<Widget> days = [];
      
      for (int weekday = 1; weekday <= 7; weekday++) {
        if ((week == 0 && weekday < firstWeekdayOfMonth) || dayCounter > daysInMonth) {
          // Empty cell for days before the month starts or after it ends
          days.add(
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(2),
              ),
            ),
          );
        } else {
          // Valid day in the month
          final date = DateTime(_today.year, _today.month, dayCounter);
          final dateStr = dateFormat.format(date);
          final hasData = _attendanceMap.containsKey(dateStr);
          final isPresent = hasData ? _attendanceMap[dateStr]! : false;
          final isToday = date.day == _today.day && 
                          date.month == _today.month && 
                          date.year == _today.year;
          
          Color backgroundColor;
          Color textColor;
          
          if (hasData) {
            if (isPresent) {
              backgroundColor = Colors.green;
              textColor = Colors.white;
            } else {
              backgroundColor = Colors.red;
              textColor = Colors.white;
            }
          } else {
            backgroundColor = Colors.grey.shade300;
            textColor = Colors.grey.shade700;
          }
          
          // Ensure future dates look different
          if (date.isAfter(_today)) {
            backgroundColor = Colors.grey.shade100;
            textColor = Colors.grey.shade400;
          }
          
          days.add(
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (hasData) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Status on ${DateFormat('MMM dd, yyyy').format(date)}: ${isPresent ? 'Present' : 'Absent'}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: isPresent ? Colors.green : Colors.red,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  height: 45,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday ? Border.all(
                      color: Colors.blue.shade700,
                      width: 2,
                    ) : null,
                    boxShadow: isToday ? [
                      BoxShadow(
                        color: Colors.blue.shade200.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayCounter',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          
          dayCounter++;
        }
      }
      
      weeks.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days,
        ),
      );
      
      if (week < totalWeeks - 1) {
        weeks.add(const SizedBox(height: 8));
      }
    }
    
    return Column(children: weeks);
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}