import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:minipro/warden/pages/functions/studentattendance.dart';
import 'package:minipro/warden/wardenQueries/queries.dart';

class WardenAttendanceDashboard extends StatefulWidget {
 

  const WardenAttendanceDashboard();

  @override
  State<WardenAttendanceDashboard> createState() => _WardenAttendanceDashboardState();
}

class _WardenAttendanceDashboardState extends State<WardenAttendanceDashboard> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> todayAttendance = [];
  bool isLoading = true;
  String? hostelId;

  int presentCount = 0;
  int absentCount = 0;
  int totalStudents = 0;

  List<Map<String, dynamic>> weeklyData = [];

  @override
  void initState() {
    super.initState(); 
    _fetchHostelId();
  }

  void _fetchHostelId() async {
    String? fetchedHostelId = await fetchHostelId();
    if (fetchedHostelId != null) {
      setState(() {
        hostelId = fetchedHostelId;
      });
      await loadDashboard();
    }
  }
  Future<void> loadDashboard() async {
    await fetchTodayAttendance();
    await fetchLast7DaysData();
  }

  Future<void> fetchTodayAttendance() async {
    setState(() => isLoading = true);
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    final studentsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('hostelId', isEqualTo:hostelId)
        .where('role', isEqualTo: 'student')
        .where('isApproved', isEqualTo: true)
        .get();

    if (studentsSnapshot.docs.isEmpty) {
      setState(() {
        isLoading = false;
        return;
      });
    }

    totalStudents = studentsSnapshot.docs.length;
    List<Map<String, dynamic>> tempData = [];
    int present = 0;

    for (var student in studentsSnapshot.docs) {
      final studentId = student.id;
      final name = student['username'];

      final attendanceDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .collection('attendance')
          .doc(formattedDate)
          .get();

      final isPresent = attendanceDoc.exists && attendanceDoc['present'] == true;
      if (isPresent) present++;

      tempData.add({'id': studentId,'username': name, 'present': isPresent});
    }

    setState(() {
      todayAttendance = tempData;
      presentCount = present;
      absentCount = totalStudents - presentCount;
      isLoading = false;
    });
  }

  Future<void> fetchLast7DaysData() async {
    List<Map<String, dynamic>> data = [];

    final studentsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('hostelId', isEqualTo: hostelId)
        .where('isApproved', isEqualTo: true)
        .get();

    final studentIds = studentsSnapshot.docs.map((e) => e.id).toList();

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final dayName = DateFormat('EEE').format(date);

      int dailyPresent = 0;

      for (var studentId in studentIds) {
        final attendanceDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(studentId)
            .collection('attendance')
            .doc(formattedDate)
            .get();

         final data = attendanceDoc.data(); // safer approach

  if (data != null && data['present'] == true) {
    dailyPresent++;
        }
      }

      data.add({
        'day': dayName,
        'date': date,
        'present': dailyPresent,
        'absent': studentIds.length - dailyPresent,
      });
    }
print('Weekly Data: $weeklyData');
    setState(() {
      weeklyData = data;
    });
  }

  Widget buildImprovedChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Attendance Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Showing attendance for the past 7 days',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey[400],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: totalStudents.toDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey[800]!,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final data = weeklyData[group.x.toInt()];
                      return BarTooltipItem(
                        '${data['present']} present\n${data['absent']} absent',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= weeklyData.length || value < 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            weeklyData[value.toInt()]['day'],
                            style: TextStyle(
                              color: Colors.blueGrey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                     interval: (totalStudents == 0 ? 1 : (totalStudents / 4).ceilToDouble()),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.blueGrey[400],
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                 horizontalInterval: (totalStudents == 0 ? 1 : (totalStudents / 4).ceilToDouble()),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color:const Color(0xffe7e8ec),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: weeklyData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final presentCount = data['present'];
                  final percentage = presentCount / totalStudents;
                  
                  Color barColor;
                  if (percentage >= 0.8) {
                    barColor = Colors.greenAccent[700]!;
                  } else if (percentage >= 0.6) {
                    barColor = Colors.green;
                  } else if (percentage >= 0.4) {
                    barColor = Colors.amber;
                  } else {
                    barColor = Colors.redAccent;
                  }
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: presentCount.toDouble(),
                        color: barColor,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: totalStudents.toDouble(),
                          color: Colors.grey[200],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('High', Colors.greenAccent[700]!),
              const SizedBox(width: 16),
              _buildLegendItem('Average', Colors.green),
                const SizedBox(width: 16),
              _buildLegendItem('Low',  Colors.amber),
              const SizedBox(width: 16),
              _buildLegendItem('Critical', Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.blueGrey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title:  Text('Attendance Dashboard',style:GoogleFonts.inter(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary cards with improved design
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCountBox('Total', totalStudents, Colors.blueGrey),
                          _buildCountBox('Present', presentCount, Colors.green),
                          _buildCountBox('Absent', absentCount, Colors.red),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Improved chart
                      buildImprovedChart(),
                      
                      const SizedBox(height: 24),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blue[700], size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Today\'s Attendance ($formattedDate)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Student attendance list
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          itemCount: todayAttendance.length,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final student = todayAttendance[index];
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentMonthlyAttendance(studentId: '${student['id']}', ),
                                      
                              
                                    ),
                                );
                           
                              },
                              leading: CircleAvatar(
                                backgroundColor: student['present'] 
                                  ? Colors.green[50] 
                                  : Colors.red[50],
                                child: Icon(
                                  student['present'] ? Icons.check : Icons.close,
                                  color: student['present'] ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(
                                student['username'],
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                student['present'] ? 'Present' : 'Absent',
                                style: TextStyle(
                                  color: student['present'] ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCountBox(String label, int count, Color color) {
    final percentage = totalStudents > 0
        ? ((label == 'Present' ? count / totalStudents : label == 'Absent' ? count / totalStudents : 1) * 100).toInt()
        : 0;
    
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blueGrey[600],
            ),
          ),
          if (label != 'Total') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}