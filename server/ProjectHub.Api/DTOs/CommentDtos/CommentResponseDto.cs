using System;

namespace ProjectHub.Api.DTOs.CommentDtos;

public class CommentResponseDto
{
    public int Id { get; set; }
    public int TaskId { get; set; }
    public string AuthorId { get; set; } = string.Empty;
    public string AuthorName { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

