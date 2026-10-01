// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_task_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VoiceTaskState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceTaskState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VoiceTaskState()';
}


}

/// @nodoc
class $VoiceTaskStateCopyWith<$Res>  {
$VoiceTaskStateCopyWith(VoiceTaskState _, $Res Function(VoiceTaskState) __);
}


/// Adds pattern-matching-related methods to [VoiceTaskState].
extension VoiceTaskStatePatterns on VoiceTaskState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VoiceTaskIdle value)?  idle,TResult Function( VoiceTaskRequestingPermission value)?  requestingPermission,TResult Function( VoiceTaskPermissionDenied value)?  permissionDenied,TResult Function( VoiceTaskListening value)?  listening,TResult Function( VoiceTaskParsing value)?  parsing,TResult Function( VoiceTaskReviewDraft value)?  reviewDraft,TResult Function( VoiceTaskCreating value)?  creating,TResult Function( VoiceTaskSuccess value)?  success,TResult Function( VoiceTaskError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VoiceTaskIdle() when idle != null:
return idle(_that);case VoiceTaskRequestingPermission() when requestingPermission != null:
return requestingPermission(_that);case VoiceTaskPermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case VoiceTaskListening() when listening != null:
return listening(_that);case VoiceTaskParsing() when parsing != null:
return parsing(_that);case VoiceTaskReviewDraft() when reviewDraft != null:
return reviewDraft(_that);case VoiceTaskCreating() when creating != null:
return creating(_that);case VoiceTaskSuccess() when success != null:
return success(_that);case VoiceTaskError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VoiceTaskIdle value)  idle,required TResult Function( VoiceTaskRequestingPermission value)  requestingPermission,required TResult Function( VoiceTaskPermissionDenied value)  permissionDenied,required TResult Function( VoiceTaskListening value)  listening,required TResult Function( VoiceTaskParsing value)  parsing,required TResult Function( VoiceTaskReviewDraft value)  reviewDraft,required TResult Function( VoiceTaskCreating value)  creating,required TResult Function( VoiceTaskSuccess value)  success,required TResult Function( VoiceTaskError value)  error,}){
final _that = this;
switch (_that) {
case VoiceTaskIdle():
return idle(_that);case VoiceTaskRequestingPermission():
return requestingPermission(_that);case VoiceTaskPermissionDenied():
return permissionDenied(_that);case VoiceTaskListening():
return listening(_that);case VoiceTaskParsing():
return parsing(_that);case VoiceTaskReviewDraft():
return reviewDraft(_that);case VoiceTaskCreating():
return creating(_that);case VoiceTaskSuccess():
return success(_that);case VoiceTaskError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VoiceTaskIdle value)?  idle,TResult? Function( VoiceTaskRequestingPermission value)?  requestingPermission,TResult? Function( VoiceTaskPermissionDenied value)?  permissionDenied,TResult? Function( VoiceTaskListening value)?  listening,TResult? Function( VoiceTaskParsing value)?  parsing,TResult? Function( VoiceTaskReviewDraft value)?  reviewDraft,TResult? Function( VoiceTaskCreating value)?  creating,TResult? Function( VoiceTaskSuccess value)?  success,TResult? Function( VoiceTaskError value)?  error,}){
final _that = this;
switch (_that) {
case VoiceTaskIdle() when idle != null:
return idle(_that);case VoiceTaskRequestingPermission() when requestingPermission != null:
return requestingPermission(_that);case VoiceTaskPermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case VoiceTaskListening() when listening != null:
return listening(_that);case VoiceTaskParsing() when parsing != null:
return parsing(_that);case VoiceTaskReviewDraft() when reviewDraft != null:
return reviewDraft(_that);case VoiceTaskCreating() when creating != null:
return creating(_that);case VoiceTaskSuccess() when success != null:
return success(_that);case VoiceTaskError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  requestingPermission,TResult Function( bool permanentlyDenied)?  permissionDenied,TResult Function( String recognizedText,  double soundLevel)?  listening,TResult Function( String fullText)?  parsing,TResult Function( ParsedTaskDraftDto draft,  String rawSpokenText)?  reviewDraft,TResult Function()?  creating,TResult Function( TaskDto createdTask)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VoiceTaskIdle() when idle != null:
return idle();case VoiceTaskRequestingPermission() when requestingPermission != null:
return requestingPermission();case VoiceTaskPermissionDenied() when permissionDenied != null:
return permissionDenied(_that.permanentlyDenied);case VoiceTaskListening() when listening != null:
return listening(_that.recognizedText,_that.soundLevel);case VoiceTaskParsing() when parsing != null:
return parsing(_that.fullText);case VoiceTaskReviewDraft() when reviewDraft != null:
return reviewDraft(_that.draft,_that.rawSpokenText);case VoiceTaskCreating() when creating != null:
return creating();case VoiceTaskSuccess() when success != null:
return success(_that.createdTask);case VoiceTaskError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  requestingPermission,required TResult Function( bool permanentlyDenied)  permissionDenied,required TResult Function( String recognizedText,  double soundLevel)  listening,required TResult Function( String fullText)  parsing,required TResult Function( ParsedTaskDraftDto draft,  String rawSpokenText)  reviewDraft,required TResult Function()  creating,required TResult Function( TaskDto createdTask)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case VoiceTaskIdle():
return idle();case VoiceTaskRequestingPermission():
return requestingPermission();case VoiceTaskPermissionDenied():
return permissionDenied(_that.permanentlyDenied);case VoiceTaskListening():
return listening(_that.recognizedText,_that.soundLevel);case VoiceTaskParsing():
return parsing(_that.fullText);case VoiceTaskReviewDraft():
return reviewDraft(_that.draft,_that.rawSpokenText);case VoiceTaskCreating():
return creating();case VoiceTaskSuccess():
return success(_that.createdTask);case VoiceTaskError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  requestingPermission,TResult? Function( bool permanentlyDenied)?  permissionDenied,TResult? Function( String recognizedText,  double soundLevel)?  listening,TResult? Function( String fullText)?  parsing,TResult? Function( ParsedTaskDraftDto draft,  String rawSpokenText)?  reviewDraft,TResult? Function()?  creating,TResult? Function( TaskDto createdTask)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case VoiceTaskIdle() when idle != null:
return idle();case VoiceTaskRequestingPermission() when requestingPermission != null:
return requestingPermission();case VoiceTaskPermissionDenied() when permissionDenied != null:
return permissionDenied(_that.permanentlyDenied);case VoiceTaskListening() when listening != null:
return listening(_that.recognizedText,_that.soundLevel);case VoiceTaskParsing() when parsing != null:
return parsing(_that.fullText);case VoiceTaskReviewDraft() when reviewDraft != null:
return reviewDraft(_that.draft,_that.rawSpokenText);case VoiceTaskCreating() when creating != null:
return creating();case VoiceTaskSuccess() when success != null:
return success(_that.createdTask);case VoiceTaskError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class VoiceTaskIdle implements VoiceTaskState {
  const VoiceTaskIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceTaskIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VoiceTaskState.idle()';
}


}




/// @nodoc


class VoiceTaskRequestingPermission implements VoiceTaskState {
  const VoiceTaskRequestingPermission();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceTaskRequestingPermission);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VoiceTaskState.requestingPermission()';
}


}




