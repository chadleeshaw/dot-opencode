---
name: javascript
description: JavaScript best practices for modern, maintainable code
license: MIT
compatibility: opencode
---

# JavaScript Code Agent

Write clean, modern JavaScript (ES6+) following best practices for maintainable, performant code.

## Core Principles

1. **Self-documenting code** - Clear names, no comments needed
2. **Modern ES6+** - Use latest features
3. **Functional approach** - Prefer pure functions
4. **const over let** - Immutability by default
5. **Minimal comments** - Code explains itself

## Naming Conventions

### Variables and Functions: camelCase
```javascript
// Good
const userName = 'John';
const userAge = 30;

function calculateTotalPrice(items) {
    return items.reduce((sum, item) => sum + item.price, 0);
}
```

### Classes: PascalCase
```javascript
class UserAccount {
    constructor(name) {
        this.name = name;
    }
}

class DatabaseConnection {
    connect() {
        // Connection logic
    }
}
```

### Constants: UPPER_SNAKE_CASE
```javascript
const MAX_RETRIES = 3;
const API_ENDPOINT = 'https://api.example.com';
const DEFAULT_TIMEOUT = 5000;
```

### Booleans: is/has/should/can prefix
```javascript
const isVisible = true;
const hasPermission = false;
const shouldLoad = true;
const canEdit = false;
```

### Functions: use verbs
```javascript
// Good
function fetchUserData() {}
function validateEmail() {}
function transformData() {}

// Bad
function user() {}
function email() {}
function data() {}
```

## Modern JavaScript Features

### Use const/let, never var
```javascript
// Good
const userName = 'Alice';
let counter = 0;

// Bad
var userName = 'Alice';
```

### Arrow functions
```javascript
// Good - concise for simple functions
const double = x => x * 2;
const sum = (a, b) => a + b;

// Good - explicit return for complex logic
const processUser = user => {
    const normalized = normalizeData(user);
    return validated(normalized);
};

// Use regular function when you need 'this'
const obj = {
    value: 42,
    getValue() {
        return this.value;
    }
};
```

### Destructuring
```javascript
// Object destructuring
const { name, email, age } = user;
const { data, error, isLoading } = apiResponse;

// Array destructuring
const [first, second, ...rest] = items;

// Function parameters
function createUser({ name, email, role = 'user' }) {
    return { name, email, role };
}
```

### Template literals
```javascript
// Good
const message = `Hello ${userName}, you have ${count} messages`;
const url = `${API_BASE}/users/${userId}`;

// Bad
const message = 'Hello ' + userName + ', you have ' + count + ' messages';
```

### Spread operator
```javascript
// Arrays
const combined = [...array1, ...array2];
const copy = [...original];

// Objects
const merged = { ...defaults, ...userConfig };
const updated = { ...user, age: 31 };
```

### Optional chaining
```javascript
// Good
const city = user?.address?.city;
const firstItem = items?.[0];
const result = someFunction?.();

// Bad
const city = user && user.address && user.address.city;
```

### Nullish coalescing
```javascript
// Good
const timeout = userTimeout ?? DEFAULT_TIMEOUT;

// Bad
const timeout = userTimeout || DEFAULT_TIMEOUT; // Fails for 0
```

## Functions

### Keep functions small and focused
```javascript
// Good - single responsibility
function validateEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function sanitizeEmail(email) {
    return email.trim().toLowerCase();
}

function processEmail(email) {
    const sanitized = sanitizeEmail(email);
    
    if (!validateEmail(sanitized)) {
        throw new Error('Invalid email');
    }
    
    return sanitized;
}

// Bad - doing too much
function processEmail(email) {
    // 50 lines of validation, sanitization, and processing
}
```

### Use default parameters
```javascript
function createUser(name, role = 'user', isActive = true) {
    return { name, role, isActive };
}
```

### Return early
```javascript
// Good
function processUser(user) {
    if (!user) return null;
    if (!user.email) return null;
    if (!user.verified) return null;
    
    return processVerifiedUser(user);
}

// Bad
function processUser(user) {
    if (user) {
        if (user.email) {
            if (user.verified) {
                return processVerifiedUser(user);
            }
        }
    }
    return null;
}
```

## Arrays and Objects

### Array methods over loops
```javascript
// Good
const doubled = numbers.map(n => n * 2);
const evens = numbers.filter(n => n % 2 === 0);
const sum = numbers.reduce((acc, n) => acc + n, 0);
const hasNegative = numbers.some(n => n < 0);
const allPositive = numbers.every(n => n > 0);

// Bad
const doubled = [];
for (let i = 0; i < numbers.length; i++) {
    doubled.push(numbers[i] * 2);
}
```

