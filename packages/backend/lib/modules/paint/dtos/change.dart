import 'package:backend/core/database/tables/paints.drift.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luthor/luthor.dart';

part 'change.freezed.dart';

part 'change.g.dart';

@luthor
@freezed
class Color with _$Color {
  const factory Color({
    @HasMin(0) @HasMax(255) required int r,
    @HasMin(0) @HasMax(255) required int g,
    @HasMin(0) @HasMax(255) required int b,
  }) = _Color;

  factory Color.fromJson(Map<String, dynamic> json) => _$ColorFromJson(json);
}

@luthor
@freezed
class ChangeRequest with _$ChangeRequest {
  const factory ChangeRequest({
    @HasMin(0) required int x,
    @HasMin(0) required int y,
    required Color color,
  }) = _ChangeRequest;

  factory ChangeRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangeRequestFromJson(json);
}

enum DataType { all, update }

@freezed
class AllResponse with _$AllResponse {
  const factory AllResponse({
    @Default(DataType.all) DataType type,
    required List<Paint> data,
  }) = _AllResponse;

  factory AllResponse.fromJson(Map<String, dynamic> json) =>
      _$AllResponseFromJson(json);
}

@freezed
class UpdateResponse with _$UpdateResponse {
  const factory UpdateResponse({
    @Default(DataType.update) DataType type,
    required Paint data,
  }) = _UpdateResponse;

  factory UpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateResponseFromJson(json);
}
