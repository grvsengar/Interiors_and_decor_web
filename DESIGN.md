# Kala Interiors & Decor — Design System

## Brand Identity
- **Client:** Kala Interiors & Decor
- **Founder:** Vivek Kumar Thodupunuri (MD)
- **Tagline:** "Modern design your home!"
- **Serving:** All of Telangana

## Color Palette
| Token | Hex | Usage |
|-------|-----|-------|
| Navy | `#0A1628` | Primary background, headings, CTA bg |
| Dark Navy | `#080F1E` | Footer, deep sections |
| Gold | `#C9A84C` | Accents, CTA primary, stats bar |
| Off-White | `#F8F7F4` | Section alternation |
| White | `#FFFFFF` | Cards, body bg |

## Typography
- **Display/Headings:** Cormorant Garamond, weight 300–400, italic for emphasis
- **Body/UI:** Inter, weight 300 (light) for copy, 400–500 for labels

## Logo
- Geometric sun/arch mark in gold on navy circle
- SVG inline in navigation

## Pages
- `/` Home — hero, stats, about intro, services grid, portfolio preview, process, testimonials, CTA
- `/services` — hero, detailed service cards for all 13 services
- `/portfolio` — filterable masonry grid with JS filter tabs
- `/about` — founder bio, company story, values, timeline
- `/contact` — form + contact info + WhatsApp CTA

## Tech Stack
- Ruby on Rails 8.0.5
- Tailwind CSS v4 (via tailwindcss-rails gem)
- Propshaft asset pipeline
- SQLite3
- Google Fonts: Cormorant Garamond + Inter
- Images: Unsplash CDN