/// @nodoc


class VoiceTaskPermissionDenied implements VoiceTaskState {
  const VoiceTaskPermissionDenied({this.permanentlyDenied = false});
  

@JsonKey() final  bool permanentlyDenied;

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceTaskPermissionDeniedCopyWith<VoiceTaskPermissionDenied> get copyWith => _$VoiceTaskPermissionDeniedCopyWithImpl<VoiceTaskPermissionDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceTaskPermissionDenied&&(identical(other.permanentlyDenied, permanentlyDenied) || other.permanentlyDenied == permanentlyDenied));
}


@override
int get hashCode => Object.hash(runtimeType,permanentlyDenied);

@override
String toString() {
  return 'VoiceTaskState.permissionDenied(permanentlyDenied: $permanentlyDenied)';
}


}

/// @nodoc
abstract mixin class $VoiceTaskPermissionDeniedCopyWith<$Res> implements $VoiceTaskStateCopyWith<$Res> {
  factory $VoiceTaskPermissionDeniedCopyWith(VoiceTaskPermissionDenied value, $Res Function(VoiceTaskPermissionDenied) _then) = _$VoiceTaskPermissionDeniedCopyWithImpl;
@useResult
$Res call({
 bool permanentlyDenied
});




}
/// @nodoc
class _$VoiceTaskPermissionDeniedCopyWithImpl<$Res>
    implements $VoiceTaskPermissionDeniedCopyWith<$Res> {
  _$VoiceTaskPermissionDeniedCopyWithImpl(this._self, this._then);

  final VoiceTaskPermissionDenied _self;
  final $Res Function(VoiceTaskPermissionDenied) _then;

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? permanentlyDenied = null,}) {
  return _then(VoiceTaskPermissionDenied(
permanentlyDenied: null == permanentlyDenied ? _self.permanentlyDenied : permanentlyDenied // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class VoiceTaskListening implements VoiceTaskState {
  const VoiceTaskListening({this.recognizedText = '', this.soundLevel = 0.0});
  

@JsonKey() final  String recognizedText;
@JsonKey() final  double soundLevel;

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceTaskListeningCopyWith<VoiceTaskListening> get copyWith => _$VoiceTaskListeningCopyWithImpl<VoiceTaskListening>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceTaskListening&&(identical(other.recognizedText, recognizedText) || other.recognizedText == recognizedText)&&(identical(other.soundLevel, soundLevel) || other.soundLevel == soundLevel));
}


@override
int get hashCode => Object.hash(runtimeType,recognizedText,soundLevel);

@override
String toString() {
  return 'VoiceTaskState.listening(recognizedText: $recognizedText, soundLevel: $soundLevel)';
}


}

