import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//Exception handling code
void exception(e, String url, String function, {bool showToast = true}) async {
  print(
      '*************Exception occured at url : $url and function named : $function   **********************');
  var contactSupport = 'Please contact support@ambibuzz.com';

  print(e.response.data);
  printWrapped(e.response.data.toString());

  // print(url);
  if (e.response != null) {
    if (e is SocketException) {
      styledToast(
          'No Internet Connection. Please Connect to Wifi or Mobile Network.');
    } else if (e.response!.data['exc_type'] == 'PermissionError' ||
        e.response!.data['exc_type'] == 'ValidationError' ||
        e.response!.data['exc_type'] == 'TimestampMismatchError' ||
        e.response!.data['exc_type'] == 'MissingDocumentError' ||
        e.response!.data['exc_type'] == 'DoesNotExistError' ||
        e.response!.data['exc_type'] == 'AlreadyExistsError' ||
        e.response!.data['exc_type'] == 'UnpermittedError' ||
        e.response!.data['exc_type'] == 'InvalidStatusError' ||
        e.response!.data['exc_type'] == 'DataError' ||
        e.response!.data['exc_type'] == 'TransitionError' ||
        e.response!.data['exc_type'] == 'RateLimitExceededError' ||
        e.response!.data['exc_type'] == 'NamingError' ||
        e.response!.data['exc_type'] == 'ReadOnlyError' ||
        e.response!.data['exc_type'] == 'WorkflowPermissionError' ||
        e.response!.data['exc_type'] == 'DuplicateEntryError' ||
        e.response!.data['exc_type'] == 'OverlappingAttendanceRequestError' ||
        e.response!.data['exc_type'] == 'OverlapError' ||
        e.response!.data['exception'].split(" ")[0] ==
            'frappe.exceptions.PermissionError:' ||
        e.response!.data['exception'].split(" ")[0] ==
            'frappe.exceptions.PermissionError') {
      if (e.response!.data['exception'] != null) {
        print('****');
        print(e.response!.data);
        styledToast(e.response!.data['_server_messages']);
      }
    } else if (e.response!.data['exception'].split(" ")[0] ==
        'ModuleNotFoundError:') {
      styledToast(e.response!.data['exception']);
    } else {
      switch (e.response!.statusCode) {
        case 400:
          if (showToast) {
            styledToast(
                'Either no Permission or Session Expired. Please re-login or contact erp.support@ambibuzz.com');
          }

          break;
        case 401:
          if (showToast) {
            styledToast(
                'Either no Permission or Session Expired. Please re-login or contact erp.support@ambibuzz.com');
          }

          break;
        case 403:
          if (showToast) {
            styledToast(
                'Either no Permission or Session Expired. Please re-login or contact erp.support@ambibuzz.com');
          }

          break;
        case 404:
          if (showToast) {
            styledToast('Not found $contactSupport');
          }

          break;
        case 408:
          if (showToast) {
            styledToast('Request Timed Out $contactSupport');
          }

          break;
        case 409:
          if (showToast) {
            styledToast('Conflict $contactSupport');
          }

          break;
        case 500:
          if (showToast) {
            styledToast('Internal Server Error $contactSupport');
          }

          break;
        case 503:
          if (showToast) {
            styledToast('Service Unavailable $contactSupport');
          }

          break;
        default:
          switch (e.type) {
            case DioExceptionType.sendTimeout:
              if (showToast) {
                styledToast('Send Timeout $contactSupport');
              }
              break;
            case DioExceptionType.cancel:
              if (showToast) {
                styledToast("Request Cancelled $contactSupport");
              }
              break;
            case DioExceptionType.connectionTimeout:
              if (showToast) {
                styledToast("Connection Timeout $contactSupport");
              }
              break;
            case DioExceptionType.unknown:
              if (showToast) {
                styledToast('Unknown Error Occurred $contactSupport');
              }

              break;
            case DioExceptionType.receiveTimeout:
              if (showToast) {
                styledToast('Recieve Timeout $contactSupport');
              }
              break;
            case DioExceptionType.badCertificate:
              if (showToast) {
                styledToast('Bad Certificate $contactSupport');
              }
              break;
            case DioExceptionType.badResponse:
              if (showToast) {
                styledToast('Bad Response $contactSupport');
              }
              break;
            case DioExceptionType.connectionError:
              if (showToast) {
                styledToast('Connection Error');
              }
              break;
            default:
              if (showToast) {
                styledToast('Something went wrong! $contactSupport');
              }
              break;
          }
          break;
      }
    }
  } else {
    styledToast('Something went wrong! $contactSupport');
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
