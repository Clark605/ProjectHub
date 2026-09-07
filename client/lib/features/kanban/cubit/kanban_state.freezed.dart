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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _KanbanInitial value)?  initial,TResult Function( _KanbanLoading value)?  loading,TResult Function( KanbanLoaded value)?  loaded,TResult Function( _KanbanEmpty value)?  empty,TResult Function( _KanbanError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KanbanInitial() when initial != null:
return initial(_that);case _KanbanLoading() when loading != null:
return loading(_that);case KanbanLoaded() when loaded != null:
return loaded(_that);case _KanbanEmpty() when empty != null:
return empty(_that);case _KanbanError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _KanbanInitial value)  initial,required TResult Function( _KanbanLoading value)  loading,required TResult Function( KanbanLoaded value)  loaded,required TResult Function( _KanbanEmpty value)  empty,required TResult Function( _KanbanError value)  error,}){
final _that = this;
switch (_that) {
case _KanbanInitial():
return initial(_that);case _KanbanLoading():
return loading(_that);case KanbanLoaded():
return loaded(_that);case _KanbanEmpty():
return empty(_that);case _KanbanError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _KanbanInitial value)?  initial,TResult? Function( _KanbanLoading value)?  loading,TResult? Function( KanbanLoaded value)?  loaded,TResult? Function( _KanbanEmpty value)?  empty,TResult? Function( _KanbanError value)?  error,}){
final _that = this;
switch (_that) {
case _KanbanInitial() when initial != null:
return initial(_that);case _KanbanLoading() when loading != null:
return loading(_that);case KanbanLoaded() when loaded != null:
return loaded(_that);case _KanbanEmpty() when empty != null:
return empty(_that);case _KanbanError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( int projectId,  List<TaskDto> tasks,  List<TaskDto> allTasks,  bool isArchived,  String? searchFilter,  String? priorityFilter,  String? assigneeFilter,  String? errorMessage)?  loaded,TResult Function( int projectId,  bool isArchived)?  empty,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KanbanInitial() when initial != null:
return initial();case _KanbanLoading() when loading != null:
return loading();case KanbanLoaded() when loaded != null:
return loaded(_that.projectId,_that.tasks,_that.allTasks,_that.isArchived,_that.searchFilter,_that.priorityFilter,_that.assigneeFilter,_that.errorMessage);case _KanbanEmpty() when empty != null:
return empty(_that.projectId,_that.isArchived);case _KanbanError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( int projectId,  List<TaskDto> tasks,  List<TaskDto> allTasks,  bool isArchived,  String? searchFilter,  String? priorityFilter,  String? assigneeFilter,  String? errorMessage)  loaded,required TResult Function( int projectId,  bool isArchived)  empty,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _KanbanInitial():
return initial();case _KanbanLoading():
return loading();case KanbanLoaded():
return loaded(_that.projectId,_that.tasks,_that.allTasks,_that.isArchived,_that.searchFilter,_that.priorityFilter,_that.assigneeFilter,_that.errorMessage);case _KanbanEmpty():
return empty(_that.projectId,_that.isArchived);case _KanbanError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( int projectId,  List<TaskDto> tasks,  List<TaskDto> allTasks,  bool isArchived,  String? searchFilter,  String? priorityFilter,  String? assigneeFilter,  String? errorMessage)?  loaded,TResult? Function( int projectId,  bool isArchived)?  empty,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _KanbanInitial() when initial != null:
return initial();case _KanbanLoading() when loading != null:
return loading();case KanbanLoaded() when loaded != null:
return loaded(_that.projectId,_that.tasks,_that.allTasks,_that.isArchived,_that.searchFilter,_that.priorityFilter,_that.assigneeFilter,_that.errorMessage);case _KanbanEmpty() when empty != null:
return empty(_that.projectId,_that.isArchived);case _KanbanError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _KanbanInitial extends KanbanState {
  const _KanbanInitial(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KanbanInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'KanbanState.initial()';
}


}




/// @nodoc


class _KanbanLoading extends KanbanState {
  const _KanbanLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KanbanLoading);
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
  const KanbanLoaded({required this.projectId, required final  List<TaskDto> tasks, required final  List<TaskDto> allTasks, this.isArchived = false, this.searchFilter, this.priorityFilter, this.assigneeFilter, this.errorMessage}): _tasks = tasks,_allTasks = allTasks,super._();
  

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
 final  String? searchFilter;
 final  String? priorityFilter;
 final  String? assigneeFilter;
 final  String? errorMessage;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KanbanLoadedCopyWith<KanbanLoaded> get copyWith => _$KanbanLoadedCopyWithImpl<KanbanLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KanbanLoaded&&(identical(other.projectId, projectId) || other.projectId == projectId)&&const DeepCollectionEquality().equals(other._tasks, _tasks)&&const DeepCollectionEquality().equals(other._allTasks, _allTasks)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.searchFilter, searchFilter) || other.searchFilter == searchFilter)&&(identical(other.priorityFilter, priorityFilter) || other.priorityFilter == priorityFilter)&&(identical(other.assigneeFilter, assigneeFilter) || other.assigneeFilter == assigneeFilter)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,projectId,const DeepCollectionEquality().hash(_tasks),const DeepCollectionEquality().hash(_allTasks),isArchived,searchFilter,priorityFilter,assigneeFilter,errorMessage);

