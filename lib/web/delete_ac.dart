import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _reasonController = TextEditingController();
  final RxBool _showForm = false.obs;
  final RxBool _showSuccess = false.obs;
  final RxBool _agreedToTerms = false.obs;
  final RxString _requestStatus = ''.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _checkRequestStatus(String email) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      _requestStatus.value = '';
      return;
    }
    try {
      final query = await FirebaseFirestore.instance
          .collection('deletion_requests')
          .where('email', isEqualTo: email)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      _requestStatus.value = query.docs.isNotEmpty
          ? query.docs.first['status'] ?? 'Pending'
          : '';
    } catch (e) {
      _requestStatus.value = '';
      Get.snackbar(
        'Error',
        'Failed to check request status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 60,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(children: [_buildHeader(), _buildContent()]),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text(
            '🗑️ Delete Your Inkkaro Account',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Request permanent deletion of your account and data',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.95),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWarningBox(),
          const SizedBox(height: 30),
          _buildSectionTitle(),
          const SizedBox(height: 30),
          _buildOption1Card(),
          const SizedBox(height: 30),
          _buildDivider(),
          const SizedBox(height: 30),
          _buildOption2Card(),
          const SizedBox(height: 30),
          _buildInfoBox(),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        border: const Border(
          left: BorderSide(color: Color(0xFFFFC107), width: 4),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'Important Warning',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF856404),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Account deletion is permanent and cannot be undone. Once deleted, you will not be able to recover:',
            style: TextStyle(color: const Color(0xFF856404), height: 1.5),
          ),
          const SizedBox(height: 8),
          _buildWarningItem('All your saved drafts and designs'),
          _buildWarningItem('Your favorites and bookmarks'),
          _buildWarningItem('Your profile information'),
          _buildWarningItem('All personal data associated with your account'),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF856404))),
          Expanded(
            child: Text(text, style: const TextStyle(color: Color(0xFF856404))),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        const Icon(Icons.list_alt, color: Color(0xFF667eea), size: 28),
        const SizedBox(width: 10),
        Text(
          'Choose Your Deletion Method',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF667eea),
          ),
        ),
      ],
    );
  }

  Widget _buildOption1Card() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 2),
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Option 1: Delete via Mobile App (Fastest)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'If you have the Inkkaro app installed, you can delete your account instantly:',
            style: TextStyle(color: Colors.grey[700], height: 1.6),
          ),
          const SizedBox(height: 20),
          _buildStepsBox(),
        ],
      ),
    );
  }

  Widget _buildStepsBox() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          _buildStep(
            1,
            'Open Settings',
            'Launch the app and tap the Settings icon',
          ),
          const SizedBox(height: 20),
          _buildStep(
            2,
            'Find Delete Account',
            'Scroll to the bottom and tap "Delete Account"',
          ),
          const SizedBox(height: 20),
          _buildStep(
            3,
            'Confirm Deletion',
            'Follow the prompts and verify your identity',
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFF667eea),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: const Color(0xFFE9ECEF));
  }

  Widget _buildOption2Card() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 2),
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Option 2: Request Deletion via Web',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Don't have the app installed? Submit a deletion request below, and we'll process it within 48 hours.",
            style: TextStyle(color: Colors.grey[700], height: 1.6),
          ),
          const SizedBox(height: 20),
          Obx(
            () => _showSuccess.value
                ? _buildSuccessMessage()
                : _showForm.value
                ? _buildDeletionForm()
                : _buildRequestButton(),
          ),
          const SizedBox(height: 20),
          Obx(
            () => _requestStatus.value.isNotEmpty
                ? _buildStatusMessage()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showForm.value = true;
          _requestStatus.value = '';
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC3545),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          'Request Account Deletion',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDeletionForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email Address *',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter your account email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE9ECEF),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE9ECEF),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF667eea),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onChanged: (value) {
              _checkRequestStatus(value);
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Reason for Deletion (Optional)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _reasonController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Tell us why you're leaving (optional)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE9ECEF),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE9ECEF),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF667eea),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => CheckboxListTile(
              value: _agreedToTerms.value,
              onChanged: (value) => _agreedToTerms.value = value ?? false,
              title: const Text(
                'I understand that this action is permanent and all my data will be deleted',
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _requestStatus.value.isNotEmpty
                      ? null
                      : () => _submitDeletionRequest(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _requestStatus.value.isNotEmpty
                        ? Colors.grey
                        : const Color(0xFFDC3545),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _requestStatus.value.isNotEmpty
                        ? 'Request Already Submitted'
                        : 'Submit Deletion Request',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showForm.value = false;
                    _agreedToTerms.value = false;
                    _emailController.clear();
                    _reasonController.clear();
                    _requestStatus.value = '';
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C757D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD4EDDA),
        border: const Border(
          left: BorderSide(color: Color(0xFF28A745), width: 4),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✅ Request Submitted Successfully',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF155724),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Your account deletion request has been received. We'll process it within 48 hours and send a confirmation email to the address you provided.",
            style: TextStyle(color: const Color(0xFF155724), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    Color statusColor;
    String statusText;
    switch (_requestStatus.value) {
      case 'Pending':
        statusColor = Colors.amber;
        statusText = '⏳ Your deletion request is pending.';
        break;
      case 'Processed':
        statusColor = Colors.green;
        statusText = '✅ Your deletion request has been processed.';
        break;
      case 'Failed':
        statusColor = Colors.red;
        statusText = '❌ Your deletion request failed. Please contact support.';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown status';
    }

    return Container(
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE7F3FF),
        border: const Border(
          left: BorderSide(color: Color(0xFF2196F3), width: 4),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📧 Need Help?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: TextStyle(color: const Color(0xFF0D47A1), height: 1.5),
              children: [
                const TextSpan(
                  text:
                      'If you have questions or need assistance with account deletion, contact us at: ',
                ),
                TextSpan(
                  text: 'support@inkkaro.com',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Subject line: "Account Deletion Request"',
            style: TextStyle(color: const Color(0xFF0D47A1)),
          ),
        ],
      ),
    );
  }

  void _submitDeletionRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms.value) {
      Get.snackbar(
        'Agreement Required',
        'Please confirm that you understand this action is permanent',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final email = _emailController.text;
    final reason = _reasonController.text;

    try {
      // Check if a request already exists
      final existingRequest = await FirebaseFirestore.instance
          .collection('deletion_requests')
          .where('email', isEqualTo: email)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        _requestStatus.value =
            existingRequest.docs.first['status'] ?? 'Pending';
        Get.snackbar(
          'Request Exists',
          'A deletion request for this email already exists. Current status: ${_requestStatus.value}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('deletion_requests').add({
        'email': email,
        'reason': reason.isEmpty ? 'Not specified' : reason,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending',
      });

      // Send email notification (optional)
      final subject = Uri.encodeComponent('Account Deletion Request');
      final body = Uri.encodeComponent(
        'I request the deletion of my Inkkaro account.\n\n'
        'Email: $email\n'
        'Reason: ${reason.isEmpty ? "Not specified" : reason}\n\n'
        'I understand this action is permanent and all my data will be deleted.',
      );
      final mailtoUrl =
          'mailto:support@inkkaro.com?subject=$subject&body=$body';
      if (await canLaunchUrl(Uri.parse(mailtoUrl))) {
        await launchUrl(Uri.parse(mailtoUrl));
      }

      _showForm.value = false;
      _showSuccess.value = true;
      _requestStatus.value = 'Pending';
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit request: $e. Please contact support@inkkaro.com.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
// class AccountDeletionPage extends StatefulWidget {
//   const AccountDeletionPage({super.key});

//   @override
//   State<AccountDeletionPage> createState() => _AccountDeletionPageState();
// }

// class _AccountDeletionPageState extends State<AccountDeletionPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _reasonController = TextEditingController();
//   final RxBool _showForm = false.obs;
//   final RxBool _showSuccess = false.obs;
//   final RxBool _agreedToTerms = false.obs;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _reasonController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.3),
//                           blurRadius: 60,
//                           offset: const Offset(0, 20),
//                         ),
//                       ],
//                     ),
//                     child: Column(children: [_buildHeader(), _buildContent()]),
//                   ),
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//         ),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//       ),
//       padding: const EdgeInsets.all(40),
//       child: Column(
//         children: [
//           Text(
//             '🗑️ Delete Your Inkkaro Account',
//             style: TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Request permanent deletion of your account and data',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.white.withOpacity(0.95),
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent() {
//     return Padding(
//       padding: const EdgeInsets.all(40),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildWarningBox(),
//           const SizedBox(height: 30),
//           _buildSectionTitle(),
//           const SizedBox(height: 30),
//           _buildOption1Card(),
//           const SizedBox(height: 30),
//           _buildDivider(),
//           const SizedBox(height: 30),
//           _buildOption2Card(),
//           const SizedBox(height: 30),
//           _buildInfoBox(),
//         ],
//       ),
//     );
//   }

//   Widget _buildWarningBox() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFF3CD),
//         border: const Border(
//           left: BorderSide(color: Color(0xFFFFC107), width: 4),
//         ),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Text('⚠️', style: TextStyle(fontSize: 20)),
//               const SizedBox(width: 10),
//               Text(
//                 'Important Warning',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF856404),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Account deletion is permanent and cannot be undone. Once deleted, you will not be able to recover:',
//             style: TextStyle(color: const Color(0xFF856404), height: 1.5),
//           ),
//           const SizedBox(height: 8),
//           _buildWarningItem('All your saved drafts and designs'),
//           _buildWarningItem('Your favorites and bookmarks'),
//           _buildWarningItem('Your profile information'),
//           _buildWarningItem('All personal data associated with your account'),
//         ],
//       ),
//     );
//   }

//   Widget _buildWarningItem(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 20, top: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('• ', style: TextStyle(color: Color(0xFF856404))),
//           Expanded(
//             child: Text(text, style: const TextStyle(color: Color(0xFF856404))),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle() {
//     return Row(
//       children: [
//         const Icon(Icons.list_alt, color: Color(0xFF667eea), size: 28),
//         const SizedBox(width: 10),
//         Text(
//           'Choose Your Deletion Method',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF667eea),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOption1Card() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8F9FA),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE9ECEF), width: 2),
//       ),
//       padding: const EdgeInsets.all(30),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Option 1: Delete via Mobile App (Fastest)',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF667eea),
//             ),
//           ),
//           const SizedBox(height: 15),
//           Text(
//             'If you have the Inkkaro app installed, you can delete your account instantly:',
//             style: TextStyle(color: Colors.grey[700], height: 1.6),
//           ),
//           const SizedBox(height: 20),
//           _buildStepsBox(),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepsBox() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8F9FA),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.all(30),
//       child: Column(
//         children: [
//           _buildStep(
//             1,
//             'Open Settings',
//             'Launch the app and tap the Settings icon',
//           ),
//           const SizedBox(height: 20),
//           _buildStep(
//             2,
//             'Find Delete Account',
//             'Scroll to the bottom and tap "Delete Account"',
//           ),
//           const SizedBox(height: 20),
//           _buildStep(
//             3,
//             'Confirm Deletion',
//             'Follow the prompts and verify your identity',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStep(int number, String title, String description) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 36,
//           height: 36,
//           decoration: const BoxDecoration(
//             color: Color(0xFF667eea),
//             shape: BoxShape.circle,
//           ),
//           child: Center(
//             child: Text(
//               '$number',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 15),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.only(top: 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   description,
//                   style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDivider() {
//     return Container(height: 1, color: const Color(0xFFE9ECEF));
//   }

//   Widget _buildOption2Card() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8F9FA),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE9ECEF), width: 2),
//       ),
//       padding: const EdgeInsets.all(30),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Option 2: Request Deletion via Web',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF667eea),
//             ),
//           ),
//           const SizedBox(height: 15),
//           Text(
//             "Don't have the app installed? Submit a deletion request below, and we'll process it within 48 hours.",
//             style: TextStyle(color: Colors.grey[700], height: 1.6),
//           ),
//           const SizedBox(height: 20),
//           Obx(
//             () => _showSuccess.value
//                 ? _buildSuccessMessage()
//                 : _showForm.value
//                 ? _buildDeletionForm()
//                 : _buildRequestButton(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRequestButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () => _showForm.value = true,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFFDC3545),
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           elevation: 0,
//         ),
//         child: const Text(
//           'Request Account Deletion',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }

//   Widget _buildDeletionForm() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Email Address *',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[800],
//             ),
//           ),
//           const SizedBox(height: 8),
//           TextFormField(
//             controller: _emailController,
//             keyboardType: TextInputType.emailAddress,
//             decoration: InputDecoration(
//               hintText: 'Enter your account email',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: const BorderSide(
//                   color: Color(0xFFE9ECEF),
//                   width: 2,
//                 ),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: const BorderSide(
//                   color: Color(0xFFE9ECEF),
//                   width: 2,
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: const BorderSide(
//                   color: Color(0xFF667eea),
//                   width: 2,
//                 ),
//               ),
//               contentPadding: const EdgeInsets.all(12),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your email';
//               }
//               if (!GetUtils.isEmail(value)) {
//                 return 'Please enter a valid email';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Reason for Deletion (Optional)',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[800],
//             ),
//           ),
//           const SizedBox(height: 8),
//           TextFormField(
//             controller: _reasonController,
//             maxLines: 4,
//             decoration: InputDecoration(
//               hintText: "Tell us why you're leaving (optional)",
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: const BorderSide(
//                   color: Color(0xFFE9ECEF),
//                   width: 2,
//                 ),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: const BorderSide(
//                   color: Color(0xFFE9ECEF),
//                   width: 2,
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: const BorderSide(
//                   color: Color(0xFF667eea),
//                   width: 2,
//                 ),
//               ),
//               contentPadding: const EdgeInsets.all(12),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Obx(
//             () => CheckboxListTile(
//               value: _agreedToTerms.value,
//               onChanged: (value) => _agreedToTerms.value = value ?? false,
//               title: const Text(
//                 'I understand that this action is permanent and all my data will be deleted',
//                 style: TextStyle(fontSize: 14),
//               ),
//               controlAffinity: ListTileControlAffinity.leading,
//               contentPadding: EdgeInsets.zero,
//               activeColor: const Color(0xFF667eea),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () => _submitDeletionRequest(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFDC3545),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'Submit Deletion Request',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     _showForm.value = false;
//                     _agreedToTerms.value = false;
//                     _emailController.clear();
//                     _reasonController.clear();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF6C757D),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'Cancel',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSuccessMessage() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFD4EDDA),
//         border: const Border(
//           left: BorderSide(color: Color(0xFF28A745), width: 4),
//         ),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '✅ Request Submitted Successfully',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF155724),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             "Your account deletion request has been received. We'll process it within 48 hours and send a confirmation email to the address you provided.",
//             style: TextStyle(color: const Color(0xFF155724), height: 1.5),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoBox() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFE7F3FF),
//         border: const Border(
//           left: BorderSide(color: Color(0xFF2196F3), width: 4),
//         ),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '📧 Need Help?',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF1976D2),
//             ),
//           ),
//           const SizedBox(height: 10),
//           RichText(
//             text: TextSpan(
//               style: TextStyle(color: const Color(0xFF0D47A1), height: 1.5),
//               children: [
//                 const TextSpan(
//                   text:
//                       'If you have questions or need assistance with account deletion, contact us at: ',
//                 ),
//                 TextSpan(
//                   text: 'support@inkkaro.com',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1976D2),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Subject line: "Account Deletion Request"',
//             style: TextStyle(color: const Color(0xFF0D47A1)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _submitDeletionRequest() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (!_agreedToTerms.value) {
//       Get.snackbar(
//         'Agreement Required',
//         'Please confirm that you understand this action is permanent',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     final email = _emailController.text;
//     final reason = _reasonController.text;

//     final subject = Uri.encodeComponent('Account Deletion Request');
//     final body = Uri.encodeComponent(
//       'I request the deletion of my Inkkaro account.\n\n'
//       'Email: $email\n'
//       'Reason: ${reason.isEmpty ? "Not specified" : reason}\n\n'
//       'I understand this action is permanent and all my data will be deleted.',
//     );

//     final mailtoUrl = 'mailto:support@inkkaro.com?subject=$subject&body=$body';

//     try {
//       if (await canLaunchUrl(Uri.parse(mailtoUrl))) {
//         await launchUrl(Uri.parse(mailtoUrl));
//         _showForm.value = false;
//         _showSuccess.value = true;
//       } else {
//         Get.snackbar(
//           'Error',
//           'Could not open email client. Please email support@inkkaro.com directly.',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Could not send email. Please contact support@inkkaro.com directly.',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
// }
