import 'package:orderit/config/theme_model.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';

class ConnectivityStatusStrip {
  static Widget strip(
      ConnectivityStatus connectivityStatus, BuildContext context) {
    var status = '';
    if (connectivityStatus == ConnectivityStatus.cellular ||
        connectivityStatus == ConnectivityStatus.wifi) {
      status = 'Online';
    } else {
      status = 'Offline';
    }
    return status == 'Offline'
        ? Container(
            height: 22,
            width: displayWidth(context),
            decoration: BoxDecoration(
                color: status == 'Online' ? Colors.green : Colors.red),
            child: Center(
              child: Text(
                status,
                style: TextStyle(
                  color: ThemeModel().isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          )
        : Container();
  }
}
