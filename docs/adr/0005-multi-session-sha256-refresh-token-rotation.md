# Multi-Session SHA256 Refresh Token Rotation

Authentication uses a dedicated `RefreshToken` entity storing SHA256 hashes of high-entropy tokens with rotation and `IsUsed` tracking. Storing single-column tokens breaks multi-device/multi-browser sessions, while plaintext tokens expose credentials in database compromise scenarios. Retaining consumed tokens marked with `IsUsed = true` enables immediate token reuse detection to safeguard against token theft.

