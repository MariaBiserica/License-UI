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
      'Introduction and Justification',
      'Impact in Machine Learning',
      'Classic Architecture',
      'Advantages for Regression Tasks',
      'Adaptation for Regression',
      'Loss Functions'
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
      'VGG16 is a deep convolutional neural network (CNN) introduced by Simonyan and Zisserman in 2014. It gained popularity due to its remarkable performance in the ImageNet Large Scale Visual Recognition Challenge (ILSVRC) 2014. VGG16 was chosen for this work due to its solid reputation and well-studied structure, making it ideal for adaptations and experiments. Despite newer models like ResNet showing superior performance in many applications, VGG16’s simplicity and efficiency make it a valuable choice for research and development in image quality assessment systems.',
      'VGG16 had a significant impact on machine learning by demonstrating that deeper neural networks can significantly improve image recognition accuracy. Its straightforward structure, based on 3x3 convolution layers and 2x2 max-pooling layers, facilitated a clearer understanding of how network depth affects performance.',
      'The classic architecture of VGG16 consists of 16 layers, including 13 convolutional layers and 3 fully connected layers. Each convolutional layer uses 3x3 filters, followed by a 2x2 max-pooling layer after each set of convolutional layers. The final network structure includes: 2 convolutional layers (64 filters) + max-pooling, 2 convolutional layers (128 filters) + max-pooling, 3 convolutional layers (256 filters) + max-pooling, 3 convolutional layers (512 filters) + max-pooling, 3 convolutional layers (512 filters) + max-pooling, 3 fully connected layers + softmax for classification.',
      'Adapting VGG16 for regression tasks offers several advantages: Transfer Learning: Pre-trained weights from large datasets like ImageNet can be used to extract relevant features from images, reducing training time and resources. Accuracy: VGG16’s deep architecture and small convolutional layers (3x3) capture fine details at each depth level, contributing to high accuracy. Flexibility: VGG16 can be easily adapted to different data types and tasks by modifying the output layers. Reduced Overfitting: Transfer learning and built-in regularization help reduce overfitting, improving model generalization on unseen data. Computational Efficiency: Despite its depth, VGG16’s simplified structure and efficient use of convolutions and max-pooling make training and inference faster compared to other deep networks.',
      'To adapt VGG16 for regression tasks, modifications were made to the original architecture. The upper layers of the original VGG16 model were removed to allow the addition of customized dense layers for regression tasks. After flattening the extracted features, dense layers were added to process these features, culminating in an output layer with linear activation to produce a continuous score. Dropout layers were introduced before the output layer to reduce overfitting.',
      'Various loss functions were tested to optimize the model effectively for regression tasks. These include: Mean Squared Error (MSE), Mean Absolute Error (MAE), and Huber loss. These functions were chosen for their ability to handle different aspects of error penalization during training, improving the overall performance of the model. By constantly adjusting the parameters and architecture, VGG16 was optimized for the specific regression task, demonstrating its adaptability beyond traditional image classification.'
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
                  fontFamily: 'HeaderFont', 
                  fontSize: 34, 
                  fontWeight: FontWeight.bold,
                  color: themeColors['panelBackground'],
                  shadows: <Shadow>[
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
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
                  fontFamily: 'HeaderFont', 
                  fontSize: 21, 
                  fontWeight: FontWeight.bold,
                  color: themeColors['panelBackground'],
                  shadows: <Shadow>[
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
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
                  fontFamily: 'HeaderFont', 
                  fontSize: 34, 
                  fontWeight: FontWeight.bold,
                  color: themeColors['panelBackground'],
                  shadows: <Shadow>[
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
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
            fontFamily: 'HeaderFont', 
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            color: themeColors['panelBackground'],
            shadows: <Shadow>[
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
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
