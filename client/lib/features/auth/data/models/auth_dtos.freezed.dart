// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginDto {

 String get email; String get password;
/// Create a copy of LoginDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginDtoCopyWith<LoginDto> get copyWith => _$LoginDtoCopyWithImpl<LoginDto>(this as LoginDto, _$identity);

  /// Serializes this LoginDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginDto&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'LoginDto(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class $LoginDtoCopyWith<$Res>  {
  factory $LoginDtoCopyWith(LoginDto value, $Res Function(LoginDto) _then) = _$LoginDtoCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class _$LoginDtoCopyWithImpl<$Res>
    implements $LoginDtoCopyWith<$Res> {
  _$LoginDtoCopyWithImpl(this._self, this._then);

  final LoginDto _self;
  final $Res Function(LoginDto) _then;

/// Create a copy of LoginDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginDto].
extension LoginDtoPatterns on LoginDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginDto value)  $default,){
final _that = this;
switch (_that) {
case _LoginDto():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginDto value)?  $default,){
final _that = this;
switch (_that) {
case _LoginDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginDto() when $default != null:
return $default(_that.email,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password)  $default,) {final _that = this;
switch (_that) {
case _LoginDto():
return $default(_that.email,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password)?  $default,) {final _that = this;
switch (_that) {
case _LoginDto() when $default != null:
return $default(_that.email,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginDto implements LoginDto {
  const _LoginDto({required this.email, required this.password});
  factory _LoginDto.fromJson(Map<String, dynamic> json) => _$LoginDtoFromJson(json);

@override final  String email;
@override final  String password;

/// Create a copy of LoginDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginDtoCopyWith<_LoginDto> get copyWith => __$LoginDtoCopyWithImpl<_LoginDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginDto&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'LoginDto(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class _$LoginDtoCopyWith<$Res> implements $LoginDtoCopyWith<$Res> {
  factory _$LoginDtoCopyWith(_LoginDto value, $Res Function(_LoginDto) _then) = __$LoginDtoCopyWithImpl;
@override @useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class __$LoginDtoCopyWithImpl<$Res>
    implements _$LoginDtoCopyWith<$Res> {
  __$LoginDtoCopyWithImpl(this._self, this._then);

  final _LoginDto _self;
  final $Res Function(_LoginDto) _then;

/// Create a copy of LoginDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(_LoginDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RegisterDto {

 String get name; String get email; String get password;
/// Create a copy of RegisterDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterDtoCopyWith<RegisterDto> get copyWith => _$RegisterDtoCopyWithImpl<RegisterDto>(this as RegisterDto, _$identity);

  /// Serializes this RegisterDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterDto&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,password);

@override
String toString() {
  return 'RegisterDto(name: $name, email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class $RegisterDtoCopyWith<$Res>  {
  factory $RegisterDtoCopyWith(RegisterDto value, $Res Function(RegisterDto) _then) = _$RegisterDtoCopyWithImpl;
@useResult
$Res call({
 String name, String email, String password
});




}
/// @nodoc
class _$RegisterDtoCopyWithImpl<$Res>
    implements $RegisterDtoCopyWith<$Res> {
  _$RegisterDtoCopyWithImpl(this._self, this._then);

  final RegisterDto _self;
  final $Res Function(RegisterDto) _then;

/// Create a copy of RegisterDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? email = null,Object? password = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterDto].
extension RegisterDtoPatterns on RegisterDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterDto value)  $default,){
final _that = this;
switch (_that) {
case _RegisterDto():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterDto value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String email,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterDto() when $default != null:
return $default(_that.name,_that.email,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String email,  String password)  $default,) {final _that = this;
switch (_that) {
case _RegisterDto():
return $default(_that.name,_that.email,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String email,  String password)?  $default,) {final _that = this;
switch (_that) {
case _RegisterDto() when $default != null:
return $default(_that.name,_that.email,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterDto implements RegisterDto {
  const _RegisterDto({required this.name, required this.email, required this.password});
  factory _RegisterDto.fromJson(Map<String, dynamic> json) => _$RegisterDtoFromJson(json);

@override final  String name;
@override final  String email;
@override final  String password;

/// Create a copy of RegisterDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterDtoCopyWith<_RegisterDto> get copyWith => __$RegisterDtoCopyWithImpl<_RegisterDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterDto&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,password);

@override
String toString() {
  return 'RegisterDto(name: $name, email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class _$RegisterDtoCopyWith<$Res> implements $RegisterDtoCopyWith<$Res> {
  factory _$RegisterDtoCopyWith(_RegisterDto value, $Res Function(_RegisterDto) _then) = __$RegisterDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, String email, String password
});




}
/// @nodoc
class __$RegisterDtoCopyWithImpl<$Res>
    implements _$RegisterDtoCopyWith<$Res> {
  __$RegisterDtoCopyWithImpl(this._self, this._then);

  final _RegisterDto _self;
  final $Res Function(_RegisterDto) _then;

/// Create a copy of RegisterDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? email = null,Object? password = null,}) {
  return _then(_RegisterDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AuthResponseDto {

 String get token; String get refreshToken;
/// Create a copy of AuthResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthResponseDtoCopyWith<AuthResponseDto> get copyWith => _$AuthResponseDtoCopyWithImpl<AuthResponseDto>(this as AuthResponseDto, _$identity);

  /// Serializes this AuthResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthResponseDto&&(identical(other.token, token) || other.token == token)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,refreshToken);

@override
String toString() {
  return 'AuthResponseDto(token: $token, refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class $AuthResponseDtoCopyWith<$Res>  {
  factory $AuthResponseDtoCopyWith(AuthResponseDto value, $Res Function(AuthResponseDto) _then) = _$AuthResponseDtoCopyWithImpl;
@useResult
$Res call({
 String token, String refreshToken
});




}
/// @nodoc
class _$AuthResponseDtoCopyWithImpl<$Res>
    implements $AuthResponseDtoCopyWith<$Res> {
  _$AuthResponseDtoCopyWithImpl(this._self, this._then);

  final AuthResponseDto _self;
  final $Res Function(AuthResponseDto) _then;

/// Create a copy of AuthResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? refreshToken = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthResponseDto].
extension AuthResponseDtoPatterns on AuthResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthResponseDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _AuthResponseDto():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuthResponseDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthResponseDto() when $default != null:
return $default(_that.token,_that.refreshToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String refreshToken)  $default,) {final _that = this;
switch (_that) {
case _AuthResponseDto():
return $default(_that.token,_that.refreshToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _AuthResponseDto() when $default != null:
return $default(_that.token,_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthResponseDto implements AuthResponseDto {
  const _AuthResponseDto({required this.token, required this.refreshToken});
  factory _AuthResponseDto.fromJson(Map<String, dynamic> json) => _$AuthResponseDtoFromJson(json);

@override final  String token;
@override final  String refreshToken;

/// Create a copy of AuthResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthResponseDtoCopyWith<_AuthResponseDto> get copyWith => __$AuthResponseDtoCopyWithImpl<_AuthResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthResponseDto&&(identical(other.token, token) || other.token == token)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,refreshToken);

@override
String toString() {
  return 'AuthResponseDto(token: $token, refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$AuthResponseDtoCopyWith<$Res> implements $AuthResponseDtoCopyWith<$Res> {
  factory _$AuthResponseDtoCopyWith(_AuthResponseDto value, $Res Function(_AuthResponseDto) _then) = __$AuthResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String token, String refreshToken
});




}
/// @nodoc
class __$AuthResponseDtoCopyWithImpl<$Res>
    implements _$AuthResponseDtoCopyWith<$Res> {
  __$AuthResponseDtoCopyWithImpl(this._self, this._then);

  final _AuthResponseDto _self;
  final $Res Function(_AuthResponseDto) _then;

/// Create a copy of AuthResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? refreshToken = null,}) {
  return _then(_AuthResponseDto(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ForgotPasswordDto {

 String get email;
/// Create a copy of ForgotPasswordDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForgotPasswordDtoCopyWith<ForgotPasswordDto> get copyWith => _$ForgotPasswordDtoCopyWithImpl<ForgotPasswordDto>(this as ForgotPasswordDto, _$identity);

  /// Serializes this ForgotPasswordDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgotPasswordDto&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'ForgotPasswordDto(email: $email)';
}


}

/// @nodoc
abstract mixin class $ForgotPasswordDtoCopyWith<$Res>  {
  factory $ForgotPasswordDtoCopyWith(ForgotPasswordDto value, $Res Function(ForgotPasswordDto) _then) = _$ForgotPasswordDtoCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$ForgotPasswordDtoCopyWithImpl<$Res>
    implements $ForgotPasswordDtoCopyWith<$Res> {
  _$ForgotPasswordDtoCopyWithImpl(this._self, this._then);

  final ForgotPasswordDto _self;
  final $Res Function(ForgotPasswordDto) _then;

/// Create a copy of ForgotPasswordDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ForgotPasswordDto].
extension ForgotPasswordDtoPatterns on ForgotPasswordDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForgotPasswordDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForgotPasswordDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForgotPasswordDto value)  $default,){
final _that = this;
switch (_that) {
case _ForgotPasswordDto():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForgotPasswordDto value)?  $default,){
final _that = this;
switch (_that) {
case _ForgotPasswordDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForgotPasswordDto() when $default != null:
return $default(_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email)  $default,) {final _that = this;
switch (_that) {
case _ForgotPasswordDto():
return $default(_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email)?  $default,) {final _that = this;
switch (_that) {
case _ForgotPasswordDto() when $default != null:
return $default(_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForgotPasswordDto implements ForgotPasswordDto {
  const _ForgotPasswordDto({required this.email});
  factory _ForgotPasswordDto.fromJson(Map<String, dynamic> json) => _$ForgotPasswordDtoFromJson(json);

@override final  String email;

/// Create a copy of ForgotPasswordDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForgotPasswordDtoCopyWith<_ForgotPasswordDto> get copyWith => __$ForgotPasswordDtoCopyWithImpl<_ForgotPasswordDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForgotPasswordDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForgotPasswordDto&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'ForgotPasswordDto(email: $email)';
}


}

/// @nodoc
abstract mixin class _$ForgotPasswordDtoCopyWith<$Res> implements $ForgotPasswordDtoCopyWith<$Res> {
  factory _$ForgotPasswordDtoCopyWith(_ForgotPasswordDto value, $Res Function(_ForgotPasswordDto) _then) = __$ForgotPasswordDtoCopyWithImpl;
@override @useResult
$Res call({
 String email
});




}
/// @nodoc
class __$ForgotPasswordDtoCopyWithImpl<$Res>
    implements _$ForgotPasswordDtoCopyWith<$Res> {
  __$ForgotPasswordDtoCopyWithImpl(this._self, this._then);

  final _ForgotPasswordDto _self;
  final $Res Function(_ForgotPasswordDto) _then;

/// Create a copy of ForgotPasswordDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(_ForgotPasswordDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ForgotPasswordResponseDto {

 String get message; String? get developmentResetToken;
/// Create a copy of ForgotPasswordResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForgotPasswordResponseDtoCopyWith<ForgotPasswordResponseDto> get copyWith => _$ForgotPasswordResponseDtoCopyWithImpl<ForgotPasswordResponseDto>(this as ForgotPasswordResponseDto, _$identity);

  /// Serializes this ForgotPasswordResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgotPasswordResponseDto&&(identical(other.message, message) || other.message == message)&&(identical(other.developmentResetToken, developmentResetToken) || other.developmentResetToken == developmentResetToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,developmentResetToken);

@override
String toString() {
  return 'ForgotPasswordResponseDto(message: $message, developmentResetToken: $developmentResetToken)';
}


}

/// @nodoc
abstract mixin class $ForgotPasswordResponseDtoCopyWith<$Res>  {
  factory $ForgotPasswordResponseDtoCopyWith(ForgotPasswordResponseDto value, $Res Function(ForgotPasswordResponseDto) _then) = _$ForgotPasswordResponseDtoCopyWithImpl;
@useResult
$Res call({
 String message, String? developmentResetToken
});




}
/// @nodoc
class _$ForgotPasswordResponseDtoCopyWithImpl<$Res>
    implements $ForgotPasswordResponseDtoCopyWith<$Res> {
  _$ForgotPasswordResponseDtoCopyWithImpl(this._self, this._then);

  final ForgotPasswordResponseDto _self;
  final $Res Function(ForgotPasswordResponseDto) _then;

/// Create a copy of ForgotPasswordResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? developmentResetToken = freezed,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,developmentResetToken: freezed == developmentResetToken ? _self.developmentResetToken : developmentResetToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ForgotPasswordResponseDto].
extension ForgotPasswordResponseDtoPatterns on ForgotPasswordResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForgotPasswordResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForgotPasswordResponseDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForgotPasswordResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _ForgotPasswordResponseDto():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForgotPasswordResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ForgotPasswordResponseDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  String? developmentResetToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForgotPasswordResponseDto() when $default != null:
return $default(_that.message,_that.developmentResetToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  String? developmentResetToken)  $default,) {final _that = this;
switch (_that) {
case _ForgotPasswordResponseDto():
return $default(_that.message,_that.developmentResetToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  String? developmentResetToken)?  $default,) {final _that = this;
switch (_that) {
case _ForgotPasswordResponseDto() when $default != null:
return $default(_that.message,_that.developmentResetToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForgotPasswordResponseDto implements ForgotPasswordResponseDto {
  const _ForgotPasswordResponseDto({required this.message, this.developmentResetToken});
  factory _ForgotPasswordResponseDto.fromJson(Map<String, dynamic> json) => _$ForgotPasswordResponseDtoFromJson(json);

@override final  String message;
@override final  String? developmentResetToken;

/// Create a copy of ForgotPasswordResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForgotPasswordResponseDtoCopyWith<_ForgotPasswordResponseDto> get copyWith => __$ForgotPasswordResponseDtoCopyWithImpl<_ForgotPasswordResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForgotPasswordResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForgotPasswordResponseDto&&(identical(other.message, message) || other.message == message)&&(identical(other.developmentResetToken, developmentResetToken) || other.developmentResetToken == developmentResetToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,developmentResetToken);

@override
String toString() {
  return 'ForgotPasswordResponseDto(message: $message, developmentResetToken: $developmentResetToken)';
}


}

/// @nodoc
abstract mixin class _$ForgotPasswordResponseDtoCopyWith<$Res> implements $ForgotPasswordResponseDtoCopyWith<$Res> {
  factory _$ForgotPasswordResponseDtoCopyWith(_ForgotPasswordResponseDto value, $Res Function(_ForgotPasswordResponseDto) _then) = __$ForgotPasswordResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 String message, String? developmentResetToken
});




}
/// @nodoc
class __$ForgotPasswordResponseDtoCopyWithImpl<$Res>
    implements _$ForgotPasswordResponseDtoCopyWith<$Res> {
  __$ForgotPasswordResponseDtoCopyWithImpl(this._self, this._then);

  final _ForgotPasswordResponseDto _self;
  final $Res Function(_ForgotPasswordResponseDto) _then;

/// Create a copy of ForgotPasswordResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? developmentResetToken = freezed,}) {
  return _then(_ForgotPasswordResponseDto(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,developmentResetToken: freezed == developmentResetToken ? _self.developmentResetToken : developmentResetToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ResetPasswordDto {

 String get email; String get token; String get newPassword;
/// Create a copy of ResetPasswordDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResetPasswordDtoCopyWith<ResetPasswordDto> get copyWith => _$ResetPasswordDtoCopyWithImpl<ResetPasswordDto>(this as ResetPasswordDto, _$identity);

  /// Serializes this ResetPasswordDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResetPasswordDto&&(identical(other.email, email) || other.email == email)&&(identical(other.token, token) || other.token == token)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,token,newPassword);

@override
String toString() {
  return 'ResetPasswordDto(email: $email, token: $token, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class $ResetPasswordDtoCopyWith<$Res>  {
  factory $ResetPasswordDtoCopyWith(ResetPasswordDto value, $Res Function(ResetPasswordDto) _then) = _$ResetPasswordDtoCopyWithImpl;
@useResult
$Res call({
 String email, String token, String newPassword
});




}
/// @nodoc
class _$ResetPasswordDtoCopyWithImpl<$Res>
    implements $ResetPasswordDtoCopyWith<$Res> {
  _$ResetPasswordDtoCopyWithImpl(this._self, this._then);

  final ResetPasswordDto _self;
  final $Res Function(ResetPasswordDto) _then;

/// Create a copy of ResetPasswordDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? token = null,Object? newPassword = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ResetPasswordDto].
extension ResetPasswordDtoPatterns on ResetPasswordDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResetPasswordDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResetPasswordDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResetPasswordDto value)  $default,){
final _that = this;
switch (_that) {
case _ResetPasswordDto():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResetPasswordDto value)?  $default,){
final _that = this;
switch (_that) {
case _ResetPasswordDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String token,  String newPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResetPasswordDto() when $default != null:
return $default(_that.email,_that.token,_that.newPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String token,  String newPassword)  $default,) {final _that = this;
switch (_that) {
case _ResetPasswordDto():
return $default(_that.email,_that.token,_that.newPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String token,  String newPassword)?  $default,) {final _that = this;
switch (_that) {
case _ResetPasswordDto() when $default != null:
return $default(_that.email,_that.token,_that.newPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResetPasswordDto implements ResetPasswordDto {
  const _ResetPasswordDto({required this.email, required this.token, required this.newPassword});
  factory _ResetPasswordDto.fromJson(Map<String, dynamic> json) => _$ResetPasswordDtoFromJson(json);

@override final  String email;
@override final  String token;
@override final  String newPassword;

/// Create a copy of ResetPasswordDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResetPasswordDtoCopyWith<_ResetPasswordDto> get copyWith => __$ResetPasswordDtoCopyWithImpl<_ResetPasswordDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResetPasswordDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetPasswordDto&&(identical(other.email, email) || other.email == email)&&(identical(other.token, token) || other.token == token)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,token,newPassword);

@override
String toString() {
  return 'ResetPasswordDto(email: $email, token: $token, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class _$ResetPasswordDtoCopyWith<$Res> implements $ResetPasswordDtoCopyWith<$Res> {
  factory _$ResetPasswordDtoCopyWith(_ResetPasswordDto value, $Res Function(_ResetPasswordDto) _then) = __$ResetPasswordDtoCopyWithImpl;
@override @useResult
$Res call({
 String email, String token, String newPassword
});




}
/// @nodoc
class __$ResetPasswordDtoCopyWithImpl<$Res>
    implements _$ResetPasswordDtoCopyWith<$Res> {
  __$ResetPasswordDtoCopyWithImpl(this._self, this._then);

  final _ResetPasswordDto _self;
  final $Res Function(_ResetPasswordDto) _then;

/// Create a copy of ResetPasswordDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? token = null,Object? newPassword = null,}) {
  return _then(_ResetPasswordDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LogoutDto {

 String get refreshToken;
/// Create a copy of LogoutDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogoutDtoCopyWith<LogoutDto> get copyWith => _$LogoutDtoCopyWithImpl<LogoutDto>(this as LogoutDto, _$identity);

  /// Serializes this LogoutDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogoutDto&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'LogoutDto(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class $LogoutDtoCopyWith<$Res>  {
  factory $LogoutDtoCopyWith(LogoutDto value, $Res Function(LogoutDto) _then) = _$LogoutDtoCopyWithImpl;
@useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class _$LogoutDtoCopyWithImpl<$Res>
    implements $LogoutDtoCopyWith<$Res> {
  _$LogoutDtoCopyWithImpl(this._self, this._then);

  final LogoutDto _self;
  final $Res Function(LogoutDto) _then;

/// Create a copy of LogoutDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refreshToken = null,}) {
  return _then(_self.copyWith(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LogoutDto].
extension LogoutDtoPatterns on LogoutDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogoutDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogoutDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogoutDto value)  $default,){
final _that = this;
switch (_that) {
case _LogoutDto():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogoutDto value)?  $default,){
final _that = this;
switch (_that) {
case _LogoutDto() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogoutDto() when $default != null:
return $default(_that.refreshToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String refreshToken)  $default,) {final _that = this;
switch (_that) {
case _LogoutDto():
return $default(_that.refreshToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _LogoutDto() when $default != null:
return $default(_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LogoutDto implements LogoutDto {
  const _LogoutDto({required this.refreshToken});
  factory _LogoutDto.fromJson(Map<String, dynamic> json) => _$LogoutDtoFromJson(json);

@override final  String refreshToken;

/// Create a copy of LogoutDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogoutDtoCopyWith<_LogoutDto> get copyWith => __$LogoutDtoCopyWithImpl<_LogoutDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LogoutDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogoutDto&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'LogoutDto(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$LogoutDtoCopyWith<$Res> implements $LogoutDtoCopyWith<$Res> {
  factory _$LogoutDtoCopyWith(_LogoutDto value, $Res Function(_LogoutDto) _then) = __$LogoutDtoCopyWithImpl;
@override @useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class __$LogoutDtoCopyWithImpl<$Res>
    implements _$LogoutDtoCopyWith<$Res> {
  __$LogoutDtoCopyWithImpl(this._self, this._then);

  final _LogoutDto _self;
  final $Res Function(_LogoutDto) _then;

/// Create a copy of LogoutDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refreshToken = null,}) {
  return _then(_LogoutDto(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
