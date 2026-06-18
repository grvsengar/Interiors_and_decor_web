# GStack Browse QA Guide

A complete guide to browser-based QA testing using GStack Browse — from first-time setup to running a full test pass on your Rails app.

---

## What is GStack Browse?

GStack Browse (`$B`) is a headless Chromium browser controlled from the terminal. It lets you navigate pages, interact with UI elements, capture screenshots, inspect the console, and verify real user flows — the same way a QA engineer would, but scriptable and repeatable.

---

## 1. Setup

### Prerequisites

- GStack installed at `~/.claude/skills/gstack/`
- Bun runtime (installed automatically by GStack setup)
- A running local dev server (e.g. `rails server` on `localhost:3000`)

### One-time build

If the browse binary doesn't exist yet, build it:

```bash
cd ~/.claude/skills/gstack
./setup
```

This compiles `browse/dist/browse` for your platform (~30 seconds).

### Set the `$B` shortcut

Add this to your shell profile (`.bashrc` or `.zshrc`) for convenience:

```bash
export B="$HOME/.claude/skills/gstack/browse/dist/browse"
```

Or use the full path inline:

```bash
~/.claude/skills/gstack/browse/dist/browse goto http://localhost:3000
```

### Verify it works

```bash
$B goto https://example.com
$B screenshot /tmp/test.png
```

---

## 2. Core Commands Reference

### Navigation

```bash
$B goto http://localhost:3000          # navigate to URL
$B goto http://localhost:3000/contact  # navigate to a specific page
$B back                                # browser back
$B reload                              # reload current page
$B url                                 # print current URL
```

### Taking Screenshots

```bash
$B screenshot /tmp/page.png                     # full page screenshot
$B screenshot --viewport /tmp/page.png          # viewport only (no scroll)
$B responsive /tmp/shots/page                   # 3 screenshots: mobile/tablet/desktop
```

### Snapshots (Interactive element map)

`snapshot` is the most important QA command — it maps every clickable/fillable element on the page and assigns `@e1`, `@e2`... refs you can use as selectors.

```bash
$B snapshot                    # text snapshot of elements
$B snapshot -i                 # interactive elements only (buttons, links, inputs)
$B snapshot -i -a -o /tmp/annotated.png   # annotated screenshot with ref labels
$B snapshot -D                 # diff against previous snapshot (shows what changed)
$B snapshot -C                 # find non-ARIA clickable elements (divs with cursor:pointer)
```

### Clicking and Filling

```bash
$B click @e3                   # click element by ref
$B click "Submit"              # click by text
$B click "button.submit"       # click by CSS selector

$B fill @e4 "John Smith"       # fill input by ref
$B fill "#name" "John Smith"   # fill by CSS selector

$B select @e5 "Plywood Cupboards"    # select dropdown option by label
$B hover @e2                   # hover (triggers hover states)
$B press Tab                   # keyboard press
$B type "Hello world"          # type text at current focus
```

### Console and Network

```bash
$B console                     # all console output
$B console --errors            # errors and warnings only

$B js "document.title"                                   # run JS, get return value
$B js "window.location.href"                             # get current URL from JS
$B js "performance.getEntriesByType('resource').length"  # count loaded resources
```

### Checking for Failed Resources

This is the key command to verify zero 4xx/5xx errors on a page:

```bash
$B js "JSON.stringify(
  performance.getEntriesByType('resource')
    .filter(r => r.responseStatus && r.responseStatus >= 400)
    .map(r => ({ url: r.name, status: r.responseStatus }))
)"
```

Returns `[]` when everything loaded cleanly.

### Viewport / Mobile Testing

```bash
$B viewport 375x812            # iPhone SE
$B viewport 768x1024           # iPad
$B viewport 1280x720           # desktop (reset to this after mobile tests)
```

---

## 3. QA Workflow for Kala Interiors

### Step 1 — Start the Rails server

```bash
cd ~/kala_interiors
rails server
```

Confirm it's running:

```bash
$B goto http://localhost:3000
```

Expect: `Navigated to http://localhost:3000 (200)`

### Step 2 — Create output directories

```bash
mkdir -p ~/kala_interiors/.gstack/qa-reports/screenshots
```

### Step 3 — Test each page

Run this block for each page. Replace `PAGE` and `NAME`:

```bash
PAGE="http://localhost:3000"
NAME="home"
SHOTS="$HOME/kala_interiors/.gstack/qa-reports/screenshots"

$B goto $PAGE
sleep 1
$B screenshot "$SHOTS/$NAME.png"

# Check for failed resources
$B js "JSON.stringify(performance.getEntriesByType('resource').filter(r=>r.responseStatus && r.responseStatus>=400).map(r=>({url:r.name,status:r.responseStatus})))"
```

Pages to test:

| Page | URL |
|------|-----|
| Home | `http://localhost:3000` |
| Services | `http://localhost:3000/services` |
| Portfolio | `http://localhost:3000/portfolio` |
| About | `http://localhost:3000/about` |
| Contact | `http://localhost:3000/contact` |

### Step 4 — Test interactive elements

#### Contact form

