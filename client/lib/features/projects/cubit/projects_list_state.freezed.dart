// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'projects_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProjectsListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectsListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectsListState()';
}


}

/// @nodoc
class $ProjectsListStateCopyWith<$Res>  {
$ProjectsListStateCopyWith(ProjectsListState _, $Res Function(ProjectsListState) __);
}


/// Adds pattern-matching-related methods to [ProjectsListState].
extension ProjectsListStatePatterns on ProjectsListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ProjectsListInitial value)?  initial,TResult Function( _ProjectsListLoading value)?  loading,TResult Function( ProjectsListLoaded value)?  loaded,TResult Function( _ProjectsListEmpty value)?  empty,TResult Function( _ProjectsListError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectsListInitial() when initial != null:
return initial(_that);case _ProjectsListLoading() when loading != null:
return loading(_that);case ProjectsListLoaded() when loaded != null:
return loaded(_that);case _ProjectsListEmpty() when empty != null:
return empty(_that);case _ProjectsListError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ProjectsListInitial value)  initial,required TResult Function( _ProjectsListLoading value)  loading,required TResult Function( ProjectsListLoaded value)  loaded,required TResult Function( _ProjectsListEmpty value)  empty,required TResult Function( _ProjectsListError value)  error,}){
final _that = this;
switch (_that) {
case _ProjectsListInitial():
return initial(_that);case _ProjectsListLoading():
return loading(_that);case ProjectsListLoaded():
return loaded(_that);case _ProjectsListEmpty():
return empty(_that);case _ProjectsListError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ProjectsListInitial value)?  initial,TResult? Function( _ProjectsListLoading value)?  loading,TResult? Function( ProjectsListLoaded value)?  loaded,TResult? Function( _ProjectsListEmpty value)?  empty,TResult? Function( _ProjectsListError value)?  error,}){
final _that = this;
switch (_that) {
case _ProjectsListInitial() when initial != null:
return initial(_that);case _ProjectsListLoading() when loading != null:
return loading(_that);case ProjectsListLoaded() when loaded != null:
return loaded(_that);case _ProjectsListEmpty() when empty != null:
return empty(_that);case _ProjectsListError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<ProjectDto> projects,  List<ProjectDto> allProjects,  String selectedFilter)?  loaded,TResult Function( String selectedFilter)?  empty,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectsListInitial() when initial != null:
return initial();case _ProjectsListLoading() when loading != null:
return loading();case ProjectsListLoaded() when loaded != null:
return loaded(_that.projects,_that.allProjects,_that.selectedFilter);case _ProjectsListEmpty() when empty != null:
return empty(_that.selectedFilter);case _ProjectsListError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<ProjectDto> projects,  List<ProjectDto> allProjects,  String selectedFilter)  loaded,required TResult Function( String selectedFilter)  empty,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _ProjectsListInitial():
return initial();case _ProjectsListLoading():
return loading();case ProjectsListLoaded():
return loaded(_that.projects,_that.allProjects,_that.selectedFilter);case _ProjectsListEmpty():
return empty(_that.selectedFilter);case _ProjectsListError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<ProjectDto> projects,  List<ProjectDto> allProjects,  String selectedFilter)?  loaded,TResult? Function( String selectedFilter)?  empty,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _ProjectsListInitial() when initial != null:
return initial();case _ProjectsListLoading() when loading != null:
return loading();case ProjectsListLoaded() when loaded != null:
return loaded(_that.projects,_that.allProjects,_that.selectedFilter);case _ProjectsListEmpty() when empty != null:
return empty(_that.selectedFilter);case _ProjectsListError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ProjectsListInitial implements ProjectsListState {
  const _ProjectsListInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectsListInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectsListState.initial()';
}


}




/// @nodoc


class _ProjectsListLoading implements ProjectsListState {
  const _ProjectsListLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectsListLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProjectsListState.loading()';
}


}




/// @nodoc


class ProjectsListLoaded implements ProjectsListState {
  const ProjectsListLoaded({required final  List<ProjectDto> projects, required final  List<ProjectDto> allProjects, this.selectedFilter = 'All'}): _projects = projects,_allProjects = allProjects;
  

 final  List<ProjectDto> _projects;
 List<ProjectDto> get projects {
  if (_projects is EqualUnmodifiableListView) return _projects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_projects);
}

 final  List<ProjectDto> _allProjects;
 List<ProjectDto> get allProjects {
  if (_allProjects is EqualUnmodifiableListView) return _allProjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allProjects);
}

@JsonKey() final  String selectedFilter;