### Object methods
```javascript
const keys = Object.keys(user);
const values = Object.values(user);
const entries = Object.entries(user);

const filtered = Object.fromEntries(
    Object.entries(user).filter(([key, value]) => value != null)
);
```

### Use Map and Set
```javascript
// Map for key-value pairs
const userMap = new Map([
    ['user1', { name: 'Alice' }],
    ['user2', { name: 'Bob' }]
]);

// Set for unique values
const uniqueIds = new Set([1, 2, 2, 3, 3, 3]);
```

## Async Programming

### Async/await over promises
```javascript
// Good
async function fetchUserData(userId) {
    try {
        const response = await fetch(`/api/users/${userId}`);
        const user = await response.json();
        return user;
    } catch (error) {
        console.error('Failed to fetch user:', error);
        return null;
    }
}

// Bad
function fetchUserData(userId) {
    return fetch(`/api/users/${userId}`)
        .then(response => response.json())
        .then(user => user)
        .catch(error => {
            console.error('Failed to fetch user:', error);
            return null;
        });
}
```

### Parallel async operations
```javascript
// Good - run in parallel
async function fetchAllData() {
    const [users, posts, comments] = await Promise.all([
        fetchUsers(),
        fetchPosts(),
        fetchComments()
    ]);
    
    return { users, posts, comments };
}

// Bad - sequential (slower)
async function fetchAllData() {
    const users = await fetchUsers();
    const posts = await fetchPosts();
    const comments = await fetchComments();
    
    return { users, posts, comments };
}
```

## Error Handling

### Try-catch for async
```javascript
async function loadUserData(userId) {
    try {
        const response = await fetch(`/api/users/${userId}`);
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error(`Failed to load user ${userId}:`, error);
        return null;
    }
}
```

### Custom errors
```javascript
class ValidationError extends Error {
    constructor(field, message) {
        super(message);
        this.name = 'ValidationError';
        this.field = field;
    }
}

function validateUser(user) {
    if (!user.email) {
        throw new ValidationError('email', 'Email is required');
    }
}
```

## Modules

### ES6 imports/exports
```javascript
// Named exports
export function calculateTotal(items) {
    return items.reduce((sum, item) => sum + item.price, 0);
}

export const TAX_RATE = 0.08;

// Default export
export default class UserService {
    // Implementation
}

// Imports
import UserService from './UserService';
import { calculateTotal, TAX_RATE } from './utils';
```

## Common Patterns

### Conditional object properties
```javascript
const user = {
    name: 'Alice',
    email: 'alice@example.com',
    ...(isAdmin && { role: 'admin' }),
    ...(hasPremium && { premium: true })
};
```

### Guard clauses
```javascript
function processOrder(order) {
    if (!order) return;
    if (order.status !== 'pending') return;
    if (order.items.length === 0) return;
    
    // Process order
}
```

### Function composition
```javascript
const compose = (...fns) => x => fns.reduceRight((v, f) => f(v), x);

const sanitizeEmail = email => email.trim().toLowerCase();
const validateEmail = email => {
    if (!email.includes('@')) throw new Error('Invalid email');
    return email;
};

const processEmail = compose(validateEmail, sanitizeEmail);
```

## Testing

### Jest/Vitest pattern
```javascript
describe('calculateTotal', () => {
    it('should sum item prices', () => {
        const items = [
            { price: 10 },
            { price: 20 },
            { price: 30 }
        ];
        
        const result = calculateTotal(items);
        
        expect(result).toBe(60);
    });
    
    it('should return 0 for empty array', () => {
        const result = calculateTotal([]);
        
        expect(result).toBe(0);
    });
});
```

## Icons

When rendering icons dynamically, use SVG — not emoji characters or Unicode symbols.

```javascript
// Good - SVG icon
function createIcon(path, label) {
  const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  svg.setAttribute('viewBox', '0 0 16 16');
  svg.setAttribute('aria-hidden', 'true');
  svg.setAttribute('focusable', 'false');
  svg.innerHTML = path;
  return svg;
}

// Bad - emoji as icon
button.textContent = '🔍 Search';
button.innerHTML = '✕';
```

## What to Avoid

- var keyword
- Long functions (>30 lines)
- Deep nesting (>3 levels)
- Mutating parameters
- Callback hell
- Unnecessary comments
- Generic names
- console.log in production
- Emoji as icons or UI elements (use SVG)

## TypeScript Note

If using TypeScript, add type annotations:

```typescript
interface User {
    id: number;
    name: string;
    email: string;
}

function getUserById(id: number): Promise<User | null> {
    // Implementation
}
```

## Communication Style

When writing JavaScript:
- State what you're doing concisely
- Show code without excessive explanation
- Code should be self-explanatory
- Minimal markdown formatting
- Direct and to the point
