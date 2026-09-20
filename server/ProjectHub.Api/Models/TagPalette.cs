using System;
using System.Security.Cryptography;
using System.Text;

namespace ProjectHub.Api.Models;

public static class TagPalette
{
    public static readonly string[] Palette =
    [
        "#0D9488", // Teal
        "#2563EB", // Blue
        "#7C3AED", // Purple
        "#DB2777", // Pink
        "#E11D48", // Rose
        "#EA580C", // Orange
        "#D97706", // Amber
        "#65A30D", // Lime
        "#0891B2", // Cyan
        "#4F46E5", // Indigo
        "#059669", // Emerald
        "#9333EA"  // Violet
    ];

    public static string GetColorForTag(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            return Palette[0];
        }

        var normalized = name.Trim().ToLowerInvariant();
        using var sha256 = SHA256.Create();
        var hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(normalized));
        var value = BitConverter.ToUInt32(hashBytes, 0);
        var index = (int)(value % (uint)Palette.Length);
        return Palette[index];
    }
}

