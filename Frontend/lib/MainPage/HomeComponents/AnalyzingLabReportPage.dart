import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyzingLabReportPage extends StatelessWidget {
  const AnalyzingLabReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample predictable data
    final sampleReports = [
      {
        'createdAt': '2025-01-01T00:00:00Z',
        'Hemoglobin': 12.0,
        'RBC_Count': 4.2,
        'WBC_Count': 6000,
        'Platelet_Count': 180000,
        'Hematocrit': 38,
        'MCV': 90,
        'MCH': 28,
        'MCHC': 33,
        'ESR': 15,
      },
      {
        'createdAt': '2025-02-01T00:00:00Z',
        'Hemoglobin': 11.0,
        'RBC_Count': 4.0,
        'WBC_Count': 7000,
        'Platelet_Count': 200000,
        'Hematocrit': 34,
        'MCV': 85,
        'MCH': 27,
        'MCHC': 32,
        'ESR': 20,
      },
      {
        'createdAt': '2025-03-01T00:00:00Z',
        'Hemoglobin': 10.5,
        'RBC_Count': 3.8,
        'WBC_Count': 7000,
        'Platelet_Count': 200000,
        'Hematocrit': 32,
        'MCV': 84,
        'MCH': 27,
        'MCHC': 32,
        'ESR': 25,
      },
    ];

    final predictions = {
      'Hemoglobin': 'Low (10.5 < 13.8)',
      'RBC_Count': 'Low (3.8 < 4.5)',
      'Hematocrit': 'Low (32 < 40)',
      'MCV': 'Normal (84)',
      'WBC_Count': 'Normal (7000)',
      'Platelet_Count': 'Normal (200000)',
      'ESR': 'High (25 > 20)',
      'Condition': 'Normocytic Anemia',
      'Inflammation': 'Possible inflammation',
    };

    final precautions = [
      'Low hemoglobin: Avoid strenuous activity; increase iron intake (e.g., spinach, red meat).',
      'Low RBC and Hematocrit: Possible anemia; consult a doctor for further tests (e.g., ferritin).',
      'High ESR: Monitor symptoms (e.g., fatigue, fever); investigate inflammation source with a healthcare provider.',
      'General: Stay hydrated and maintain a balanced diet to support recovery.',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Report Analysis", style: TextStyle(fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              _buildChartSection(context, sampleReports),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              _buildSummarySection(context, sampleReports.last),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              _buildPredictionsSection(context, predictions),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              _buildPrecautionsSection(context, precautions),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              _buildHealthTipsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Lab Report Analytics",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.blue),
          onPressed: () {}, // Placeholder for refresh action
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context, List<dynamic> reports) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Trends Over Time",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            _buildChart(context, "Hemoglobin (g/dL)", _getSpots(reports, 'Hemoglobin'), 13.8, 17.2),
            _buildChart(context, "RBC Count (million/µL)", _getSpots(reports, 'RBC_Count'), 4.5, 5.9),
            _buildChart(context, "WBC Count (/µL)", _getSpots(reports, 'WBC_Count'), 4000, 11000),
            // Add more charts as needed
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpots(List<dynamic> reports, String field) {
    return reports.map((report) {
      final date = DateTime.parse(report['createdAt']);
      final value = report[field] as num? ?? 0.0;
      return FlSpot(date.millisecondsSinceEpoch.toDouble(), value.toDouble());
    }).toList();
  }

  Widget _buildChart(BuildContext context, String title, List<FlSpot> spots, double minRange, double maxRange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: spots.length > 1 ? (spots.last.x - spots.first.x) / 4 : null,
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
              minX: spots.isNotEmpty ? spots.first.x : 0,
              maxX: spots.isNotEmpty ? spots.last.x : 1,
              minY: 0,
              maxY: spots.isNotEmpty ? (spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.2) : maxRange * 1.2,
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(y: minRange, color: Colors.green, strokeWidth: 1, dashArray: [5, 5]),
                  HorizontalLine(y: maxRange, color: Colors.green, strokeWidth: 1, dashArray: [5, 5]),
                ],
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blue.shade800,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context, Map<String, dynamic> latestReport) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Latest Report Summary",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            _buildSummaryRow('Date', DateTime.parse(latestReport['createdAt']).toString().substring(0, 10)),
            _buildSummaryRow('Hemoglobin', '${latestReport['Hemoglobin']} g/dL'),
            _buildSummaryRow('RBC Count', '${latestReport['RBC_Count']} million/µL'),
            _buildSummaryRow('WBC Count', '${latestReport['WBC_Count']} /µL'),
            _buildSummaryRow('Platelet Count', '${latestReport['Platelet_Count']} /µL'),
            _buildSummaryRow('ESR', '${latestReport['ESR']} mm/hr'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildPredictionsSection(BuildContext context, Map<String, String> predictions) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Health Predictions",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            ...predictions.entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          color: entry.value.contains('Low') || entry.value.contains('High')
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrecautionsSection(BuildContext context, List<String> precautions) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recommended Precautions",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            ...precautions.map(
                  (precaution) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        precaution,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTipsSection(BuildContext context) {
    final tips = [
      "Stay hydrated: Drink 8-10 glasses of water daily to support blood volume.",
      "Balanced diet: Include iron-rich foods (e.g., leafy greens) and vitamins (e.g., B12).",
      "Regular checkups: Schedule blood tests every 3-6 months to monitor trends.",
      "Exercise moderately: Light activity can boost circulation, but avoid overexertion if anemic.",
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "General Health Tips",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            ...tips.map(
                  (tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}