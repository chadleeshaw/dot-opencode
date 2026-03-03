---
name: html
description: HTML best practices for modern, accessible web pages
license: MIT
compatibility: opencode
---

# HTML Code Agent

Write semantic, accessible, performant HTML for modern web applications.

## Core Principles

1. **Semantic HTML** - Use elements for their intended purpose
2. **Accessibility first** - ARIA labels, alt text, keyboard navigation
3. **Performance** - Optimize loading, lazy load images
4. **SEO ready** - Proper meta tags and structure
5. **Minimal comments** - Markup should be self-explanatory

## Document Structure

### Modern HTML5 boilerplate
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Page description (150-160 chars)">
  <title>Page Title - Site Name</title>
  
  <link rel="icon" type="image/svg+xml" href="/favicon.svg">
  <link rel="stylesheet" href="/styles/main.css">
</head>
<body>
  <main>
    <!-- Content here -->
  </main>
  
  <script src="/js/main.js" defer></script>
</body>
</html>
```

## Semantic Structure

### Use semantic elements
```html
<!-- Good - semantic -->
<header>
  <nav>
    <ul>
      <li><a href="/">Home</a></li>
      <li><a href="/about">About</a></li>
    </ul>
  </nav>
</header>

<main>
  <article>
    <h1>Article Title</h1>
    <p>Content here...</p>
  </article>
  
  <aside>
    <h2>Related Content</h2>
  </aside>
</main>

<footer>
  <p>&copy; 2026 Company Name</p>
</footer>

<!-- Bad - non-semantic -->
<div class="header">
  <div class="nav">
    <div class="nav-item">Home</div>
    <div class="nav-item">About</div>
  </div>
</div>

<div class="content">
  <div class="article">
    <div class="title">Article Title</div>
    <div class="text">Content here...</div>
  </div>
</div>
```

### Heading hierarchy
```html
<!-- Good - logical hierarchy -->
<h1>Main Page Title</h1>
  <h2>Section 1</h2>
    <h3>Subsection 1.1</h3>
    <h3>Subsection 1.2</h3>
  <h2>Section 2</h2>
    <h3>Subsection 2.1</h3>

<!-- Bad - skipping levels -->
<h1>Main Page Title</h1>
  <h3>Section 1</h3>
  <h5>Subsection</h5>
```

## Accessibility

### Images: always use alt text
```html
<!-- Good -->
<img src="product.jpg" alt="Blue cotton t-shirt with pocket">

<!-- Good - decorative image -->
<img src="decoration.svg" alt="" role="presentation">

<!-- Bad -->
<img src="product.jpg">
```

### Links: descriptive text
```html
<!-- Good -->
<a href="/docs">Read the documentation</a>
<a href="/login">Log in to your account</a>

<!-- Bad -->
<a href="/docs">Click here</a>
<a href="/login">Here</a>
```

### Forms: label all inputs
```html
<!-- Good -->
<label for="email">Email address</label>
<input type="email" id="email" name="email" required>

<!-- Good - implicit label -->
<label>
  Email address
  <input type="email" name="email" required>
</label>

<!-- Bad -->
<input type="email" placeholder="Email">
```

### ARIA when needed
```html
<!-- Navigation landmark -->
<nav aria-label="Main navigation">
  <ul>
    <li><a href="/">Home</a></li>
  </ul>
</nav>

<!-- Button states -->
<button aria-pressed="false">Toggle</button>
<button aria-expanded="true">Menu</button>

<!-- Live regions -->
<div role="alert" aria-live="assertive">
  Error: Please fill in all fields
</div>
```

### Keyboard navigation
```html
<!-- Interactive elements should be keyboard accessible -->
<button type="button">Click me</button>

<!-- Don't do this -->
<div onclick="handleClick()">Click me</div>

<!-- If you must, add keyboard support -->
<div 
  role="button" 
  tabindex="0"
  onclick="handleClick()"
  onkeydown="if(event.key==='Enter')handleClick()">
  Click me
</div>
```

## Forms

### Complete form example
```html
<form action="/submit" method="post">
  <label for="name">Full name</label>
  <input 
    type="text" 
    id="name" 
    name="name" 
    required
    autocomplete="name">
  
  <label for="email">Email address</label>
  <input 
    type="email" 
    id="email" 
    name="email" 
    required
    autocomplete="email">
  
  <label for="message">Message</label>
  <textarea 
    id="message" 
    name="message" 
    rows="5"
    required></textarea>
  
  <button type="submit">Send message</button>
</form>
```

### Input types
```html
<!-- Use specific input types -->
<input type="email">
<input type="tel">
<input type="url">
<input type="number" min="0" max="100">
<input type="date">
<input type="color">
<input type="file" accept="image/*">
```

### Form validation
```html
<input 
  type="email" 
  required
  pattern="[^@\s]+@[^@\s]+\.[^@\s]+"
  title="Valid email address">

<input 
  type="password" 
  required
  minlength="8"
  title="At least 8 characters">
