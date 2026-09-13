// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkspaceMembershipDto {

 String get role; DateTime? get joinedAt;
/// Create a copy of WorkspaceMembershipDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceMembershipDtoCopyWith<WorkspaceMembershipDto> get copyWith => _$WorkspaceMembershipDtoCopyWithImpl<WorkspaceMembershipDto>(this as WorkspaceMembershipDto, _$identity);

  /// Serializes this WorkspaceMembershipDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceMembershipDto&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,joinedAt);

@override
String toString() {
  return 'WorkspaceMembershipDto(role: $role, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $WorkspaceMembershipDtoCopyWith<$Res>  {
  factory $WorkspaceMembershipDtoCopyWith(WorkspaceMembershipDto value, $Res Function(WorkspaceMembershipDto) _then) = _$WorkspaceMembershipDtoCopyWithImpl;
@useResult
$Res call({
 String role, DateTime? joinedAt
});




}
/// @nodoc
class _$WorkspaceMembershipDtoCopyWithImpl<$Res>
    implements $WorkspaceMembershipDtoCopyWith<$Res> {
  _$WorkspaceMembershipDtoCopyWithImpl(this._self, this._then);

  final WorkspaceMembershipDto _self;
  final $Res Function(WorkspaceMembershipDto) _then;

/// Create a copy of WorkspaceMembershipDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? joinedAt = freezed,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceMembershipDto].
extension WorkspaceMembershipDtoPatterns on WorkspaceMembershipDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceMembershipDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceMembershipDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceMembershipDto value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceMembershipDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceMembershipDto value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceMembershipDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String role,  DateTime? joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceMembershipDto() when $default != null:
return $default(_that.role,_that.joinedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String role,  DateTime? joinedAt)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceMembershipDto():
return $default(_that.role,_that.joinedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String role,  DateTime? joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceMembershipDto() when $default != null:
return $default(_that.role,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkspaceMembershipDto implements WorkspaceMembershipDto {
  const _WorkspaceMembershipDto({required this.role, this.joinedAt});
  factory _WorkspaceMembershipDto.fromJson(Map<String, dynamic> json) => _$WorkspaceMembershipDtoFromJson(json);

@override final  String role;
@override final  DateTime? joinedAt;

/// Create a copy of WorkspaceMembershipDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceMembershipDtoCopyWith<_WorkspaceMembershipDto> get copyWith => __$WorkspaceMembershipDtoCopyWithImpl<_WorkspaceMembershipDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkspaceMembershipDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceMembershipDto&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,role,joinedAt);

@override
String toString() {
  return 'WorkspaceMembershipDto(role: $role, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceMembershipDtoCopyWith<$Res> implements $WorkspaceMembershipDtoCopyWith<$Res> {
  factory _$WorkspaceMembershipDtoCopyWith(_WorkspaceMembershipDto value, $Res Function(_WorkspaceMembershipDto) _then) = __$WorkspaceMembershipDtoCopyWithImpl;
@override @useResult
$Res call({
 String role, DateTime? joinedAt
});




}
/// @nodoc
class __$WorkspaceMembershipDtoCopyWithImpl<$Res>
    implements _$WorkspaceMembershipDtoCopyWith<$Res> {
  __$WorkspaceMembershipDtoCopyWithImpl(this._self, this._then);

  final _WorkspaceMembershipDto _self;
  final $Res Function(_WorkspaceMembershipDto) _then;

/// Create a copy of WorkspaceMembershipDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? joinedAt = freezed,}) {
  return _then(_WorkspaceMembershipDto(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$WorkspaceDto {

 int get id; String get name; String get description; String get accentColor; WorkspaceMembershipDto? get membership;
/// Create a copy of WorkspaceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceDtoCopyWith<WorkspaceDto> get copyWith => _$WorkspaceDtoCopyWithImpl<WorkspaceDto>(this as WorkspaceDto, _$identity);

  /// Serializes this WorkspaceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.membership, membership) || other.membership == membership));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,accentColor,membership);

@override
String toString() {
  return 'WorkspaceDto(id: $id, name: $name, description: $description, accentColor: $accentColor, membership: $membership)';
}


}

/// @nodoc
abstract mixin class $WorkspaceDtoCopyWith<$Res>  {
  factory $WorkspaceDtoCopyWith(WorkspaceDto value, $Res Function(WorkspaceDto) _then) = _$WorkspaceDtoCopyWithImpl;
@useResult
$Res call({
 int id, String name, String description, String accentColor, WorkspaceMembershipDto? membership
});


$WorkspaceMembershipDtoCopyWith<$Res>? get membership;

}
/// @nodoc
class _$WorkspaceDtoCopyWithImpl<$Res>
    implements $WorkspaceDtoCopyWith<$Res> {
  _$WorkspaceDtoCopyWithImpl(this._self, this._then);

  final WorkspaceDto _self;
  final $Res Function(WorkspaceDto) _then;

/// Create a copy of WorkspaceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? accentColor = null,Object? membership = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as String,membership: freezed == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as WorkspaceMembershipDto?,
  ));
}
/// Create a copy of WorkspaceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkspaceMembershipDtoCopyWith<$Res>? get membership {
    if (_self.membership == null) {
    return null;
  }

  return $WorkspaceMembershipDtoCopyWith<$Res>(_self.membership!, (value) {
    return _then(_self.copyWith(membership: value));
  });
}
}


/// Adds pattern-matching-related methods to [WorkspaceDto].
extension WorkspaceDtoPatterns on WorkspaceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceDto value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceDto value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String description,  String accentColor,  WorkspaceMembershipDto? membership)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.accentColor,_that.membership);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String description,  String accentColor,  WorkspaceMembershipDto? membership)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceDto():
return $default(_that.id,_that.name,_that.description,_that.accentColor,_that.membership);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String description,  String accentColor,  WorkspaceMembershipDto? membership)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceDto() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.accentColor,_that.membership);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkspaceDto implements WorkspaceDto {
  const _WorkspaceDto({required this.id, required this.name, this.description = '', this.accentColor = 'teal', this.membership});
  factory _WorkspaceDto.fromJson(Map<String, dynamic> json) => _$WorkspaceDtoFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  String accentColor;
@override final  WorkspaceMembershipDto? membership;

/// Create a copy of WorkspaceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceDtoCopyWith<_WorkspaceDto> get copyWith => __$WorkspaceDtoCopyWithImpl<_WorkspaceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkspaceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.membership, membership) || other.membership == membership));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,accentColor,membership);

@override
String toString() {
  return 'WorkspaceDto(id: $id, name: $name, description: $description, accentColor: $accentColor, membership: $membership)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceDtoCopyWith<$Res> implements $WorkspaceDtoCopyWith<$Res> {
  factory _$WorkspaceDtoCopyWith(_WorkspaceDto value, $Res Function(_WorkspaceDto) _then) = __$WorkspaceDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String description, String accentColor, WorkspaceMembershipDto? membership
});


@override $WorkspaceMembershipDtoCopyWith<$Res>? get membership;

}
/// @nodoc
class __$WorkspaceDtoCopyWithImpl<$Res>
    implements _$WorkspaceDtoCopyWith<$Res> {
  __$WorkspaceDtoCopyWithImpl(this._self, this._then);

  final _WorkspaceDto _self;
  final $Res Function(_WorkspaceDto) _then;

/// Create a copy of WorkspaceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? accentColor = null,Object? membership = freezed,}) {
  return _then(_WorkspaceDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as String,membership: freezed == membership ? _self.membership : membership // ignore: cast_nullable_to_non_nullable
as WorkspaceMembershipDto?,
  ));
}

/// Create a copy of WorkspaceDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkspaceMembershipDtoCopyWith<$Res>? get membership {
    if (_self.membership == null) {
    return null;
  }

  return $WorkspaceMembershipDtoCopyWith<$Res>(_self.membership!, (value) {
    return _then(_self.copyWith(membership: value));
  });
}
}

// dart format on
