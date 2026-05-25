import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeScreen extends StatelessWidget {
  final String selectedBoard;
  final String selectedClass;

  const HomeScreen({
    super.key,
    required this.selectedBoard,
    required this.selectedClass,
  });

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
          // 1. HERO BRANDING CARD (PW/Allen Inspired)
          _buildHeroBanner(context, isDesktop),
          const SizedBox(height: 32),

          // 2. BOARD SPECIFIC NEWS & TICKER
          _buildNoticeBoard(context),
          const SizedBox(height: 32),

          // 3. TARGET BATCHES SECTION
          Text(
            'ACTIVE TARGET BATCHES',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: isDesktop ? 22 : 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 16),
          _buildBatchesGrid(context, isDesktop, isTablet),
          const SizedBox(height: 32),

          // 4. OFFLINE CENTER INFRASTRUCTURE BANNER
          _buildOfflineCenterInfo(context, isDesktop),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00BFA5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'BIHAR\'S NEXT EDUCATIONAL REVOLUTION',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SANT ACADEMY',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isDesktop ? 48 : 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'High Quality Board Preparation Coaching for BSEB & CBSE students. Empowering rural Bihar with premium resources.',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.8),
              fontSize: isDesktop ? 16 : 12,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.phoneCall, size: 16),
            label: const Text('CALL COUNSELLOR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0D47A1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeBoard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.bell, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IMPORTANT UPDATE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'BSEB Class 10 & 12 Daily Target Study Sheets for $selectedClass are now uploaded in the Study Notes tab.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchesGrid(BuildContext context, bool isDesktop, bool isTablet) {
    final List<Map<String, dynamic>> batches = [
      {
        'title': 'TARGET 2027 (BOARD EXAM)',
        'class': '10th Standard',
        'board': 'BSEB & CBSE',
        'features': ['Daily Objective Quiz', 'Offline Test Series', 'Chapter Notes PDF'],
        'cost': '₹3,500/year',
        'color': const Color(0xFFE3F2FD),
        'textColor': const Color(0xFF0D47A1),
      },
      {
        'title': 'VISHWAS BATCH (SCIENCE)',
        'class': '12th Standard',
        'board': 'BSEB (Physics & Chemistry)',
        'features': ['NCERT Key Derivations', 'Board Model Papers', 'Quiz Practice Sheets'],
        'cost': '₹5,500/year',
        'color': const Color(0xFFE0F2F1),
        'textColor': const Color(0xFF00796B),
      },
      {
        'title': 'FOUNDATION MATHEMATICS',
        'class': '9th Standard',
        'board': 'CBSE & BSEB',
        'features': ['Concept Video Sheets', 'Formulas Handbook', 'Classroom Worksheets'],
        'cost': '₹2,500/year',
        'color': const Color(0xFFF3E5F5),
        'textColor': const Color(0xFF7B1FA2),
      }
    ];

    final int cols = isDesktop ? 3 : (isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 260,
      ),
      itemCount: batches.length,
      itemBuilder: (context, index) {
        final b = batches[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          b['class'],
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: b['color'],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            b['board'],
                            style: GoogleFonts.poppins(
                              color: b['textColor'],
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      b['title'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    // Features list
                    ...List.generate((b['features'] as List).length, (idx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.circleCheck, color: Colors.green, size: 12),
                            const SizedBox(width: 6),
                            Text(
                              b['features'][idx],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      b['cost'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF0D47A1),
                            fontSize: 18,
                          ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('ENROLL NOW'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOfflineCenterInfo(BuildContext context, bool isDesktop) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF131A2C)
          : const Color(0xFFFFFFFF),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 32 : 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OFFLINE EDUCATION CENTER',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sant Academy Madhepur Campus',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Visit us for interactive face-to-face board classes, smart classrooms, printed study bundles, and custom mentorship sheets.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Near High School, Madhepur, Madhubani, Bihar - 847408',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
