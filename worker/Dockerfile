# Stage 1: Build
FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/sdk:7.0 AS build
ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM
WORKDIR /source

RUN echo "TARGETPLATFORM: ${TARGETPLATFORM}, TARGETARCH: ${TARGETARCH}, BUILDPLATFORM: ${BUILDPLATFORM}"

COPY . .

# Correction apporté pour corriger un bug de build quand les architecture de la machine hôte et de la cible sont différentes 
ENV DOTNET_EnableWriteXorExecute=0  

# Install dependencies
RUN dotnet restore -a ${TARGETARCH}

# Compile the application
RUN dotnet publish -c release -o /app -a ${TARGETARCH} --self-contained false --no-restore

# Stage 2: Runtime
FROM --platform=${TARGETPLATFORM} mcr.microsoft.com/dotnet/runtime:7.0
WORKDIR /app
COPY --from=build /app .

# Run the application
ENTRYPOINT ["dotnet", "Worker.dll"]