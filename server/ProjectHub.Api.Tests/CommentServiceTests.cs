using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Moq;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.CommentDtos;
using ProjectHub.Api.Exceptions;
using ProjectHub.Api.Hubs;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services;
using ProjectHub.Api.Services.Interfaces;
using Xunit;
using TaskEntity = ProjectHub.Api.Models.Task;

namespace ProjectHub.Api.Tests;

public class CommentServiceTests
{
    private AppDbContext CreateInMemoryDbContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new AppDbContext(options);
    }

    private CommentService CreateService(AppDbContext context, Mock<IHubContext<WorkspaceHub>>? hubMock = null)
    {
        var mockHubContext = hubMock ?? new Mock<IHubContext<WorkspaceHub>>();
        var mockClients = new Mock<IHubClients>();
        var mockClientProxy = new Mock<IClientProxy>();
        mockHubContext.Setup(h => h.Clients).Returns(mockClients.Object);
        mockClients.Setup(c => c.Group(It.IsAny<string>())).Returns(mockClientProxy.Object);

        var mockActivityLogger = new Mock<IActivityLogger>();
        var mockLogger = new Mock<ILogger<CommentService>>();

        return new CommentService(context, mockActivityLogger.Object, mockHubContext.Object, mockLogger.Object);
    }

    [Fact]
    public async System.Threading.Tasks.Task CreateComment_RequiresWorkspaceMembership()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        var project = new Project { Id = 10, WorkspaceId = 1, Name = "Project 1", CreatedBy = "owner-id" };
        var task = new TaskEntity { Id = 100, ProjectId = 10, Title = "Task 1", CreatedBy = "owner-id" };
        context.WorkSpaces.Add(workspace);
        context.Projects.Add(project);
        context.Tasks.Add(task);
        context.Users.Add(new AppUser { Id = "non-member", UserName = "nonmember@test.com", Name = "Non Member" });
        await context.SaveChangesAsync();

        var service = CreateService(context);

        await Assert.ThrowsAsync<KeyNotFoundException>(() =>
            service.CreateCommentAsync("non-member", 100, new CreateCommentRequestDto { Content = "Hello" }));
    }

    [Fact]
    public async System.Threading.Tasks.Task EditComment_AuthorCanEdit_NonAuthorForbidden()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        var project = new Project { Id = 10, WorkspaceId = 1, Name = "Project 1", CreatedBy = "owner-id" };
        var task = new TaskEntity { Id = 100, ProjectId = 10, Title = "Task 1", CreatedBy = "owner-id" };
        var author = new AppUser { Id = "author-id", UserName = "author@test.com", Name = "Author User" };
        var comment = new Comment { Id = 5, TaskId = 100, AuthorId = "author-id", Content = "Original text" };

        context.WorkSpaces.Add(workspace);
        context.Projects.Add(project);
        context.Tasks.Add(task);
        context.Users.Add(author);
        context.Comments.Add(comment);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 1, UserId = "author-id", Workspace = workspace, Role = WorkspaceRoles.Member.ToString() });
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 2, UserId = "other-id", Workspace = workspace, Role = WorkspaceRoles.Member.ToString() });
        await context.SaveChangesAsync();

        var service = CreateService(context);

        // Author edits successfully
        var updated = await service.UpdateCommentAsync("author-id", 5, new UpdateCommentRequestDto { Content = "Updated text" });
        Assert.Equal("Updated text", updated.Content);

        // Other member is forbidden
        await Assert.ThrowsAsync<ForbiddenException>(() =>
            service.UpdateCommentAsync("other-id", 5, new UpdateCommentRequestDto { Content = "Hacked" }));
    }

    [Fact]
    public async System.Threading.Tasks.Task DeleteComment_AuthorOrOwnerCanDelete_OtherMemberForbidden()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        var project = new Project { Id = 10, WorkspaceId = 1, Name = "Project 1", CreatedBy = "owner-id" };
        var task = new TaskEntity { Id = 100, ProjectId = 10, Title = "Task 1", CreatedBy = "owner-id" };
        var comment1 = new Comment { Id = 1, TaskId = 100, AuthorId = "author-id", Content = "Comment 1" };
        var comment2 = new Comment { Id = 2, TaskId = 100, AuthorId = "author-id", Content = "Comment 2" };

        context.WorkSpaces.Add(workspace);
        context.Projects.Add(project);
        context.Tasks.Add(task);
        context.Comments.AddRange(comment1, comment2);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 1, UserId = "owner-id", Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 2, UserId = "author-id", Workspace = workspace, Role = WorkspaceRoles.Member.ToString() });
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 3, UserId = "regular-id", Workspace = workspace, Role = WorkspaceRoles.Member.ToString() });
        await context.SaveChangesAsync();

        var service = CreateService(context);

        // Regular non-author member is forbidden
        await Assert.ThrowsAsync<ForbiddenException>(() =>
            service.DeleteCommentAsync("regular-id", 1));

        // Author can delete their own comment
        await service.DeleteCommentAsync("author-id", 1);
        Assert.Null(await context.Comments.FindAsync(1));

        // Workspace Owner can delete another member's comment
        await service.DeleteCommentAsync("owner-id", 2);
        Assert.Null(await context.Comments.FindAsync(2));
    }
}
