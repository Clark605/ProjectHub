namespace ProjectHub.Api.Models;

public static class AccentColors
{
    public static readonly string[] Values =
    [
        "teal",
        "blue",
        "indigo",
        "violet",
        "pink",
        "rose",
        "orange",
        "amber",
        "lime",
        "cyan"
    ];

    public const string Default = "teal";

    public static bool IsValid(string? id) =>
        !string.IsNullOrWhiteSpace(id) && Values.Contains(id.Trim().ToLowerInvariant());

    public static string AutoAssign(int index) =>
        Values[Math.Abs(index) % Values.Length];
}
