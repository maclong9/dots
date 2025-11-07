---
name: complete-stack
version: 1.0.0
description: Full-stack Swift application with shared library, Hummingbird backend, WebUI frontend, and SwiftUI apps
tags: [swift, hummingbird, webui, swiftui, full-stack, monorepo, container]
---

# Complete-Stack Swift Application

Scaffolds a complete Swift application ecosystem with:
- **Shared library**: Domain models, DTOs, validation, utilities
- **Backend**: Hummingbird server with Fluent/PostgreSQL/Redis
- **WebUI**: Server-rendered frontend
- **iOS/macOS**: Native SwiftUI applications
- **Config**: PKL-based configuration management
- **Deploy**: Production container with apple/container

## Architecture

```
┌─────────────────────────────────────────────────┐
│              Shared Library                     │
│  (Models, DTOs, Validation, Extensions)         │
└─────────────────────────────────────────────────┘
         ↓                ↓                ↓
    ┌────────┐      ┌─────────┐     ┌──────────┐
    │Backend │      │ WebUI   │     │ iOS/Mac  │
    │Hummingbird─────→Frontend │     │ SwiftUI  │
    │        │      │         │     │          │
    └────────┘      └─────────┘     └──────────┘
         ↓               ↑                ↑
    ┌────────────────────────────────────────┐
    │    PostgreSQL + Redis (Containers)     │
    └────────────────────────────────────────┘
```

## Key Features

### Shared Library Pattern
All platforms share domain models, DTOs, validation, and utilities.
One source of truth for business logic across backend, WebUI, and native apps.

### Production Container
Single container image containing:
- PostgreSQL 16 database
- Redis 7 cache
- Hummingbird backend (port 8080)
- WebUI frontend (port 8081)
- Nginx reverse proxy (port 80/443)
- Supervisor process manager

### One-Command Deployment
```bash
# Build production image
./scripts/build-production.sh myapp v1.0.0

# Deploy to any VPS
./scripts/deploy-vps.sh user@vps.com myapp:v1.0.0
```

### App Store Ready
iOS/macOS SwiftUI apps consume the deployed backend API.
Native platform features with shared business logic.

## Usage

```bash
# Initialize project
./scripts/scaffold.sh MyApp

# Development (starts containers + servers)
cd MyApp && ./scripts/dev.sh

# Build & deploy
./scripts/build-production.sh myapp v1.0.0
./scripts/deploy-vps.sh user@vps myapp:v1.0.0

# Release iOS/macOS to App Store
cd iOS && open Package.swift
```

## Example: Shared Model Used Everywhere

```swift
// Shared/Sources/Models/User.swift
public struct User: Codable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var email: String
}

// Backend API
func getUser(req: Request) async throws -> User {
    try await userRepo.find(id)
}

// WebUI Component
struct UserProfile: HTML {
    let user: User
    var body: some HTML {
        div {
            h1 { user.name }
            p { user.email }
        }
    }
}

// SwiftUI View
struct UserRow: View {
    let user: User
    var body: some View {
        VStack(alignment: .leading) {
            Text(user.name).font(.headline)
            Text(user.email).font(.subheadline)
        }
    }
}
```

Complete Swift ecosystem from development to App Store deployment.
