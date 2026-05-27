# Stage 1: Build the .NET Web API
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build-stage
WORKDIR /src

# Copy csproj and restore dependencies
COPY Backend.csproj ./
RUN dotnet restore

# Copy all source files and compile
COPY . .
RUN dotnet publish -c Release -o /app/publish

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime-stage
WORKDIR /app
COPY --from=build-stage /app/publish .

# Expose the default ASP.NET Core 8/9 port (8080)
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "Backend.dll"]
