import 'package:fines_plus/core/widgets/trend_icon.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Statistics mileage", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.directions_car, size: 28, color: Colors.grey),
                              SizedBox(width: 8),
                              Column(
                                children: [
                                  Text("AUG '25", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text("1007 KM", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Row(children: [SizedBox(width: 8), TrendIcon(isUp: false)]),

                              Column(
                                children: [
                                  Text("70%", style: TextStyle(color: Colors.green, fontSize: 20)),
                                  Transform.translate(
                                    offset: Offset(5, -5),
                                    child: Text("per month", style: TextStyle(color: Colors.black87, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Month", style: TextStyle(color: Colors.grey)),
                          const SizedBox(width: 50),
                          Container(height: 20, width: 2, color: Colors.grey),
                          const SizedBox(width: 50),
                          Text("Average", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Statistics costs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.attach_money, size: 28, color: Colors.grey),
                          SizedBox(width: 8),
                          Column(
                            children: [
                              Text("AUG '25", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("5 512 UAH", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Row(children: [SizedBox(width: 8), TrendIcon(isUp: true)]),

                              Column(
                                children: [
                                  Text(" JUL '25 ", style: TextStyle(color: Colors.black87, fontSize: 18)),
                                  Transform.translate(
                                    offset: Offset(5, -5),
                                    child: Text("10657 km", style: TextStyle(color: Colors.red, fontSize: 16)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// Pie chart
                  Container(
                    color: Colors.grey,
                    width: double.infinity,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(value: 121541, color: Colors.green, title: "Fuel", radius: 50),
                                PieChartSectionData(value: 64390, color: Colors.red, title: "Repair", radius: 50),
                                PieChartSectionData(value: 13982, color: Colors.blue, title: "Tuning", radius: 50),
                                PieChartSectionData(value: 10000, color: Colors.grey, title: "Other", radius: 50),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _LegendItem(color: Colors.green, text: "Fuel"),
                            _LegendItem(color: Colors.red, text: "Repair"),
                            _LegendItem(color: Colors.blue, text: "Tuning"),
                            _LegendItem(color: Colors.grey, text: "Other"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [TextButton(onPressed: () {}, child: Text("Open statistics"))],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: color),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
