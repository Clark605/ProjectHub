namespace ProjectHub.Api.Responses
{
    public class ApiErrorResponse
    {
        public int StatusCode { get; set; }
        public string? Message { get; set; }
        public string? Details { get; set; }
        public string? TraceId { get; set; }

    }
}
    