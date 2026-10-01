// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_task_draft_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParsedTaskDraftDto {

 String get title; String get description; String get priority; String? get assigneeId; String? get assigneeName; DateTime? get dueDate; List<String> get warnings;
/// Create a copy of ParsedTaskDraftDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedTaskDraftDtoCopyWith<ParsedTaskDraftDto> get copyWith => _$ParsedTaskDraftDtoCopyWithImpl<ParsedTaskDraftDto>(this as ParsedTaskDraftDto, _$identity);

  /// Serializes this ParsedTaskDraftDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedTaskDraftDto&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.assigneeId, assigneeId) || other.assigneeId == assigneeId)&&(identical(other.assigneeName, assigneeName) || other.assigneeName == assigneeName)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&const DeepCollectionEquality().equals(other.warnings, warnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,priority,assigneeId,assigneeName,dueDate,const DeepCollectionEquality().hash(warnings));

@override
String toString() {
  return 'ParsedTaskDraftDto(title: $title, description: $description, priority: $priority, assigneeId: $assigneeId, assigneeName: $assigneeName, dueDate: $dueDate, warnings: $warnings)';
}


}

/// @nodoc
abstract mixin class $ParsedTaskDraftDtoCopyWith<$Res>  {
  factory $ParsedTaskDraftDtoCopyWith(ParsedTaskDraftDto value, $Res Function(ParsedTaskDraftDto) _then) = _$ParsedTaskDraftDtoCopyWithImpl;
@useResult
$Res call({
 String title, String description, String priority, String? assigneeId, String? assigneeName, DateTime? dueDate, List<String> warnings
});




}
/// @nodoc
class _$ParsedTaskDraftDtoCopyWithImpl<$Res>
    implements $ParsedTaskDraftDtoCopyWith<$Res> {
  _$ParsedTaskDraftDtoCopyWithImpl(this._self, this._then);

  final ParsedTaskDraftDto _self;
  final $Res Function(ParsedTaskDraftDto) _then;

/// Create a copy of ParsedTaskDraftDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = null,Object? priority = null,Object? assigneeId = freezed,Object? assigneeName = freezed,Object? dueDate = freezed,Object? warnings = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,assigneeId: freezed == assigneeId ? _self.assigneeId : assigneeId // ignore: cast_nullable_to_non_nullable
as String?,assigneeName: freezed == assigneeName ? _self.assigneeName : assigneeName // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedTaskDraftDto].
extension ParsedTaskDraftDtoPatterns on ParsedTaskDraftDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedTaskDraftDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedTaskDraftDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedTaskDraftDto value)  $default,){
final _that = this;
switch (_that) {
case _ParsedTaskDraftDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedTaskDraftDto value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedTaskDraftDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String description,  String priority,  String? assigneeId,  String? assigneeName,  DateTime? dueDate,  List<String> warnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedTaskDraftDto() when $default != null:
return $default(_that.title,_that.description,_that.priority,_that.assigneeId,_that.assigneeName,_that.dueDate,_that.warnings);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String description,  String priority,  String? assigneeId,  String? assigneeName,  DateTime? dueDate,  List<String> warnings)  $default,) {final _that = this;
switch (_that) {
case _ParsedTaskDraftDto():
return $default(_that.title,_that.description,_that.priority,_that.assigneeId,_that.assigneeName,_that.dueDate,_that.warnings);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String description,  String priority,  String? assigneeId,  String? assigneeName,  DateTime? dueDate,  List<String> warnings)?  $default,) {final _that = this;
switch (_that) {
case _ParsedTaskDraftDto() when $default != null:
return $default(_that.title,_that.description,_that.priority,_that.assigneeId,_that.assigneeName,_that.dueDate,_that.warnings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ParsedTaskDraftDto implements ParsedTaskDraftDto {
  const _ParsedTaskDraftDto({required this.title, this.description = '', this.priority = 'Medium', this.assigneeId, this.assigneeName, this.dueDate, final  List<String> warnings = const []}): _warnings = warnings;
  factory _ParsedTaskDraftDto.fromJson(Map<String, dynamic> json) => _$ParsedTaskDraftDtoFromJson(json);

@override final  String title;
@override@JsonKey() final  String description;
@override@JsonKey() final  String priority;
@override final  String? assigneeId;
@override final  String? assigneeName;
@override final  DateTime? dueDate;
 final  List<String> _warnings;
@override@JsonKey() List<String> get warnings {
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warnings);
}


/// Create a copy of ParsedTaskDraftDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedTaskDraftDtoCopyWith<_ParsedTaskDraftDto> get copyWith => __$ParsedTaskDraftDtoCopyWithImpl<_ParsedTaskDraftDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParsedTaskDraftDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedTaskDraftDto&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.assigneeId, assigneeId) || other.assigneeId == assigneeId)&&(identical(other.assigneeName, assigneeName) || other.assigneeName == assigneeName)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&const DeepCollectionEquality().equals(other._warnings, _warnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,priority,assigneeId,assigneeName,dueDate,const DeepCollectionEquality().hash(_warnings));

@override
String toString() {
  return 'ParsedTaskDraftDto(title: $title, description: $description, priority: $priority, assigneeId: $assigneeId, assigneeName: $assigneeName, dueDate: $dueDate, warnings: $warnings)';
}


}

/// @nodoc
abstract mixin class _$ParsedTaskDraftDtoCopyWith<$Res> implements $ParsedTaskDraftDtoCopyWith<$Res> {
  factory _$ParsedTaskDraftDtoCopyWith(_ParsedTaskDraftDto value, $Res Function(_ParsedTaskDraftDto) _then) = __$ParsedTaskDraftDtoCopyWithImpl;
@override @useResult
$Res call({
 String title, String description, String priority, String? assigneeId, String? assigneeName, DateTime? dueDate, List<String> warnings
});




}
/// @nodoc
class __$ParsedTaskDraftDtoCopyWithImpl<$Res>
    implements _$ParsedTaskDraftDtoCopyWith<$Res> {
  __$ParsedTaskDraftDtoCopyWithImpl(this._self, this._then);

  final _ParsedTaskDraftDto _self;
  final $Res Function(_ParsedTaskDraftDto) _then;

/// Create a copy of ParsedTaskDraftDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? priority = null,Object? assigneeId = freezed,Object? assigneeName = freezed,Object? dueDate = freezed,Object? warnings = null,}) {
  return _then(_ParsedTaskDraftDto(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String,assigneeId: freezed == assigneeId ? _self.assigneeId : assigneeId // ignore: cast_nullable_to_non_nullable
as String?,assigneeName: freezed == assigneeName ? _self.assigneeName : assigneeName // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,warnings: null == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
