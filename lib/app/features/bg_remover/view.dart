// import 'package:cardmaker/app/features/bg_remover/controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class BackgroundRemovalPage extends StatelessWidget {
//   const BackgroundRemovalPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(BackgroundRemovalController());

//     return Scaffold(
//       appBar: AppBar(title: const Text('Background Removal')),
//       body: Column(
//         children: [
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: controller.pickAndProcessImage,
//             child: const Text('Select Image'),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: Center(
//               child: Obx(() {
//                 if (controller.isProcessing.value) {
//                   return const Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(),
//                       SizedBox(height: 16),
//                       Text('Processing image...'),
//                     ],
//                   );
//                 }

//                 if (controller.outputBytes.value != null) {
//                   return Container(
//                     decoration: BoxDecoration(
//                       // Checkerboard pattern to show transparency
//                       image: const DecorationImage(
//                         image: AssetImage('assets/transparency_bg.png'),
//                         repeat: ImageRepeat.repeat,
//                       ),
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.memory(
//                         controller.outputBytes.value!,
//                         fit: BoxFit.contain,
//                         // This ensures transparency is properly displayed
//                         filterQuality: FilterQuality.high,
//                       ),
//                     ),
//                   );
//                 }

//                 if (controller.inputImage.value != null) {
//                   return ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       controller.inputImage.value!,
//                       fit: BoxFit.contain,
//                     ),
//                   );
//                 }

//                 return const Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.image, size: 64, color: Colors.grey),
//                     SizedBox(height: 16),
//                     Text('No image selected'),
//                   ],
//                 );
//               }),
//             ),
//           ),
//           // Add save/share options
//           Obx(() {
//             if (controller.outputBytes.value != null) {
//               return Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         // Add your save to gallery logic here
//                         Get.snackbar('Success', 'Image saved to gallery');
//                       },
//                       icon: const Icon(Icons.save),
//                       label: const Text('Save'),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         // Add your share logic here
//                         Get.snackbar('Info', 'Share functionality');
//                       },
//                       icon: const Icon(Icons.share),
//                       label: const Text('Share'),
//                     ),
//                   ],
//                 ),
//               );
//             }
//             return const SizedBox.shrink();
//           }),
//         ],
//       ),
//     );
//   }
// }
