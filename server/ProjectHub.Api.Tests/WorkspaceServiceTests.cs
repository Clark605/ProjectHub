using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Hybrid;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Moq;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.WorkSpaceDtos;
using ProjectHub.Api.Exceptions;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services;
using ProjectHub.Api.Services.Interfaces;
using Xunit;

namespace ProjectHub.Api.Tests;

public class WorkspaceServiceTests
{
    private AppDbContext CreateInMemoryDbContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new AppDbContext(options);
    }

    private static Mock<UserManager<AppUser>> CreateMockUserManager()
    {
        var store = new Mock<IUserStore<AppUser>>();
        return new Mock<UserManager<AppUser>>(store.Object, null!, null!, null!, null!, null!, null!, null!, null!);
    }

    private WorkspaceService CreateService(AppDbContext context, Mock<UserManager<AppUser>>? userManagerMock = null)
    {
        var userManager = userManagerMock ?? CreateMockUserManager();

        var services = new ServiceCollection();
#pragma warning disable EXTEXP0018
        services.AddHybridCache();
#pragma warning restore EXTEXP0018
        var cache = services.BuildServiceProvider().GetRequiredService<HybridCache>();

        var mockActivityLogger = new Mock<IActivityLogger>();
        var mockLogger = new Mock<ILogger<WorkspaceService>>();

        return new WorkspaceService(
            context,
            userManager.Object,
            cache,
            mockActivityLogger.Object,
            mockLogger.Object);
    }

    [Fact]
    public void Validator_RejectsInvalidRole()
    {
        var validator = new UpdateMemberRoleDtoValidator();
        var request = new UpdateMemberRoleDto { Role = "SuperAdmin" };

        var result = validator.Validate(request);

        Assert.False(result.IsValid);
        Assert.Contains(result.Errors, e => e.PropertyName == "Role");
    }

    [Fact]
    public void Validator_AcceptsValidRoles()
    {
        var validator = new UpdateMemberRoleDtoValidator();
        var requestOwner = new UpdateMemberRoleDto { Role = "Owner" };
        var requestMember = new UpdateMemberRoleDto { Role = "Member" };

        Assert.True(validator.Validate(requestOwner).IsValid);
        Assert.True(validator.Validate(requestMember).IsValid);
    }

    [Fact]
    public async System.Threading.Tasks.Task UpdateMemberRole_PromotesMemberToOwner()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        var ownerUser = new AppUser { Id = "owner-1", Name = "Owner", Email = "owner@test.com" };
        var memberUser = new AppUser { Id = "member-1", Name = "Member", Email = "member@test.com" };

        context.WorkSpaces.Add(workspace);
        context.Users.AddRange(ownerUser, memberUser);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 1, UserId = "owner-1", Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 2, UserId = "member-1", Workspace = workspace, Role = WorkspaceRoles.Member.ToString() });
        await context.SaveChangesAsync();

        var service = CreateService(context);

        var result = await service.UpdateMemberRoleAsync("owner-1", 1, "member-1", new UpdateMemberRoleDto { Role = "Owner" });

        Assert.NotNull(result);
        Assert.Equal("member-1", result.UserId);
        Assert.Equal("Owner", result.Role);

        var memberInDb = await context.WorkspaceMembers.FirstOrDefaultAsync(wm => wm.UserId == "member-1" && wm.Workspace.Id == 1);
        Assert.NotNull(memberInDb);
        Assert.Equal("Owner", memberInDb.Role);
    }

    [Fact]
    public async System.Threading.Tasks.Task UpdateMemberRole_PreventsDemotingSoleOwner()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        var ownerUser = new AppUser { Id = "owner-1", Name = "Owner", Email = "owner@test.com" };

        context.WorkSpaces.Add(workspace);
        context.Users.Add(ownerUser);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 1, UserId = "owner-1", Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });
        await context.SaveChangesAsync();

        var service = CreateService(context);

        var ex = await Assert.ThrowsAsync<ArgumentException>(() =>
            service.UpdateMemberRoleAsync("owner-1", 1, "owner-1", new UpdateMemberRoleDto { Role = "Member" }));

        Assert.Contains("Cannot demote the sole owner", ex.Message);
    }

    [Fact]
    public async System.Threading.Tasks.Task UpdateMemberRole_ThrowsForbidden_WhenCallerIsNotOwner()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        var ownerUser = new AppUser { Id = "owner-1", Name = "Owner", Email = "owner@test.com" };
        var memberUser = new AppUser { Id = "member-1", Name = "Member", Email = "member@test.com" };
        var targetUser = new AppUser { Id = "target-1", Name = "Target", Email = "target@test.com" };

        context.WorkSpaces.Add(workspace);
        context.Users.AddRange(ownerUser, memberUser, targetUser);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 1, UserId = "owner-1", Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 2, UserId = "member-1", Workspace = workspace, Role = WorkspaceRoles.Member.ToString() });
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 3, UserId = "target-1", Workspace = workspace, Role = WorkspaceRoles.Member.ToString() });
        await context.SaveChangesAsync();

        var service = CreateService(context);

        await Assert.ThrowsAsync<ForbiddenException>(() =>
            service.UpdateMemberRoleAsync("member-1", 1, "target-1", new UpdateMemberRoleDto { Role = "Owner" }));
    }

    [Fact]
    public async System.Threading.Tasks.Task GetMemberRoleAsync_ReturnsRoleCorrectly()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        var ownerUser = new AppUser { Id = "owner-1", Name = "Owner", Email = "owner@test.com" };

        context.WorkSpaces.Add(workspace);
        context.Users.Add(ownerUser);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 1, UserId = "owner-1", Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });
        await context.SaveChangesAsync();

        var service = CreateService(context);

        var role = await service.GetMemberRoleAsync("owner-1", 1);
        Assert.Equal("Owner", role);

        var nonMemberRole = await service.GetMemberRoleAsync("random-user", 1);
        Assert.Null(nonMemberRole);
    }
}

