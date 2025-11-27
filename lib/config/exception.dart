import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:orderit/common/services/error_log_service.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Exception handling code
void exception(e, String url, String function,
    {bool showToast = true, BuildContext? context}) async {
  print(
      '*************Exception occurred at url: $url and function named: $function **********************');
  var contactSupport = 'Please contact support@ambibuzz.com';
  print(e);

  // Handle socket exception for no internet
  if (e is DioException) {
    if (e.error is SocketException) {
      await locator
          .get<NavigationService>()
          .navigateTo(noInternetConnectionViewRoute);
      return;
    }
  }

  if (e.response != null) {
    await locator
        .get<ErrorLogService>()
        .saveErrorLog(e.response.data.toString(), e.response!.statusCode, e);

    printWrapped(e.response.data.toString());

    // Handle Frappe-specific exceptions
    if (e.response!.data is Map) {
      final responseData = e.response!.data;
      
      // Check if exc_type exists (Frappe error structure)
      if (responseData.containsKey('exc_type')) {
        _handleFrappeException(responseData, showToast, contactSupport);
        return;
      }
      
      // Check if exception field exists
      if (responseData.containsKey('exception')) {
        _handleExceptionField(responseData, showToast, contactSupport);
        return;
      }
    }

    // Handle HTTP status codes
    _handleHttpStatusCode(e, showToast, contactSupport);
  } else {
    if (showToast) {
      styledToast('Something went wrong! $contactSupport');
    }
  }
}

void _handleFrappeException(Map<String, dynamic> responseData, bool showToast, String contactSupport) {
  final excType = responseData['exc_type'];
  
  // List of Frappe exception types that should show user-friendly messages
  final knownExceptionTypes = [
    'PermissionError',
    'ValidationError',
    'TimestampMismatchError',
    'MissingDocumentError',
    'DoesNotExistError',
    'AlreadyExistsError',
    'UnpermittedError',
    'InvalidStatusError',
    'DataError',
    'TransitionError',
    'RateLimitExceededError',
    'NamingError',
    'ReadOnlyError',
    'WorkflowPermissionError',
    'DuplicateEntryError',
    'OverlappingAttendanceRequestError',
    'OverlapError',
    'LinkValidationError',
    'MandatoryError',
    'UniqueValidationError',
    'CharacterLengthExceededError',
    'UpdateAfterSubmitError',
    'CancelledDocumentError',
    'LinkExistsError',
    'InvalidDocumentTypeError',
  ];

  if (knownExceptionTypes.contains(excType)) {
    // Try to get message from _server_messages first
    String? message = _extractServerMessage(responseData);
    
    // If no server message, try exception field
    if (message == null && responseData.containsKey('exception')) {
      message = _parseExceptionMessage(responseData['exception']);
    }
    
    // If still no message, use exc_type
    if (message == null) {
      message = excType.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim();
    }

    if (showToast) {
      styledToast(parseHtmlString(message??''));
    }
  } else {
    // Unknown exception type
    if (showToast) {
      styledToast('An error occurred. $contactSupport');
    }
  }
}

void _handleExceptionField(Map<String, dynamic> responseData, bool showToast, String contactSupport) {
  final exception = responseData['exception'];
  
  if (exception is String) {
    // Check for specific Frappe exception patterns
    if (exception.contains('frappe.exceptions.')) {
      final message = _parseExceptionMessage(exception);
      if (showToast) {
        styledToast(parseHtmlString(message));
      }
    } else if (exception.startsWith('ModuleNotFoundError:')) {
      if (showToast) {
        styledToast(parseHtmlString(exception));
      }
    } else {
      if (showToast) {
        styledToast('An error occurred. $contactSupport');
      }
    }
  }
}

