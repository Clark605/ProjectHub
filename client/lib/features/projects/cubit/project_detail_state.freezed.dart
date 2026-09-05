// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProjectDetailState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectDetailState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectDetailState()';
}


}

/// @nodoc
class $ProjectDetailStateCopyWith<$Res>  {
$ProjectDetailStateCopyWith(ProjectDetailState _, $Res Function(ProjectDetailState) __);
}


/// Adds pattern-matching-related methods to [ProjectDetailState].
extension ProjectDetailStatePatterns on ProjectDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ProjectDetailInitial value)?  initial,TResult Function( _ProjectDetailLoading value)?  loading,TResult Function( ProjectDetailLoaded value)?  loaded,TResult Function( _ProjectDetailDeleted value)?  deleted,TResult Function( _ProjectDetailError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectDetailInitial() when initial != null:
return initial(_that);case _ProjectDetailLoading() when loading != null:
return loading(_that);case ProjectDetailLoaded() when loaded != null:
return loaded(_that);case _ProjectDetailDeleted() when deleted != null:
return deleted(_that);case _ProjectDetailError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ProjectDetailInitial value)  initial,required TResult Function( _ProjectDetailLoading value)  loading,required TResult Function( ProjectDetailLoaded value)  loaded,required TResult Function( _ProjectDetailDeleted value)  deleted,required TResult Function( _ProjectDetailError value)  error,}){
final _that = this;
switch (_that) {
case _ProjectDetailInitial():
return initial(_that);case _ProjectDetailLoading():
return loading(_that);case ProjectDetailLoaded():
return loaded(_that);case _ProjectDetailDeleted():
return deleted(_that);case _ProjectDetailError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ProjectDetailInitial value)?  initial,TResult? Function( _ProjectDetailLoading value)?  loading,TResult? Function( ProjectDetailLoaded value)?  loaded,TResult? Function( _ProjectDetailDeleted value)?  deleted,TResult? Function( _ProjectDetailError value)?  error,}){
final _that = this;
switch (_that) {
case _ProjectDetailInitial() when initial != null:
return initial(_that);case _ProjectDetailLoading() when loading != null:
return loading(_that);case ProjectDetailLoaded() when loaded != null:
return loaded(_that);case _ProjectDetailDeleted() when deleted != null:
return deleted(_that);case _ProjectDetailError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( ProjectDto project,  bool isSaving,  bool isDeleting,  String? errorMessage,  String? actionSuccessMessage)?  loaded,TResult Function()?  deleted,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectDetailInitial() when initial != null:
return initial();case _ProjectDetailLoading() when loading != null:
return loading();case ProjectDetailLoaded() when loaded != null:
return loaded(_that.project,_that.isSaving,_that.isDeleting,_that.errorMessage,_that.actionSuccessMessage);case _ProjectDetailDeleted() when deleted != null:
return deleted();case _ProjectDetailError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( ProjectDto project,  bool isSaving,  bool isDeleting,  String? errorMessage,  String? actionSuccessMessage)  loaded,required TResult Function()  deleted,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _ProjectDetailInitial():
return initial();case _ProjectDetailLoading():
return loading();case ProjectDetailLoaded():
return loaded(_that.project,_that.isSaving,_that.isDeleting,_that.errorMessage,_that.actionSuccessMessage);case _ProjectDetailDeleted():
return deleted();case _ProjectDetailError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( ProjectDto project,  bool isSaving,  bool isDeleting,  String? errorMessage,  String? actionSuccessMessage)?  loaded,TResult? Function()?  deleted,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _ProjectDetailInitial() when initial != null:
return initial();case _ProjectDetailLoading() when loading != null:
return loading();case ProjectDetailLoaded() when loaded != null:
return loaded(_that.project,_that.isSaving,_that.isDeleting,_that.errorMessage,_that.actionSuccessMessage);case _ProjectDetailDeleted() when deleted != null:
return deleted();case _ProjectDetailError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ProjectDetailInitial implements ProjectDetailState {
  const _ProjectDetailInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectDetailInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectDetailState.initial()';
}


}




/// @nodoc


class _ProjectDetailLoading implements ProjectDetailState {
  const _ProjectDetailLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectDetailLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectDetailState.loading()';
}


}




