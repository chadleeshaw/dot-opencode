---
name: golang
description: Go best practices for readable, idiomatic, production-quality code
license: MIT
compatibility: opencode
---

# Go Code Agent

Write clean, idiomatic Go following the conventions of the Go community and the standard library. Favor simplicity, explicitness, and composability.

## Core Principles

1. **Idiomatic Go** — Write code that looks like the standard library
2. **Explicit over clever** — Clear, direct code beats clever one-liners
3. **Errors are values** — Handle them explicitly, never ignore them
4. **Small interfaces** — Define interfaces where they're used, keep them minimal
5. **Composition over inheritance** — Build behavior through embedding and interfaces
6. **Minimal comments** — Good names and structure make code self-documenting

---

## Naming Conventions

### Packages: short, lowercase, no underscores
```go
// Good
package auth
package httputil
package store

// Bad
package authService
package http_util
package userStore
```

### Variables and Functions: camelCase
```go
// Good
userID := 42
maxRetries := 3
func parseConfig(path string) (*Config, error)

// Bad
user_id := 42
MaxRetries := 3  // unexported should be camelCase
func ParseConfig(path string) (*Config, error)  // unexported intent, wrong case
```

### Exported identifiers: PascalCase
```go
type UserService struct{}
func NewUserService() *UserService
const DefaultTimeout = 30 * time.Second
```

### Acronyms: all caps or all lower, never mixed
```go
// Good
userID   // not userId
httpURL  // not httpUrl
parseJSON  // not parseJson
type JSONParser struct{}  // not JsonParser

// Bad
userId
httpUrl
parseJson
```

### Booleans: clear predicates
```go
isValid := true
hasPermission := false
shouldRetry := true
```

### Error variables: prefix with `err` or `Err`
```go
var ErrNotFound = errors.New("not found")
var ErrUnauthorized = errors.New("unauthorized")

result, err := fetchUser(id)
if err != nil { ... }
```

---

## Code Structure

### Package layout
```
myservice/
├── main.go           // entry point only — minimal logic
├── config.go         // configuration types and loading
├── server.go         // HTTP server setup
├── handler/
│   ├── user.go
│   └── order.go
├── store/
│   ├── user.go
│   └── order.go
└── model/
    ├── user.go
    └── order.go
```

### File organization
- One primary type or concern per file
- Keep files under ~300 lines; split when growing
- Group: types → constructors → methods → helpers

### Imports: stdlib, then external, then internal
```go
import (
    "context"
    "fmt"
    "net/http"

    "github.com/some/external"

    "myrepo/internal/auth"
)
```

---

## Functions

### Keep functions small and focused
```go
// Good — each function does one thing
func validateEmail(email string) bool {
    return strings.Contains(email, "@") && strings.Contains(email, ".")
}

func hashPassword(password string) (string, error) {
    bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
    return string(bytes), err
}

func createUser(email, password string) (*User, error) {
    if !validateEmail(email) {
        return nil, ErrInvalidEmail
    }
    hash, err := hashPassword(password)
    if err != nil {
        return nil, fmt.Errorf("hashing password: %w", err)
    }
    return &User{Email: email, PasswordHash: hash}, nil
}
```

### Return errors, don't panic
```go
// Good
func loadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("reading config file: %w", err)
    }
    var cfg Config
    if err := json.Unmarshal(data, &cfg); err != nil {
        return nil, fmt.Errorf("parsing config: %w", err)
    }
    return &cfg, nil
}

// Bad
func loadConfig(path string) *Config {
    data, _ := os.ReadFile(path)  // ignoring error
    var cfg Config
    json.Unmarshal(data, &cfg)    // ignoring error
    return &cfg
}
```

### Accept interfaces, return concrete types
```go
// Good — flexible input, predictable output
func processReader(r io.Reader) (*Result, error) { ... }
func NewServer(store Store, logger *slog.Logger) *Server { ... }

// Bad — overly specific input, or abstract output
func processFile(f *os.File) (*Result, error) { ... }
func NewServer(store Store) Server { ... }  // returning interface is usually wrong
```

### Use functional options for complex constructors
```go
type ServerOption func(*Server)

func WithTimeout(d time.Duration) ServerOption {
    return func(s *Server) {
        s.timeout = d
    }
}

func WithMaxConns(n int) ServerOption {
    return func(s *Server) {
        s.maxConns = n
    }
}

func NewServer(addr string, opts ...ServerOption) *Server {
    s := &Server{
        addr:     addr,
        timeout:  30 * time.Second,
        maxConns: 100,
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}
```

---

## Error Handling

### Always handle errors explicitly
```go
// Good
result, err := doSomething()
if err != nil {
    return fmt.Errorf("doing something: %w", err)
}

// Bad — never do this
result, _ := doSomething()
```

### Wrap errors with context
```go
// Good — context at every layer
func (s *UserService) GetUser(ctx context.Context, id int) (*User, error) {
    user, err := s.store.FindUser(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get user %d: %w", id, err)
    }
    return user, nil
}
```

### Sentinel errors for known conditions
```go
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
    ErrConflict     = errors.New("conflict")
)

// Check with errors.Is
if errors.Is(err, ErrNotFound) {
    http.Error(w, "not found", http.StatusNotFound)
    return
}
```

