# BlazorHero Clean Architecture - Coding Agent Instructions

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Prerequisites and Dependencies
- **.NET 8.0** is already installed and configured
- **No additional SDKs required** - all dependencies are NuGet packages

### Build and Test the Repository
- `dotnet build BlazorHero.CleanArchitecture.sln --configuration Release` -- NEVER CANCEL. Takes 18 seconds when already built, 2+ minutes on fresh build. Set timeout to 5+ minutes.
- **NEVER CANCEL BUILD COMMANDS**: Wait for completion. Fresh builds may take up to 2 minutes, incremental builds 15-30 seconds.
- **NO UNIT TESTS**: This solution has no test projects. Do not run `dotnet test` as there are no tests to execute.
- `./test-deployment.sh` -- NEVER CANCEL. Takes 23 seconds. Validates build, publish, and startup scenarios.

### Run the Application
- **ALWAYS build first**: `cd src/Server && dotnet build`
- **Start development server**: `cd src/Server && ASPNETCORE_ENVIRONMENT=Development dotnet run`
- **Application URLs**:
  - Frontend: `https://localhost:5001` (redirects from http://localhost:5000)
  - API/Swagger: `https://localhost:5001/swagger`
- **NEVER CANCEL APPLICATION STARTUP**: Wait 10-20 seconds for full initialization and database seeding.

### Publish for Deployment
- `dotnet publish src/Server/Server.csproj --configuration Release --output ./publish-output` -- NEVER CANCEL. Takes 20 seconds when already built, 1-2 minutes on fresh publish. Set timeout to 3+ minutes.

## Validation Requirements

### Always Test After Changes
- **BUILD VALIDATION**: Run `dotnet build BlazorHero.CleanArchitecture.sln --configuration Release` and ensure it succeeds
- **DEPLOYMENT VALIDATION**: Run `./test-deployment.sh` to verify application starts correctly in both Development and Production modes
- **APPLICATION VALIDATION**: Start the application and verify:
  1. Application starts without errors (look for "Application started" in logs)
  2. Database seeding completes (look for "Seeded Administrator Role" messages)
  3. Can access frontend at `https://localhost:5001`
  4. Can access Swagger at `https://localhost:5001/swagger`

### Manual Testing Scenarios
When making significant changes, test these user scenarios:
- **Login Flow**: Navigate to `https://localhost:5001`, click Login, use credentials:
  - Admin: `mukesh@blazorhero.com` / `123Pa$$word!`
  - User: `john@blazorhero.com` / `123Pa$$word!`
- **Dashboard Access**: After login, verify dashboard loads with navigation menu
- **API Access**: Check Swagger UI works at `https://localhost:5001/swagger`

## Application Architecture

### Project Structure
- **Server Project** (`src/Server/`): ASP.NET Core backend API + hosts Blazor WebAssembly frontend
- **Client Project** (`src/Client/`): Blazor WebAssembly frontend (MudBlazor UI components)
- **Core Projects**:
  - `src/Domain/`: Domain entities and contracts
  - `src/Application/`: Application logic, MediatR handlers, CQRS
  - `src/Shared/`: Shared DTOs and constants
- **Infrastructure Projects**:
  - `src/Infrastructure/`: Data access, Entity Framework, external services
  - `src/Infrastructure.Shared/`: Shared infrastructure services

### Database Configuration
- **Development Environment**: Uses InMemory database automatically
- **Production Environment**: Falls back to InMemory if LocalDB connection string detected
- **Database Seeding**: Automatic on startup - creates default admin and basic users

### Key Technologies
- **.NET 8.0** with Blazor WebAssembly
- **MudBlazor** for UI components
- **Entity Framework Core** with InMemory provider
- **MediatR** for CQRS pattern
- **Hangfire** for background jobs (InMemory storage)
- **JWT Authentication** with role-based permissions
- **Serilog** for logging
- **Swagger** for API documentation

## Common Issues and Workarounds

### Known Security Warnings
The build produces these security warnings (existing issues, not your responsibility):
- `System.Linq.Dynamic.Core` has known vulnerabilities
- `MimeKit` has known vulnerabilities
- These are **NOT** errors and do not prevent building/running

### Build Behavior
- **First build takes longer**: Up to 2 minutes for package restore and compilation
- **Subsequent builds faster**: 5-30 seconds if no major changes
- **Publish includes Client**: Server project publish automatically includes Blazor WebAssembly client

### No Linting/Formatting Tools
- **No built-in linting**: Solution has no ESLint, StyleCop, or similar tools configured
- **No formatting scripts**: No automated code formatting available
- **Manual code review**: Rely on IDE/editor formatting and manual review

## CI/CD Pipeline Information

### GitHub Actions Workflow
- **Build Workflow**: `.github/workflows/dotnet.yml` - builds Server project only
- **Deployment**: Targets Azure App Service via separate deployment workflows
- **No test execution**: CI does not run tests (none exist)

### Azure Deployment
- **Target**: Server project deploys to Azure App Service
- **Environment**: Uses Development environment with InMemory database
- **Startup check**: `test-deployment.sh` validates Azure deployment configuration

## Time Expectations and Timeouts

### Critical Timing Information
- **Build time**: 18 seconds incremental, 2 minutes fresh - NEVER CANCEL
- **Publish time**: 20 seconds incremental, 1-2 minutes fresh - NEVER CANCEL  
- **Test script time**: 23 seconds - NEVER CANCEL
- **Application startup**: 21 seconds for build + startup, 10-20 seconds startup only
- **Database seeding**: 3-5 seconds (automatic on startup, look for "Seeded Administrator Role" messages)

### Recommended Timeout Values
- **Build commands**: 5+ minutes timeout
- **Publish commands**: 3+ minutes timeout
- **Application startup**: 30+ seconds timeout
- **Test script**: 2+ minutes timeout

## Common File Locations

### Configuration Files
- **Application settings**: `src/Server/appsettings.json`, `src/Server/appsettings.Development.json`
- **Solution file**: `BlazorHero.CleanArchitecture.sln`
- **Docker**: `docker-compose.yml`, `src/Server/Dockerfile`

### Key Source Files
- **Server startup**: `src/Server/Startup.cs`, `src/Server/Program.cs`
- **Client entry point**: `src/Client/Program.cs`
- **Database context**: `src/Infrastructure/Contexts/BlazorHeroContext.cs`
- **User seeding**: `src/Infrastructure/DatabaseSeeder.cs`

### Documentation
- **Features**: `Features.md`
- **Deployment**: `DEPLOYMENT.md`
- **Fix history**: `FIX-SUMMARY.md`
- **General**: `README.md`

## Default Test Users

### Administrator Account
- **Email**: `mukesh@blazorhero.com`
- **Username**: `mukesh`
- **Password**: `123Pa$$word!`
- **Role**: Administrator (full permissions)

### Basic User Account  
- **Email**: `john@blazorhero.com`
- **Username**: `johndoe`
- **Password**: `123Pa$$word!`
- **Role**: Basic (limited permissions)

Both accounts are seeded automatically on application startup.