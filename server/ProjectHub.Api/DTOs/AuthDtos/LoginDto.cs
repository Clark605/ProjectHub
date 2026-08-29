using System;
using System.ComponentModel.DataAnnotations;

namespace ProjectHub.Api.DTOs.AuthDtos;

public class LoginDto
{
	[Required]
	[EmailAddress]
	public string Email { get; set; } = null!;

	[Required]
	public string Password { get; set; } = null!;
}
