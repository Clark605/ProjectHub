// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkspaceSettingsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceSettingsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkspaceSettingsState()';
}


}

/// @nodoc
class $WorkspaceSettingsStateCopyWith<$Res>  {
$WorkspaceSettingsStateCopyWith(WorkspaceSettingsState _, $Res Function(WorkspaceSettingsState) __);
}


/// Adds pattern-matching-related methods to [WorkspaceSettingsState].
extension WorkspaceSettingsStatePatterns on WorkspaceSettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WorkspaceSettingsInitial value)?  initial,TResult Function( WorkspaceSettingsLoading value)?  loading,TResult Function( WorkspaceSettingsLoaded value)?  loaded,TResult Function( WorkspaceSettingsDeleted value)?  deleted,TResult Function( WorkspaceSettingsError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WorkspaceSettingsInitial() when initial != null:
return initial(_that);case WorkspaceSettingsLoading() when loading != null:
return loading(_that);case WorkspaceSettingsLoaded() when loaded != null:
return loaded(_that);case WorkspaceSettingsDeleted() when deleted != null:
return deleted(_that);case WorkspaceSettingsError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WorkspaceSettingsInitial value)  initial,required TResult Function( WorkspaceSettingsLoading value)  loading,required TResult Function( WorkspaceSettingsLoaded value)  loaded,required TResult Function( WorkspaceSettingsDeleted value)  deleted,required TResult Function( WorkspaceSettingsError value)  error,}){
final _that = this;
switch (_that) {
case WorkspaceSettingsInitial():
return initial(_that);case WorkspaceSettingsLoading():
return loading(_that);case WorkspaceSettingsLoaded():
return loaded(_that);case WorkspaceSettingsDeleted():
return deleted(_that);case WorkspaceSettingsError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WorkspaceSettingsInitial value)?  initial,TResult? Function( WorkspaceSettingsLoading value)?  loading,TResult? Function( WorkspaceSettingsLoaded value)?  loaded,TResult? Function( WorkspaceSettingsDeleted value)?  deleted,TResult? Function( WorkspaceSettingsError value)?  error,}){
final _that = this;
switch (_that) {
case WorkspaceSettingsInitial() when initial != null:
return initial(_that);case WorkspaceSettingsLoading() when loading != null:
return loading(_that);case WorkspaceSettingsLoaded() when loaded != null:
return loaded(_that);case WorkspaceSettingsDeleted() when deleted != null:
return deleted(_that);case WorkspaceSettingsError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( WorkspaceDto workspace,  List<MemberDto> members,  bool isSaving,  bool isInviting,  bool isRevalidating,  String? actionSuccessMessage,  String? errorMessage)?  loaded,TResult Function()?  deleted,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WorkspaceSettingsInitial() when initial != null:
return initial();case WorkspaceSettingsLoading() when loading != null:
return loading();case WorkspaceSettingsLoaded() when loaded != null:
return loaded(_that.workspace,_that.members,_that.isSaving,_that.isInviting,_that.isRevalidating,_that.actionSuccessMessage,_that.errorMessage);case WorkspaceSettingsDeleted() when deleted != null:
return deleted();case WorkspaceSettingsError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( WorkspaceDto workspace,  List<MemberDto> members,  bool isSaving,  bool isInviting,  bool isRevalidating,  String? actionSuccessMessage,  String? errorMessage)  loaded,required TResult Function()  deleted,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case WorkspaceSettingsInitial():
return initial();case WorkspaceSettingsLoading():
return loading();case WorkspaceSettingsLoaded():
return loaded(_that.workspace,_that.members,_that.isSaving,_that.isInviting,_that.isRevalidating,_that.actionSuccessMessage,_that.errorMessage);case WorkspaceSettingsDeleted():
return deleted();case WorkspaceSettingsError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( WorkspaceDto workspace,  List<MemberDto> members,  bool isSaving,  bool isInviting,  bool isRevalidating,  String? actionSuccessMessage,  String? errorMessage)?  loaded,TResult? Function()?  deleted,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case WorkspaceSettingsInitial() when initial != null:
return initial();case WorkspaceSettingsLoading() when loading != null:
return loading();case WorkspaceSettingsLoaded() when loaded != null:
return loaded(_that.workspace,_that.members,_that.isSaving,_that.isInviting,_that.isRevalidating,_that.actionSuccessMessage,_that.errorMessage);case WorkspaceSettingsDeleted() when deleted != null:
return deleted();case WorkspaceSettingsError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class WorkspaceSettingsInitial implements WorkspaceSettingsState {
  const WorkspaceSettingsInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceSettingsInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkspaceSettingsState.initial()';
}


}




/// @nodoc


class WorkspaceSettingsLoading implements WorkspaceSettingsState {
  const WorkspaceSettingsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceSettingsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkspaceSettingsState.loading()';
}


}




/// @nodoc


