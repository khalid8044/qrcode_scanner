import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BirthdayCountdownScreen extends StatefulWidget {
  final String dob;
  const BirthdayCountdownScreen({super.key, required this.dob});

  @override
  State createState() => _BirthdayCountdownScreenState();
}

class _BirthdayCountdownScreenState extends State<BirthdayCountdownScreen> {
  DateTime? _nextBirthday;
  Duration _remainingTime = Duration();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _calculateNextBirthday();
  }

  void _calculateNextBirthday() {
    DateTime dob = DateFormat('yyyy-MM-dd').parse(widget.dob);
    DateTime now = DateTime.now();
    DateTime thisYearBirthday = DateTime(now.year, dob.month, dob.day);

    setState(() {
      _nextBirthday = thisYearBirthday.isBefore(now)
          ? DateTime(now.year + 1, dob.month, dob.day)
          : thisYearBirthday;
      _startCountdown();
    });
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = _nextBirthday!.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDDECF2),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 90, child: _buildCountdownText()),
          if (_nextBirthday != null)
            Positioned(top: 350, child: CircularCountdownWidget(targetDate: _nextBirthday!)),
        ],
      ),
    );
  }

  Widget _buildCountdownText() {
    return Column(
      children: [
        Text(
          "BIRTHDAY COUNTDOWN",
          style: GoogleFonts.aBeeZee(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        SizedBox(height: 10),
        Text(
          " Your DOB: ${widget.dob}",
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.blueGrey,
          ),
        ),
        SizedBox(height: 10),
        if (_nextBirthday != null)
          Text(
            "Next Birthday: ${DateFormat('dd MMMM yyyy').format(_nextBirthday!)}",
            style: GoogleFonts.aBeeZee(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
        SizedBox(height: 10),
       
      ],
    );
  }
}

class CircularCountdownWidget extends StatefulWidget {
  final DateTime targetDate;
  const CircularCountdownWidget({super.key, required this.targetDate});

  @override
  State<CircularCountdownWidget> createState() => _CircularCountdownWidgetState();
}

class _CircularCountdownWidgetState extends State<CircularCountdownWidget> {
  late Timer _timer;
  Duration _timeLeft = Duration();

  @override
  void initState() {
    super.initState();
    _updateTimeLeft();
    _startTimer();
  }

  void _updateTimeLeft() {
    setState(() {
      _timeLeft = widget.targetDate.difference(DateTime.now());
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTimeLeft();
      }
    });
  }

  double _calculateProgress() {
    DateTime now = DateTime.now();
    DateTime startOfYear = DateTime(widget.targetDate.year - 1, widget.targetDate.month, widget.targetDate.day);
    Duration totalDuration = widget.targetDate.difference(startOfYear);
    Duration elapsed = now.difference(startOfYear);
    return elapsed.inSeconds / totalDuration.inSeconds;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 280,
          height: 280,
          child: CircularProgressIndicator(strokeCap: StrokeCap.round,
            value: _calculateProgress(),
            strokeWidth: 10,
            backgroundColor: Colors.black12,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Colors.purple, Colors.blue, Colors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${_timeLeft.inDays} d",
                style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                "${_timeLeft.inHours % 24}h ${_timeLeft.inMinutes % 60}m ${_timeLeft.inSeconds % 60}s",
                style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}