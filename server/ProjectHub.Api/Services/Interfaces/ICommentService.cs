using System.Collections.Generic;
using System.Threading.Tasks;
using ProjectHub.Api.DTOs.CommentDtos;

namespace ProjectHub.Api.Services.Interfaces;

public interface ICommentService
{
    Task<IEnumerable<CommentResponseDto>> GetCommentsByTaskAsync(string userId, int taskId);
    Task<CommentResponseDto> CreateCommentAsync(string userId, int taskId, CreateCommentRequestDto request);
    Task<CommentResponseDto> UpdateCommentAsync(string userId, int commentId, UpdateCommentRequestDto request);
    Task DeleteCommentAsync(string userId, int commentId);
}

