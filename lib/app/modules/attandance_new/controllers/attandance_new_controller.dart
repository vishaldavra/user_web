import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;
import 'package:intl/intl.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

import '../../../../Constants/api_constants.dart';
import '../../../../Constants/string_constants.dart';
import '../../../../Models/DateWiseDataModel.dart';
import '../../../../Utilities/customeDialogs.dart';
import '../../../../main.dart';
import '../../../data/network_client.dart';

class AttandanceNewController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final count = 0.obs;
  RxBool webClockIn = false.obs;
  RxBool hasData = false.obs;
  Rx<DateTime> now = DateTime.now().obs;

  DateTime selected = DateTime.now();
  late List<AttendanceDetailsModel> attandanceList;
  List<String> columnData = ["Date", "Total Time"];
  List<String> columnDataForDay = ["Status", "Time"];
  RxString selectedDate = "".obs;
  ScrollControllers? scrollController = ScrollControllers();
  ScrollControllers? scrollController1 = ScrollControllers();
  RxList<AttendanceDetail> getDataOfDay = RxList<AttendanceDetail>([]);
  @override
  void onInit() {
    getLastDateOfMonth(now.value);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      callApiForGetTodayEntry(context: Get.context!, isFromButton: true);
    });
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  getLastDateOfMonth(DateTime now) {
    DateTime lastDayOfMonth = new DateTime(now.year, now.month + 1, 0);
    DateTime fDayOfMonth = new DateTime(now.year, now.month, 1);
    // print("${lastDayOfMonth.month}/${lastDayOfMonth.day}");
    // print("${fDayOfMonth.month}/${fDayOfMonth.day}");
    return lastDayOfMonth;
  }

  getTotalTime(int sec) {
    Duration diff = Duration(seconds: sec);
    // totalSecond = int.parse(checkInOutModel.data!.total.toString());
    String h = strDigits(diff.inHours.remainder(24));
    String mm = strDigits(diff.inMinutes.remainder(60));
    String ss = strDigits(diff.inSeconds.remainder(60));
    return '$h : $mm : $ss';
  }

  String strDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  callApiForGetTodayEntry(
      {required BuildContext context, bool isFromButton = false}) {
    FocusScope.of(context).unfocus();
    if (!isFromButton) {
      app.resolve<CustomDialogs>().showCircularDialog(context);
    }
    Map<String, dynamic> dict = {};
    hasData.value = false;
    dict["email"] = box.read(StringConstants.userEmailAddress);
    // dict["email"] = "ajay01@gmail.com";

    // dict["date"] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // dict["date1"] = DateFormat('yyyy-MM-dd')
    //     .format(DateTime((now.value.year - 1), now.value.month, 1));
    // dict["date1"] = "2021-01-01";
    // // if (now.value.month != DateTime.now().month) {
    // dict["date2"] = DateFormat('yyyy-MM-dd')
    //     .format(getLastDateOfMonth(now.value.add(Duration(days: 365))));
    // } else {
    //   dict["date2"] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // }
    // dict["date2"] =
    //     DateFormat('yyyy-MM-dd').format(getLastDateOfMonth(now.value));
    // dict["date"] = DateFormat('yyyy-MM-dd').format(DateTime.now());

    FormData data = FormData.fromMap(dict);
   // print(dict);
    //print(data);
    hasData.value = false;

    return NetworkClient.getInstance.callApi(
      context,
      baseURL,
      ApiConstant.dateWiseData,
      MethodType.Post,
      headers: NetworkClient.getInstance.getAuthHeaders(),
      params: data,
      successCallback: (response, message) {
        if (!isFromButton) {
          app.resolve<CustomDialogs>().hideCircularDialog(context);
        }
        hasData.value = true;
        List data = jsonDecode(response) as List;
        //
        attandanceList =
            data.map((e) => AttendanceDetailsModel.fromJson(e)).toList();

        getDataOfDay.value.clear();
        selectedDate.value = attandanceList.last.date.toString();
        if (attandanceList.last.data!.isNotEmpty) {
          getDataOfDay.addAll(attandanceList.last.data!);
        }
        // attandanceList.first.data!.forEach((element) {
        //   getDataOfDay.value.add(element);
        // });

      //  print(attandanceList);

       // print(response);
      },
      failureCallback: (status, message) {
        hasData.value = true;

        if (!isFromButton) {
          app.resolve<CustomDialogs>().hideCircularDialog(context);
        }
        app.resolve<CustomDialogs>().getDialog(title: "Failed", desc: message);

      //  print(" error");

        //print(status);
      },
    );
  }

  @override
  void onClose() {}
  void increment() => count.value++;
}
