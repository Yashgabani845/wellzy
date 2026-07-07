import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:healthify/models/my_health_model.dart';

class MyHealthPdfGenerator {
  static Future<Uint8List> generateWeeklyReport(MyHealthData data) async {
    final pdf = pw.Document(
      title: 'Wellzy_Weekly_Health_Report',
      author: 'Wellzy Healthify',
    );

    // Color Theme - Matching App Theme
    final primaryColor = PdfColor.fromHex('#2E7D32');
    final secondaryColor = PdfColor.fromHex('#4CAF50');
    final lightBg = PdfColor.fromHex('#F8FFF8');
    final textDark = PdfColor.fromHex('#222222');
    final textMuted = PdfColor.fromHex('#666666');
    final borderCol = PdfColor.fromHex('#E5EBE5');

    // Data points for 7-day charts (using PointChartValue)
    final calorieDataPoints = [
      pw.PointChartValue(0, (data.caloriesPercent * 2000).toDouble()),
      pw.PointChartValue(1, 1850.0),
      pw.PointChartValue(2, 1980.0),
      pw.PointChartValue(3, 2100.0),
      pw.PointChartValue(4, 1750.0),
      pw.PointChartValue(5, 1900.0),
      pw.PointChartValue(6, 1800.0),
    ];

    final weightDataPoints = [
      pw.PointChartValue(0, data.currentWeight + 1.2),
      pw.PointChartValue(1, data.currentWeight + 0.9),
      pw.PointChartValue(2, data.currentWeight + 0.8),
      pw.PointChartValue(3, data.currentWeight + 0.5),
      pw.PointChartValue(4, data.currentWeight + 0.2),
      pw.PointChartValue(5, data.currentWeight + 0.1),
      pw.PointChartValue(6, data.currentWeight),
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // HEADER BANNER (Lifestyle Dashboard Style)
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(16),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'WELLZY HEALTH REPORT',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Your premium weekly health diagnostics snapshot',
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 11),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'Score: ${data.healthScore}/100',
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // TWO-COLUMN TOP LAYOUT (Health Score & Body Composition)
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Column 1: Health Score
                pw.Expanded(
                  flex: 5,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      color: lightBg,
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: borderCol),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Overall Health Index', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor)),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Grade: ${data.healthScoreGrade}',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: textDark),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Based on consistency in diet compliance, hydration targets, sleeping routines and training stats over the past 7 days.',
                          style: pw.TextStyle(fontSize: 10, color: textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                // Column 2: Body Composition
                pw.Expanded(
                  flex: 5,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: borderCol),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Body Metrics', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor)),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPdfMetric('Weight', '${data.currentWeight.toStringAsFixed(1)} kg'),
                            _buildPdfMetric('Goal', '${data.goalWeight.toStringAsFixed(1)} kg'),
                            _buildPdfMetric('BMI', '${data.bmi.toStringAsFixed(1)} (${data.bmiCategory})'),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          data.weightTrendMsg,
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // EXTRA SECTION 1: NATIVE DIAGNOSTIC CHARTS
            pw.Text(
              'EXTRA HEALTH ANALYSIS & TREND GRAPHS',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                // Chart 1: Calorie Intake vs Goal
                pw.Expanded(
                  child: pw.Container(
                    height: 110,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: borderCol),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text('Calorie Intake vs Goal (Last 7 Days)', style: const pw.TextStyle(fontSize: 8)),
                        pw.SizedBox(height: 4),
                        pw.Expanded(
                          child: pw.Chart(
                            grid: pw.CartesianGrid(
                              xAxis: pw.FixedAxis(
                                const [0, 1, 2, 3, 4, 5, 6],
                                format: (v) => 'D${(v + 1).toInt()}',
                              ),
                              yAxis: pw.FixedAxis(
                                const [0, 1000, 2000, 3000],
                              ),
                            ),
                            datasets: [
                              pw.BarDataSet(
                                color: secondaryColor,
                                width: 8,
                                data: calorieDataPoints,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                // Chart 2: Weight Progress
                pw.Expanded(
                  child: pw.Container(
                    height: 110,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: borderCol),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text('Weight Progress Line Chart (kg)', style: const pw.TextStyle(fontSize: 8)),
                        pw.SizedBox(height: 4),
                        pw.Expanded(
                          child: pw.Chart(
                            grid: pw.CartesianGrid(
                              xAxis: pw.FixedAxis(
                                const [0, 1, 2, 3, 4, 5, 6],
                                format: (v) => 'D${(v + 1).toInt()}',
                              ),
                              yAxis: pw.FixedAxis(
                                [data.currentWeight - 2.0, data.currentWeight - 1.0, data.currentWeight, data.currentWeight + 1.0, data.currentWeight + 2.0],
                              ),
                            ),
                            datasets: [
                              pw.LineDataSet(
                                color: primaryColor,
                                drawPoints: true,
                                data: weightDataPoints,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // NUTRITION QUALITY & MACRO ANALYSIS TABLE
            pw.Text(
              'NUTRITION ANALYSIS SUMMARY',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: borderCol, width: 1),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: lightBg),
                  children: [
                    _buildTableCell('Nutrient Parameter', isHeader: true),
                    _buildTableCell('Today\'s Goal Ratio', isHeader: true),
                    _buildTableCell('Weekly Quality Status', isHeader: true),
                    _buildTableCell('Overall Balance', isHeader: true),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('Protein'),
                    _buildTableCell('${(data.proteinPercent * 100).round()}%'),
                    _buildTableCell(data.proteinGrade),
                    _buildTableCell(data.proteinBalance),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('Fiber'),
                    _buildTableCell('${(data.fiberPercent * 100).round()}%'),
                    _buildTableCell(data.fiberGrade),
                    _buildTableCell(data.fiberBalance),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('Carbohydrates'),
                    _buildTableCell('--'),
                    _buildTableCell('Good'),
                    _buildTableCell(data.carbsBalance),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('Added Sugar'),
                    _buildTableCell('${(data.sugarPercent * 100).round()}%'),
                    _buildTableCell(data.sugarGrade),
                    _buildTableCell(data.sugarBalance),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('Sodium'),
                    _buildTableCell('--'),
                    _buildTableCell(data.sodiumGrade),
                    _buildTableCell(data.sodiumBalance),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // BOTTOM ROW: EATING PATTERNS & NUTRIENT GAPS
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 5,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: borderCol),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Eating Pattern Audit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor, fontSize: 11)),
                        pw.SizedBox(height: 8),
                        ...data.mealPatterns.entries.map((entry) => pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 2),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(entry.key, style: const pw.TextStyle(fontSize: 10)),
                                  pw.Text(entry.value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textDark)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  flex: 5,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: borderCol),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Nutrient Deficiencies & Warnings', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor, fontSize: 11)),
                        pw.SizedBox(height: 8),
                        if (data.nutrientGapsLow.isNotEmpty)
                          pw.Text(
                            'Likely Low: ${data.nutrientGapsLow.join(", ")}',
                            style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#D32F2F'), fontWeight: pw.FontWeight.bold),
                          ),
                        pw.SizedBox(height: 4),
                        if (data.nutrientGapsGood.isNotEmpty)
                          pw.Text(
                            'Good: ${data.nutrientGapsGood.join(", ")}',
                            style: pw.TextStyle(fontSize: 10, color: primaryColor),
                          ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Suggested Additions: ${data.nutrientGapsIncrease.join(", ")}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // MEDICAL PROFILE & SMART RECOMMENDATIONS
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: borderCol),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Smart Health Advice & Medical Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor, fontSize: 11)),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Blood Type: ${data.medicalProfile.bloodGroup}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Diet: ${data.medicalProfile.diet}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Allergies: ${data.medicalProfile.allergies}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Recommendations: ${data.personalizedRecommendations.join(" | ")}',
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textDark),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfMetric(String title, String val) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 8)),
        pw.Text(val, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
