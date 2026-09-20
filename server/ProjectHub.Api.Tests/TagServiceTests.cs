using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Moq;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.TagDtos;
using ProjectHub.Api.Exceptions;
using ProjectHub.Api.Hubs;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services;
using Xunit;
using TaskEntity = ProjectHub.Api.Models.Task;

namespace ProjectHub.Api.Tests;

public class TagServiceTests
{
    private AppDbContext CreateInMemoryDbContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new AppDbContext(options);
    }

    private TagService CreateService(AppDbContext context)
    {
        var mockHubContext = new Mock<IHubContext<WorkspaceHub>>();
        var mockClients = new Mock<IHubClients>();
        var mockClientProxy = new Mock<IClientProxy>();
        mockHubContext.Setup(h => h.Clients).Returns(mockClients.Object);
        mockClients.Setup(c => c.Group(It.IsAny<string>())).Returns(mockClientProxy.Object);

        var mockLogger = new Mock<ILogger<TagService>>();
        return new TagService(context, mockHubContext.Object, mockLogger.Object);
    }

    [Fact]
    public void TagPalette_GetColorForTag_ReturnsDeterministicColors()
    {
        var color1 = TagPalette.GetColorForTag("Frontend");
        var color2 = TagPalette.GetColorForTag("Frontend");
        var color3 = TagPalette.GetColorForTag("frontend ");

        Assert.Equal(color1, color2);
        Assert.Equal(color1, color3);
        Assert.Contains(color1, TagPalette.Palette);
    }

    [Fact]
    public async System.Threading.Tasks.Task CreateWorkspaceTag_EnforcesWorkspaceOwner()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        context.WorkSpaces.Add(workspace);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 1, UserId = "owner-id", Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 2, UserId = "member-id", Workspace = workspace, Role = WorkspaceRoles.Member.ToString() });
        await context.SaveChangesAsync();

        var service = CreateService(context);

        // Owner succeeds
        var tag = await service.CreateWorkspaceTagAsync("owner-id", 1, new CreateTagRequestDto { Name = "Urgent" });
        Assert.NotNull(tag);
        Assert.Equal("Urgent", tag.Name);
        Assert.Null(tag.ProjectId);

        // Regular member is forbidden
        await Assert.ThrowsAsync<ForbiddenException>(() =>
            service.CreateWorkspaceTagAsync("member-id", 1, new CreateTagRequestDto { Name = "Blocked" }));
    }

    [Fact]
    public async System.Threading.Tasks.Task CreateProjectTag_AllowsOwnerOrCreator_BlocksOthers()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        var project = new Project { Id = 10, WorkspaceId = 1, Name = "Project 1", CreatedBy = "creator-id" };
        context.WorkSpaces.Add(workspace);
        context.Projects.Add(project);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 1, UserId = "owner-id", Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 2, UserId = "creator-id", Workspace = workspace, Role = WorkspaceRoles.Member.ToString() });
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 3, UserId = "other-id", Workspace = workspace, Role = WorkspaceRoles.Member.ToString() });
        await context.SaveChangesAsync();

        var service = CreateService(context);

        // Owner creates project tag
        var tagOwner = await service.CreateProjectTagAsync("owner-id", 10, new CreateTagRequestDto { Name = "Backend" });
        Assert.Equal(10, tagOwner.ProjectId);

        // Project creator creates project tag
        var tagCreator = await service.CreateProjectTagAsync("creator-id", 10, new CreateTagRequestDto { Name = "API" });
        Assert.Equal(10, tagCreator.ProjectId);

        // Other member is forbidden
        await Assert.ThrowsAsync<ForbiddenException>(() =>
            service.CreateProjectTagAsync("other-id", 10, new CreateTagRequestDto { Name = "Blocked" }));
    }

    [Fact]
    public async System.Threading.Tasks.Task AttachTagToTask_EnforcesMax5TagsLimit()
    {
        using var context = CreateInMemoryDbContext();
        var owner = new AppUser { Id = "owner-id", UserName = "owner@test.com", Name = "Owner" };
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        var project = new Project { Id = 10, WorkspaceId = 1, Name = "Project 1", CreatedBy = "owner-id", Creator = owner, Workspace = workspace };
        var task = new TaskEntity { Id = 100, ProjectId = 10, Title = "Task 1", CreatedBy = "owner-id", Creator = owner, Project = project };
        context.Users.Add(owner);
        context.WorkSpaces.Add(workspace);
        context.Projects.Add(project);
        context.Tasks.Add(task);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 1, UserId = "owner-id", Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });

        // Create 6 tags
        for (int i = 1; i <= 6; i++)
        {
            context.Tags.Add(new Tag { Id = i, WorkspaceId = 1, Name = $"Tag{i}", Color = "#0D9488", Workspace = workspace });
        }
        await context.SaveChangesAsync();

        var service = CreateService(context);

        // Attach 5 tags
        for (int i = 1; i <= 5; i++)
        {
            await service.AttachTagToTaskAsync("owner-id", 100, i);
        }

        // 6th tag must fail with InvalidOperationException
        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            service.AttachTagToTaskAsync("owner-id", 100, 6));
    }

    [Fact]
    public async System.Threading.Tasks.Task DeleteTag_CascadeDetachesFromTasks()
    {
        using var context = CreateInMemoryDbContext();
        var owner = new AppUser { Id = "owner-id", UserName = "owner@test.com", Name = "Owner" };
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        var project = new Project { Id = 10, WorkspaceId = 1, Name = "Project 1", CreatedBy = "owner-id", Creator = owner, Workspace = workspace };
        var task = new TaskEntity { Id = 100, ProjectId = 10, Title = "Task 1", CreatedBy = "owner-id", Creator = owner, Project = project };
        var tag = new Tag { Id = 50, WorkspaceId = 1, Name = "Bug", Color = "#E11D48", Workspace = workspace };
        context.Users.Add(owner);
        context.WorkSpaces.Add(workspace);
        context.Projects.Add(project);
        context.Tasks.Add(task);
        context.Tags.Add(tag);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 1, UserId = "owner-id", Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });
        await context.SaveChangesAsync();

        var service = CreateService(context);
        await service.AttachTagToTaskAsync("owner-id", 100, 50);

        Assert.Equal(1, await context.TaskTags.CountAsync());

        // Delete tag
        await service.DeleteTagAsync("owner-id", 50);

        Assert.Null(await context.Tags.FindAsync(50));
        Assert.NotNull(await context.Tasks.FindAsync(100));
    }
}
