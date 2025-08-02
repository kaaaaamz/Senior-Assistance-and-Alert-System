import 'dart:async';
import 'package:authtest/langconsts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import 'package:d_chart/d_chart.dart';

import 'elderinfo.dart';

class LiveChartSpo2Page extends StatefulWidget {
  final String elderId;
  LiveChartSpo2Page({Key? key, required this.elderId}) : super(key: key);

  @override
  _LiveChartSpo2PageState createState() => _LiveChartSpo2PageState();
}

class _LiveChartSpo2PageState extends State<LiveChartSpo2Page> {

  DateTime? selectedDate;

late Stream<QuerySnapshot<Map<String, dynamic>>> streamChart;
  @override
  void initState() {
    super.initState();
    streamChart = FirebaseFirestore.instance
      .collection('data')
      .doc(widget.elderId)
      .collection('spo2')
      .orderBy('time', descending: true)
      .snapshots(includeMetadataChanges: true);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 52, 103, 0.8),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
            margin: EdgeInsets.only(top: 90),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              color: Colors.white,
            ),
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _selectDate(context);
                      },
                      child: Text(
                        selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                            : translation(context).slctdate,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedDate = null;
                        });
                      },
                      icon: Icon(Icons.clear),
                    ),
                  ],
                ),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: streamChart,
                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasData) {
                      List<Map<String, dynamic>?> listChart = snapshot.data!.docs
                          .map((e) {
                            DateTime timestamp = e.data()['time'].toDate();
                            if (selectedDate != null && !isSameDate(timestamp, selectedDate!)) {
                              return null; // Skip data not matching selected date
                            }
                            int hour = timestamp.hour;
                            int minute = timestamp.minute;
                            int minuteIndex = hour * 6 + (minute ~/ 10);
                            String hourString = hour.toString().padLeft(2, '0');
                            String minuteString = (minute ~/ 10 * 10).toString().padLeft(2, '0');
                            String timeString = '$hourString:$minuteString';
                            return {
                              'domain': timeString,
                              'measure': e.data()['value'],
                              'minuteIndex': minuteIndex,
                            };
                          })
                          .where((data) => data != null)
                          .toList();

                      if (listChart.isEmpty) {
                        return Text(translation(context).nodataavl);
                      }
                       List<Map<String, dynamic>> hourAverages = List.generate(24, (index) {
  int hour = index;
  String hourString = hour.toString().padLeft(2, '0');
  return {
    'domain': '$hourString:00',
    'measure': 0,
    'count': 0,
  };
});

for (var data in listChart) {
  int hour = data!['minuteIndex'] ~/ 6;
  hourAverages[hour]['measure'] += data['measure'];
  hourAverages[hour]['count']++;
}

for (var average in hourAverages) {
  if (average['count'] > 0) {
    average['measure'] = (average['measure'] / average['count']).toInt();
  }
}
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 2000, // Set the width to extend infinitely
                          height: 655, // Set the width to match the screen width
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: DChartBar(
                              data: [
                                {
                                  'id': 'Bar',
                                  'data': hourAverages,
                                },
                              ],
                              domainLabelPaddingToAxisLine: 8,
                              axisLineTick: 2,
                              axisLinePointTick: 3,
                              axisLinePointWidth: 10,
                              axisLineColor: Colors.black,
                              measureLabelPaddingToAxisLine: 16,
                              barColor: (barData, index, id) => Color.fromRGBO(43, 52, 103, 0.8),
                              barValue: (barData, index) => '${barData['measure']}',
                              showBarValue: true,
                              barValueColor: Colors.white,
                              showMeasureLine: true,
                              animate: true,
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(translation(context).err('${snapshot.error}'));
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 33,
            left: 0,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(
                  width: 300,
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    logout(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDate(DateTime dateTime1, DateTime dateTime2) {
    return dateTime1.year == dateTime2.year &&
        dateTime1.month == dateTime2.month &&
        dateTime1.day == dateTime2.day;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}