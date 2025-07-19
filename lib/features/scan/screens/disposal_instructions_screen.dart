import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DisposalInstructionsScreen extends StatefulWidget {
  final String imagePath;

  const DisposalInstructionsScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<DisposalInstructionsScreen> createState() =>
      _DisposalInstructionsScreenState();
}

class _DisposalInstructionsScreenState extends State<DisposalInstructionsScreen>
    with TickerProviderStateMixin {
  bool _isAnalyzing = true;
  Map<String, dynamic>? _classificationResult;
  late AnimationController _progressController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _simulateAnalysis();
  }

  Future<void> _simulateAnalysis() async {
    _progressController.forward();

    // Simulate AI processing time
    await Future.delayed(const Duration(seconds: 3));

    // Mock classification result
    setState(() {
      _isAnalyzing = false;
      _classificationResult = {
        'category': 'Recyclable',
        'confidence': 0.92,
        'itemType': 'Plastic Bottle',
        'material': 'PET Plastic',
        'instructions': ['Remove Cap', 'Rinse Item', 'Place in Blue Bin'],
        'environmentalImpact': {
          'co2Saved': '0.2 kg',
          'energySaved': '1.5 kWh',
          'description':
              'Recycling this bottle saves energy equivalent to running a 60W bulb for 25 hours!'
        },
        'alternativeUses': [
          'Plant pot for small herbs',
          'Storage container for small items',
          'Bird feeder (with modifications)'
        ]
      };
    });

    _slideController.forward();
  }

  Color _getCategoryColor(String category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    switch (category.toLowerCase()) {
      case 'recyclable':
        return const Color(0xFF4CAF50); // Green
      case 'compost':
        return const Color(0xFF8BC34A); // Light Green
      case 'hazardous':
        return const Color(0xFFFF5722); // Deep Orange
      case 'electronic':
        return const Color(0xFF2196F3); // Blue
      case 'trash':
        return const Color(0xFF9E9E9E); // Grey
      default:
        return colorScheme.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'recyclable':
        return Icons.recycling;
      case 'compostable':
        return Icons.compost;
      case 'landfill':
        return Icons.delete;
      case 'hazardous':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
          ),
        ),
        title: Text(
          _isAnalyzing ? 'Analyzing Item' : 'Disposal Instructions',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: !_isAnalyzing
            ? [
                IconButton(
                  onPressed: () {
                    // TODO: Share functionality
                  },
                  icon: Icon(
                    Icons.share,
                    color: colorScheme.onSurface,
                  ),
                ),
              ]
            : null,
      ),
      body: _isAnalyzing ? _buildAnalyzingState() : _buildResultState(),
    );
  }

  Widget _buildAnalyzingState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.6 > 300 ? 300.0 : screenWidth * 0.6;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Captured Image
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildImageWidget(),
                ),
              ),

              const SizedBox(height: 40),

              // Progress Animation
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.psychology,
                          color: colorScheme.onPrimary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: colorScheme.outline.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${(_progressController.value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI is analyzing your waste item...',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultState() {
    final result = _classificationResult!;
    final categoryColor = _getCategoryColor(result['category']);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            categoryColor.withValues(alpha: 0.1),
            colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutCubic,
          )),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Classification Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getCategoryIcon(result['category']),
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        result['category'],
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                      Text(
                        result['itemType'],
                        style: TextStyle(
                          fontSize: 18,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Confidence: ${(result['confidence'] * 100).toInt()}%',
                          style: TextStyle(
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Disposal Instructions
                _buildSection(
                  'Disposal Instructions',
                  Icons.assignment_turned_in,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: result['instructions']
                        .asMap()
                        .entries
                        .map<Widget>((entry) {
                      final index = entry.key;
                      final instruction = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: categoryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                instruction,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Environmental Impact
                _buildSection(
                  'Environmental Impact',
                  Icons.eco,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildImpactMetric(
                              'CO₂ Saved',
                              result['environmentalImpact']['co2Saved'],
                              Icons.cloud_off,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildImpactMetric(
                              'Energy Saved',
                              result['environmentalImpact']['energySaved'],
                              Icons.flash_on,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        result['environmentalImpact']['description'],
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Alternative Uses
                _buildSection(
                  'Creative Reuse Ideas',
                  Icons.lightbulb,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: result['alternativeUses']
                        .map<Widget>((use) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      use,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/congratulations', extra: {
                            'category': result['category'],
                            'points': 5,
                            'streak': 1,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: categoryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'I\'ve Sorted It',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: categoryColor),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.camera_alt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildImpactMetric(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (kIsWeb) {
      // For web, show a placeholder since we can't access the file system
      return Container(
        width: double.infinity,
        height: 250,
        color: colorScheme.primary.withValues(alpha: 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Image Preview',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    } else {
      // For mobile devices, display the actual image
      try {
        return Image.file(
          File(widget.imagePath),
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 250,
              color: colorScheme.primary.withValues(alpha: 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } catch (e) {
        return Container(
          width: double.infinity,
          height: 250,
          color: colorScheme.primary.withValues(alpha: 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Image unavailable',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}
