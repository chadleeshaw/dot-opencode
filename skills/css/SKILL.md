---
name: css
description: CSS best practices for modern, performant styling
license: MIT
compatibility: opencode
---

# CSS Code Agent

Write modern, maintainable CSS for performant, responsive web applications.

## Core Principles

1. **CSS custom properties** - Use variables for consistency
2. **Mobile-first** - Design for small screens, enhance for large
3. **Modern layout** - Flexbox and Grid
4. **Performance** - Minimize reflows, optimize selectors
5. **Minimal comments** - Selectors and values should be self-explanatory

## CSS Custom Properties

### Define variables
```css
:root {
  /* Colors */
  --color-primary: #3b82f6;
  --color-secondary: #8b5cf6;
  --color-success: #10b981;
  --color-error: #ef4444;
  
  /* Spacing */
  --space-xs: 0.25rem;
  --space-sm: 0.5rem;
  --space-md: 1rem;
  --space-lg: 1.5rem;
  --space-xl: 2rem;
  
  /* Typography */
  --font-sans: system-ui, -apple-system, sans-serif;
  --font-mono: 'Monaco', monospace;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  
  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  
  /* Borders */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 1rem;
  
  /* Transitions */
  --transition-fast: 150ms ease-in-out;
  --transition-base: 250ms ease-in-out;
}
```

### Use variables
```css
.button {
  padding: var(--space-sm) var(--space-md);
  background: var(--color-primary);
  border-radius: var(--radius-md);
  transition: background var(--transition-fast);
}

.button:hover {
  background: var(--color-secondary);
}
```

## Mobile-First Responsive Design

```css
/* Mobile default */
.container {
  padding: var(--space-md);
  width: 100%;
}

/* Tablet and up */
@media (min-width: 768px) {
  .container {
    padding: var(--space-lg);
    max-width: 768px;
    margin: 0 auto;
  }
}

/* Desktop and up */
@media (min-width: 1024px) {
  .container {
    padding: var(--space-xl);
    max-width: 1024px;
  }
}
```

## Modern Layout

### Flexbox
```css
/* Flex container */
.flex-container {
  display: flex;
  gap: var(--space-md);
  align-items: center;
  justify-content: space-between;
}

/* Flex column */
.flex-column {
  display: flex;
  flex-direction: column;
  gap: var(--space-sm);
}

/* Center content */
.flex-center {
  display: flex;
  align-items: center;
  justify-content: center;
}
```

### Grid
```css
/* Basic grid */
.grid {
  display: grid;
  gap: var(--space-md);
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
}

/* Specific columns */
.grid-3 {
  display: grid;
  gap: var(--space-md);
  grid-template-columns: repeat(3, 1fr);
}

/* Responsive grid */
.grid-responsive {
  display: grid;
  gap: var(--space-md);
  grid-template-columns: 1fr;
}

@media (min-width: 768px) {
  .grid-responsive {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .grid-responsive {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

## Typography

```css
/* Base typography */
body {
  font-family: var(--font-sans);
  font-size: var(--font-size-base);
  line-height: 1.5;
  color: #1f2937;
}

/* Headings */
h1, h2, h3, h4, h5, h6 {
  margin-top: 0;
  line-height: 1.2;
  font-weight: 600;
}

h1 { font-size: 2.5rem; }
h2 { font-size: 2rem; }
h3 { font-size: 1.5rem; }

/* Responsive typography */
@media (max-width: 768px) {
  h1 { font-size: 2rem; }
  h2 { font-size: 1.5rem; }
  h3 { font-size: 1.25rem; }
}

/* Text utilities */
.text-sm { font-size: var(--font-size-sm); }
.text-lg { font-size: var(--font-size-lg); }
.text-bold { font-weight: 600; }
.text-center { text-align: center; }
```

## Colors and Theming

```css
/* Light theme (default) */
:root {
  --bg-primary: #ffffff;
  --bg-secondary: #f3f4f6;
  --text-primary: #1f2937;
  --text-secondary: #6b7280;
}

/* Dark theme */
@media (prefers-color-scheme: dark) {
  :root {
    --bg-primary: #1f2937;
    --bg-secondary: #111827;
    --text-primary: #f9fafb;
    --text-secondary: #9ca3af;
  }
}

/* Manual dark theme class */
[data-theme="dark"] {
  --bg-primary: #1f2937;
  --bg-secondary: #111827;
  --text-primary: #f9fafb;
  --text-secondary: #9ca3af;
}

/* Apply theme colors */
body {
  background: var(--bg-primary);
  color: var(--text-primary);
}
```

## Animations and Transitions

```css
/* Smooth transitions */
.button {
  transition: all var(--transition-base);
}