/// @nodoc
abstract mixin class $VoiceTaskListeningCopyWith<$Res> implements $VoiceTaskStateCopyWith<$Res> {
  factory $VoiceTaskListeningCopyWith(VoiceTaskListening value, $Res Function(VoiceTaskListening) _then) = _$VoiceTaskListeningCopyWithImpl;
@useResult
$Res call({
 String recognizedText, double soundLevel
});




}
/// @nodoc
class _$VoiceTaskListeningCopyWithImpl<$Res>
    implements $VoiceTaskListeningCopyWith<$Res> {
  _$VoiceTaskListeningCopyWithImpl(this._self, this._then);

  final VoiceTaskListening _self;
  final $Res Function(VoiceTaskListening) _then;

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? recognizedText = null,Object? soundLevel = null,}) {
  return _then(VoiceTaskListening(
recognizedText: null == recognizedText ? _self.recognizedText : recognizedText // ignore: cast_nullable_to_non_nullable
as String,soundLevel: null == soundLevel ? _self.soundLevel : soundLevel // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class VoiceTaskParsing implements VoiceTaskState {
  const VoiceTaskParsing({required this.fullText});
  

 final  String fullText;

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceTaskParsingCopyWith<VoiceTaskParsing> get copyWith => _$VoiceTaskParsingCopyWithImpl<VoiceTaskParsing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceTaskParsing&&(identical(other.fullText, fullText) || other.fullText == fullText));
}


@override
int get hashCode => Object.hash(runtimeType,fullText);

@override
String toString() {
  return 'VoiceTaskState.parsing(fullText: $fullText)';
}


}

/// @nodoc
abstract mixin class $VoiceTaskParsingCopyWith<$Res> implements $VoiceTaskStateCopyWith<$Res> {
  factory $VoiceTaskParsingCopyWith(VoiceTaskParsing value, $Res Function(VoiceTaskParsing) _then) = _$VoiceTaskParsingCopyWithImpl;
@useResult
$Res call({
 String fullText
});




}
/// @nodoc
class _$VoiceTaskParsingCopyWithImpl<$Res>
    implements $VoiceTaskParsingCopyWith<$Res> {
  _$VoiceTaskParsingCopyWithImpl(this._self, this._then);

  final VoiceTaskParsing _self;
  final $Res Function(VoiceTaskParsing) _then;

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fullText = null,}) {
  return _then(VoiceTaskParsing(
fullText: null == fullText ? _self.fullText : fullText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class VoiceTaskReviewDraft implements VoiceTaskState {
  const VoiceTaskReviewDraft({required this.draft, required this.rawSpokenText});
  

 final  ParsedTaskDraftDto draft;
 final  String rawSpokenText;

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceTaskReviewDraftCopyWith<VoiceTaskReviewDraft> get copyWith => _$VoiceTaskReviewDraftCopyWithImpl<VoiceTaskReviewDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceTaskReviewDraft&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.rawSpokenText, rawSpokenText) || other.rawSpokenText == rawSpokenText));
}


@override
int get hashCode => Object.hash(runtimeType,draft,rawSpokenText);

