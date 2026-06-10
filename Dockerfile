# Etapa 1: Compilar el frontend Astro
FROM node:24-alpine AS build-frontend

WORKDIR /usr/app

COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build


# Etapa 2: Compilar y publicar el backend .NET
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-backend

WORKDIR /usr/app

COPY backend/ ./
RUN dotnet publish -c Release -o out


# Etapa 3: Imagen final
FROM mcr.microsoft.com/dotnet/sdk:8.0

WORKDIR /app

# Binario .NET publicado
COPY --from=build-backend /usr/app/out ./

# Archivos estáticos del frontend → wwwroot (Kestrel los sirve automáticamente)
COPY --from=build-frontend /usr/app/dist ./wwwroot

CMD ["dotnet", "MangaApi.dll"]