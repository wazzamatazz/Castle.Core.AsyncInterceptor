########################################################################################################################
# shellcheck - lining for bash scrips
FROM koalaman/shellcheck-alpine:stable

COPY ./ ./

# Convert CRLF to CR as it causes shellcheck warnings.
RUN find . -type f -name '*.sh' -exec dos2unix {} \;

# Run shell check on all the shell files.
RUN find . -type f -name '*.sh' | wc -l && find . -type f -name '*.sh' | xargs shellcheck --external-sources

########################################################################################################################
# .NET Core 3.1
FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine

ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true

RUN apk add --no-cache --update dos2unix

WORKDIR /work

# Copy just the solution and proj files to make best use of docker image caching.
COPY ./castle.core.asyncinterceptor.sln .
COPY ./src/Castle.Core.AsyncInterceptor/Castle.Core.AsyncInterceptor.csproj ./src/Castle.Core.AsyncInterceptor/Castle.Core.AsyncInterceptor.csproj
COPY ./test/Castle.Core.AsyncInterceptor.Tests/Castle.Core.AsyncInterceptor.Tests.csproj ./test/Castle.Core.AsyncInterceptor.Tests/Castle.Core.AsyncInterceptor.Tests.csproj

# Run restore on just the project files, this should cache the image after restore.
RUN dotnet restore

COPY . .

RUN dos2unix -k -q ./coverage.sh

RUN ./coverage.sh netcoreapp3.1 Debug