```bash
$B goto http://localhost:3000/contact
$B snapshot -i

# Fill form using the @e refs from snapshot output
$B fill @e10 "Test User"
$B fill @e11 "+91 9876543210"
$B fill @e12 "test@example.com"
$B select @e13 "Plywood Cupboards"
$B fill @e30 "Hyderabad"
$B select @e31 "₹3 – ₹7 Lakhs"
$B fill @e38 "Test message"

$B screenshot $SHOTS/contact-filled.png
$B click @e39           # Submit button
sleep 2
$B screenshot $SHOTS/contact-submitted.png
```

Expect: page reloads to `/contact` with a green flash success message at the top.

#### Portfolio filter

```bash
$B goto http://localhost:3000/portfolio
$B snapshot -i          # find filter buttons (@e7=All, @e8=Living Room, etc.)

$B click @e8            # click "Living Room"
sleep 1
$B screenshot $SHOTS/portfolio-filtered.png

$B click @e7            # click "All" to reset
```

Expect: grid shows only filtered items after clicking a category.

### Step 5 — Mobile testing

```bash
$B viewport 375x812

$B goto http://localhost:3000
$B screenshot $SHOTS/home-mobile.png

# Test hamburger menu
$B snapshot -i          # find @e2 = Menu button
$B click @e2
sleep 1
$B screenshot $SHOTS/mobile-menu-open.png
# Confirm nav links appear in snapshot after click

$B viewport 1280x720    # reset
```

---

## 4. Reading Console Output

The `$B console --errors` command shows the **accumulated history** from the entire browser session, not just the current page. Timestamps in the past (hours ago) are stale — ignore them.

To see only **current page errors**, use the performance API approach:

```bash
# Navigate fresh first
$B goto http://localhost:3000
sleep 1

# Check what actually failed to load on THIS page load
$B js "JSON.stringify(performance.getEntriesByType('resource').filter(r=>r.responseStatus && r.responseStatus>=400).map(r=>({url:r.name,status:r.responseStatus})))"
```

A result of `[]` means the page is clean — no 4xx or 5xx resource failures.

### Common false positives to ignore

| Error | Why it appears | Action |
|-------|---------------|--------|
| `status:0` on Unsplash images | Opaque CORS response in headless mode — not a real error | Ignore |
| Preload warnings for `.css` files | Turbo hover-prefetch (disabled in this project) | Ignore |
| Old 403s with timestamps from hours ago | Stale console history from previous sessions | Ignore |
| `401` / `403` at old timestamps | Accumulated from past test runs | Ignore |

---

## 5. Health Score Rubric

After testing all pages, calculate a health score:

| Category | Weight | Scoring |
|----------|--------|---------|
| Console errors | 15% | 0 errors=100, 1-3=70, 4-10=40, 10+=10 |
| Broken links | 10% | -15 per broken link |
| Functional (forms, buttons) | 20% | -25 critical, -15 high, -8 medium |
| Visual layout | 10% | -25 critical, -15 high, -8 medium |
| UX / responsiveness | 15% | -25 critical, -15 high, -8 medium |
| Accessibility | 15% | -25 critical, -15 high, -8 medium |
| Performance | 10% | -25 critical, -15 high, -8 medium |
| Content | 5% | -25 critical, -15 high, -8 medium |

**Score = Σ (category_score × weight)**

---

## 6. Known Issues & Context

| Issue | Status | Fix Applied |
|-------|--------|-------------|
| Pexels video 403 | Fixed | Replaced `<video>` with CSS `background-image` (Unsplash) |
| Turbo preload console warnings | Fixed | `<meta name="turbo-prefetch" content="false">` in `<head>` |
| Chrome DevTools 403 | Fixed | Route added: `/.well-known/appspecific/com.chrome.devtools.json` → `{}` |
| CSRF 422 hard error | Fixed | `rescue_from` in `ApplicationController` + branded 422 page |
| Generic Rails 404 page | Fixed | Branded `public/404.html` matching Kala Interiors design |
| Phone link opening Zoom picker | Fixed | `tel:+918686475754` (E.164 format with country code) |

---

## 7. Running /qa Skill (automated)

GStack has a built-in `/qa` skill that automates the entire workflow above — it navigates every page, finds bugs, fixes them in source code, commits each fix atomically, and produces a structured report.

To invoke it in Claude Code:

```
/qa http://localhost:3000
```

Or simply:

```
/qa
```

(It auto-detects the running app on common ports: 3000, 4000, 8080.)

The skill produces:
- `~/kala_interiors/.gstack/qa-reports/qa-report-localhost-YYYY-MM-DD.md`
- Before/after screenshots for every fix
- A health score (baseline → final)
- Atomic commits per fix: `fix(qa): ISSUE-NNN — description`

---

## 8. Quick Reference Card

```bash
# Navigate
$B goto http://localhost:3000

# Snapshot interactive elements (get @e refs)
$B snapshot -i

# Annotated screenshot
$B snapshot -i -a -o /tmp/annotated.png

# Screenshot
$B screenshot /tmp/page.png

# Check for failed resources (0 = clean)
$B js "JSON.stringify(performance.getEntriesByType('resource').filter(r=>r.responseStatus&&r.responseStatus>=400).map(r=>({url:r.name,status:r.responseStatus})))"

# Fill a form field
$B fill @e10 "value"

# Click
$B click @e3

# Select dropdown
$B select @e13 "Option Label"

# Mobile viewport
$B viewport 375x812

# Reset viewport
$B viewport 1280x720

# Diff: what changed after an action?
$B snapshot -D

# Responsive (3 viewports at once)
$B responsive /tmp/shots/prefix
```
