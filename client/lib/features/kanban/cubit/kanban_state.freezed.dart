// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kanban_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KanbanState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KanbanState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'KanbanState()';
}


}

/// @nodoc
class $KanbanStateCopyWith<$Res>  {
$KanbanStateCopyWith(KanbanState _, $Res Function(KanbanState) __);
}


/// Adds pattern-matching-related methods to [KanbanState].
extension KanbanStatePatterns on KanbanState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( KanbanInitial value)?  initial,TResult Function( KanbanLoading value)?  loading,TResult Function( KanbanLoaded value)?  loaded,TResult Function( KanbanEmpty value)?  empty,TResult Function( KanbanError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case KanbanInitial() when initial != null:
return initial(_that);case KanbanLoading() when loading != null:
return loading(_that);case KanbanLoaded() when loaded != null:
return loaded(_that);case KanbanEmpty() when empty != null:
return empty(_that);case KanbanError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( KanbanInitial value)  initial,required TResult Function( KanbanLoading value)  loading,required TResult Function( KanbanLoaded value)  loaded,required TResult Function( KanbanEmpty value)  empty,required TResult Function( KanbanError value)  error,}){
final _that = this;
switch (_that) {
case KanbanInitial():
return initial(_that);case KanbanLoading():
return loading(_that);case KanbanLoaded():
return loaded(_that);case KanbanEmpty():
return empty(_that);case KanbanError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( KanbanInitial value)?  initial,TResult? Function( KanbanLoading value)?  loading,TResult? Function( KanbanLoaded value)?  loaded,TResult? Function( KanbanEmpty value)?  empty,TResult? Function( KanbanError value)?  error,}){
final _that = this;
switch (_that) {
case KanbanInitial() when initial != null:
return initial(_that);case KanbanLoading() when loading != null:
return loading(_that);case KanbanLoaded() when loaded != null:
return loaded(_that);case KanbanEmpty() when empty != null:
return empty(_that);case KanbanError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( int projectId,  List<TaskDto> tasks,  List<TaskDto> allTasks,  bool isArchived,  TaskFilter filter,  AppFailure? failure)?  loaded,TResult Function( int projectId,  bool isArchived,  AppFailure? failure)?  empty,TResult Function( AppFailure failure)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case KanbanInitial() when initial != null:
return initial();case KanbanLoading() when loading != null:
return loading();case KanbanLoaded() when loaded != null:
return loaded(_that.projectId,_that.tasks,_that.allTasks,_that.isArchived,_that.filter,_that.failure);case KanbanEmpty() when empty != null:
return empty(_that.projectId,_that.isArchived,_that.failure);case KanbanError() when error != null:
return error(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( int projectId,  List<TaskDto> tasks,  List<TaskDto> allTasks,  bool isArchived,  TaskFilter filter,  AppFailure? failure)  loaded,required TResult Function( int projectId,  bool isArchived,  AppFailure? failure)  empty,required TResult Function( AppFailure failure)  error,}) {final _that = this;
switch (_that) {
case KanbanInitial():
return initial();case KanbanLoading():
return loading();case KanbanLoaded():
return loaded(_that.projectId,_that.tasks,_that.allTasks,_that.isArchived,_that.filter,_that.failure);case KanbanEmpty():
return empty(_that.projectId,_that.isArchived,_that.failure);case KanbanError():
return error(_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( int projectId,  List<TaskDto> tasks,  List<TaskDto> allTasks,  bool isArchived,  TaskFilter filter,  AppFailure? failure)?  loaded,TResult? Function( int projectId,  bool isArchived,  AppFailure? failure)?  empty,TResult? Function( AppFailure failure)?  error,}) {final _that = this;
switch (_that) {
case KanbanInitial() when initial != null:
return initial();case KanbanLoading() when loading != null:
return loading();case KanbanLoaded() when loaded != null:
return loaded(_that.projectId,_that.tasks,_that.allTasks,_that.isArchived,_that.filter,_that.failure);case KanbanEmpty() when empty != null:
return empty(_that.projectId,_that.isArchived,_that.failure);case KanbanError() when error != null:
return error(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class KanbanInitial extends KanbanState {
  const KanbanInitial(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KanbanInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'KanbanState.initial()';
}


}




/// @nodoc


class KanbanLoading extends KanbanState {
  const KanbanLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KanbanLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'KanbanState.loading()';
}


}




/// @nodoc


class KanbanLoaded extends KanbanState {
  const KanbanLoaded({required this.projectId, required final  List<TaskDto> tasks, required final  List<TaskDto> allTasks, this.isArchived = false, this.filter = const TaskFilter(), this.failure}): _tasks = tasks,_allTasks = allTasks,super._();
  

 final  int projectId;
 final  List<TaskDto> _tasks;
 List<TaskDto> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}

 final  List<TaskDto> _allTasks;
 List<TaskDto> get allTasks {
  if (_allTasks is EqualUnmodifiableListView) return _allTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allTasks);
}

@JsonKey() final  bool isArchived;
@JsonKey() final  TaskFilter filter;
 final  AppFailure? failure;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KanbanLoadedCopyWith<KanbanLoaded> get copyWith => _$KanbanLoadedCopyWithImpl<KanbanLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KanbanLoaded&&(identical(other.projectId, projectId) || other.projectId == projectId)&&const DeepCollectionEquality().equals(other._tasks, _tasks)&&const DeepCollectionEquality().equals(other._allTasks, _allTasks)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,projectId,const DeepCollectionEquality().hash(_tasks),const DeepCollectionEquality().hash(_allTasks),isArchived,filter,failure);

@override
String toString() {
  return 'KanbanState.loaded(projectId: $projectId, tasks: $tasks, allTasks: $allTasks, isArchived: $isArchived, filter: $filter, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $KanbanLoadedCopyWith<$Res> implements $KanbanStateCopyWith<$Res> {
  factory $KanbanLoadedCopyWith(KanbanLoaded value, $Res Function(KanbanLoaded) _then) = _$KanbanLoadedCopyWithImpl;
@useResult
$Res call({
 int projectId, List<TaskDto> tasks, List<TaskDto> allTasks, bool isArchived, TaskFilter filter, AppFailure? failure
});




}
/// @nodoc
class _$KanbanLoadedCopyWithImpl<$Res>
    implements $KanbanLoadedCopyWith<$Res> {
  _$KanbanLoadedCopyWithImpl(this._self, this._then);

  final KanbanLoaded _self;
  final $Res Function(KanbanLoaded) _then;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? projectId = null,Object? tasks = null,Object? allTasks = null,Object? isArchived = null,Object? filter = null,Object? failure = freezed,}) {
  return _then(KanbanLoaded(
projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int,tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<TaskDto>,allTasks: null == allTasks ? _self._allTasks : allTasks // ignore: cast_nullable_to_non_nullable
as List<TaskDto>,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as TaskFilter,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class KanbanEmpty extends KanbanState {
  const KanbanEmpty({required this.projectId, this.isArchived = false, this.failure}): super._();
  

 final  int projectId;
@JsonKey() final  bool isArchived;
 final  AppFailure? failure;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KanbanEmptyCopyWith<KanbanEmpty> get copyWith => _$KanbanEmptyCopyWithImpl<KanbanEmpty>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KanbanEmpty&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,projectId,isArchived,failure);

@override
String toString() {
  return 'KanbanState.empty(projectId: $projectId, isArchived: $isArchived, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $KanbanEmptyCopyWith<$Res> implements $KanbanStateCopyWith<$Res> {
  factory $KanbanEmptyCopyWith(KanbanEmpty value, $Res Function(KanbanEmpty) _then) = _$KanbanEmptyCopyWithImpl;
@useResult
$Res call({
 int projectId, bool isArchived, AppFailure? failure
});




}
/// @nodoc
class _$KanbanEmptyCopyWithImpl<$Res>
    implements $KanbanEmptyCopyWith<$Res> {
  _$KanbanEmptyCopyWithImpl(this._self, this._then);

  final KanbanEmpty _self;
  final $Res Function(KanbanEmpty) _then;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? projectId = null,Object? isArchived = null,Object? failure = freezed,}) {
  return _then(KanbanEmpty(
projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class KanbanError extends KanbanState {
  const KanbanError(this.failure): super._();
  

 final  AppFailure failure;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KanbanErrorCopyWith<KanbanError> get copyWith => _$KanbanErrorCopyWithImpl<KanbanError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KanbanError&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'KanbanState.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $KanbanErrorCopyWith<$Res> implements $KanbanStateCopyWith<$Res> {
  factory $KanbanErrorCopyWith(KanbanError value, $Res Function(KanbanError) _then) = _$KanbanErrorCopyWithImpl;
@useResult
$Res call({
 AppFailure failure
});




}
/// @nodoc
class _$KanbanErrorCopyWithImpl<$Res>
    implements $KanbanErrorCopyWith<$Res> {
  _$KanbanErrorCopyWithImpl(this._self, this._then);

  final KanbanError _self;
  final $Res Function(KanbanError) _then;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(KanbanError(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
