import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatefulWidget {
  final String selectedBoard;
  final String selectedClass;

  const QuizScreen({
    super.key,
    required this.selectedBoard,
    required this.selectedClass,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _quizzes = [];

  // Offline mock database for quizzes & questions fallback
  final List<Map<String, dynamic>> _mockQuizzes = [
    {
      'id': 'quiz-1',
      'title': 'BSEB Class 10 Science Objective Test 1',
      'description': 'Important board objective questions for Science.',
      'duration_minutes': 10,
      'board': 'BSEB',
      'class_level': '10th',
      'subject': 'Science',
    },
    {
      'id': 'quiz-2',
      'title': 'CBSE Class 10 Quadratic Equations Test',
      'description': 'Practice questions on Quadratic Equations.',
      'duration_minutes': 15,
      'board': 'CBSE',
      'class_level': '10th',
      'subject': 'Mathematics',
    }
  ];

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  @override
  void didUpdateWidget(covariant QuizScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedBoard != widget.selectedBoard ||
        oldWidget.selectedClass != widget.selectedClass) {
      _fetchQuizzes();
    }
  }

  Future<void> _fetchQuizzes() async {
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('quizzes')
          .select('*')
          .eq('board', widget.selectedBoard)
          .eq('class_level', widget.selectedClass);

      if (response != null) {
        setState(() {
          _quizzes = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint('Sync quizzes fail: using local database.');
      setState(() {
        _quizzes = _mockQuizzes
            .where((q) =>
                q['board'] == widget.selectedBoard &&
                q['class_level'] == widget.selectedClass)
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

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 16,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRACTICE TEST & QUIZZES',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: isDesktop ? 22 : 16,
                  fontWeight: FontWeight.black,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _quizzes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _quizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = _quizzes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.between,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          quiz['subject'].toString().toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: 9,
                                            fontWeight: FontWeight.black,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.clock, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${quiz['duration_minutes']} MINS',
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    quiz['title'],
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    quiz['description'] ?? "",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _startQuiz(quiz),
                                      icon: const Icon(LucideIcons.play, size: 14),
                                      label: const Text('START PRACTICE'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
          const Icon(LucideIcons.award, color: Colors.grey, size: 48),
          const SizedBox(height: 16),
          Text(
            'NO PRACTICE TESTS ASSIGNED',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Practice tests are uploaded daily. Make sure settings match your syllabus.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _startQuiz(Map<String, dynamic> quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActiveQuizPage(quiz: quiz),
      ),
    );
  }
}

// Active Quiz Interactive Page
class ActiveQuizPage extends StatefulWidget {
  final Map<String, dynamic> quiz;
  const ActiveQuizPage({super.key, required this.quiz});

  @override
  State<ActiveQuizPage> createState() => _ActiveQuizPageState();
}

class _ActiveQuizPageState extends State<ActiveQuizPage> {
  bool _loading = false;
  int _currentQuestionIdx = 0;
  int? _selectedOptionIdx;
  bool _showExplanation = false;
  int _score = 0;
  
  // Timer States
  late Timer _timer;
  int _secondsRemaining = 0;

  List<Map<String, dynamic>> _questions = [];

  final List<Map<String, dynamic>> _mockQuestions = [
    {
      'question_text': 'Which acid is present in tomato (टमाटर में कौन सा अम्ल पाया जाता है)?',
      'options': [
        'Citric Acid (साइट्रिक अम्ल)',
        'Oxalic Acid (ऑक्सेलिक अम्ल)',
        'Lactic Acid (लैक्टिक अम्ल)',
        'Tartaric Acid (टार्टरिक अम्ल)'
      ],
      'correct_option_index': 1,
      'explanation': 'Oxalic acid is present in tomato. (टमाटर में ऑक्सेलिक अम्ल पाया जाता है।)',
    },
    {
      'question_text': 'What is the focal length of a flat mirror (समतल दर्पण की फोकस दूरी होती है)?',
      'options': [
        'Zero (शून्य)',
        'Infinite (अनंत)',
        '25 cm',
        '50 cm'
      ],
      'correct_option_index': 1,
      'explanation': 'The focal length of a flat mirror is infinite because its reflecting surface is flat. (समतल दर्पण की फोकस दूरी अनंत होती है।)',
    },
    {
      'question_text': 'What is the discriminant of the quadratic equation x^2 - 4x + 4 = 0?',
      'options': [
        '4',
        '0',
        '-4',
        '8'
      ],
      'correct_option_index': 1,
      'explanation': 'D = b^2 - 4ac = (-4)^2 - 4(1)(4) = 16 - 16 = 0.',
    }
  ];

  @override
  void initState() {
    super.initState();
    _secondsRemaining = (widget.quiz['duration_minutes'] as int) * 60;
    _startTimer();
    _fetchQuestions();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer.cancel();
        _submitQuiz();
      }
    });
  }

  Future<void> _fetchQuestions() async {
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('quiz_questions')
          .select('*')
          .eq('quiz_id', widget.quiz['id']);
      
      if (response != null && (response as List).isNotEmpty) {
        setState(() {
          _questions = List<Map<String, dynamic>>.from(response);
        });
      } else {
        throw Exception("Empty questions");
      }
    } catch (e) {
      debugPrint('Sync questions fail: using mock test.');
      setState(() {
        _questions = _mockQuestions;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _answerQuestion(int index) {
    if (_selectedOptionIdx != null) return; // Prevent changing answer
    setState(() {
      _selectedOptionIdx = index;
      _showExplanation = true;
      if (index == _questions[_currentQuestionIdx]['correct_option_index']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIdx < _questions.length - 1) {
      setState(() {
        _currentQuestionIdx++;
        _selectedOptionIdx = null;
        _showExplanation = false;
      });
    } else {
      _submitQuiz();
    }
  }

  void _submitQuiz() {
    _timer.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('PRACTICE COMPLETED', style: TextStyle(fontWeight: FontWeight.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Final Score: $_score / ${_questions.length} Correct Answers'),
            const SizedBox(height: 8),
            Text('Accuracy: ${((_score / _questions.length) * 100).toStringAsFixed(0)}%'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close active quiz
            },
            child: const Text('OKAY'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1024;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: Text("Preparing test questions...")));
    }

    final q = _questions[_currentQuestionIdx];
    final String timerText = '${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz['title'].toString().toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.clock, color: Colors.red, size: 14),
                    const SizedBox(width: 4),
                    Text(timerText, style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 120 : 16,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Progress
            Text(
              'QUESTION ${_currentQuestionIdx + 1} OF ${_questions.length}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),

            // Question Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  q['question_text'],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Options List
            ...List.generate(4, (index) {
              final optionText = q['options'][index];
              Color? optionColor;
              IconData? trailingIcon;
              
              if (_selectedOptionIdx != null) {
                final isCorrectAnswer = index == q['correct_option_index'];
                final isSelectedAnswer = index == _selectedOptionIdx;
                
                if (isCorrectAnswer) {
                  optionColor = Colors.green.withOpacity(0.1);
                  trailingIcon = LucideIcons.check;
                } else if (isSelectedAnswer) {
                  optionColor = Colors.red.withOpacity(0.1);
                  trailingIcon = LucideIcons.x;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _answerQuestion(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: optionColor ?? Colors.black.withOpacity(0.01),
                      border: Border.all(
                        color: optionColor != null
                            ? (optionColor.opacity == 0.1 ? Colors.green : Colors.red)
                            : Theme.of(context).dividerColor.withOpacity(0.1),
                        width: optionColor != null ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Expanded(
                          child: Text(
                            optionText,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: optionColor != null 
                                  ? (trailingIcon == LucideIcons.check ? Colors.green : Colors.red)
                                  : null,
                            ),
                          ),
                        ),
                        if (trailingIcon != null)
                          Icon(trailingIcon, color: trailingIcon == LucideIcons.check ? Colors.green : Colors.red, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            }),
            
            // Explanation section
            if (_showExplanation && q['explanation'] != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.amber.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.amber, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(LucideIcons.lightbulb, color: Colors.amber, size: 16),
                          SizedBox(width: 6),
                          Text('ANSWER EXPLANATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(q['explanation'], style: const TextStyle(fontSize: 12, height: 1.4)),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Controls
            if (_selectedOptionIdx != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(_currentQuestionIdx == _questions.length - 1 ? 'SUBMIT TEST' : 'NEXT QUESTION'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
