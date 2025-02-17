import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:tollcalculator/calculator/birthday_count_down.dart';

class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _targetDateController = TextEditingController();
  DateTime? _nextBirthday;
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    _calculateNextBirthday();
  }

  void _calculateNextBirthday() {
    if (_dobController.text.isNotEmpty) {
      DateTime dob = DateFormat('yyyy-MM-dd').parse(_dobController.text);
      DateTime now = DateTime.now();
      DateTime thisYearBirthday = DateTime(now.year, dob.month, dob.day);

      setState(() {
        _nextBirthday = thisYearBirthday.isBefore(now)
            ? DateTime(now.year + 1, dob.month, dob.day)
            : thisYearBirthday;

        _showAnimation = true;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        if (controller == _dobController) _calculateNextBirthday();
      });
    }
  }

  Widget _buildDateField(BuildContext context, TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(context, controller),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.calendar_month, color: Colors.blue),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildAgeResult(double fontSize) {
    if (_dobController.text.isEmpty) {
      return _buildMessage("Please select a valid Date of Birth", fontSize);
    }

    DateTime dob = DateFormat('yyyy-MM-dd').parse(_dobController.text);
    DateTime targetDate = _targetDateController.text.isNotEmpty
        ? DateFormat('yyyy-MM-dd').parse(_targetDateController.text)
        : DateTime.now();

    if (targetDate.isBefore(dob)) {
      return _buildMessage("Target date cannot be earlier than Date of Birth", fontSize, color: Colors.red);
    }

    Duration ageDuration = targetDate.difference(dob);
    int years = targetDate.year - dob.year;
    int months = targetDate.month - dob.month;
    int days = targetDate.day - dob.day;
      int totalDays = ageDuration.inDays;
    int totalWeeks = totalDays ~/ 7;
    int totalHours = ageDuration.inHours;
    int totalMinutes = ageDuration.inMinutes;
    int totalSeconds = ageDuration.inSeconds;

    if (days < 0) {
      months--;
      days += DateTime(targetDate.year, targetDate.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    return _buildAgeCard(years:years, months:months, days:days,weeks: totalWeeks,hours:totalHours,minutes: totalMinutes,secods: totalSeconds, fontSize);
  }

  Widget _buildMessage(String message, double fontSize, {Color color = Colors.white}) {
    return Center(
      child: Text(
        message,
        style: GoogleFonts.aBeeZee(fontSize: fontSize, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

Widget _buildMetadta({int? year,int? month, int? day,int? weeks, int? hours,int? minutes,int? secods} ){
  return Column(children: [
              _richText2("Total Year(s)", year??0,),
                _richText2("Total Month(s)", month??0,),
              _richText2("Total Week(s)", weeks??0,),
              _richText2("Total Day(s)", day??0,),
              _richText2("Total Hour(s)", hours??0,),
              _richText2("Total Minutes", minutes??0,),
              _richText2("Total Seconds", secods??0,),],);
}
  Widget _buildAgeCard(double fontSize,{int? years, int? months, int? days,int? weeks, int? hours,int? minutes,int? secods }) {
    return Container(
    
      padding: EdgeInsets.all(fontSize * 0.8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(fontSize),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, spreadRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/schedule.png',height: 12,width: 12,),
              SizedBox(width: fontSize * 0.5),
              Text("Your Age:", style: GoogleFonts.aBeeZee(color: Colors.grey, fontSize: fontSize)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRichText("Years", years??0, fontSize),
              _buildRichText("Months", months??0, fontSize),
              _buildRichText("Days", days??0, fontSize),

            ],
          ),
          const Divider(),
          _buildMetadta(year: years,minutes: minutes,day: days,secods: secods,month: months,weeks: weeks,hours: hours)
          
        ],
      ),
    );
  }

  Widget _buildRichText(String label, int value, double fontSize) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: "$value ", style: GoogleFonts.aBeeZee(color: Colors.black, fontSize: fontSize, fontWeight: FontWeight.bold)),
          TextSpan(text: label, style: GoogleFonts.aBeeZee(color: Colors.grey, fontSize: fontSize * 0.9)),
        ],
      ),
    );
  }
 Widget _richText2(String label, int value, ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$label :", style: GoogleFonts.aBeeZee(color: Colors.grey, fontSize: 12)),
        Text("$value", style: GoogleFonts.aBeeZee(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double fontSize = width * 0.04;

    return Scaffold(
      backgroundColor: const Color(0xFFA9BDC9),
      body: Padding(
        padding: EdgeInsets.all(fontSize),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: fontSize * 1.5),
            Center(
              child: Image.asset("assets/calendar.png", height: fontSize * 10, colorBlendMode: BlendMode.softLight),
            ),
            SizedBox(height: fontSize),
            Text("Date of Birth", style: GoogleFonts.aBeeZee(fontSize: fontSize)),
            SizedBox(height: fontSize * 0.5),
            _buildDateField(context, _dobController, "Select Date of Birth"),
            SizedBox(height: fontSize),
            Text("Calculate till", style: GoogleFonts.aBeeZee(fontSize: fontSize)),
            SizedBox(height: fontSize * 0.5),
            _buildDateField(context, _targetDateController, "Select Till Date (Optional)"),
            SizedBox(height: fontSize),
            
            if (_nextBirthday != null)
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BirthdayCountdownScreen(dob: _dobController.text,)),
                ),
                child: Container(margin: EdgeInsets.all(4),padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.grey.shade100,borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      "Next Birthday: ${DateFormat('dd MMM yyyy').format(_nextBirthday!)} 🎂🎉   ->",
                      style: GoogleFonts.aBeeZee(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
            _buildAgeResult(fontSize),
          ],
        ),
      ),
    );
  }
}
