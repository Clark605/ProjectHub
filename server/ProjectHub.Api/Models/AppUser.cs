namespace ProjectHub.Api.Models;

public class AppUser : Microsoft.AspNetCore.Identity.IdentityUser
{
    public string Name { get; set; } = null!;
    public string Bio { get; set; }=string.Empty;   
}