class WorkspaceSettingsLoaded implements WorkspaceSettingsState {
  const WorkspaceSettingsLoaded({required this.workspace, required final  List<MemberDto> members, this.isSaving = false, this.isInviting = false, this.isRevalidating = false, this.actionSuccessMessage, this.errorMessage}): _members = members;
  

 final  WorkspaceDto workspace;
 final  List<MemberDto> _members;
 List<MemberDto> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

@JsonKey() final  bool isSaving;
@JsonKey() final  bool isInviting;
@JsonKey() final  bool isRevalidating;
 final  String? actionSuccessMessage;
 final  String? errorMessage;

/// Create a copy of WorkspaceSettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceSettingsLoadedCopyWith<WorkspaceSettingsLoaded> get copyWith => _$WorkspaceSettingsLoadedCopyWithImpl<WorkspaceSettingsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceSettingsLoaded&&(identical(other.workspace, workspace) || other.workspace == workspace)&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isInviting, isInviting) || other.isInviting == isInviting)&&(identical(other.isRevalidating, isRevalidating) || other.isRevalidating == isRevalidating)&&(identical(other.actionSuccessMessage, actionSuccessMessage) || other.actionSuccessMessage == actionSuccessMessage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,workspace,const DeepCollectionEquality().hash(_members),isSaving,isInviting,isRevalidating,actionSuccessMessage,errorMessage);

@override
String toString() {
  return 'WorkspaceSettingsState.loaded(workspace: $workspace, members: $members, isSaving: $isSaving, isInviting: $isInviting, isRevalidating: $isRevalidating, actionSuccessMessage: $actionSuccessMessage, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $WorkspaceSettingsLoadedCopyWith<$Res> implements $WorkspaceSettingsStateCopyWith<$Res> {
  factory $WorkspaceSettingsLoadedCopyWith(WorkspaceSettingsLoaded value, $Res Function(WorkspaceSettingsLoaded) _then) = _$WorkspaceSettingsLoadedCopyWithImpl;
@useResult
$Res call({
 WorkspaceDto workspace, List<MemberDto> members, bool isSaving, bool isInviting, bool isRevalidating, String? actionSuccessMessage, String? errorMessage
});


$WorkspaceDtoCopyWith<$Res> get workspace;

}
/// @nodoc
class _$WorkspaceSettingsLoadedCopyWithImpl<$Res>
    implements $WorkspaceSettingsLoadedCopyWith<$Res> {
  _$WorkspaceSettingsLoadedCopyWithImpl(this._self, this._then);

  final WorkspaceSettingsLoaded _self;
  final $Res Function(WorkspaceSettingsLoaded) _then;

/// Create a copy of WorkspaceSettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? workspace = null,Object? members = null,Object? isSaving = null,Object? isInviting = null,Object? isRevalidating = null,Object? actionSuccessMessage = freezed,Object? errorMessage = freezed,}) {
  return _then(WorkspaceSettingsLoaded(
workspace: null == workspace ? _self.workspace : workspace // ignore: cast_nullable_to_non_nullable
as WorkspaceDto,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<MemberDto>,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isInviting: null == isInviting ? _self.isInviting : isInviting // ignore: cast_nullable_to_non_nullable
as bool,isRevalidating: null == isRevalidating ? _self.isRevalidating : isRevalidating // ignore: cast_nullable_to_non_nullable
as bool,actionSuccessMessage: freezed == actionSuccessMessage ? _self.actionSuccessMessage : actionSuccessMessage // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of WorkspaceSettingsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkspaceDtoCopyWith<$Res> get workspace {
  
  return $WorkspaceDtoCopyWith<$Res>(_self.workspace, (value) {
    return _then(_self.copyWith(workspace: value));
  });
}
}

/// @nodoc


class WorkspaceSettingsDeleted implements WorkspaceSettingsState {
  const WorkspaceSettingsDeleted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceSettingsDeleted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkspaceSettingsState.deleted()';
}


}




/// @nodoc


class WorkspaceSettingsError implements WorkspaceSettingsState {
  const WorkspaceSettingsError(this.message);
  

 final  String message;

/// Create a copy of WorkspaceSettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceSettingsErrorCopyWith<WorkspaceSettingsError> get copyWith => _$WorkspaceSettingsErrorCopyWithImpl<WorkspaceSettingsError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceSettingsError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'WorkspaceSettingsState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $WorkspaceSettingsErrorCopyWith<$Res> implements $WorkspaceSettingsStateCopyWith<$Res> {
  factory $WorkspaceSettingsErrorCopyWith(WorkspaceSettingsError value, $Res Function(WorkspaceSettingsError) _then) = _$WorkspaceSettingsErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$WorkspaceSettingsErrorCopyWithImpl<$Res>
    implements $WorkspaceSettingsErrorCopyWith<$Res> {
  _$WorkspaceSettingsErrorCopyWithImpl(this._self, this._then);

  final WorkspaceSettingsError _self;
  final $Res Function(WorkspaceSettingsError) _then;

/// Create a copy of WorkspaceSettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(WorkspaceSettingsError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
