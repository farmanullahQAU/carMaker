const Map<String, String> authErrors = {
  'invalid-email': 'Invalid email address format.',
  'user-disabled': 'This user account has been disabled.',
  'user-not-found': 'No user found with this email.',
  'wrong-password': 'Incorrect password.',
  'email-already-in-use': 'This email is already registered.',
  'operation-not-allowed': 'Email/password accounts are not enabled.',
  'weak-password': 'Password is too weak.',
  'network-request-failed': 'Network error. Please check your connection.',
  'too-many-requests': 'Too many requests. Try again later.',
  'invalid-credential': 'Invalid authentication credentials.',
  'user-token-expired': 'Session expired. Please sign in again.',
  'invalid-verification-code': 'Invalid verification code.',
  'invalid-verification-id': 'Invalid verification ID.',
};
const Map<String, String> firestoreErrors = {
  'cancelled': 'The operation was cancelled.',
  'unknown': 'Unknown Firestore error occurred.',
  'invalid-argument': 'Invalid argument provided.',
  'deadline-exceeded': 'Operation took too long to complete.',
  'not-found': 'Requested document not found.',
  'already-exists': 'Document already exists.',
  'permission-denied': 'You do not have permission to perform this action.',
  'resource-exhausted': 'Resource limit reached.',
  'failed-precondition': 'Precondition for the operation failed.',
  'aborted': 'Operation was aborted.',
  'out-of-range': 'Value out of range.',
  'unimplemented': 'Operation not implemented.',
  'internal': 'Internal Firestore error.',
  'unavailable': 'Firestore is currently unavailable. Try again later.',
  'data-loss': 'Data loss occurred.',
  'unauthenticated': 'Authentication required.',
};
const Map<String, String> storageErrors = {
  'object-not-found': 'The requested file does not exist.',
  'bucket-not-found': 'Storage bucket not found.',
  'project-not-found': 'Project not found.',
  'quota-exceeded': 'Storage quota exceeded.',
  'unauthenticated': 'You must be signed in to perform this action.',
  'unauthorized': 'You are not authorized for this operation.',
  'retry-limit-exceeded': 'Retry limit exceeded.',
  'invalid-checksum': 'File corrupted during upload.',
  'canceled': 'File upload was cancelled.',
};

/// Maps GoogleSignIn error codes to human-friendly messages.
const Map<String, String> googleSignInErrors = {
  'canceled': 'Google sign-in was cancelled by the user.',
  'failed': 'Google sign-in failed. Please try again.',
  'network_error': 'Network error. Please check your connection.',
};