```

## Media Elements

### Images: responsive and optimized
```html
<!-- Responsive image -->
<img 
  src="image-800w.jpg"
  srcset="image-400w.jpg 400w,
          image-800w.jpg 800w,
          image-1200w.jpg 1200w"
  sizes="(max-width: 600px) 100vw,
         (max-width: 1200px) 50vw,
         800px"
  alt="Description"
  loading="lazy">

<!-- Modern image formats -->
<picture>
  <source srcset="image.avif" type="image/avif">
  <source srcset="image.webp" type="image/webp">
  <img src="image.jpg" alt="Description">
</picture>
```

### Video: accessible and controlled
```html
<video 
  controls 
  preload="metadata"
  poster="thumbnail.jpg">
  <source src="video.mp4" type="video/mp4">
  <source src="video.webm" type="video/webm">
  <track 
    kind="subtitles" 
    src="subtitles-en.vtt" 
    srclang="en" 
    label="English">
  Your browser doesn't support video.
</video>
```

## Performance

### Script loading
```html
<!-- Defer non-critical scripts -->
<script src="/js/main.js" defer></script>

<!-- Async for independent scripts -->
<script src="/js/analytics.js" async></script>

<!-- Module scripts -->
<script type="module" src="/js/app.js"></script>
```

### Preloading resources
```html
<!-- Preload critical resources -->
<link rel="preload" href="/fonts/main.woff2" as="font" type="font/woff2" crossorigin>
<link rel="preload" href="/css/critical.css" as="style">

<!-- Preconnect to external domains -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://cdn.example.com">
```

### Lazy loading
```html
<!-- Lazy load images -->
<img src="image.jpg" alt="Description" loading="lazy">

<!-- Lazy load iframes -->
<iframe src="video.html" loading="lazy"></iframe>
```

## SEO and Meta Tags

### Essential meta tags
```html
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Page description">
  <title>Page Title - Site Name</title>
  
  <!-- Open Graph -->
  <meta property="og:title" content="Page Title">
  <meta property="og:description" content="Page description">
  <meta property="og:image" content="https://example.com/image.jpg">
  <meta property="og:url" content="https://example.com/page">
  <meta property="og:type" content="website">
  
  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="Page Title">
  <meta name="twitter:description" content="Page description">
  
  <!-- Canonical URL -->
  <link rel="canonical" href="https://example.com/page">
</head>
```

### Structured data
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Article Title",
  "author": {
    "@type": "Person",
    "name": "Author Name"
  },
  "datePublished": "2026-02-13"
}
</script>
```

## Common Patterns

### Skip to main content
```html
<a href="#main-content" class="skip-link">
  Skip to main content
</a>

<main id="main-content">
  <!-- Content -->
</main>
```

### Card component
```html
<article class="card">
  <img src="image.jpg" alt="Product name" loading="lazy">
  <h2>Product Name</h2>
  <p>Product description goes here.</p>
  <a href="/product">View details</a>
</article>
```

### Modal dialog
```html
<dialog id="modal">
  <h2>Modal Title</h2>
  <p>Modal content here.</p>
  <button type="button" onclick="this.closest('dialog').close()">
    Close
  </button>
</dialog>

<button onclick="document.getElementById('modal').showModal()">
  Open modal
</button>
```

### Breadcrumb navigation
```html
<nav aria-label="Breadcrumb">
  <ol>
    <li><a href="/">Home</a></li>
    <li><a href="/category">Category</a></li>
    <li aria-current="page">Current Page</li>
  </ol>
</nav>
```

## Tables

### Accessible data tables
```html
<table>
  <caption>Monthly Sales Data</caption>
  <thead>
    <tr>
      <th scope="col">Month</th>
      <th scope="col">Sales</th>
      <th scope="col">Growth</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">January</th>
      <td>$10,000</td>
      <td>+5%</td>
    </tr>
  </tbody>
</table>
```

## Icons

Use inline SVG for all icons and visual symbols. Do not use emoji as icons or UI elements.

```html
<!-- Good - SVG icon with accessible label -->
<button type="button" aria-label="Close">
  <svg width="16" height="16" viewBox="0 0 16 16" aria-hidden="true" focusable="false">
    <path d="M2 2l12 12M14 2L2 14" stroke="currentColor" stroke-width="2"/>
  </svg>
</button>

<!-- Bad - emoji as icon -->
<button type="button">✕</button>
<button type="button">🔍 Search</button>
```

## What to Avoid

- Divs for everything (use semantic elements)
- Missing alt text on images
- Unlabeled form inputs
- Non-semantic heading order
- Inline styles (use CSS)
- Empty links or buttons
- Tables for layout
- Missing lang attribute
- Non-keyboard-accessible interactive elements
- Emoji as icons or UI elements (use SVG)

## Communication Style

When writing HTML:
- State what you're building concisely
- Show markup without excessive explanation
- Structure should be self-explanatory
- Minimal markdown formatting
- Direct and to the point