### Custom error types for structured errors
```go
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation error on %s: %s", e.Field, e.Message)
}

// Check with errors.As
var ve *ValidationError
if errors.As(err, &ve) {
    http.Error(w, ve.Message, http.StatusBadRequest)
}
```

---

## Interfaces

### Keep interfaces small — one or two methods
```go
// Good — minimal, composable
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Store interface {
    FindUser(ctx context.Context, id int) (*User, error)
    SaveUser(ctx context.Context, u *User) error
}

// Bad — too large, hard to mock and compose
type UserService interface {
    Find(id int) (*User, error)
    Save(u *User) error
    Delete(id int) error
    List() ([]*User, error)
    Authenticate(email, pass string) (*Token, error)
    ResetPassword(email string) error
    SendVerification(id int) error
}
```

### Define interfaces at the point of use, not the point of implementation
```go
// Good — handler package defines what it needs
package handler

type UserStore interface {
    FindUser(ctx context.Context, id int) (*User, error)
}

type UserHandler struct {
    store UserStore
}

// The concrete *store.UserStore satisfies this implicitly — no declaration needed there
```

---

## Concurrency

### Pass context everywhere
```go
func (s *Service) ProcessOrder(ctx context.Context, orderID int) error {
    order, err := s.store.GetOrder(ctx, orderID)
    if err != nil {
        return fmt.Errorf("get order: %w", err)
    }
    return s.payment.Charge(ctx, order)
}
```

### Use channels for signaling, mutexes for state
```go
// Signaling with channels
done := make(chan struct{})
go func() {
    defer close(done)
    doWork()
}()
<-done

// Protecting shared state with mutex
type Counter struct {
    mu    sync.Mutex
    value int
}

func (c *Counter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.value++
}
```

### Always use defer to unlock
```go
func (s *Store) Get(key string) (string, bool) {
    s.mu.RLock()
    defer s.mu.RUnlock()
    v, ok := s.data[key]
    return v, ok
}
```

### Goroutine hygiene — always have a way to stop
```go
func (w *Worker) Start(ctx context.Context) {
    go func() {
        for {
            select {
            case <-ctx.Done():
                return
            case job := <-w.jobs:
                w.process(job)
            }
        }
    }()
}
```

---

## Structs and Types

### Use constructors for non-trivial types
```go
type Server struct {
    addr    string
    timeout time.Duration
    store   Store
}

func NewServer(addr string, store Store) *Server {
    return &Server{
        addr:    addr,
        timeout: 30 * time.Second,
        store:   store,
    }
}
```

### Embed for composition, not inheritance
```go
type TimestampedModel struct {
    CreatedAt time.Time
    UpdatedAt time.Time
}

type User struct {
    TimestampedModel
    ID    int
    Email string
}
```

### Use struct tags consistently
```go
type User struct {
    ID        int       `json:"id"         db:"id"`
    Email     string    `json:"email"      db:"email"`
    CreatedAt time.Time `json:"created_at" db:"created_at"`
}
```

---

## Testing

### Table-driven tests
```go
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name  string
        email string
        want  bool
    }{
        {"valid email", "user@example.com", true},
        {"missing at sign", "userexample.com", false},
        {"empty string", "", false},
        {"missing domain", "user@", false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := validateEmail(tt.email)
            if got != tt.want {
                t.Errorf("validateEmail(%q) = %v, want %v", tt.email, got, tt.want)
            }
        })
    }
}
```

### Use t.Helper() in test helpers
```go
func assertNoError(t *testing.T, err error) {
    t.Helper()
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
}
```

### Test the behavior, not the implementation
```go
// Good — tests what the function does
func TestCreateUser_WithValidInput_ReturnsUser(t *testing.T) {
    user, err := createUser("user@example.com", "password123")
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if user.Email != "user@example.com" {
        t.Errorf("got email %q, want %q", user.Email, "user@example.com")
    }
}

// Bad — tests internals
func TestCreateUser_CallsHashPassword(t *testing.T) { ... }
```

---

## What to Avoid

- Ignoring errors (`_` for error returns)
- `init()` functions with side effects
- Global mutable state
- Large interfaces (prefer small, composable ones)
- Returning interfaces from constructors (usually)
- Naked returns in long functions
- Deeply nested code — use early returns
- `panic` outside of `main` or truly unrecoverable situations
- Magic numbers — use named constants

---

## Common Patterns

### Options pattern for config
See functional options above.

### Middleware / handler chaining
```go
type Middleware func(http.Handler) http.Handler

func WithLogging(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        log.Printf("%s %s", r.Method, r.URL.Path)
        next.ServeHTTP(w, r)
    })
}
```

### Graceful shutdown
```go
func main() {
    srv := &http.Server{Addr: ":8080"}

    go func() {
        if err := srv.ListenAndServe(); err != http.ErrServerClosed {
            log.Fatalf("server error: %v", err)
        }
    }()

    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    if err := srv.Shutdown(ctx); err != nil {
        log.Fatalf("shutdown error: %v", err)
    }
}
```

---

## Communication Style

When writing Go code:
- State what you're building concisely
- Show code without excessive explanation
- Prefer idiomatic patterns over clever solutions
- Minimal markdown formatting
- Direct and to the point
