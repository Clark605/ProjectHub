using System.Text.Json;
using ProjectHub.Api.Exceptions;
using ProjectHub.Api.Responses;

namespace ProjectHub.Api.Middleware
{
    public class ExceptionHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionHandlingMiddleware> _logger;
        private readonly IWebHostEnvironment _env;

        public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger, IWebHostEnvironment env)
        {
            _next = next;
            _logger = logger;
            _env = env;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                await HandleExceptionAsync(context, ex);
            }
        }

        private async Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            var traceId = context.TraceIdentifier;



            context.Response.ContentType = "application/json";
            var statusCode = exception switch
            {
                KeyNotFoundException => StatusCodes.Status404NotFound,
                ArgumentException => StatusCodes.Status400BadRequest,
                InvalidOperationException => StatusCodes.Status400BadRequest,
                UnauthorizedAccessException => StatusCodes.Status401Unauthorized,
                ForbiddenException => StatusCodes.Status403Forbidden,
                _ => StatusCodes.Status500InternalServerError
            };

            context.Response.StatusCode = statusCode;
            if (statusCode == StatusCodes.Status500InternalServerError)
            {
                _logger.LogError(exception, "Unhandled exception occurred. TraceId: {TraceId}", traceId);
            }
            var response = new ApiErrorResponse
            {
                StatusCode = context.Response.StatusCode,
                Message = statusCode switch
                {
                    StatusCodes.Status404NotFound => "Resource not found.",
                    StatusCodes.Status400BadRequest => exception.Message ?? "Request is invalid.",
                    StatusCodes.Status401Unauthorized => "Unauthorized access to preform this action",
                    StatusCodes.Status403Forbidden => "You do not have permission to access this resource.",

                    _ => exception.Message ?? "An unexpected error occurred."
                },
                Details = _env.IsDevelopment() ? exception.Message : null,
                TraceId = traceId
            };
            var json = JsonSerializer.Serialize(response);
            await context.Response.WriteAsync(json);
        }
    }
}