/// @nodoc


class ProjectDetailLoaded implements ProjectDetailState {
  const ProjectDetailLoaded({required this.project, this.isSaving = false, this.isDeleting = false, this.errorMessage, this.actionSuccessMessage});
  

 final  ProjectDto project;
@JsonKey() final  bool isSaving;
@JsonKey() final  bool isDeleting;
 final  String? errorMessage;
 final  String? actionSuccessMessage;

/// Create a copy of ProjectDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectDetailLoadedCopyWith<ProjectDetailLoaded> get copyWith => _$ProjectDetailLoadedCopyWithImpl<ProjectDetailLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectDetailLoaded&&(identical(other.project, project) || other.project == project)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isDeleting, isDeleting) || other.isDeleting == isDeleting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.actionSuccessMessage, actionSuccessMessage) || other.actionSuccessMessage == actionSuccessMessage));
}


@override
int get hashCode => Object.hash(runtimeType,project,isSaving,isDeleting,errorMessage,actionSuccessMessage);

@override
String toString() {
  return 'ProjectDetailState.loaded(project: $project, isSaving: $isSaving, isDeleting: $isDeleting, errorMessage: $errorMessage, actionSuccessMessage: $actionSuccessMessage)';
}


}

/// @nodoc
abstract mixin class $ProjectDetailLoadedCopyWith<$Res> implements $ProjectDetailStateCopyWith<$Res> {
  factory $ProjectDetailLoadedCopyWith(ProjectDetailLoaded value, $Res Function(ProjectDetailLoaded) _then) = _$ProjectDetailLoadedCopyWithImpl;
@useResult
$Res call({
 ProjectDto project, bool isSaving, bool isDeleting, String? errorMessage, String? actionSuccessMessage
});


$ProjectDtoCopyWith<$Res> get project;

}
/// @nodoc
class _$ProjectDetailLoadedCopyWithImpl<$Res>
    implements $ProjectDetailLoadedCopyWith<$Res> {
  _$ProjectDetailLoadedCopyWithImpl(this._self, this._then);

  final ProjectDetailLoaded _self;
  final $Res Function(ProjectDetailLoaded) _then;

/// Create a copy of ProjectDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? project = null,Object? isSaving = null,Object? isDeleting = null,Object? errorMessage = freezed,Object? actionSuccessMessage = freezed,}) {
  return _then(ProjectDetailLoaded(
project: null == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as ProjectDto,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isDeleting: null == isDeleting ? _self.isDeleting : isDeleting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,actionSuccessMessage: freezed == actionSuccessMessage ? _self.actionSuccessMessage : actionSuccessMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ProjectDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectDtoCopyWith<$Res> get project {
  
  return $ProjectDtoCopyWith<$Res>(_self.project, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}

/// @nodoc


class _ProjectDetailDeleted implements ProjectDetailState {
  const _ProjectDetailDeleted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectDetailDeleted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectDetailState.deleted()';
}


}




/// @nodoc


class _ProjectDetailError implements ProjectDetailState {
  const _ProjectDetailError(this.message);
  

 final  String message;

/// Create a copy of ProjectDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectDetailErrorCopyWith<_ProjectDetailError> get copyWith => __$ProjectDetailErrorCopyWithImpl<_ProjectDetailError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectDetailError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ProjectDetailState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ProjectDetailErrorCopyWith<$Res> implements $ProjectDetailStateCopyWith<$Res> {
  factory _$ProjectDetailErrorCopyWith(_ProjectDetailError value, $Res Function(_ProjectDetailError) _then) = __$ProjectDetailErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ProjectDetailErrorCopyWithImpl<$Res>
    implements _$ProjectDetailErrorCopyWith<$Res> {
  __$ProjectDetailErrorCopyWithImpl(this._self, this._then);

  final _ProjectDetailError _self;
  final $Res Function(_ProjectDetailError) _then;

/// Create a copy of ProjectDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_ProjectDetailError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
