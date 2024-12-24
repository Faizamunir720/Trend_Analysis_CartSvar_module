import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
    theme: ThemeData.light(),
    home: TrendAnalysisModule(),
  ));
}
final FirestoreService _firestoreService = FirestoreService();
class TrendAnalysisModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trend Analysis Module"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No new notifications")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionCard(
              title: "Pattern Detection",
              child: PatternDetectionCheckbox(),
            ),
            const SizedBox(height: 24),
            SectionCard(
              title: "Abandonment Insights",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Cart Abandonment Reasons",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(height: 200, child: PieChartWidget()),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Call to the helper function for Shipping Costs Impact Chart
            SectionCard(
              title: "Impact of Shipping Costs on Abandonment",
              child: getShippingCostsImpactChart(),
            ),
            const SizedBox(height: 24),
            // Call to the helper function for Weekly Cart Abandonment Trends Chart
            SectionCard(
              title: "Weekly Cart Abandonment Trends",
              child: WeeklyCartAbandonmentTrendsChart(),
            ),
            const SizedBox(height: 24),
            // Integrating the GraphScreen here
            SectionCard(
              title: "Sales and Temperature Trends",
              child: GraphScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
// Function to return Shipping Costs Impact BarChartWidget
Widget getShippingCostsImpactChart() {
  return FutureBuilder<Map<String, dynamic>>(
    future: _firestoreService.fetchShippingCostsImpactData(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error loading data'));
      } else if (!snapshot.hasData || snapshot.data!['data'].isEmpty) {
        return Center(child: Text('No data available'));
      } else {
        // Convert List<int> to List<double>
        List<double> data = List<double>.from(snapshot.data!['data'].map((e) => e.toDouble()));
        List<String> categories = List<String>.from(snapshot.data!['categories']);

        return SizedBox(
          height: 200,
          child: BarChartWidget(
            title: "Shipping Costs Impact",
            data: data,  // Now data is a List<double>
            colors: [Colors.blue, Colors.orange, Colors.red],
            categories: categories,
          ),
        );
      }
    },
  );
}
class WeeklyCartAbandonmentTrendsChart extends StatefulWidget {
  @override
  _WeeklyCartAbandonmentTrendsChartState createState() => _WeeklyCartAbandonmentTrendsChartState();
}

class _WeeklyCartAbandonmentTrendsChartState extends State<WeeklyCartAbandonmentTrendsChart> {
  final FirestoreService _firestoreService = FirestoreService();

  // Placeholder for fetched data
  List<double> weeklyAbandonmentData = [];
  List<String> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch data for weekly cart abandonment trends
  void fetchData() async {
    try {
      // Fetch Weekly Cart Abandonment Trends data
      var data = await _firestoreService.fetchGraphData('weekly_trends');
      if (data != null) {
        print("Fetched data: $data");
        setState(() {
          weeklyAbandonmentData = (data['dataValues'] as List)
              .map((e) => (e as num).toDouble())
              .toList();
          categories = List<String>.from(data['categories']);
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (weeklyAbandonmentData.isEmpty || categories.isEmpty) {
      return Center(child: Text('No data available'));
    }

    return SizedBox(
      height: 200,
      child: BarChartWidget(
        title: "Weekly Abandonments",
        data: weeklyAbandonmentData,
        colors: [
          Colors.blue,
          Colors.green,
          Colors.purple,
          Colors.orange,
          Colors.red,
          Colors.yellow,
          Colors.blueAccent,
        ],
        categories: categories,
      ),
    );
  }
}



class GraphScreen extends StatefulWidget {
  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Placeholder for fetched data
  List<double> winterSalesData1 = [];
  List<double> winterSalesData2 = [];
  List<double> springTempData1 = [];
  List<double> springTempData2 = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch data for both graphs
  void fetchData() async {
    try {
      // Fetch Winter Sales Analysis
      var winterData =
      await _firestoreService.fetchGraphData('winter_sales_analysis');
      if (winterData != null) {
        setState(() {
          winterSalesData1 = (winterData['data1'] as List)
              .map((e) => (e as num).toDouble())
              .toList();
          winterSalesData2 = (winterData['data2'] as List)
              .map((e) => (e as num).toDouble())
              .toList();
        });
      }

      // Fetch Spring Temperature Variations
      var springData =
      await _firestoreService.fetchGraphData('spring_temperature_variations');
      if (springData != null) {
        setState(() {
          springTempData1 = (springData['data1'] as List)
              .map((e) => (e as num).toDouble())
              .toList();
          springTempData2 = (springData['data2'] as List)
              .map((e) => (e as num).toDouble())
              .toList();
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
      children: [
        // Winter Sales Graph
        SizedBox(
          height: 300,
          child: GraphCard(
            title: "Winter Sales Analysis",
            legend1: "Sales",
            legend2: "Returns",
            data1: winterSalesData1,
            data2: winterSalesData2,
            color1: Colors.blue,
            color2: Colors.red,
          ),
        ),
        SizedBox(height: 16),
        // Spring Temperature Graph
        SizedBox(
          height: 300,
          child: GraphCard(
            title: "Spring Temperature Variations",
            legend1: "Day",
            legend2: "Night",
            data1: springTempData1,
            data2: springTempData2,
            color1: Colors.orange,
            color2: Colors.purple,
          ),
        ),
      ],
    );
  }
}

// GraphCard Class
class GraphCard extends StatelessWidget {
  final String title;
  final String legend1;
  final String legend2;
  final List<double> data1;
  final List<double> data2;
  final Color color1;
  final Color color2;

  const GraphCard({
    required this.title,
    required this.legend1,
    required this.legend2,
    required this.data1,
    required this.data2,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  titlesData: FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data1
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: color1,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: data2
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: color2,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Legend(color: color1, text: legend1),
                SizedBox(width: 16),
                Legend(color: color2, text: legend2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Legend Class
class Legend extends StatelessWidget {
  final Color color;
  final String text;

  const Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class PatternDetectionCheckbox extends StatefulWidget {
  @override
  _PatternDetectionCheckboxState createState() =>
      _PatternDetectionCheckboxState();
}

class _PatternDetectionCheckboxState extends State<PatternDetectionCheckbox> {
  bool productPageViews = true;
  bool addToCartActions = true;
  bool viewCartButNoCheckout = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text("Product Page Views"),
          value: productPageViews,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                productPageViews = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Product Page Views ${value ? 'Enabled' : 'Disabled'}")),
              );
            }
          },
        ),
        CheckboxListTile(
          title: const Text("Add to Cart Actions"),
          value: addToCartActions,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                addToCartActions = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Add to Cart Actions ${value ? 'Enabled' : 'Disabled'}")),
              );
            }
          },
        ),
        CheckboxListTile(
          title: const Text("View Cart but No Checkout"),
          value: viewCartButNoCheckout,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                viewCartButNoCheckout = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("View Cart but No Checkout ${value ? 'Enabled' : 'Disabled'}")),
              );
            }
          },
        ),
      ],
    );
  }
}

class PieChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 50,
            color: Colors.blue,
            title: "Shipping Costs",
            radius: 50,
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: 30,
            color: Colors.red,
            title: "Long Checkout Process",
            radius: 50,
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          PieChartSectionData(
            value: 20,
            color: Colors.green,
            title: "Product Unavailable",
            radius: 50,
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
        sectionsSpace: 4,
        centerSpaceRadius: 30,
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final String title;
  final List<double> data;
  final List<Color> colors;
  final List<String> categories;

  const BarChartWidget({
    required this.title,
    required this.data,
    required this.colors,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: data
            .asMap()
            .map((index, value) {
          return MapEntry(
            index,
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: colors[index],
                  width: 16,
                )
              ],
            ),
          );
        })
            .values
            .toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  categories[value.toInt()],
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}