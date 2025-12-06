// import 'dart:async';

// import 'package:cardmaker/app/features/editor/controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';

// /// Direction enum for alignment controls
// enum AlignmentDirection { up, down, left, right }

// /// Professional pixel alignment controls with arrow buttons
// /// Shows position values and allows tap/long-press to move items
// class PixelAlignmentControls extends StatefulWidget {
//   const PixelAlignmentControls({super.key, required this.controller});

//   final CanvasController controller;

//   @override
//   State<PixelAlignmentControls> createState() => _PixelAlignmentControlsState();
// }

// class _PixelAlignmentControlsState extends State<PixelAlignmentControls> {
//   Timer? _longPressTimer;
//   bool _isLongPressing = false;
//   double _pixelStep = 1.0;
//   final _steps = [1.0, 5.0, 10.0];
//   int _currentStepIndex = 0;

//   @override
//   void dispose() {
//     _longPressTimer?.cancel();
//     super.dispose();
//   }

//   void _startLongPress(AlignmentDirection direction) {
//     _isLongPressing = true;
//     _longPressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
//       if (_isLongPressing && mounted) {
//         _moveItem(direction);
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   void _stopLongPress() {
//     _isLongPressing = false;
//     _longPressTimer?.cancel();
//     _longPressTimer = null;
//   }

//   void _moveItem(AlignmentDirection direction) {
//     if (!mounted) return;
//     print('_moveItem called: direction=$direction, step=$_pixelStep');
//     HapticFeedback.lightImpact();
//     widget.controller.nudgeItem(direction, _pixelStep);
//   }

//   void _cyclePixelStep() {
//     setState(() {
//       _currentStepIndex = (_currentStepIndex + 1) % _steps.length;
//       _pixelStep = _steps[_currentStepIndex];
//     });
//     HapticFeedback.lightImpact();
//   }

//   void _showPixelSlider(BuildContext context) {
//     HapticFeedback.mediumImpact();
//     showDialog(
//       context: context,
//       barrierColor: Colors.black.withOpacity(0.2),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               contentPadding: const EdgeInsets.all(16),
//               backgroundColor: Theme.of(context).colorScheme.surface,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               title: Text(
//                 'Nudge by',
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     '${_pixelStep.toStringAsFixed(0)} px',
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Slider(
//                     value: _pixelStep,
//                     min: 1,
//                     max: 50,
//                     divisions: 49,
//                     label: _pixelStep.round().toString(),
//                     onChanged: (value) {
//                       setDialogState(() {
//                         setState(() {
//                           _pixelStep = value;
//                         });
//                       });
//                     },
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('Done'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final showControls = widget.controller.showPixelAlignment.value;

//       // Only close if explicitly closed via close button or context menu
//       if (!showControls) {
//         return const SizedBox.shrink();
//       }

//       final activeItem = widget.controller.activeItem.value;

//       // If no active item, show empty controls but keep widget open
//       if (activeItem == null) {
//         return Positioned(
//           bottom: 100,
//           right: 16,
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surface,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.15),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Close button row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const SizedBox(width: 4),
//                       Text(
//                         'Alignment',
//                         style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: Theme.of(context).colorScheme.onSurface,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           onTap: () {
//                             HapticFeedback.lightImpact();
//                             widget.controller.showPixelAlignment.value = false;
//                           },
//                           borderRadius: BorderRadius.circular(16),
//                           child: Container(
//                             width: 28,
//                             height: 28,
//                             decoration: BoxDecoration(
//                               color: Colors.grey.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Icon(
//                               Icons.close,
//                               size: 16,
//                               color: Theme.of(context).colorScheme.onSurface,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Text(
//                       'No item selected',
//                       style: Theme.of(
//                         context,
//                       ).textTheme.bodySmall?.copyWith(color: Colors.grey),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }

//       final canvasSize = Size(
//         widget.controller.scaledCanvasWidth.value,
//         widget.controller.scaledCanvasHeight.value,
//       );

//       // Calculate current pixel positions
//       final left = activeItem.offset.dx - activeItem.size.width / 2;
//       final right =
//           canvasSize.width - (activeItem.offset.dx + activeItem.size.width / 2);
//       final top = activeItem.offset.dy - activeItem.size.height / 2;
//       final bottom =
//           canvasSize.height -
//           (activeItem.offset.dy + activeItem.size.height / 2);

//       return Positioned(
//         bottom: 100,
//         right: 16,
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.surface,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.15),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Close button row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const SizedBox(width: 4),
//                     Text(
//                       'Alignment',
//                       style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: Theme.of(context).colorScheme.onSurface,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: () {
//                           HapticFeedback.lightImpact();
//                           widget.controller.showPixelAlignment.value = false;
//                         },
//                         borderRadius: BorderRadius.circular(16),
//                         child: Container(
//                           width: 28,
//                           height: 28,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Icon(
//                             Icons.close,
//                             size: 16,
//                             color: Theme.of(context).colorScheme.onSurface,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 // Top arrow
//                 _CompactDirectionButton(
//                   direction: AlignmentDirection.up,
//                   value: top,
//                   onTap: () => _moveItem(AlignmentDirection.up),
//                   onLongPressStart: () =>
//                       _startLongPress(AlignmentDirection.up),
//                   onLongPressEnd: _stopLongPress,
//                 ),
//                 const SizedBox(height: 4),
//                 // Left and Right arrows
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _CompactDirectionButton(
//                       direction: AlignmentDirection.left,
//                       value: left,
//                       onTap: () => _moveItem(AlignmentDirection.left),
//                       onLongPressStart: () =>
//                           _startLongPress(AlignmentDirection.left),
//                       onLongPressEnd: _stopLongPress,
//                     ),
//                     const SizedBox(width: 4),
//                     _PixelStepButton(
//                       pixelStep: _pixelStep,
//                       onTap: _cyclePixelStep,
//                       onLongPress: () => _showPixelSlider(context),
//                     ),
//                     const SizedBox(width: 4),
//                     _CompactDirectionButton(
//                       direction: AlignmentDirection.right,
//                       value: right,
//                       onTap: () => _moveItem(AlignmentDirection.right),
//                       onLongPressStart: () =>
//                           _startLongPress(AlignmentDirection.right),
//                       onLongPressEnd: _stopLongPress,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 // Bottom arrow
//                 _CompactDirectionButton(
//                   direction: AlignmentDirection.down,
//                   value: bottom,
//                   onTap: () => _moveItem(AlignmentDirection.down),
//                   onLongPressStart: () =>
//                       _startLongPress(AlignmentDirection.down),
//                   onLongPressEnd: _stopLongPress,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }

// class _PixelStepButton extends StatelessWidget {
//   const _PixelStepButton({
//     required this.pixelStep,
//     required this.onTap,
//     required this.onLongPress,
//   });

//   final double pixelStep;
//   final VoidCallback onTap;
//   final VoidCallback onLongPress;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return GestureDetector(
//       onTap: onTap,
//       onLongPress: onLongPress,
//       child: Container(
//         width: 44,
//         height: 44,
//         decoration: BoxDecoration(
//           color: theme.colorScheme.primaryContainer.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: theme.colorScheme.primary.withOpacity(0.4),
//             width: 1,
//           ),
//         ),
//         child: Center(
//           child: Text(
//             '${pixelStep.toStringAsFixed(0)}px',
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: theme.colorScheme.primary,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _CompactDirectionButton extends StatefulWidget {
//   const _CompactDirectionButton({
//     required this.direction,
//     required this.value,
//     required this.onTap,
//     required this.onLongPressStart,
//     required this.onLongPressEnd,
//   });

//   final AlignmentDirection direction;
//   final double value;
//   final VoidCallback onTap;
//   final VoidCallback onLongPressStart;
//   final VoidCallback onLongPressEnd;

//   @override
//   State<_CompactDirectionButton> createState() =>
//       _CompactDirectionButtonState();
// }

// class _CompactDirectionButtonState extends State<_CompactDirectionButton> {
//   bool _isPressed = false;
//   Timer? _longPressTimer;
//   bool _isLongPressing = false;

//   IconData get _icon {
//     switch (widget.direction) {
//       case AlignmentDirection.up:
//         return Icons.keyboard_arrow_up;
//       case AlignmentDirection.down:
//         return Icons.keyboard_arrow_down;
//       case AlignmentDirection.left:
//         return Icons.keyboard_arrow_left;
//       case AlignmentDirection.right:
//         return Icons.keyboard_arrow_right;
//     }
//   }

//   @override
//   void dispose() {
//     _longPressTimer?.cancel();
//     super.dispose();
//   }

//   void _handleTap() {
//     // Simple tap - move once
//     print('_handleTap called for ${widget.direction}');
//     widget.onTap();
//   }

//   void _handleLongPress() {
//     print('_handleLongPress called for ${widget.direction}');
//     _isLongPressing = true;
//     widget.onLongPressStart();
//     // Start continuous movement
//     _longPressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
//       if (mounted && _isLongPressing) {
//         widget.onTap(); // Trigger move repeatedly
//       } else {
//         timer.cancel();
//         _longPressTimer = null;
//       }
//     });
//   }

//   void _handleLongPressEnd() {
//     print('_handleLongPressEnd called for ${widget.direction}');
//     _isLongPressing = false;
//     _longPressTimer?.cancel();
//     _longPressTimer = null;
//     widget.onLongPressEnd();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isHorizontal =
//         widget.direction == AlignmentDirection.left ||
//         widget.direction == AlignmentDirection.right;

//     return Listener(
//       onPointerDown: (_) {
//         setState(() => _isPressed = true);
//         // Start timer for long press detection
//         _longPressTimer = Timer(const Duration(milliseconds: 500), () {
//           if (mounted && _isPressed) {
//             _handleLongPress();
//           }
//         });
//       },
//       onPointerUp: (_) {
//         _longPressTimer?.cancel();
//         _longPressTimer = null;
//         if (_isLongPressing) {
//           _handleLongPressEnd();
//         } else {
//           // It was a tap
//           _handleTap();
//         }
//         setState(() {
//           _isPressed = false;
//           _isLongPressing = false;
//         });
//       },
//       onPointerCancel: (_) {
//         _longPressTimer?.cancel();
//         _longPressTimer = null;
//         if (_isLongPressing) {
//           _handleLongPressEnd();
//         }
//         setState(() {
//           _isPressed = false;
//           _isLongPressing = false;
//         });
//       },
//       child: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         child: Container(
//           width: isHorizontal ? 50 : 44,
//           height: isHorizontal ? 44 : 50,
//           decoration: BoxDecoration(
//             color: _isPressed
//                 ? theme.colorScheme.primary.withOpacity(0.2)
//                 : theme.colorScheme.primaryContainer.withOpacity(0.3),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: theme.colorScheme.primary.withOpacity(0.4),
//               width: 1,
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(_icon, color: theme.colorScheme.primary, size: 20),
//               const SizedBox(height: 2),
//               Text(
//                 widget.value.toStringAsFixed(0),
//                 style: theme.textTheme.labelSmall?.copyWith(
//                   color: theme.colorScheme.primary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 10,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
