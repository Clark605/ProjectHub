// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comments_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommentsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CommentsState()';
}


}

/// @nodoc
class $CommentsStateCopyWith<$Res>  {
$CommentsStateCopyWith(CommentsState _, $Res Function(CommentsState) __);
}


/// Adds pattern-matching-related methods to [CommentsState].
extension CommentsStatePatterns on CommentsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _CommentsInitial value)?  initial,TResult Function( _CommentsLoading value)?  loading,TResult Function( CommentsLoaded value)?  loaded,TResult Function( _CommentsError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentsInitial() when initial != null:
return initial(_that);case _CommentsLoading() when loading != null:
return loading(_that);case CommentsLoaded() when loaded != null:
return loaded(_that);case _CommentsError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _CommentsInitial value)  initial,required TResult Function( _CommentsLoading value)  loading,required TResult Function( CommentsLoaded value)  loaded,required TResult Function( _CommentsError value)  error,}){
final _that = this;
switch (_that) {
case _CommentsInitial():
return initial(_that);case _CommentsLoading():
return loading(_that);case CommentsLoaded():
return loaded(_that);case _CommentsError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _CommentsInitial value)?  initial,TResult? Function( _CommentsLoading value)?  loading,TResult? Function( CommentsLoaded value)?  loaded,TResult? Function( _CommentsError value)?  error,}){
final _that = this;
switch (_that) {
case _CommentsInitial() when initial != null:
return initial(_that);case _CommentsLoading() when loading != null:
return loading(_that);case CommentsLoaded() when loaded != null:
return loaded(_that);case _CommentsError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<CommentDto> comments,  bool isSending,  String? errorMessage)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentsInitial() when initial != null:
return initial();case _CommentsLoading() when loading != null:
return loading();case CommentsLoaded() when loaded != null:
return loaded(_that.comments,_that.isSending,_that.errorMessage);case _CommentsError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<CommentDto> comments,  bool isSending,  String? errorMessage)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _CommentsInitial():
return initial();case _CommentsLoading():
return loading();case CommentsLoaded():
return loaded(_that.comments,_that.isSending,_that.errorMessage);case _CommentsError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<CommentDto> comments,  bool isSending,  String? errorMessage)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _CommentsInitial() when initial != null:
return initial();case _CommentsLoading() when loading != null:
return loading();case CommentsLoaded() when loaded != null:
return loaded(_that.comments,_that.isSending,_that.errorMessage);case _CommentsError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _CommentsInitial implements CommentsState {
  const _CommentsInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentsInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CommentsState.initial()';
}


}




/// @nodoc


class _CommentsLoading implements CommentsState {
  const _CommentsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CommentsState.loading()';
}


}




/// @nodoc


class CommentsLoaded implements CommentsState {
  const CommentsLoaded({required final  List<CommentDto> comments, this.isSending = false, this.errorMessage}): _comments = comments;
  

 final  List<CommentDto> _comments;
 List<CommentDto> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

@JsonKey() final  bool isSending;
 final  String? errorMessage;

/// Create a copy of CommentsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentsLoadedCopyWith<CommentsLoaded> get copyWith => _$CommentsLoadedCopyWithImpl<CommentsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentsLoaded&&const DeepCollectionEquality().equals(other._comments, _comments)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_comments),isSending,errorMessage);

@override
String toString() {
  return 'CommentsState.loaded(comments: $comments, isSending: $isSending, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $CommentsLoadedCopyWith<$Res> implements $CommentsStateCopyWith<$Res> {
  factory $CommentsLoadedCopyWith(CommentsLoaded value, $Res Function(CommentsLoaded) _then) = _$CommentsLoadedCopyWithImpl;
@useResult
$Res call({
 List<CommentDto> comments, bool isSending, String? errorMessage
});




}
/// @nodoc
class _$CommentsLoadedCopyWithImpl<$Res>
    implements $CommentsLoadedCopyWith<$Res> {
  _$CommentsLoadedCopyWithImpl(this._self, this._then);

  final CommentsLoaded _self;
  final $Res Function(CommentsLoaded) _then;

/// Create a copy of CommentsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? comments = null,Object? isSending = null,Object? errorMessage = freezed,}) {
  return _then(CommentsLoaded(
comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<CommentDto>,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _CommentsError implements CommentsState {
  const _CommentsError(this.message);
  

 final  String message;

/// Create a copy of CommentsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentsErrorCopyWith<_CommentsError> get copyWith => __$CommentsErrorCopyWithImpl<_CommentsError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentsError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CommentsState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$CommentsErrorCopyWith<$Res> implements $CommentsStateCopyWith<$Res> {
  factory _$CommentsErrorCopyWith(_CommentsError value, $Res Function(_CommentsError) _then) = __$CommentsErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$CommentsErrorCopyWithImpl<$Res>
    implements _$CommentsErrorCopyWith<$Res> {
  __$CommentsErrorCopyWithImpl(this._self, this._then);

  final _CommentsError _self;
  final $Res Function(_CommentsError) _then;

/// Create a copy of CommentsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_CommentsError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
