import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/responsive_layout.dart';
import 'package:provider/provider.dart';
import 'package:license_peaksight/theme_provider.dart';

class HelpAndDocumentationWidget extends StatefulWidget {
  final Function(String) onSectionSelected;

  HelpAndDocumentationWidget({required this.onSectionSelected});

  @override
  _HelpAndDocumentationWidgetState createState() => _HelpAndDocumentationWidgetState();
}

class _HelpAndDocumentationWidgetState extends State<HelpAndDocumentationWidget> {
  int _selectedTutorialIndex = 0;
  int _selectedAlgorithmIndex = -1; // -1 means no algorithm is selected
  int _currentStep = 0;

  final List<String> tutorials = [
    'Getting Started',
    'Batch Processing',
    'Image Quality Assessment',
    'Image Modification',
  ];

  final Map<String, List<String>> tutorialSteps = {
    'Getting Started': [
      'Step 1: Sign up or log in to your account.',
      'Step 2: Navigate through the app using the menu.',
      'Step 3: Access different functionalities from the dashboard.'
    ],
    'Batch Processing': [
      'Step 1: Select multiple images.',
      'Step 2: Choose the desired processing options.',
      'Step 3: Review the processed images.'
    ],
    'Image Quality Assessment': [
      'Step 1: Upload an image for quality assessment.',
      'Step 2: Select the metrics to evaluate.',
      'Step 3: Review the quality scores and details.'
    ],
    'Image Modification': [
      'Step 1: Upload an image for modification.',
      'Step 2: Choose the desired modification options.',
      'Step 3: Save or download the modified image.'
    ],
  };

  final List<String> algorithms = [
    'VGG16',
    'BRISQUE',
    'NIQE',
    'ILNIQE',
  ];

  final Map<String, List<String>> algorithmSteps = {
    'VGG16': [
      'Introduction',
      'What it does',
      'How to use it',
      'Effects',
    ],
    'BRISQUE': [
      'Introduction',
      'What it does',
      'How to use it',
      'Effects',
    ],
    'NIQE': [
      'Introduction',
      'What it does',
      'How to use it',
      'Effects',
    ],
    'ILNIQE': [
      'Introduction',
      'What it does',
      'How to use it',
      'Effects',
    ],
  };

  final Map<String, List<String>> algorithmDetails = {
    'VGG16': [
      'VGG16 Introduction: VGG16 is a convolutional neural network model...',
      'What VGG16 does: VGG16 is used for image classification...',
      'How to use VGG16: To use VGG16, you need to...',
      'Effects of VGG16: The effects of using VGG16 include...',
    ],
    'BRISQUE': [
      'BRISQUE Introduction: BRISQUE stands for Blind/Referenceless Image Spatial Quality Evaluator...',
      'What BRISQUE does: BRISQUE assesses image quality without reference...',
      'How to use BRISQUE: To use BRISQUE, you need to...',
      'Effects of BRISQUE: The effects of using BRISQUE include...',
    ],
    'NIQE': [
      'NIQE Introduction: NIQE stands for Natural Image Quality Evaluator...',
      'What NIQE does: NIQE evaluates the quality of images...',
      'How to use NIQE: To use NIQE, you need to...',
      'Effects of NIQE: The effects of using NIQE include...',
    ],
    'ILNIQE': [
      'ILNIQE Introduction: ILNIQE stands for Integrated Local NIQE...',
      'What ILNIQE does: ILNIQE evaluates the quality of images using local metrics...',
      'How to use ILNIQE: To use ILNIQE, you need to...',
      'Effects of ILNIQE: The effects of using ILNIQE include...',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeColors = themeProvider.themeColors;

    return ResponsiveLayout(
      tiny: _buildScrollableColumnLayout(themeColors),
      phone: _buildScrollableColumnLayout(themeColors),
      tablet: _buildScrollableColumnLayout(themeColors),
      largeTablet: _buildLargeTabletLayout(themeColors),
      computer: _buildComputerLayout(themeColors),
    );
  }

  Widget _buildScrollableColumnLayout(Map<String, Color> themeColors) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHelpSection(themeColors),
          SizedBox(height: 20),
          _buildTutorialSection(themeColors),
        ],
      ),
    );
  }

  Widget _buildLargeTabletLayout(Map<String, Color> themeColors) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildHelpSection(themeColors)),
        Expanded(flex: 3, child: _buildTutorialSection(themeColors)),
      ],
    );
  }

  Widget _buildComputerLayout(Map<String, Color> themeColors) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DrawerPage(
            onSectionSelected: widget.onSectionSelected,
          ),
        ),
        Expanded(flex: 2, child: _buildHelpSection(themeColors)),
        Expanded(flex: 3, child: _buildTutorialSection(themeColors)),
      ],
    );
  }

  Widget _buildHelpSection(Map<String, Color> themeColors) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: themeColors['helpPanelBackground'],
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeColors['panelBackground'],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'This section provides you with the necessary information on how to use the app. You can navigate through different features and functionalities using the menu. If you need further assistance, please refer to the tutorials section.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Select a Topic:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeColors['panelBackground'],
                  ),
                ),
                SizedBox(height: 10),
                DropdownButton<int>(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  borderRadius: BorderRadius.circular(10),
                  dropdownColor: themeColors['helpPanelBackground'],
                  value: _selectedTutorialIndex,
                  items: List.generate(tutorials.length, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text(tutorials[index]),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedTutorialIndex = value!;
                    });
                  },
                  isExpanded: true,
                ),
                SizedBox(height: 10),
                _buildTutorialSteps(themeColors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialSection(Map<String, Color> themeColors) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: themeColors['helpPanelBackground'],
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tutorials',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeColors['panelBackground'],
                  ),
                ),
                SizedBox(height: 10),
                _buildAlgorithmsGrid(themeColors),
                SizedBox(height: 20),
                if (_selectedAlgorithmIndex != -1) _buildAlgorithmSteps(themeColors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlgorithmsGrid(Map<String, Color> themeColors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: algorithms.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAlgorithmIndex = index;
              _currentStep = 0; // Reset step to 0
            });
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
            child: Center(
              child: Text(
                algorithms[index],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeColors['panelBackground'],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlgorithmSteps(Map<String, Color> themeColors) {
    String selectedAlgorithm = algorithms[_selectedAlgorithmIndex];
    List<String> steps = algorithmSteps[selectedAlgorithm]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedAlgorithm,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeColors['panelBackground'],
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: List.generate(steps.length, (index) {
            return ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = index;
                });
              },
              child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentStep == index ? themeColors['panelForeground'] : themeColors['subtitleColor'],
                shape: CircleBorder(),
                padding: EdgeInsets.all(20),
              ),
            );
          }),
        ),
        SizedBox(height: 20),
        Text(
          steps[_currentStep],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        Text(
          algorithmDetails[selectedAlgorithm]![_currentStep],
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTutorialSteps(Map<String, Color> themeColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(tutorialSteps[tutorials[_selectedTutorialIndex]]!.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}.',
                style: TextStyle(
                  fontSize: 16,
                  color: themeColors['panelBackground'],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  tutorialSteps[tutorials[_selectedTutorialIndex]]![index],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
