// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reset_password_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResetPasswordState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResetPasswordState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ResetPasswordState()';
}


}

/// @nodoc
class $ResetPasswordStateCopyWith<$Res>  {
$ResetPasswordStateCopyWith(ResetPasswordState _, $Res Function(ResetPasswordState) __);
}


/// Adds pattern-matching-related methods to [ResetPasswordState].
extension ResetPasswordStatePatterns on ResetPasswordState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ResetPasswordInitial value)?  initial,TResult Function( _ResetPasswordLoading value)?  loading,TResult Function( _ResetPasswordSuccess value)?  success,TResult Function( _ResetPasswordFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResetPasswordInitial() when initial != null:
return initial(_that);case _ResetPasswordLoading() when loading != null:
return loading(_that);case _ResetPasswordSuccess() when success != null:
return success(_that);case _ResetPasswordFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ResetPasswordInitial value)  initial,required TResult Function( _ResetPasswordLoading value)  loading,required TResult Function( _ResetPasswordSuccess value)  success,required TResult Function( _ResetPasswordFailure value)  failure,}){
final _that = this;
switch (_that) {
case _ResetPasswordInitial():
return initial(_that);case _ResetPasswordLoading():
return loading(_that);case _ResetPasswordSuccess():
return success(_that);case _ResetPasswordFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ResetPasswordInitial value)?  initial,TResult? Function( _ResetPasswordLoading value)?  loading,TResult? Function( _ResetPasswordSuccess value)?  success,TResult? Function( _ResetPasswordFailure value)?  failure,}){
final _that = this;
switch (_that) {
case _ResetPasswordInitial() when initial != null:
return initial(_that);case _ResetPasswordLoading() when loading != null:
return loading(_that);case _ResetPasswordSuccess() when success != null:
return success(_that);case _ResetPasswordFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  success,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResetPasswordInitial() when initial != null:
return initial();case _ResetPasswordLoading() when loading != null:
return loading();case _ResetPasswordSuccess() when success != null:
return success();case _ResetPasswordFailure() when failure != null:
return failure(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  success,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case _ResetPasswordInitial():
return initial();case _ResetPasswordLoading():
return loading();case _ResetPasswordSuccess():
return success();case _ResetPasswordFailure():
return failure(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case _ResetPasswordInitial() when initial != null:
return initial();case _ResetPasswordLoading() when loading != null:
return loading();case _ResetPasswordSuccess() when success != null:
return success();case _ResetPasswordFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ResetPasswordInitial implements ResetPasswordState {
  const _ResetPasswordInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetPasswordInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ResetPasswordState.initial()';
}


}




/// @nodoc


class _ResetPasswordLoading implements ResetPasswordState {
  const _ResetPasswordLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetPasswordLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ResetPasswordState.loading()';
}


}




/// @nodoc


class _ResetPasswordSuccess implements ResetPasswordState {
  const _ResetPasswordSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetPasswordSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ResetPasswordState.success()';
}


}




/// @nodoc


class _ResetPasswordFailure implements ResetPasswordState {
  const _ResetPasswordFailure(this.message);
  

 final  String message;

/// Create a copy of ResetPasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResetPasswordFailureCopyWith<_ResetPasswordFailure> get copyWith => __$ResetPasswordFailureCopyWithImpl<_ResetPasswordFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetPasswordFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ResetPasswordState.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ResetPasswordFailureCopyWith<$Res> implements $ResetPasswordStateCopyWith<$Res> {
  factory _$ResetPasswordFailureCopyWith(_ResetPasswordFailure value, $Res Function(_ResetPasswordFailure) _then) = __$ResetPasswordFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ResetPasswordFailureCopyWithImpl<$Res>
    implements _$ResetPasswordFailureCopyWith<$Res> {
  __$ResetPasswordFailureCopyWithImpl(this._self, this._then);

  final _ResetPasswordFailure _self;
  final $Res Function(_ResetPasswordFailure) _then;

/// Create a copy of ResetPasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_ResetPasswordFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
