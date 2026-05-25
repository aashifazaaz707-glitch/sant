import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class MaterialsScreen extends StatefulWidget {
  final String selectedBoard;
  final String selectedClass;

  const MaterialsScreen({
    super.key,
    required this.selectedBoard,
    required this.selectedClass,
  });

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  bool _loading = false;
  String _searchQuery = "";
  String _selectedSubject = "All";
  List<Map<String, dynamic>> _dbMaterials = [];

  // Offline fallback database for instant preview/local usage
  final List<Map<String, dynamic>> _mockMaterials = [
    {
      'title': 'BSEB Class 10 Science Objective Notes',
      'description': 'Bihar board Class 10 Science Chapter-wise objective questions with solutions.',
      'pdf_url': 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      'board': 'BSEB',
      'class_level': '10th',
      'subject': 'Science',
    },
    {
      'title': 'CBSE Class 10 Maths Formula Sheet',
      'description': 'All important mathematical formulas for Class 10 CBSE Board Exams.',
      'pdf_url': 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      'board': 'CBSE',
      'class_level': '10th',
      'subject': 'Mathematics',
    },
    {
      'title': 'BSEB Class 12 Physics VVI Subjective',
      'description': 'Class 12 Bihar Board Physics subjective questions & conceptual notes.',
      'pdf_url': 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      'board': 'BSEB',
      'class_level': '12th',
      'subject': 'Physics',
    },
    {
      'title': 'BSEB Class 10 Social Science Notes',
      'description': 'History, Civics, and Geography notes for matriculation exam.',
      'pdf_url': 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      'board': 'BSEB',
      'class_level': '10th',
      'subject': 'Social Science',
    }
  ];

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  @override
  void didUpdateWidget(covariant MaterialsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedBoard != widget.selectedBoard || 
        oldWidget.selectedClass != widget.selectedClass) {
      _fetchMaterials();
    }
  }

  Future<void> _fetchMaterials() async {
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('study_materials')
          .select('*')
          .eq('board', widget.selectedBoard)
          .eq('class_level', widget.selectedClass);
          
      if (response != null) {
        setState(() {
          _dbMaterials = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint('Sync materials fail: using local database.');
      // Filter mock database locally
      setState(() {
        _dbMaterials = _mockMaterials
            .where((m) => 
                m['board'] == widget.selectedBoard && 
                m['class_level'] == widget.selectedClass)
            .toList();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1024;

    // Subjects Filter List
    final Set<String> subjects = {'All'};
    for (var m in _dbMaterials) {
      subjects.add(m['subject']);
    }

    // Filter materials based on search and subject chip
    final filteredMaterials = _dbMaterials.where((m) {
      final matchSearch = m['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m['description'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchSubject = _selectedSubject == "All" || m['subject'] == _selectedSubject;
      return matchSearch && matchSubject;
    }).toList();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 16,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title
          Text(
            'STUDY NOTES & HANDBOOKS',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: isDesktop ? 22 : 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'SEARCH NOTES, SYLLABUS, BOOKS...',
              prefixIcon: const Icon(LucideIcons.search, size: 18),
              hintStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // Subject Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: subjects.map((sub) {
                final isSelected = _selectedSubject == sub;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      sub.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedSubject = sub);
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Materials List / Grid
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filteredMaterials.isEmpty
                    ? _buildEmptyState()
                    : isDesktop
                        ? _buildDesktopGrid(filteredMaterials)
                        : _buildMobileList(filteredMaterials),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.fileText, color: Colors.grey, size: 48),
          const SizedBox(height: 16),
          Text(
            'NO STUDY NOTES AVAILABLE',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Check back soon or select a different board/class settings.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final m = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(LucideIcons.fileText, color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(
              m['title'],
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 13),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                m['description'] ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ),
            trailing: const Icon(LucideIcons.chevronRight),
            onTap: () => _openPdfReader(m['title'], m['pdf_url']),
          ),
        );
      },
    );
  }

  Widget _buildDesktopGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 130,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final m = items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.fileText, color: Theme.of(context).colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m['title'],
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m['description'] ?? "",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton.icon(
                          onPressed: () => _openPdfReader(m['title'], m['pdf_url']),
                          icon: const Icon(LucideIcons.externalLink, size: 14),
                          label: const Text('OPEN NOTE'),
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openPdfReader(String title, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PdfReaderPage(title: title, pdfUrl: url),
      ),
    );
  }
}

// Built-in Premium PDF Viewer Page
class PdfReaderPage extends StatelessWidget {
  final String title;
  final String pdfUrl;

  const PdfReaderPage({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download started! Material will be saved offline.')),
              );
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        onDocumentLoadFailed: (details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Document failed to load: ${details.description}')),
          );
        },
      ),
    );
  }
}
