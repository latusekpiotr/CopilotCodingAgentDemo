#!/bin/bash

# Simple test script to validate the deployment configuration
# This script simulates the Azure deployment environment

echo "🧪 Testing deployment configuration..."
echo ""

# Clean up any previous test artifacts
rm -rf ./test-deployment-output

# Step 1: Build the solution
echo "📦 Step 1: Building solution..."
dotnet build BlazorHero.CleanArchitecture.sln --configuration Release
if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi
echo "✅ Build successful"
echo ""

# Step 2: Publish the Server project (matching deployment workflow)
echo "🚀 Step 2: Publishing Server project..."
dotnet publish src/Server/Server.csproj \
    --configuration Release \
    --output ./test-deployment-output \
    --no-build
if [ $? -ne 0 ]; then
    echo "❌ Publish failed"
    exit 1
fi
echo "✅ Publish successful"
echo ""

# Step 3: Test Development environment (Azure dev environment)
echo "🌟 Step 3: Testing Development environment (Azure dev)..."
cd ./test-deployment-output
timeout 10s bash -c 'ASPNETCORE_ENVIRONMENT=Development ASPNETCORE_URLS=http://+:8080 ./BlazorHero.CleanArchitecture.Server' > dev-test.log 2>&1 &
DEV_PID=$!
sleep 8

# Check if the process is still running (success)
if kill -0 $DEV_PID 2>/dev/null; then
    echo "✅ Development environment test passed"
    kill $DEV_PID 2>/dev/null
    wait $DEV_PID 2>/dev/null
else
    echo "❌ Development environment test failed"
    echo "Log output:"
    cat dev-test.log
    cd ..
    exit 1
fi
echo ""

# Step 4: Test Production environment with LocalDB (fallback scenario)
echo "🏭 Step 4: Testing Production environment with LocalDB fallback..."
timeout 10s bash -c 'ASPNETCORE_ENVIRONMENT=Production ASPNETCORE_URLS=http://+:8081 ./BlazorHero.CleanArchitecture.Server' > prod-test.log 2>&1 &
PROD_PID=$!
sleep 8

# Check if the process is still running (success)
if kill -0 $PROD_PID 2>/dev/null; then
    echo "✅ Production environment test passed"
    kill $PROD_PID 2>/dev/null
    wait $PROD_PID 2>/dev/null
else
    echo "❌ Production environment test failed"
    echo "Log output:"
    cat prod-test.log
    cd ..
    exit 1
fi

cd ..

# Clean up
rm -rf ./test-deployment-output

echo ""
echo "🎉 All deployment tests passed!"
echo ""
echo "Summary:"
echo "✅ Solution builds successfully"
echo "✅ Server project publishes correctly"
echo "✅ Application starts in Development environment (Azure dev)"
echo "✅ Application starts in Production environment with LocalDB fallback"
echo ""
echo "The deployment should now work correctly in Azure!"