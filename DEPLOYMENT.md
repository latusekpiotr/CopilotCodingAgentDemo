# Azure Deployment Configuration

This document explains the deployment configuration and fixes applied to ensure the application runs correctly in Azure App Service.

## Issues Fixed

### 1. Deployment Target
**Problem**: The original deployment workflow was publishing the entire solution, which doesn't clearly specify the entry point for Azure App Service.

**Solution**: Updated the deployment workflow to specifically target the `src/Server/Server.csproj` project, which is the correct entry point for the application.

```yaml
# Before
dotnet publish BlazorHero.CleanArchitecture.sln

# After  
dotnet publish src/Server/Server.csproj
```

### 2. Database Configuration
**Problem**: The application was configured to use SQL Server with LocalDB connection strings in Production mode, but LocalDB doesn't work in Azure/Linux environments.

**Solution**: Enhanced the database configuration to detect LocalDB connection strings and automatically fallback to InMemory database for Azure environments.

**Location**: `src/Server/Extensions/ServiceCollectionExtensions.cs`

```csharp
// Automatically uses InMemory database when:
// 1. ASPNETCORE_ENVIRONMENT=Development, OR
// 2. Connection string is empty, OR  
// 3. Connection string contains "(localdb)" (Windows LocalDB)
```

### 3. Hangfire Configuration
**Problem**: Hangfire was also trying to use SQL Server with LocalDB connection strings in Production mode.

**Solution**: Applied the same fallback logic to Hangfire configuration.

**Location**: `src/Server/Startup.cs`

```csharp
// Uses InMemory storage for Hangfire when LocalDB is detected
```

## Azure Environment Configuration

The Azure infrastructure is configured via `infrastructure/main.bicep`:

- **Environment Variable**: `ASPNETCORE_ENVIRONMENT=Development` for dev environment
- **Runtime**: .NET 8.0 on Linux
- **Port**: Application listens on port 80 (configured via `ASPNETCORE_URLS=http://+:80`)

## Testing the Configuration

Run the test script to validate the deployment configuration:

```bash
./test-deployment.sh
```

This script tests:
- ✅ Solution builds successfully
- ✅ Server project publishes correctly  
- ✅ Application starts in Development environment (Azure dev scenario)
- ✅ Application starts in Production environment with LocalDB fallback

## Application Architecture

The application consists of:
- **Server Project**: ASP.NET Core backend API + Blazor Server hosting
- **Client Project**: Blazor WebAssembly frontend (served from Server's wwwroot)
- **Shared Libraries**: Domain, Application, Infrastructure layers

When deployed, the Server project serves both:
1. **API endpoints** for backend functionality
2. **Static Blazor WebAssembly files** from wwwroot folder

## Database Strategy

For the Azure dev environment, the application uses **InMemory database** which:
- ✅ Requires no external dependencies
- ✅ Works on Linux/Azure App Service
- ✅ Automatically seeds test data on startup
- ✅ Keeps costs low (no SQL Database required)

For production environments with real SQL Server, simply provide a valid connection string in Azure App Service configuration.

## Deployment Workflow

The deployment process:

1. **Build**: Builds the entire solution in Release configuration
2. **Publish**: Publishes only the Server project (includes Client in wwwroot)
3. **Deploy**: Deploys to Azure App Service as a zip package
4. **Restart**: Restarts the App Service to ensure new deployment is active

## Verification

After deployment, the application should be accessible at:
- **Frontend**: `https://codingagentdemo-app-dev-6pqweg.azurewebsites.net/`
- **API**: `https://codingagentdemo-app-dev-6pqweg.azurewebsites.net/api/`
- **Swagger**: `https://codingagentdemo-app-dev-6pqweg.azurewebsites.net/swagger/`