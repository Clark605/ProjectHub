// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_tasks_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MyTasksState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyTasksState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MyTasksState()';
}


}

/// @nodoc
class $MyTasksStateCopyWith<$Res>  {
$MyTasksStateCopyWith(MyTasksState _, $Res Function(MyTasksState) __);
}


/// Adds pattern-matching-related methods to [MyTasksState].
extension MyTasksStatePatterns on MyTasksState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _MyTasksInitial value)?  initial,TResult Function( _MyTasksLoading value)?  loading,TResult Function( MyTasksLoaded value)?  loaded,TResult Function( _MyTasksEmpty value)?  empty,TResult Function( _MyTasksError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyTasksInitial() when initial != null:
return initial(_that);case _MyTasksLoading() when loading != null:
return loading(_that);case MyTasksLoaded() when loaded != null:
return loaded(_that);case _MyTasksEmpty() when empty != null:
return empty(_that);case _MyTasksError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _MyTasksInitial value)  initial,required TResult Function( _MyTasksLoading value)  loading,required TResult Function( MyTasksLoaded value)  loaded,required TResult Function( _MyTasksEmpty value)  empty,required TResult Function( _MyTasksError value)  error,}){
final _that = this;
switch (_that) {
case _MyTasksInitial():
return initial(_that);case _MyTasksLoading():
return loading(_that);case MyTasksLoaded():
return loaded(_that);case _MyTasksEmpty():
return empty(_that);case _MyTasksError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _MyTasksInitial value)?  initial,TResult? Function( _MyTasksLoading value)?  loading,TResult? Function( MyTasksLoaded value)?  loaded,TResult? Function( _MyTasksEmpty value)?  empty,TResult? Function( _MyTasksError value)?  error,}){
final _that = this;
switch (_that) {
case _MyTasksInitial() when initial != null:
return initial(_that);case _MyTasksLoading() when loading != null:
return loading(_that);case MyTasksLoaded() when loaded != null:
return loaded(_that);case _MyTasksEmpty() when empty != null:
return empty(_that);case _MyTasksError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( int workspaceId,  List<TaskDto> urgentTasks,  List<TaskDto> inProgressTasks,  List<TaskDto> todoTasks,  List<TaskDto> doneTasks,  bool showDone,  String? errorMessage)?  loaded,TResult Function( int workspaceId)?  empty,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyTasksInitial() when initial != null:
return initial();case _MyTasksLoading() when loading != null:
return loading();case MyTasksLoaded() when loaded != null:
return loaded(_that.workspaceId,_that.urgentTasks,_that.inProgressTasks,_that.todoTasks,_that.doneTasks,_that.showDone,_that.errorMessage);case _MyTasksEmpty() when empty != null:
return empty(_that.workspaceId);case _MyTasksError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( int workspaceId,  List<TaskDto> urgentTasks,  List<TaskDto> inProgressTasks,  List<TaskDto> todoTasks,  List<TaskDto> doneTasks,  bool showDone,  String? errorMessage)  loaded,required TResult Function( int workspaceId)  empty,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _MyTasksInitial():
return initial();case _MyTasksLoading():
return loading();case MyTasksLoaded():
return loaded(_that.workspaceId,_that.urgentTasks,_that.inProgressTasks,_that.todoTasks,_that.doneTasks,_that.showDone,_that.errorMessage);case _MyTasksEmpty():
return empty(_that.workspaceId);case _MyTasksError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( int workspaceId,  List<TaskDto> urgentTasks,  List<TaskDto> inProgressTasks,  List<TaskDto> todoTasks,  List<TaskDto> doneTasks,  bool showDone,  String? errorMessage)?  loaded,TResult? Function( int workspaceId)?  empty,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _MyTasksInitial() when initial != null:
return initial();case _MyTasksLoading() when loading != null:
return loading();case MyTasksLoaded() when loaded != null:
return loaded(_that.workspaceId,_that.urgentTasks,_that.inProgressTasks,_that.todoTasks,_that.doneTasks,_that.showDone,_that.errorMessage);case _MyTasksEmpty() when empty != null:
return empty(_that.workspaceId);case _MyTasksError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _MyTasksInitial extends MyTasksState {
  const _MyTasksInitial(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyTasksInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MyTasksState.initial()';
}


}




/// @nodoc


class _MyTasksLoading extends MyTasksState {
  const _MyTasksLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyTasksLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MyTasksState.loading()';
}


}




/// @nodoc


class MyTasksLoaded extends MyTasksState {
  const MyTasksLoaded({required this.workspaceId, required final  List<TaskDto> urgentTasks, required final  List<TaskDto> inProgressTasks, required final  List<TaskDto> todoTasks, required final  List<TaskDto> doneTasks, this.showDone = false, this.errorMessage}): _urgentTasks = urgentTasks,_inProgressTasks = inProgressTasks,_todoTasks = todoTasks,_doneTasks = doneTasks,super._();
  

 final  int workspaceId;
 final  List<TaskDto> _urgentTasks;
 List<TaskDto> get urgentTasks {
  if (_urgentTasks is EqualUnmodifiableListView) return _urgentTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_urgentTasks);
}

 final  List<TaskDto> _inProgressTasks;
 List<TaskDto> get inProgressTasks {
  if (_inProgressTasks is EqualUnmodifiableListView) return _inProgressTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inProgressTasks);
}

 final  List<TaskDto> _todoTasks;
 List<TaskDto> get todoTasks {
  if (_todoTasks is EqualUnmodifiableListView) return _todoTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_todoTasks);
}

 final  List<TaskDto> _doneTasks;
 List<TaskDto> get doneTasks {
  if (_doneTasks is EqualUnmodifiableListView) return _doneTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_doneTasks);
}

