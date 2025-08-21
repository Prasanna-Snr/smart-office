import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StaffAttendanceScreen extends StatefulWidget {
  const StaffAttendanceScreen({super.key});

  @override
  State<StaffAttendanceScreen> createState() => _StaffAttendanceScreenState();
}

class _StaffAttendanceScreenState extends State<StaffAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  // Dummy Data (replace with Firebase later)
  final Map<String, List<Map<String, dynamic>>> attendanceData = {
    "2025-08-21": [
      {"name": "Kritika C.", "rfid": "A1B2C3", "checkIn": "09:10 AM", "status": "Present"},
      {"name": "Bhavi S.", "rfid": "D4E5F6", "checkIn": "09:25 AM", "status": "Present"},
      {"name": "Ashok P.", "rfid": "G7H8I9", "checkIn": null, "status": "Absent"},
    ],
    "2025-08-20": [
      {"name": "Kritika C.", "rfid": "A1B2C3", "checkIn": "09:05 AM", "status": "Present"},
      {"name": "Bhavi S.", "rfid": "D4E5F6", "checkIn": null, "status": "Absent"},
    ],
  };

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 1),
      lastDate: DateTime.now(), // 🔹 Restrict only up to today
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent, // header background
              onPrimary: Colors.white, // header text
              onSurface: Colors.black, // body text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final attendanceList = attendanceData[formattedDate] ?? [];

    int total = attendanceList.length;
    int present = attendanceList.where((u) => u['status'] == "Present").length;
    int absent = attendanceList.where((u) => u['status'] == "Absent").length;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text("Staff Attendance"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date Picker Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.date_range, color: Colors.blueAccent),
                title: Text(
                  "Selected Date: $formattedDate",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: ElevatedButton(
                  onPressed: () => _pickDate(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Pick Date"),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Summary Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _summaryCard("Total", total.toString(), Colors.blue),
                _summaryCard("Present", present.toString(), Colors.green),
                _summaryCard("Absent", absent.toString(), Colors.red),
              ],
            ),
            const SizedBox(height: 20),

            // Attendance List
            Expanded(
              child: attendanceList.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.info_outline, color: Colors.grey, size: 50),
                    SizedBox(height: 8),
                    Text(
                      "No attendance records for this date.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: attendanceList.length,
                itemBuilder: (context, index) {
                  final user = attendanceList[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user['status'] == "Present"
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        child: Icon(
                          user['status'] == "Present" ? Icons.check : Icons.close,
                          color: user['status'] == "Present" ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        user['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          "RFID: ${user['rfid']} | In: ${user['checkIn'] ?? '--'}"),
                      trailing: Text(
                        user['status'],
                        style: TextStyle(
                          color: user['status'] == "Present" ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ],
      ),
    );
  }
}
