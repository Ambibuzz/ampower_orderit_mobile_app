import 'package:orderit/locators/locator.dart';
import 'package:orderit/common/models/alert_request.dart';
import 'package:orderit/common/models/alert_response.dart';
import 'package:orderit/common/services/dialog_service.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class DialogManager extends StatefulWidget {
  final Widget? child;
  const DialogManager({super.key, required this.child});

  @override
  DialogManagerState createState() => DialogManagerState();
}

class DialogManagerState extends State<DialogManager> {
  DialogService dialogService = locator.get<DialogService>();

  @override
  void initState() {
    super.initState();
    dialogService.registerDialogListener(_showDialog);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }

  void _showDialog(AlertRequest request) {
    Alert(
      context: context,
      title: request.title,
      desc: request.description,
      closeFunction: () =>
          dialogService.dialogComplete(AlertResponse(confirmed: false)),
      closeIcon: GestureDetector(
          onTap: () {
            dialogService.dialogComplete(AlertResponse(confirmed: false));
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.close,
            size: Sizes.iconSizeWidget(context),
          )),
      style: AlertStyle(
        titleStyle: Theme.of(context).textTheme.titleMedium!,
        descStyle: Theme.of(context).dialogTheme.contentTextStyle!.copyWith(
              fontSize: displayWidth(context) < 600 ? 12 : 12 * 1.5,
            ),
        titleTextAlign: TextAlign.left,
        descTextAlign: TextAlign.left,
      ),
      buttons: [
        DialogButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            dialogService.dialogComplete(AlertResponse(confirmed: true));
            Navigator.of(context).pop();
          },
          child: Text(
            request.buttonTitle ?? 'OK',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
        ),
      ],
    ).show();
  }
}
