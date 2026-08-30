// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppAuthState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppAuthState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppAuthState()';
}


}

/// @nodoc
class $AppAuthStateCopyWith<$Res>  {
$AppAuthStateCopyWith(AppAuthState _, $Res Function(AppAuthState) __);
}


/// Adds pattern-matching-related methods to [AppAuthState].
extension AppAuthStatePatterns on AppAuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _AppAuthInitial value)?  initial,TResult Function( _AppAuthAuthenticated value)?  authenticated,TResult Function( _AppAuthUnauthenticated value)?  unauthenticated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppAuthInitial() when initial != null:
return initial(_that);case _AppAuthAuthenticated() when authenticated != null:
return authenticated(_that);case _AppAuthUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _AppAuthInitial value)  initial,required TResult Function( _AppAuthAuthenticated value)  authenticated,required TResult Function( _AppAuthUnauthenticated value)  unauthenticated,}){
final _that = this;
switch (_that) {
case _AppAuthInitial():
return initial(_that);case _AppAuthAuthenticated():
return authenticated(_that);case _AppAuthUnauthenticated():
return unauthenticated(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _AppAuthInitial value)?  initial,TResult? Function( _AppAuthAuthenticated value)?  authenticated,TResult? Function( _AppAuthUnauthenticated value)?  unauthenticated,}){
final _that = this;
switch (_that) {
case _AppAuthInitial() when initial != null:
return initial(_that);case _AppAuthAuthenticated() when authenticated != null:
return authenticated(_that);case _AppAuthUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( User user)?  authenticated,TResult Function()?  unauthenticated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppAuthInitial() when initial != null:
return initial();case _AppAuthAuthenticated() when authenticated != null:
return authenticated(_that.user);case _AppAuthUnauthenticated() when unauthenticated != null:
return unauthenticated();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( User user)  authenticated,required TResult Function()  unauthenticated,}) {final _that = this;
switch (_that) {
case _AppAuthInitial():
return initial();case _AppAuthAuthenticated():
return authenticated(_that.user);case _AppAuthUnauthenticated():
return unauthenticated();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( User user)?  authenticated,TResult? Function()?  unauthenticated,}) {final _that = this;
switch (_that) {
case _AppAuthInitial() when initial != null:
return initial();case _AppAuthAuthenticated() when authenticated != null:
return authenticated(_that.user);case _AppAuthUnauthenticated() when unauthenticated != null:
return unauthenticated();case _:
  return null;

}
}

}

/// @nodoc


class _AppAuthInitial implements AppAuthState {
  const _AppAuthInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppAuthInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppAuthState.initial()';
}


}




/// @nodoc


class _AppAuthAuthenticated implements AppAuthState {
  const _AppAuthAuthenticated(this.user);
  

 final  User user;

/// Create a copy of AppAuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppAuthAuthenticatedCopyWith<_AppAuthAuthenticated> get copyWith => __$AppAuthAuthenticatedCopyWithImpl<_AppAuthAuthenticated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppAuthAuthenticated&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,user);

@override
String toString() {
  return 'AppAuthState.authenticated(user: $user)';
}


}

/// @nodoc
abstract mixin class _$AppAuthAuthenticatedCopyWith<$Res> implements $AppAuthStateCopyWith<$Res> {
  factory _$AppAuthAuthenticatedCopyWith(_AppAuthAuthenticated value, $Res Function(_AppAuthAuthenticated) _then) = __$AppAuthAuthenticatedCopyWithImpl;
@useResult
$Res call({
 User user
});


$UserCopyWith<$Res> get user;

}
/// @nodoc
class __$AppAuthAuthenticatedCopyWithImpl<$Res>
    implements _$AppAuthAuthenticatedCopyWith<$Res> {
  __$AppAuthAuthenticatedCopyWithImpl(this._self, this._then);

  final _AppAuthAuthenticated _self;
  final $Res Function(_AppAuthAuthenticated) _then;

/// Create a copy of AppAuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,}) {
  return _then(_AppAuthAuthenticated(
null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,
  ));
}

/// Create a copy of AppAuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

/// @nodoc


class _AppAuthUnauthenticated implements AppAuthState {
  const _AppAuthUnauthenticated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppAuthUnauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppAuthState.unauthenticated()';
}


}




// dart format on
