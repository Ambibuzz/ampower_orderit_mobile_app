import 'dart:convert';

import 'package:orderit/base_view.dart';
import 'package:orderit/common/models/error_log.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/viewmodels/error_log_list_viewmodel.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/common/widgets/empty_widget.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ErrorLogListView extends StatelessWidget {
  const ErrorLogListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ErrorLogListViewModel>(
      onModelReady: (model) async {
        await model.getErrorLogList();
        // delete hive box data
        // var box = locator.get<StorageService>().getHiveBox('offline');
        // var res = await box.delete('errorlog');
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: Common.commonAppBar('Error Logs', [], context),
          body: model.errorLogList.isNotEmpty
              ? errorLogList(model, context)
              : Center(
                  child: EmptyWidget(
                    height: displayHeight(context),
                  ),
                ),
        );
      },
    );
  }

  Widget errorLogList(ErrorLogListViewModel model, BuildContext context) {
    return Skeletonizer(
      enabled: model.isErrorLogLoading,
      child: ListView.builder(
        itemCount: model.errorLogList.length,
        padding: EdgeInsets.symmetric(
          vertical: Sizes.smallPaddingWidget(context),
          horizontal: Sizes.paddingWidget(context),
        ),
        itemBuilder: (context, index) {
          var errorLog = model.errorLogList[index];
          return errorLogTile(errorLog, context);
        },
      ),
    );
  }

  Widget errorLogTile(ErrorLog errorLog, BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: Sizes.smallPaddingWidget(context)),
      child: ClipRRect(
        borderRadius: Corners.xlBorder,
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(borderRadius: Corners.xlBorder),
          tilePadding: EdgeInsets.symmetric(
            horizontal: Sizes.paddingWidget(context),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time : ${errorLog.time}',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(),
                    ),
                    Text(
                      'Error : ${parseHtmlString(errorLog.exception ?? '')}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await shareText('Error ', errorLog.error ?? '');
                },
                child: Icon(
                  Icons.share,
                  size: Sizes.iconSizeWidget(context),
                ),
              ),
            ],
          ),
          // initiallyExpanded: true,
          // onExpansionChanged: model.onExpansionChanged,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Sizes.paddingWidget(context),
                vertical: Sizes.paddingWidget(context),
              ),
              child: Column(
                children: [
                  Text('${errorLog.error}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
