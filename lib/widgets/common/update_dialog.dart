// import 'package:cardmaker/core/values/app_colors.dart';
// import 'package:flutter/material.dart';

// class UpdateDialog {
//   static void showRequired(
//     BuildContext context, {
//     required String title,
//     required List<String> newFeatures,
//     required VoidCallback onUpdatePressed,
//   }) {
//     _showDialog(
//       context,
//       title: title,
//       newFeatures: newFeatures,
//       onUpdatePressed: onUpdatePressed,
//       isOptional: false,
//     );
//   }

//   static void showOptional(
//     BuildContext context, {
//     required String title,
//     required List<String> newFeatures,
//     required VoidCallback onUpdatePressed,
//     VoidCallback? onSkipPressed,
//   }) {
//     _showDialog(
//       context,
//       title: title,
//       newFeatures: newFeatures,
//       onUpdatePressed: onUpdatePressed,
//       onSkipPressed: onSkipPressed ?? () => Navigator.of(context).pop(),
//       isOptional: true,
//     );
//   }

//   static void _showDialog(
//     BuildContext context, {
//     required String title,
//     required List<String> newFeatures,
//     required VoidCallback onUpdatePressed,
//     VoidCallback? onSkipPressed,
//     required bool isOptional,
//   }) {
//     showDialog(
//       context: context,
//       barrierDismissible: isOptional,
//       barrierColor: Colors.black54,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async => isOptional,
//           child: Dialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             child: Container(
//               constraints: BoxConstraints(
//                 maxHeight: MediaQuery.of(context).size.height * 0.7,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20.0),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Header with gradient
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(24.0),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           AppColors.branding.withOpacity(0.9),
//                           AppColors.branding.withOpacity(0.7),
//                         ],
//                       ),
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(20.0),
//                         topRight: Radius.circular(20.0),
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         // Icon
//                         Container(
//                           padding: const EdgeInsets.all(12.0),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.system_update_rounded,
//                             color: Colors.white,
//                             size: 32.0,
//                           ),
//                         ),
//                         const SizedBox(height: 16.0),
//                         // Title
//                         Text(
//                           title,
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             fontSize: 20.0,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Content - FIXED: Removed Expanded and added constraints
//                   ConstrainedBox(
//                     constraints: BoxConstraints(
//                       maxHeight: MediaQuery.of(context).size.height * 0.3,
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24.0,
//                         vertical: 20.0,
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "What's New:",
//                             style: TextStyle(
//                               fontSize: 16.0,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 12.0),

//                           // Features list - FIXED: Removed Expanded
//                           Flexible(
//                             child: newFeatures.isEmpty
//                                 ? const Center(
//                                     child: Text(
//                                       "Performance improvements and bug fixes",
//                                       style: TextStyle(
//                                         color: Colors.grey,
//                                         fontStyle: FontStyle.italic,
//                                       ),
//                                     ),
//                                   )
//                                 : ListView.builder(
//                                     shrinkWrap: true,
//                                     physics: const BouncingScrollPhysics(),
//                                     itemCount: newFeatures.length,
//                                     itemBuilder: (context, index) {
//                                       return Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                           vertical: 6.0,
//                                         ),
//                                         child: Row(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Icon(
//                                               Icons.check_circle_rounded,
//                                               color: AppColors.branding,
//                                               size: 20.0,
//                                             ),
//                                             const SizedBox(width: 12.0),
//                                             Expanded(
//                                               child: Text(
//                                                 newFeatures[index],
//                                                 style: const TextStyle(
//                                                   fontSize: 14.0,
//                                                   color: Colors.black87,
//                                                   height: 1.4,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // Buttons section
//                   Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       children: [
//                         // Update button
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: onUpdatePressed,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.branding,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 16.0,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12.0),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: const Text(
//                               'UPDATE NOW',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16.0,
//                               ),
//                             ),
//                           ),
//                         ),

//                         // Later button (only for optional updates)
//                         if (isOptional) ...[
//                           const SizedBox(height: 12.0),
//                           SizedBox(
//                             width: double.infinity,
//                             child: TextButton(
//                               onPressed: onSkipPressed,
//                               style: TextButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 14.0,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12.0),
//                                 ),
//                               ),
//                               child: const Text(
//                                 'NOT NOW',
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 15.0,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
