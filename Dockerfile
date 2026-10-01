# Multi-stage Dockerfile for ProjectHub.Api (.NET 10)
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy project file and restore dependencies as distinct cached layer
COPY ["server/ProjectHub.Api/ProjectHub.Api.csproj", "server/ProjectHub.Api/"]
RUN dotnet restore "server/ProjectHub.Api/ProjectHub.Api.csproj"

# Copy API source files and compile release artifact
COPY ["server/ProjectHub.Api/", "server/ProjectHub.Api/"]
WORKDIR "/src/server/ProjectHub.Api"
RUN dotnet publish "ProjectHub.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Ensure logging directory exists for Serilog file sink
RUN mkdir -p /app/logs

# Cloud Run defaults: Port 8080, Reverse Proxy Forwarded Headers, Workstation GC
ENV ASPNETCORE_HTTP_PORTS=8080
ENV ASPNETCORE_FORWARDEDHEADERS_ENABLED=true
ENV DOTNET_gcServer=0

EXPOSE 8080

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "ProjectHub.Api.dll"]
