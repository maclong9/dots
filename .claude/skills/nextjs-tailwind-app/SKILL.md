---
name: nextjs-tailwind-app
version: 1.0.0
description: Next.js 14+ full-stack application with App Router and TailwindCSS
tags: [nextjs, react, typescript, tailwindcss, full-stack]
---

# Next.js + TailwindCSS Application

Scaffolds a modern Next.js 14+ full-stack application.

## Features

- **Next.js 14+**: App Router with Server Components
- **TypeScript**: Strict mode, full type safety
- **TailwindCSS**: Utility-first styling
- **Server Actions**: Type-safe mutations
- **API Routes**: RESTful endpoints
- **Database**: Prisma or Drizzle ORM
- **Authentication**: NextAuth.js ready

## Project Structure

```
my-nextjs-app/
├── package.json
├── tsconfig.json
├── tailwind.config.ts
├── next.config.js
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   ├── globals.css
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   ├── dashboard/
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── api/
│   │   └── users/route.ts
│   └── actions/
│       └── user-actions.ts
├── components/
│   ├── ui/
│   └── forms/
├── lib/
│   ├── db.ts
│   └── utils.ts
└── public/
```

## Usage

```bash
# Initialize
npm create next-app@latest my-app --typescript --tailwind --app

# Development
cd my-app && npm run dev

# Build
npm run build

# Production
npm start
```

## Example Server Component

```typescript
export default async function UsersPage() {
  const users = await db.user.findMany()

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">Users</h1>
      <div className="grid gap-4">
        {users.map(user => (
          <UserCard key={user.id} user={user} />
        ))}
      </div>
    </div>
  )
}
```

## Example Server Action

```typescript
'use server'

export async function createUser(formData: FormData) {
  const name = formData.get('name') as string
  await db.user.create({ data: { name } })
  revalidatePath('/users')
  redirect('/users')
}
```

Modern full-stack web application with excellent DX.
