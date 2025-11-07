---
name: swift-webui-app
version: 1.0.0
description: WebUI server-rendered frontend application
tags: [swift, webui, frontend, server-rendering, tailwindcss]
---

# Swift WebUI Application

Scaffolds a server-rendered frontend with WebUI framework.

## Features

- **WebUI**: SwiftUI-like syntax for HTML generation
- **TailwindCSS**: Utility-first styling
- **Type-Safe**: Compile-time HTML validation
- **Server-Rendered**: Fast initial page loads
- **Component Architecture**: Reusable UI components
- **API Integration**: Consume backend REST APIs

## Project Structure

```
MyWebApp/
├── Package.swift
├── Sources/
│   ├── main.swift
│   ├── Views/
│   │   ├── Layout.swift
│   │   └── Pages/
│   │       ├── HomePage.swift
│   │       ├── AboutPage.swift
│   │       └── UserListPage.swift
│   ├── Components/
│   │   ├── Navigation.swift
│   │   ├── Footer.swift
│   │   └── Card.swift
│   ├── Services/
│   │   └── APIClient.swift
│   └── Public/
│       ├── styles.css
│       └── scripts.js
└── scripts/
    └── dev.sh
```

## Usage

```bash
# Initialize
./scripts/scaffold.sh MyWebApp

# Development
cd MyWebApp && ./scripts/dev.sh

# Build
swift build -c release
```

## Example Component

```swift
struct UserCard: HTML {
    let user: User

    var body: some HTML {
        div {
            h2 { user.name }
                .class("text-xl font-semibold")
            p { user.email }
                .class("text-gray-600")
        }
        .class("p-4 rounded-lg border")
    }
}
```

Server-rendered frontend with modern developer experience.
