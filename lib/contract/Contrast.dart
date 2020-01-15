import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:leek/Config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}

class OrdinalSales2 {
  final String time;
  final double sales;

  OrdinalSales2(this.time, this.sales);
}

class Contrast extends StatefulWidget {
  Contrast({Key key}) : super(key: key);

  @override
  _ContrastState createState() {
    return _ContrastState();
  }
}

class _ContrastState extends State<Contrast> {
  bool animate = false;
  Dio _dio = new Dio();
  List<Map<String, dynamic>> _list;
  Map<int, String> dataList = {};
  String _type = "帐户";
  String _period = "5min";
  String _symbol = "";
  Map<String, String> _types = {"帐户": "account", "持仓": "position"};
  Map<String, String> _periods = {
    "5min": "5分钟",
    "15min": "15分钟",
    "30min": "30分钟",
    "60min": "60分钟",
    "4hour": "4小时",
    "1day": "1天"
  };

  @override
  void initState() {
    super.initState();
  }

  _choose(String symbol, String type) async {
    String url =
        "${Config.httpUrl}/elite/${_types[type]}/ratio/${symbol}/${_period}";
    _symbol = symbol;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString("token");
    Response response =
        await _dio.get(url, options: Options(headers: {"token": token}));
    Map<String, dynamic> result = response.data;
    HapticFeedback.lightImpact();
    if (result["status"] == "ok") {
      List<dynamic> data = result["data"] as List<dynamic>;
      List<Map<String, dynamic>> list =
          data.map((item) => item as Map<String, dynamic>).toList();
      List<Map<String, dynamic>> copyList = list.reversed
          .toList()
          .getRange(0, min(8, list.length))
          .toList()
          .reversed
          .toList();

      List<BarChartGroupData> items = [];
      for (var i = 0; i < copyList.length; i++) {
        dataList[i] = copyList[i]["ts"];
        items.add(makeGroupData(i, double.parse(copyList[i]["buy_ratio"]) * 20,
            double.parse(copyList[i]["sell_ratio"]) * 20));
      }

      rawBarGroups = items;

      showingBarGroups = items;

      barTouchedResultStreamController = StreamController();
      barTouchedResultStreamController.stream
          .distinct()
          .listen((BarTouchResponse response) {
        if (response == null) {
          return;
        }

        if (response.spot == null) {
          setState(() {
            touchedGroupIndex = -1;
            showingBarGroups = List.of(rawBarGroups);
          });
          return;
        }

        touchedGroupIndex =
            showingBarGroups.indexOf(response.spot.touchedBarGroup);

        setState(() {
          if (response.touchInput is FlLongPressEnd) {
            touchedGroupIndex = -1;
            showingBarGroups = List.of(rawBarGroups);
          } else {
            showingBarGroups = List.of(rawBarGroups);
            if (touchedGroupIndex != -1) {
              double sum = 0;
              for (BarChartRodData rod
                  in showingBarGroups[touchedGroupIndex].barRods) {
                sum += rod.y;
              }
              final avg =
                  sum / showingBarGroups[touchedGroupIndex].barRods.length;

              showingBarGroups[touchedGroupIndex] =
                  showingBarGroups[touchedGroupIndex].copyWith(
                barRods: showingBarGroups[touchedGroupIndex].barRods.map((rod) {
                  return rod.copyWith(y: avg);
                }).toList(),
              );
            }
          }
        });
      });

      setState(() {
        _type = type;
        _list = list;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    return new Scaffold(
        body: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                child: Text(
                  "$_symbol 精英${_type}比例",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                padding: EdgeInsets.only(left: 20)),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _types.keys.map((name) {
                    return SizedBox(
                      width: 60,
                      child: Stack(
                        children: <Widget>[
                          FlatButton(
                            child: Text(
                              name,
                              style: TextStyle(color: Colors.grey),
                            ),
                            onPressed: () {
                              _choose(_symbol, name);
                              HapticFeedback.selectionClick();
                            },
                          ),
                          Positioned(
                            right: 6,
                            bottom: 10,
                            child: Icon(
                              Icons.brightness_1,
                              size: ScreenUtil.instance.setWidth(24),
                              color: _type == name
                                  ? Colors.lightBlueAccent
                                  : Colors.transparent,
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList()),
            )
          ],
        ),
        AspectRatio(
          aspectRatio: 1,
          child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(right: 4),
                                    width: 10,
                                    height: 10,
                                    color: leftBarColor),
                                Text("多军"),
                              ],
                            ),
                            SizedBox(width: 20),
                            Row(
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(right: 4),
                                    width: 10,
                                    height: 10,
                                    color: rightBarColor),
                                Text("空军")
                              ],
                            )
                          ],
                        ),
                      ),
                      Padding(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            items: _periods.keys.map((name) {
                              return new DropdownMenuItem(
                                child: new Text(_periods[name],
                                    style: TextStyle(fontSize: 14)),
                                value: name,
                              );
                            }).toList(),
                            iconSize: 18,
                            hint: Text(
                              _periods[_period],
                              style: TextStyle(fontSize: 14),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _period = value;
                              });
                              _choose(_symbol, _type);
                              HapticFeedback.selectionClick();
                            },
                          ),
                        ),
                        padding: EdgeInsets.only(right: 20),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 38,
                  ),
                  _list == null
                      ? Expanded(
                          child: Center(child: CircularProgressIndicator()))
                      : Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: BarChart(BarChartData(
                              maxY: 20,
//                                barTouchData: BarTouchData(
//                                  touchTooltipData: BarTouchTooltipData(
//                                      tooltipBgColor: Colors.grey,
//                                      getTooltipItem: (spots) {
//                                        return spots.map((TouchedSpot spot) {
//                                          return null;
//                                        }).toList();
//                                      }),
//                                  touchResponseSink:
//                                      barTouchedResultStreamController.sink,
//                                ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: SideTitles(
                                  showTitles: true,
                                  textStyle: TextStyle(
                                      color: const Color(0xff7589a2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                  margin: 20,
                                  getTitles: (double value) {
                                    return dataList[value.toInt()];
                                  },
                                ),
                                leftTitles: SideTitles(
                                  showTitles: true,
                                  textStyle: TextStyle(
                                      color: const Color(0xff7589a2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                  margin: 32,
                                  reservedSize: 14,
                                  getTitles: (value) {
                                    if (value == 0) {
                                      return '1%';
                                    } else if (value == 10) {
                                      return '50%';
                                    } else if (value == 20) {
                                      return '100%';
                                    } else {
                                      return '';
                                    }
                                  },
                                ),
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              barGroups: showingBarGroups,
                            )),
                          ),
                        ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    ));
  }

  final Color leftBarColor = const Color(0xff53fdd7);
  final Color rightBarColor = const Color(0xffff5182);
  final double width = 7;

  List<BarChartGroupData> rawBarGroups;
  List<BarChartGroupData> showingBarGroups;

  StreamController<BarTouchResponse> barTouchedResultStreamController;

  int touchedGroupIndex;

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        y: y1,
        color: leftBarColor,
        width: width,
        isRound: true,
      ),
      BarChartRodData(
        y: y2,
        color: rightBarColor,
        width: width,
        isRound: true,
      ),
    ]);
  }
}
