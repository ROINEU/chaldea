library server_api;

import 'dart:convert';
import 'dart:typed_data';

import 'package:chaldea/components/config.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:json_annotation/json_annotation.dart';

import '../widgets/custom_dialogs.dart';
import 'extensions.dart';
import 'localized/localized_base.dart';
import 'logger.dart';

part 'server_api.g.dart';

class ChaldeaResponse {
  bool success;
  dynamic msg;
  dynamic body;

  ChaldeaResponse({this.success = false, this.msg, this.body});

  static ChaldeaResponse fromResponse(Response response) {
    // print('type:${data.runtimeType}, data=$data');
    final data = response.data;
    try {
      Map map;
      if (data is String) {
        map = jsonDecode(data);
      } else {
        map = Map.from(data);
      }
      return ChaldeaResponse(
          success: map['success'] == true, msg: map['msg'], body: map['body']);
    } catch (e, s) {
      logger.e('parse ChaldeaResponse error', e, s);
      return ChaldeaResponse(msg: '$data');
    }
  }

  Future showMsg(BuildContext? context,
      {String? title, bool showBody = false}) {
    EasyLoading.dismiss();
    if (context == null) return Future.value();
    title ??= success
        ? S.current.success
        : LocalizedText.of(chs: '错误/提示', jpn: 'エラー/警告', eng: 'Error/Warning');
    String content = msg.toString();
    if (showBody) content += '\n$body';
    return SimpleCancelOkDialog(
      title: Text(title),
      content: Text(content),
    ).showDialog(context);
  }

  @override
  String toString() {
    return '$runtimeType(\n  success: $success,\n  msg: $msg\n  body: $body)';
  }
}

@JsonSerializable()
class SvtRecResults {
  String? uuid;
  List<OneSvtRecResult> results;

  SvtRecResults({this.uuid, List<OneSvtRecResult>? results})
      : results = results ?? [];

  factory SvtRecResults.fromJson(Map<String, dynamic> data) =>
      _$SvtRecResultsFromJson(data);

  Map<String, dynamic> toJson() => _$SvtRecResultsToJson(this);
}

@JsonSerializable()
class OneSvtRecResult {
  int? svtNo;
  int? maxLv;
  int? skill1;
  int? skill2;
  int? skill3;
  String? image;
  @JsonKey(ignore: true)
  bool isAppendSkill = false;

  OneSvtRecResult({
    this.svtNo,
    this.maxLv,
    this.skill1,
    this.skill2,
    this.skill3,
    this.image,
  });

  @JsonKey(ignore: true)
  bool checked = true;

  List<int?> get skills => [skill1, skill2, skill3];
  Uint8List? _imgBytes;

  Uint8List? get imgBytes {
    if (image == null) return null;
    if (_imgBytes != null) return _imgBytes;
    try {
      _imgBytes = base64Decode(image!);
    } catch (e, s) {
      logger.e('decode image base64 string failed', e, s);
    }
    return _imgBytes;
  }

  bool get isValid {
    return svtNo != null &&
        svtNo! > 0 &&
        !db.gameData.unavailableSvts.contains(svtNo) &&
        skills
            .every((e) => e != null && e >= (isAppendSkill ? 0 : 1) && e <= 10);
  }

  factory OneSvtRecResult.fromJson(Map<String, dynamic> data) =>
      _$OneSvtRecResultFromJson(data);

  Map<String, dynamic> toJson() => _$OneSvtRecResultToJson(this);
}