@override
String toString() {
  return 'KanbanState.loaded(projectId: $projectId, tasks: $tasks, allTasks: $allTasks, isArchived: $isArchived, searchFilter: $searchFilter, priorityFilter: $priorityFilter, assigneeFilter: $assigneeFilter, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $KanbanLoadedCopyWith<$Res> implements $KanbanStateCopyWith<$Res> {
  factory $KanbanLoadedCopyWith(KanbanLoaded value, $Res Function(KanbanLoaded) _then) = _$KanbanLoadedCopyWithImpl;
@useResult
$Res call({
 int projectId, List<TaskDto> tasks, List<TaskDto> allTasks, bool isArchived, String? searchFilter, String? priorityFilter, String? assigneeFilter, String? errorMessage
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
@pragma('vm:prefer-inline') $Res call({Object? projectId = null,Object? tasks = null,Object? allTasks = null,Object? isArchived = null,Object? searchFilter = freezed,Object? priorityFilter = freezed,Object? assigneeFilter = freezed,Object? errorMessage = freezed,}) {
  return _then(KanbanLoaded(
projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int,tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<TaskDto>,allTasks: null == allTasks ? _self._allTasks : allTasks // ignore: cast_nullable_to_non_nullable
as List<TaskDto>,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,searchFilter: freezed == searchFilter ? _self.searchFilter : searchFilter // ignore: cast_nullable_to_non_nullable
as String?,priorityFilter: freezed == priorityFilter ? _self.priorityFilter : priorityFilter // ignore: cast_nullable_to_non_nullable
as String?,assigneeFilter: freezed == assigneeFilter ? _self.assigneeFilter : assigneeFilter // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _KanbanEmpty extends KanbanState {
  const _KanbanEmpty({required this.projectId, this.isArchived = false}): super._();
  

 final  int projectId;
@JsonKey() final  bool isArchived;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KanbanEmptyCopyWith<_KanbanEmpty> get copyWith => __$KanbanEmptyCopyWithImpl<_KanbanEmpty>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KanbanEmpty&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived));
}


@override
int get hashCode => Object.hash(runtimeType,projectId,isArchived);

@override
String toString() {
  return 'KanbanState.empty(projectId: $projectId, isArchived: $isArchived)';
}


}

/// @nodoc
abstract mixin class _$KanbanEmptyCopyWith<$Res> implements $KanbanStateCopyWith<$Res> {
  factory _$KanbanEmptyCopyWith(_KanbanEmpty value, $Res Function(_KanbanEmpty) _then) = __$KanbanEmptyCopyWithImpl;
@useResult
$Res call({
 int projectId, bool isArchived
});




}
/// @nodoc
class __$KanbanEmptyCopyWithImpl<$Res>
    implements _$KanbanEmptyCopyWith<$Res> {
  __$KanbanEmptyCopyWithImpl(this._self, this._then);

  final _KanbanEmpty _self;
  final $Res Function(_KanbanEmpty) _then;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? projectId = null,Object? isArchived = null,}) {
  return _then(_KanbanEmpty(
projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _KanbanError extends KanbanState {
  const _KanbanError(this.message): super._();
  

 final  String message;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KanbanErrorCopyWith<_KanbanError> get copyWith => __$KanbanErrorCopyWithImpl<_KanbanError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KanbanError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'KanbanState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$KanbanErrorCopyWith<$Res> implements $KanbanStateCopyWith<$Res> {
  factory _$KanbanErrorCopyWith(_KanbanError value, $Res Function(_KanbanError) _then) = __$KanbanErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$KanbanErrorCopyWithImpl<$Res>
    implements _$KanbanErrorCopyWith<$Res> {
  __$KanbanErrorCopyWithImpl(this._self, this._then);

  final _KanbanError _self;
  final $Res Function(_KanbanError) _then;

/// Create a copy of KanbanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_KanbanError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
