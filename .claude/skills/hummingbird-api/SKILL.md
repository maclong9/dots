---
name: hummingbird-api
version: 1.0.0
description: Standalone Hummingbird backend API with Fluent/PostgreSQL/Redis
tags: [swift, hummingbird, api, backend, postgresql, redis]
---

# Hummingbird API Server

Scaffolds a standalone Swift backend API with Hummingbird framework.

## Features

- **Hummingbird 2.0+**: Modern Swift server framework
- **Fluent ORM**: PostgreSQL database with migrations
- **Redis**: Caching and session management
- **Authentication**: JWT-based auth middleware
- **Structured Logging**: Swift-log integration
- **PKL Config**: Environment-specific configuration
- **Testing**: Comprehensive test suite

## Project Structure

```
MyAPI/
├── Package.swift
├── Sources/
│   ├── main.swift
│   ├── Router.swift
│   ├── Controllers/
│   │   ├── UserController.swift
│   │   └── AuthController.swift
│   ├── Services/
│   │   ├── UserService.swift
│   │   └── AuthService.swift
│   ├── Database/
│   │   ├── DatabaseConfig.swift
│   │   ├── Migrations/
│   │   └── Repositories/
│   ├── Cache/
│   │   └── RedisCache.swift
│   └── Middleware/
│       ├── AuthMiddleware.swift
│       ├── ErrorMiddleware.swift
│       └── CORSMiddleware.swift
├── Tests/
├── Config/
│   ├── development.pkl
│   └── production.pkl
└── scripts/
    ├── dev.sh
    └── migrate.sh
```

## Usage

```bash
# Initialize
./scripts/scaffold.sh MyAPI

# Development
cd MyAPI && ./scripts/dev.sh

# Run migrations
swift run MyAPI migrate

# Build for production
swift build -c release
```

## Example Route

```swift
router.group("api/v1/users") { users in
    users.get(use: listUsers)
    users.post(use: createUser)
    users.get(":id", use: getUser)
}

func getUser(req: Request, ctx: Context) async throws -> UserResponse {
    let id = try req.parameters.require("id", as: UUID.self)
    let user = try await userService.find(id)
    return UserResponse(user)
}
```

Standalone backend API ready for any frontend.
