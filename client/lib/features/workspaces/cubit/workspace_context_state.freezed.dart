// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_context_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkspaceContextState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceContextState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkspaceContextState()';
}


}

/// @nodoc
class $WorkspaceContextStateCopyWith<$Res>  {
$WorkspaceContextStateCopyWith(WorkspaceContextState _, $Res Function(WorkspaceContextState) __);
}


/// Adds pattern-matching-related methods to [WorkspaceContextState].
extension WorkspaceContextStatePatterns on WorkspaceContextState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _WorkspaceContextInitial value)?  initial,TResult Function( _WorkspaceContextLoading value)?  loading,TResult Function( _WorkspaceContextLoaded value)?  loaded,TResult Function( _WorkspaceContextEmpty value)?  empty,TResult Function( _WorkspaceContextError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceContextInitial() when initial != null:
return initial(_that);case _WorkspaceContextLoading() when loading != null:
return loading(_that);case _WorkspaceContextLoaded() when loaded != null:
return loaded(_that);case _WorkspaceContextEmpty() when empty != null:
return empty(_that);case _WorkspaceContextError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _WorkspaceContextInitial value)  initial,required TResult Function( _WorkspaceContextLoading value)  loading,required TResult Function( _WorkspaceContextLoaded value)  loaded,required TResult Function( _WorkspaceContextEmpty value)  empty,required TResult Function( _WorkspaceContextError value)  error,}){
final _that = this;
switch (_that) {
case _WorkspaceContextInitial():
return initial(_that);case _WorkspaceContextLoading():
return loading(_that);case _WorkspaceContextLoaded():
return loaded(_that);case _WorkspaceContextEmpty():
return empty(_that);case _WorkspaceContextError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _WorkspaceContextInitial value)?  initial,TResult? Function( _WorkspaceContextLoading value)?  loading,TResult? Function( _WorkspaceContextLoaded value)?  loaded,TResult? Function( _WorkspaceContextEmpty value)?  empty,TResult? Function( _WorkspaceContextError value)?  error,}){
final _that = this;
switch (_that) {
case _WorkspaceContextInitial() when initial != null:
return initial(_that);case _WorkspaceContextLoading() when loading != null:
return loading(_that);case _WorkspaceContextLoaded() when loaded != null:
return loaded(_that);case _WorkspaceContextEmpty() when empty != null:
return empty(_that);case _WorkspaceContextError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<WorkspaceDto> workspaces,  WorkspaceDto activeWorkspace)?  loaded,TResult Function()?  empty,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceContextInitial() when initial != null:
return initial();case _WorkspaceContextLoading() when loading != null:
return loading();case _WorkspaceContextLoaded() when loaded != null:
return loaded(_that.workspaces,_that.activeWorkspace);case _WorkspaceContextEmpty() when empty != null:
return empty();case _WorkspaceContextError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<WorkspaceDto> workspaces,  WorkspaceDto activeWorkspace)  loaded,required TResult Function()  empty,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _WorkspaceContextInitial():
return initial();case _WorkspaceContextLoading():
return loading();case _WorkspaceContextLoaded():
return loaded(_that.workspaces,_that.activeWorkspace);case _WorkspaceContextEmpty():
return empty();case _WorkspaceContextError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<WorkspaceDto> workspaces,  WorkspaceDto activeWorkspace)?  loaded,TResult? Function()?  empty,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _WorkspaceContextInitial() when initial != null:
return initial();case _WorkspaceContextLoading() when loading != null:
return loading();case _WorkspaceContextLoaded() when loaded != null:
return loaded(_that.workspaces,_that.activeWorkspace);case _WorkspaceContextEmpty() when empty != null:
return empty();case _WorkspaceContextError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceContextInitial implements WorkspaceContextState {
  const _WorkspaceContextInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceContextInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkspaceContextState.initial()';
}


}




/// @nodoc


class _WorkspaceContextLoading implements WorkspaceContextState {
  const _WorkspaceContextLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceContextLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkspaceContextState.loading()';
}


}