@JsonKey() final  bool showDone;
 final  String? errorMessage;

/// Create a copy of MyTasksState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyTasksLoadedCopyWith<MyTasksLoaded> get copyWith => _$MyTasksLoadedCopyWithImpl<MyTasksLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyTasksLoaded&&(identical(other.workspaceId, workspaceId) || other.workspaceId == workspaceId)&&const DeepCollectionEquality().equals(other._urgentTasks, _urgentTasks)&&const DeepCollectionEquality().equals(other._inProgressTasks, _inProgressTasks)&&const DeepCollectionEquality().equals(other._todoTasks, _todoTasks)&&const DeepCollectionEquality().equals(other._doneTasks, _doneTasks)&&(identical(other.showDone, showDone) || other.showDone == showDone)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,workspaceId,const DeepCollectionEquality().hash(_urgentTasks),const DeepCollectionEquality().hash(_inProgressTasks),const DeepCollectionEquality().hash(_todoTasks),const DeepCollectionEquality().hash(_doneTasks),showDone,errorMessage);

@override
String toString() {
  return 'MyTasksState.loaded(workspaceId: $workspaceId, urgentTasks: $urgentTasks, inProgressTasks: $inProgressTasks, todoTasks: $todoTasks, doneTasks: $doneTasks, showDone: $showDone, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $MyTasksLoadedCopyWith<$Res> implements $MyTasksStateCopyWith<$Res> {
  factory $MyTasksLoadedCopyWith(MyTasksLoaded value, $Res Function(MyTasksLoaded) _then) = _$MyTasksLoadedCopyWithImpl;
@useResult
$Res call({
 int workspaceId, List<TaskDto> urgentTasks, List<TaskDto> inProgressTasks, List<TaskDto> todoTasks, List<TaskDto> doneTasks, bool showDone, String? errorMessage
});




}
/// @nodoc
class _$MyTasksLoadedCopyWithImpl<$Res>
    implements $MyTasksLoadedCopyWith<$Res> {
  _$MyTasksLoadedCopyWithImpl(this._self, this._then);

  final MyTasksLoaded _self;
  final $Res Function(MyTasksLoaded) _then;

/// Create a copy of MyTasksState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? workspaceId = null,Object? urgentTasks = null,Object? inProgressTasks = null,Object? todoTasks = null,Object? doneTasks = null,Object? showDone = null,Object? errorMessage = freezed,}) {
  return _then(MyTasksLoaded(
workspaceId: null == workspaceId ? _self.workspaceId : workspaceId // ignore: cast_nullable_to_non_nullable
as int,urgentTasks: null == urgentTasks ? _self._urgentTasks : urgentTasks // ignore: cast_nullable_to_non_nullable
as List<TaskDto>,inProgressTasks: null == inProgressTasks ? _self._inProgressTasks : inProgressTasks // ignore: cast_nullable_to_non_nullable
as List<TaskDto>,todoTasks: null == todoTasks ? _self._todoTasks : todoTasks // ignore: cast_nullable_to_non_nullable
as List<TaskDto>,doneTasks: null == doneTasks ? _self._doneTasks : doneTasks // ignore: cast_nullable_to_non_nullable
as List<TaskDto>,showDone: null == showDone ? _self.showDone : showDone // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _MyTasksEmpty extends MyTasksState {
  const _MyTasksEmpty({required this.workspaceId}): super._();
  

 final  int workspaceId;

/// Create a copy of MyTasksState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyTasksEmptyCopyWith<_MyTasksEmpty> get copyWith => __$MyTasksEmptyCopyWithImpl<_MyTasksEmpty>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyTasksEmpty&&(identical(other.workspaceId, workspaceId) || other.workspaceId == workspaceId));
}


@override
int get hashCode => Object.hash(runtimeType,workspaceId);

@override
String toString() {
  return 'MyTasksState.empty(workspaceId: $workspaceId)';
}


}

/// @nodoc
abstract mixin class _$MyTasksEmptyCopyWith<$Res> implements $MyTasksStateCopyWith<$Res> {
  factory _$MyTasksEmptyCopyWith(_MyTasksEmpty value, $Res Function(_MyTasksEmpty) _then) = __$MyTasksEmptyCopyWithImpl;
@useResult
$Res call({
 int workspaceId
});




}
/// @nodoc
class __$MyTasksEmptyCopyWithImpl<$Res>
    implements _$MyTasksEmptyCopyWith<$Res> {
  __$MyTasksEmptyCopyWithImpl(this._self, this._then);

  final _MyTasksEmpty _self;
  final $Res Function(_MyTasksEmpty) _then;

/// Create a copy of MyTasksState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? workspaceId = null,}) {
  return _then(_MyTasksEmpty(
workspaceId: null == workspaceId ? _self.workspaceId : workspaceId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _MyTasksError extends MyTasksState {
  const _MyTasksError(this.message): super._();
  

 final  String message;

/// Create a copy of MyTasksState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyTasksErrorCopyWith<_MyTasksError> get copyWith => __$MyTasksErrorCopyWithImpl<_MyTasksError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyTasksError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'MyTasksState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$MyTasksErrorCopyWith<$Res> implements $MyTasksStateCopyWith<$Res> {
  factory _$MyTasksErrorCopyWith(_MyTasksError value, $Res Function(_MyTasksError) _then) = __$MyTasksErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$MyTasksErrorCopyWithImpl<$Res>
    implements _$MyTasksErrorCopyWith<$Res> {
  __$MyTasksErrorCopyWithImpl(this._self, this._then);

  final _MyTasksError _self;
  final $Res Function(_MyTasksError) _then;

/// Create a copy of MyTasksState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_MyTasksError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