/// Create a copy of ProjectsListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectsListLoadedCopyWith<ProjectsListLoaded> get copyWith => _$ProjectsListLoadedCopyWithImpl<ProjectsListLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectsListLoaded&&const DeepCollectionEquality().equals(other._projects, _projects)&&const DeepCollectionEquality().equals(other._allProjects, _allProjects)&&(identical(other.selectedFilter, selectedFilter) || other.selectedFilter == selectedFilter));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_projects),const DeepCollectionEquality().hash(_allProjects),selectedFilter);

@override
String toString() {
  return 'ProjectsListState.loaded(projects: $projects, allProjects: $allProjects, selectedFilter: $selectedFilter)';
}


}

/// @nodoc
abstract mixin class $ProjectsListLoadedCopyWith<$Res> implements $ProjectsListStateCopyWith<$Res> {
  factory $ProjectsListLoadedCopyWith(ProjectsListLoaded value, $Res Function(ProjectsListLoaded) _then) = _$ProjectsListLoadedCopyWithImpl;
@useResult
$Res call({
 List<ProjectDto> projects, List<ProjectDto> allProjects, String selectedFilter
});




}
/// @nodoc
class _$ProjectsListLoadedCopyWithImpl<$Res>
    implements $ProjectsListLoadedCopyWith<$Res> {
  _$ProjectsListLoadedCopyWithImpl(this._self, this._then);

  final ProjectsListLoaded _self;
  final $Res Function(ProjectsListLoaded) _then;

/// Create a copy of ProjectsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? projects = null,Object? allProjects = null,Object? selectedFilter = null,}) {
  return _then(ProjectsListLoaded(
projects: null == projects ? _self._projects : projects // ignore: cast_nullable_to_non_nullable
as List<ProjectDto>,allProjects: null == allProjects ? _self._allProjects : allProjects // ignore: cast_nullable_to_non_nullable
as List<ProjectDto>,selectedFilter: null == selectedFilter ? _self.selectedFilter : selectedFilter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ProjectsListEmpty implements ProjectsListState {
  const _ProjectsListEmpty({this.selectedFilter = 'All'});
  

@JsonKey() final  String selectedFilter;

/// Create a copy of ProjectsListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectsListEmptyCopyWith<_ProjectsListEmpty> get copyWith => __$ProjectsListEmptyCopyWithImpl<_ProjectsListEmpty>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectsListEmpty&&(identical(other.selectedFilter, selectedFilter) || other.selectedFilter == selectedFilter));
}


@override
int get hashCode => Object.hash(runtimeType,selectedFilter);

@override
String toString() {
  return 'ProjectsListState.empty(selectedFilter: $selectedFilter)';
}


}

/// @nodoc
abstract mixin class _$ProjectsListEmptyCopyWith<$Res> implements $ProjectsListStateCopyWith<$Res> {
  factory _$ProjectsListEmptyCopyWith(_ProjectsListEmpty value, $Res Function(_ProjectsListEmpty) _then) = __$ProjectsListEmptyCopyWithImpl;
@useResult
$Res call({
 String selectedFilter
});




}
/// @nodoc
class __$ProjectsListEmptyCopyWithImpl<$Res>
    implements _$ProjectsListEmptyCopyWith<$Res> {
  __$ProjectsListEmptyCopyWithImpl(this._self, this._then);

  final _ProjectsListEmpty _self;
  final $Res Function(_ProjectsListEmpty) _then;

/// Create a copy of ProjectsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? selectedFilter = null,}) {
  return _then(_ProjectsListEmpty(
selectedFilter: null == selectedFilter ? _self.selectedFilter : selectedFilter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ProjectsListError implements ProjectsListState {
  const _ProjectsListError(this.message);
  

 final  String message;

/// Create a copy of ProjectsListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectsListErrorCopyWith<_ProjectsListError> get copyWith => __$ProjectsListErrorCopyWithImpl<_ProjectsListError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectsListError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ProjectsListState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ProjectsListErrorCopyWith<$Res> implements $ProjectsListStateCopyWith<$Res> {
  factory _$ProjectsListErrorCopyWith(_ProjectsListError value, $Res Function(_ProjectsListError) _then) = __$ProjectsListErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ProjectsListErrorCopyWithImpl<$Res>
    implements _$ProjectsListErrorCopyWith<$Res> {
  __$ProjectsListErrorCopyWithImpl(this._self, this._then);

  final _ProjectsListError _self;
  final $Res Function(_ProjectsListError) _then;

/// Create a copy of ProjectsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_ProjectsListError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
