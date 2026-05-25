import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final String selectedBoard;
  final String selectedClass;
  final Function(String board, String classLevel) onSettingsChanged;

  const ProfileScreen({
    super.key,
    required this.selectedBoard,
    required this.selectedClass,
    required this.onSettingsChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _authenticated = false;
  bool _loading = false;

  // Mock performance metrics
  final List<FlSpot> _accuracyData = const [
    FlSpot(1, 60),
    FlSpot(2, 75),
    FlSpot(3, 70),
    FlSpot(4, 90),
    FlSpot(5, 85),
  ];

  final List<Map<String, dynamic>> _mockAttempts = const [
    {'title': 'BSEB Science Test 1', 'score': '8/10', 'date': '24 May 2026', 'status': 'PASSED'},
    {'title': 'BSEB Physics Test 3', 'score': '7/10', 'date': '20 May 2026', 'status': 'PASSED'},
    {'title': 'CBSE Math Quiz 2', 'score': '9/10', 'date': '18 May 2026', 'status': 'PASSED'},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginUser() {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      setState(() {
        _loading = true;
      });
      Timer(const Duration(seconds: 1), () {
        setState(() {
          _authenticated = true;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in successfully!')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter credentials')),
      );
    }
  }

  void _logoutUser() {
    setState(() {
      _authenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1024;
    final bool isTablet = screenWidth >= 640 && screenWidth < 1024;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 16,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'STUDENT PROFILE HUB',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: isDesktop ? 22 : 16,
                  fontWeight: FontWeight.black,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 16),

          // Main split layouts
          if (!_authenticated)
            _buildLoginPanel(context)
          else if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildPerformanceAnalytics(context),
                      const SizedBox(height: 24),
                      _buildAttemptsLog(context),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: _buildSettingsSidebar(context),
                )
              ],
            )
          else
            Column(
              children: [
                _buildSettingsSidebar(context),
                const SizedBox(height: 24),
                _buildPerformanceAnalytics(context),
                const SizedBox(height: 24),
                _buildAttemptsLog(context),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildLoginPanel(BuildContext context) {
    return Center(
      child: Container(
        maxWidth: 420,
        margin: const EdgeInsets.only(top: 40),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.user, color: Theme.of(context).colorScheme.primary, size: 36),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'STUDENT PORTAL LOGIN',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.black, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'ENTER EMAIL ADDRESS OR PHONE...',
                    prefixIcon: Icon(LucideIcons.mail, size: 16),
                    hintStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'ENTER PASSWORD...',
                    prefixIcon: Icon(LucideIcons.lock, size: 16),
                    hintStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _loginUser,
                    child: _loading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('ENTER HUB'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSidebar(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text(
                  'ACADEMIC CONFIG',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                IconButton(
                  onPressed: _logoutUser,
                  icon: const Icon(LucideIcons.logOut, size: 16, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Class selection dropdown
            const Text('SELECT CLASS LEVEL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: widget.selectedClass,
                isExpanded: true,
                underline: const SizedBox(),
                items: ['9th', '10th', '11th', '12th'].map((cls) {
                  return DropdownMenuItem<String>(value: cls, child: Text('$cls Standard'));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    widget.onSettingsChanged(widget.selectedBoard, val);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Board Selection Dropdown
            const Text('SELECT BOARD SCHOOL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: widget.selectedBoard,
                isExpanded: true,
                underline: const SizedBox(),
                items: ['BSEB', 'CBSE'].map((board) {
                  return DropdownMenuItem<String>(value: board, child: Text(board == 'BSEB' ? 'BSEB (Bihar Board)' : 'CBSE Board'));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    widget.onSettingsChanged(val, widget.selectedClass);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceAnalytics(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRACTICE ACCURACY GRAPH (%)',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _accuracyData,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
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

  Widget _buildAttemptsLog(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECENT TEST ATTEMPTS LOGS',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _mockAttempts.length,
              itemBuilder: (context, index) {
                final att = _mockAttempts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.check, color: Colors.green, size: 14),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                att['title'],
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                att['date'],
                                style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            att['score'],
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.black),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            att['status'],
                            style: const TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.black, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
