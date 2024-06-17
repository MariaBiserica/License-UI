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
      'Introduction to BRISQUE',
      'Natural Scene Statistics',
      'Generalized Gaussian Distribution',
      'Pairwise Products of MSCN Coefficients',
      'Image Quality Evaluation with BRISQUE',
      'BRISQUE Scores and MOS Scaling'
    ],
    'NIQE': [
      'Introduction to NIQE',
      'NIQE Model for Image Quality Evaluation',
      'Spatial Domain of NSS',
      'Selecting Image Patches',
      'Characterizing Image Patches',
      'Multivariate Gaussian Model',
      'NIQE Scores and MOS Scaling'
    ],
    'ILNIQE': [
      'Introduction to IL-NIQE',
      'Quality Sensitive Features',
      'Gradient Statistics',
      'Log-Gabor Responses',
      'Color Statistics',
      'Multivariate Gaussian Model',
      'IL-NIQE Scores and MOS Scaling'
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
      'BRISQUE (Blind/Referenceless Image Spatial Quality Evaluator) is an NR-IQA model proposed by A. K. Moorthy, A. Mittal and A. C. Bovik. It evaluates image quality in the spatial domain using natural scene statistics. BRISQUE does not rely on specific distortion features but uses normalized luminance coefficients to quantify the loss of naturalness due to distortions, leading to a holistic measure of quality.',
      'BRISQUE relies on the analysis of the distribution of normalized local luminance and its relationships. It operates in the spatial domain without requiring coordinate transformations like DCT or wavelet, making it different from previous NR-IQA approaches. Despite its simplicity, BRISQUE statistically outperforms many full-reference models like PSNR and SSIM and is competitive with generic NR-IQA algorithms.',
      'BRISQUE uses a Generalized Gaussian Distribution (GGD) to model the distribution of MSCN (Mean Subtracted Contrast Normalized) coefficients. The GGD provides flexibility in modeling the coefficients, and the Asymmetric Generalized Gaussian Distribution (AGGD) captures asymmetries in statistical data, crucial for evaluating image quality under various distortions.',
      'To model the statistical relationships between neighboring pixels, BRISQUE uses pairwise products of MSCN coefficients along four orientations: horizontal, vertical, main diagonal, and secondary diagonal. The distributions of these products are modeled using AGGD to better capture empirical densities observed in distorted images.',
      'BRISQUE evaluates image quality by extracting features at two scales: the original resolution and a lower resolution (downsampled by a factor of 2). A total of 36 features (18 per scale) are used to identify distortions and evaluate quality. BRISQUE learns a mapping from feature space to quality scores using a regression module, typically an SVR (Support Vector Regressor).',
      'BRISQUE scores range from 0 to 100, with lower scores indicating better quality. These scores can be scaled to the MOS (Mean Opinion Score) range of 1 to 5 for subjective interpretation. For example, a BRISQUE score of 0 corresponds to a MOS of 5, while a score of 100 corresponds to a MOS of 1. This scaling ensures direct comparability between objective BRISQUE scores and subjective human evaluations of image quality.'
    ],
    'NIQE': [
      'NIQE (Natural Image Quality Evaluator) is a completely blind image quality assessment model that evaluates image quality using measurable deviations from statistical regularities observed in natural images. Unlike many NR-IQA models, NIQE does not require training on distorted images and human opinion scores, making it an "opinion unaware" model.',
      'NIQE evaluates image quality by constructing a collection of "quality aware" statistical features based on a simple and successful model of natural scene statistics (NSS) in the spatial domain. The quality of a test image is expressed as the distance between the multivariate Gaussian fit of the NSS features extracted from the test image and a model of natural images.',
      'The NIQE model relies on spatial domain NSS features extracted from local image patches. These features capture essential low-order statistics of natural images. Normalized local luminance, local mean, and local contrast are used to characterize the image patches. Natural images tend to follow a Gaussian distribution when these coefficients are calculated, and deviations from this ideal indicate the presence and severity of distortions.',
      'To select the image patches used for feature extraction, a simple measure of local sharpness is employed. The local standard deviation quantifies the local sharpness, and patches with sharpness above a certain threshold are selected. This ensures that quality measurements are more meaningful as they focus on the clearer regions of the image.',
      'Once the image patches are selected, their statistics are characterized using NSS "quality aware" features. The features are modeled using a generalized Gaussian distribution (GGD) and the asymmetric generalized Gaussian distribution (AGGD) to capture deviations caused by distortions. Parameters of the GGD and AGGD are estimated to characterize the NSS features of the patches.',
      'A simple model of the NSS features calculated from natural image patches can be obtained by fitting them to a multivariate Gaussian density (MVG), providing a rich representation of these features. The quality of the distorted image is expressed as the distance between the NSS model of natural images and the MVG fit of the test image features.',
      'NIQE scores are expressed on an open scale, with lower scores indicating better image quality. These scores can be scaled to the MOS (Mean Opinion Score) range of 1 to 5 for subjective interpretation. For example, a NIQE score can be scaled using the minimum and maximum scores from a reference dataset to ensure comparability between objective NIQE scores and subjective human evaluations of image quality.'
    ],
    'ILNIQE': [
      'IL-NIQE (Integrated Local Natural Image Quality Evaluator) is an opinion-unaware NR-IQA model that integrates natural scene statistics (NSS) features from multiple indices to evaluate image quality without requiring subjective human scores for training. IL-NIQE constructs a multivariate Gaussian model from natural, undistorted images and measures quality using a Bhattacharyya distance.',
      'IL-NIQE uses five types of NSS features to improve image quality assessment: normalized luminance statistics, MSCN product statistics, gradient statistics, Log-Gabor responses, and color statistics. These features help capture the degree of degradation in distorted images.',
      'Gradient statistics describe the local structure and quality of an image. The gradient components (horizontal and vertical) are obtained using a Gaussian derivative filter. The gradients follow a generalized Gaussian distribution (GGD), and the Weibull distribution models the gradient magnitudes. The parameters of these distributions are used as quality features.',
      'Log-Gabor filters are used for multi-scale and multi-orientation analysis, capturing perceptually relevant details. The filter responses are modeled using GGD and Weibull distributions. The parameters from these distributions serve as additional quality features.',
      'Color statistics are captured using a classical NSS model in the log-opponent color space. The distributions of the log-opponent color components are fitted to a Gaussian model, and the parameters are used as quality features. These features capture both local and global image distortions.',
      'A simple model of the NSS features calculated from natural image patches can be obtained by fitting them to a multivariate Gaussian density (MVG), providing a rich representation of these features. The quality of the distorted image is expressed as the distance between the NSS model of natural images and the MVG fit of the test image features.',
      'IL-NIQE scores are expressed on an open scale, with lower scores indicating better image quality. These scores can be scaled to the MOS (Mean Opinion Score) range of 1 to 5 for subjective interpretation. For example, a IL-NIQE score can be scaled using the minimum and maximum scores from a reference dataset to ensure comparability between objective IL-NIQE scores and subjective human evaluations of image quality.'
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