@override
String toString() {
  return 'VoiceTaskState.reviewDraft(draft: $draft, rawSpokenText: $rawSpokenText)';
}


}

/// @nodoc
abstract mixin class $VoiceTaskReviewDraftCopyWith<$Res> implements $VoiceTaskStateCopyWith<$Res> {
  factory $VoiceTaskReviewDraftCopyWith(VoiceTaskReviewDraft value, $Res Function(VoiceTaskReviewDraft) _then) = _$VoiceTaskReviewDraftCopyWithImpl;
@useResult
$Res call({
 ParsedTaskDraftDto draft, String rawSpokenText
});


$ParsedTaskDraftDtoCopyWith<$Res> get draft;

}
/// @nodoc
class _$VoiceTaskReviewDraftCopyWithImpl<$Res>
    implements $VoiceTaskReviewDraftCopyWith<$Res> {
  _$VoiceTaskReviewDraftCopyWithImpl(this._self, this._then);

  final VoiceTaskReviewDraft _self;
  final $Res Function(VoiceTaskReviewDraft) _then;

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? draft = null,Object? rawSpokenText = null,}) {
  return _then(VoiceTaskReviewDraft(
draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as ParsedTaskDraftDto,rawSpokenText: null == rawSpokenText ? _self.rawSpokenText : rawSpokenText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParsedTaskDraftDtoCopyWith<$Res> get draft {
  
  return $ParsedTaskDraftDtoCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}

/// @nodoc


class VoiceTaskCreating implements VoiceTaskState {
  const VoiceTaskCreating();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceTaskCreating);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VoiceTaskState.creating()';
}


}




/// @nodoc


class VoiceTaskSuccess implements VoiceTaskState {
  const VoiceTaskSuccess({required this.createdTask});
  

 final  TaskDto createdTask;

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceTaskSuccessCopyWith<VoiceTaskSuccess> get copyWith => _$VoiceTaskSuccessCopyWithImpl<VoiceTaskSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceTaskSuccess&&(identical(other.createdTask, createdTask) || other.createdTask == createdTask));
}


@override
int get hashCode => Object.hash(runtimeType,createdTask);

@override
String toString() {
  return 'VoiceTaskState.success(createdTask: $createdTask)';
}


}

/// @nodoc
abstract mixin class $VoiceTaskSuccessCopyWith<$Res> implements $VoiceTaskStateCopyWith<$Res> {
  factory $VoiceTaskSuccessCopyWith(VoiceTaskSuccess value, $Res Function(VoiceTaskSuccess) _then) = _$VoiceTaskSuccessCopyWithImpl;
@useResult
$Res call({
 TaskDto createdTask
});


$TaskDtoCopyWith<$Res> get createdTask;

}
/// @nodoc
class _$VoiceTaskSuccessCopyWithImpl<$Res>
    implements $VoiceTaskSuccessCopyWith<$Res> {
  _$VoiceTaskSuccessCopyWithImpl(this._self, this._then);

  final VoiceTaskSuccess _self;
  final $Res Function(VoiceTaskSuccess) _then;

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? createdTask = null,}) {
  return _then(VoiceTaskSuccess(
createdTask: null == createdTask ? _self.createdTask : createdTask // ignore: cast_nullable_to_non_nullable
as TaskDto,
  ));
}

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TaskDtoCopyWith<$Res> get createdTask {
  
  return $TaskDtoCopyWith<$Res>(_self.createdTask, (value) {
    return _then(_self.copyWith(createdTask: value));
  });
}
}

/// @nodoc


class VoiceTaskError implements VoiceTaskState {
  const VoiceTaskError({required this.message});
  

 final  String message;

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceTaskErrorCopyWith<VoiceTaskError> get copyWith => _$VoiceTaskErrorCopyWithImpl<VoiceTaskError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceTaskError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VoiceTaskState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $VoiceTaskErrorCopyWith<$Res> implements $VoiceTaskStateCopyWith<$Res> {
  factory $VoiceTaskErrorCopyWith(VoiceTaskError value, $Res Function(VoiceTaskError) _then) = _$VoiceTaskErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$VoiceTaskErrorCopyWithImpl<$Res>
    implements $VoiceTaskErrorCopyWith<$Res> {
  _$VoiceTaskErrorCopyWithImpl(this._self, this._then);

  final VoiceTaskError _self;
  final $Res Function(VoiceTaskError) _then;

/// Create a copy of VoiceTaskState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(VoiceTaskError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