/// @nodoc


class _WorkspaceContextLoaded implements WorkspaceContextState {
  const _WorkspaceContextLoaded({required final  List<WorkspaceDto> workspaces, required this.activeWorkspace}): _workspaces = workspaces;
  

 final  List<WorkspaceDto> _workspaces;
 List<WorkspaceDto> get workspaces {
  if (_workspaces is EqualUnmodifiableListView) return _workspaces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workspaces);
}

 final  WorkspaceDto activeWorkspace;

/// Create a copy of WorkspaceContextState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceContextLoadedCopyWith<_WorkspaceContextLoaded> get copyWith => __$WorkspaceContextLoadedCopyWithImpl<_WorkspaceContextLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceContextLoaded&&const DeepCollectionEquality().equals(other._workspaces, _workspaces)&&(identical(other.activeWorkspace, activeWorkspace) || other.activeWorkspace == activeWorkspace));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_workspaces),activeWorkspace);

@override
String toString() {
  return 'WorkspaceContextState.loaded(workspaces: $workspaces, activeWorkspace: $activeWorkspace)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceContextLoadedCopyWith<$Res> implements $WorkspaceContextStateCopyWith<$Res> {
  factory _$WorkspaceContextLoadedCopyWith(_WorkspaceContextLoaded value, $Res Function(_WorkspaceContextLoaded) _then) = __$WorkspaceContextLoadedCopyWithImpl;
@useResult
$Res call({
 List<WorkspaceDto> workspaces, WorkspaceDto activeWorkspace
});


$WorkspaceDtoCopyWith<$Res> get activeWorkspace;

}
/// @nodoc
class __$WorkspaceContextLoadedCopyWithImpl<$Res>
    implements _$WorkspaceContextLoadedCopyWith<$Res> {
  __$WorkspaceContextLoadedCopyWithImpl(this._self, this._then);

  final _WorkspaceContextLoaded _self;
  final $Res Function(_WorkspaceContextLoaded) _then;

/// Create a copy of WorkspaceContextState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? workspaces = null,Object? activeWorkspace = null,}) {
  return _then(_WorkspaceContextLoaded(
workspaces: null == workspaces ? _self._workspaces : workspaces // ignore: cast_nullable_to_non_nullable
as List<WorkspaceDto>,activeWorkspace: null == activeWorkspace ? _self.activeWorkspace : activeWorkspace // ignore: cast_nullable_to_non_nullable
as WorkspaceDto,
  ));
}

/// Create a copy of WorkspaceContextState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkspaceDtoCopyWith<$Res> get activeWorkspace {
  
  return $WorkspaceDtoCopyWith<$Res>(_self.activeWorkspace, (value) {
    return _then(_self.copyWith(activeWorkspace: value));
  });
}
}

/// @nodoc


class _WorkspaceContextEmpty implements WorkspaceContextState {
  const _WorkspaceContextEmpty();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceContextEmpty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WorkspaceContextState.empty()';
}


}




/// @nodoc


class _WorkspaceContextError implements WorkspaceContextState {
  const _WorkspaceContextError(this.message);
  

 final  String message;

/// Create a copy of WorkspaceContextState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceContextErrorCopyWith<_WorkspaceContextError> get copyWith => __$WorkspaceContextErrorCopyWithImpl<_WorkspaceContextError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceContextError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'WorkspaceContextState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceContextErrorCopyWith<$Res> implements $WorkspaceContextStateCopyWith<$Res> {
  factory _$WorkspaceContextErrorCopyWith(_WorkspaceContextError value, $Res Function(_WorkspaceContextError) _then) = __$WorkspaceContextErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$WorkspaceContextErrorCopyWithImpl<$Res>
    implements _$WorkspaceContextErrorCopyWith<$Res> {
  __$WorkspaceContextErrorCopyWithImpl(this._self, this._then);

  final _WorkspaceContextError _self;
  final $Res Function(_WorkspaceContextError) _then;

/// Create a copy of WorkspaceContextState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_WorkspaceContextError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