String? _extractServerMessage(Map<String, dynamic> responseData) {
  try {
    if (responseData.containsKey('_server_messages')) {
      final serverMessages = responseData['_server_messages'];
      
      if (serverMessages is String) {
        // Parse the JSON string
        final messages = jsonDecode(serverMessages);
        
        if (messages is List && messages.isNotEmpty) {
          // Get the first message
          final firstMessage = jsonDecode(messages[0]);
          
          if (firstMessage is Map && firstMessage.containsKey('message')) {
            return firstMessage['message'];
          }
        } else if (messages is Map && messages.containsKey('message')) {
          return messages['message'];
        }
      } else if (serverMessages is List && serverMessages.isNotEmpty) {
        final firstMessage = jsonDecode(serverMessages[0]);
        
        if (firstMessage is Map && firstMessage.containsKey('message')) {
          return firstMessage['message'];
        }
      }
    }
  } catch (e) {
    print('Error extracting server message: $e');
  }
  
  return null;
}

String _parseExceptionMessage(String exception) {
  try {
    // Handle format: "frappe.exceptions.PermissionError: Message here"
    if (exception.contains('frappe.exceptions.')) {
      final parts = exception.split(': ');
      if (parts.length > 1) {
        return parts.sublist(1).join(': ').trim();
      }
    }
    
    // Handle other formats
    final parts = exception.split(': ');
    if (parts.length > 1) {
      return parts.sublist(1).join(': ').trim();
    }
    
    return exception;
  } catch (e) {
    return exception;
  }
}

void _handleHttpStatusCode(DioException e, bool showToast, String contactSupport) {
  if (!showToast) return;

  switch (e.response!.statusCode) {
    case 400:
      styledToast(
          'Either no Permission or Session Expired. Please re-login or contact erp.support@ambibuzz.com');
      break;
    case 401:
      styledToast(
          'Either no Permission or Session Expired. Please re-login or contact erp.support@ambibuzz.com');
      break;
    case 403:
      styledToast(
          'Either no Permission or Session Expired. Please re-login or contact erp.support@ambibuzz.com');
      break;
    case 404:
      styledToast('Not found $contactSupport');
      break;
    case 408:
      styledToast('Request Timed Out $contactSupport');
      break;
    case 409:
      styledToast('Conflict $contactSupport');
      break;
    case 500:
      styledToast('Internal Server Error $contactSupport');
      break;
    case 503:
      styledToast('Service Unavailable $contactSupport');
      break;
    default:
      _handleDioExceptionType(e, showToast, contactSupport);
      break;
  }
}

void _handleDioExceptionType(DioException e, bool showToast, String contactSupport) {
  if (!showToast) return;

  switch (e.type) {
    case DioExceptionType.sendTimeout:
      styledToast('Send Timeout $contactSupport');
      break;
    case DioExceptionType.cancel:
      styledToast("Request Cancelled $contactSupport");
      break;
    case DioExceptionType.connectionTimeout:
      styledToast("Connection Timeout $contactSupport");
      break;
    case DioExceptionType.unknown:
      styledToast('Unknown Error Occurred $contactSupport');
      break;
    case DioExceptionType.receiveTimeout:
      styledToast('Receive Timeout $contactSupport');
      break;
    case DioExceptionType.badCertificate:
      styledToast('Bad Certificate $contactSupport');
      break;
    case DioExceptionType.badResponse:
      styledToast('Bad Response $contactSupport');
      break;
    case DioExceptionType.connectionError:
      styledToast('Connection Error');
      break;
    default:
      styledToast('Something went wrong! $contactSupport');
      break;
  }
}

Future styledToast(String message) async {
  await Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.white,
    textColor: Colors.red,
    fontSize: 16,
    toastLength: Toast.LENGTH_LONG,
  );
}

Widget networkImageErrorBuilder(
    BuildContext context, Object error, StackTrace? stackTrace) {
  return const Center(
    child: SizedBox(
      width: 60,
      height: 60,
      child: Icon(Icons.signal_wifi_off_outlined),
    ),
  );
}

void printWrapped(String text) =>
    RegExp('.{1,800}').allMatches(text).map((m) => m.group(0)).forEach(print);