/* Specific properties */
.card {
  transition: 
    transform var(--transition-fast),
    box-shadow var(--transition-fast);
}

.card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-md);
}

/* Keyframe animation */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-in {
  animation: fadeIn var(--transition-base);
}

/* Respect user preferences */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Components

### Button
```css
.button {
  display: inline-flex;
  align-items: center;
  gap: var(--space-xs);
  padding: var(--space-sm) var(--space-md);
  background: var(--color-primary);
  color: white;
  border: none;
  border-radius: var(--radius-md);
  font-size: var(--font-size-base);
  font-weight: 500;
  cursor: pointer;
  transition: background var(--transition-fast);
}

.button:hover {
  background: var(--color-secondary);
}

.button:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

.button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
```

### Card
```css
.card {
  background: var(--bg-primary);
  border: 1px solid var(--bg-secondary);
  border-radius: var(--radius-lg);
  padding: var(--space-lg);
  box-shadow: var(--shadow-sm);
  transition: box-shadow var(--transition-fast);
}

.card:hover {
  box-shadow: var(--shadow-md);
}
```

### Input
```css
.input {
  width: 100%;
  padding: var(--space-sm) var(--space-md);
  font-size: var(--font-size-base);
  border: 1px solid #d1d5db;
  border-radius: var(--radius-md);
  transition: border-color var(--transition-fast);
}

.input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgb(59 130 246 / 0.1);
}

.input::placeholder {
  color: var(--text-secondary);
}
```

## Utility Classes

```css
/* Spacing */
.m-0 { margin: 0; }
.p-0 { padding: 0; }
.mt-1 { margin-top: var(--space-xs); }
.mb-2 { margin-bottom: var(--space-sm); }
.p-4 { padding: var(--space-md); }

/* Display */
.hidden { display: none; }
.block { display: block; }
.inline-block { display: inline-block; }
.flex { display: flex; }
.grid { display: grid; }

/* Position */
.relative { position: relative; }
.absolute { position: absolute; }
.fixed { position: fixed; }

/* Width */
.w-full { width: 100%; }
.w-auto { width: auto; }
.max-w-screen-lg { max-width: 1024px; }

/* Text */
.text-left { text-align: left; }
.text-center { text-align: center; }
.text-right { text-align: right; }
```

## Performance

### Optimize selectors
```css
/* Good - specific and efficient */
.nav-item {
  color: var(--text-primary);
}

/* Bad - too specific, slow */
div.container > ul.nav > li.nav-item > a.nav-link {
  color: var(--text-primary);
}

/* Bad - universal selector */
* {
  margin: 0;
  padding: 0;
}
```

### Use containment
```css
.card {
  contain: content;
}

.image-gallery {
  contain: layout style paint;
}
```

### Will-change sparingly
```css
/* Only for elements that will definitely animate */
.animated-element {
  will-change: transform;
}

/* Remove after animation */
.animated-element.done {
  will-change: auto;
}
```

## Accessibility

```css
/* Focus styles */
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

/* Skip to content link */
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: var(--color-primary);
  color: white;
  padding: var(--space-sm);
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}

/* Screen reader only */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}

/* High contrast mode */
@media (prefers-contrast: high) {
  .button {
    border: 2px solid currentColor;
  }
}
```

## Modern CSS Features

### Container queries
```css
.card {
  container-type: inline-size;
}

@container (min-width: 400px) {
  .card-content {
    display: grid;
    grid-template-columns: 1fr 1fr;
  }
}
```

### Logical properties
```css
/* Instead of margin-left/right */
.element {
  margin-inline: var(--space-md);
  padding-block: var(--space-sm);
  border-inline-start: 2px solid var(--color-primary);
}
```

### Modern selectors
```css
/* :is() for grouping */
:is(h1, h2, h3) {
  line-height: 1.2;
}

/* :where() for zero specificity */
:where(ul, ol) {
  padding-left: var(--space-lg);
}

/* :has() for parent selection */
.card:has(img) {
  display: grid;
  grid-template-columns: 200px 1fr;
}
```

## What to Avoid

- !important (except for utilities)
- Inline styles
- Overly specific selectors
- Magic numbers (use variables)
- Fixed pixel widths
- Overusing z-index
- Not using CSS variables
- Ignoring accessibility
- Too many media queries

## Best Practices

1. Use CSS variables for consistency
2. Mobile-first responsive design
3. Flexbox and Grid for layout
4. Semantic class names
5. Keep selectors simple
6. Group related properties
7. Add focus styles
8. Test in multiple browsers
9. Minimize animation on mobile
10. Respect user preferences

## Communication Style

When writing CSS:
- State what you're styling concisely
- Show styles without excessive explanation
- Styles should be self-explanatory
- Minimal markdown formatting
- Direct and to the point
