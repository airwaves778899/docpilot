# Language-Specific Scan Patterns

When running docpilot, use these patterns to efficiently scan source code structure without reading full file bodies.

## Rust

```bash
# Public items (functions, structs, enums, traits, impls)
grep -rn "^pub fn\|^pub struct\|^pub enum\|^pub trait\|^pub type\|^impl " src/

# Doc comments
grep -rn "^///\|^//!" src/

# Module structure
find src -name "mod.rs" -o -name "lib.rs" -o -name "main.rs"
```

## Python

```bash
# Functions, classes, async functions
grep -rn "^def \|^async def \|^class " src/

# Module docstrings (first line)
grep -rn '"""' src/ | grep -v "^Binary"

# FastAPI routes
grep -rn "@app\.\|@router\." src/
```

## TypeScript / JavaScript

```bash
# Functions, classes, interfaces, types
grep -rn "^export function\|^export class\|^export interface\|^export type\|^export const" src/

# Route handlers (Express/Fastify/NestJS)
grep -rn "@Get\|@Post\|@Put\|@Delete\|router\.\(get\|post\|put\|delete\)" src/

# JSDoc
grep -rn "^/\*\*\| \* @" src/
```

## Go

```bash
# Exported functions and types
grep -rn "^func \|^type \|^var \|^const " . --include="*.go"

# Package declarations
grep -rn "^package " . --include="*.go"
```

## Java / Kotlin

```bash
# Public methods and classes
grep -rn "public\s\+\(class\|interface\|enum\|void\|String\|int\|boolean\)" src/

# Spring/Jakarta annotations
grep -rn "@RestController\|@Service\|@Repository\|@Component\|@GetMapping\|@PostMapping" src/
```

## C# / .NET

```bash
# Public members
grep -rn "public\s\+\(class\|interface\|enum\|void\|string\|int\|async\)" .

# ASP.NET route attributes
grep -rn "\[HttpGet\]\|\[HttpPost\]\|\[Route\]" .
```

## Ruby

```bash
# Classes, modules, methods
grep -rn "^class \|^module \|^def " .

# Rails routes (routes.rb)
grep -rn "get \|post \|put \|delete \|resources\|namespace" config/routes.rb 2>/dev/null
```

## Using PowerShell (Windows)

Replace any `grep -rn "PATTERN" PATH --include="*.ext"` with:

```powershell
Get-ChildItem "PATH" -Recurse -Filter "*.ext" |
    Select-String "PATTERN" | Select-Object Path, LineNumber, Line
```
