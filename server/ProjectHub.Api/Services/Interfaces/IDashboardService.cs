using System.Threading.Tasks;
using ProjectHub.Api.DTOs.DashboardDtos;

namespace ProjectHub.Api.Services.Interfaces;

public interface IDashboardService
{
    Task<WorkspaceDashboardDto> GetWorkspaceDashboardAsync(string userId, int workspaceId);
}
