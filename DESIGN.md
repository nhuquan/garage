---
name: Garage Design System
colors:
  surface: '#f6fafe'
  surface-dim: '#d6dade'
  surface-bright: '#f6fafe'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f4f8'
  surface-container: '#eaeef2'
  surface-container-high: '#e4e9ed'
  surface-container-highest: '#dfe3e7'
  on-surface: '#171c1f'
  on-surface-variant: '#424754'
  inverse-surface: '#2c3134'
  inverse-on-surface: '#edf1f5'
  outline: '#727785'
  outline-variant: '#c2c6d6'
  surface-tint: '#005ac2'
  primary: '#0058be'
  on-primary: '#ffffff'
  primary-container: '#2170e4'
  on-primary-container: '#fefcff'
  inverse-primary: '#adc6ff'
  secondary: '#505f76'
  on-secondary: '#ffffff'
  secondary-container: '#d0e1fb'
  on-secondary-container: '#54647a'
  tertiary: '#006947'
  on-tertiary: '#ffffff'
  tertiary-container: '#00855b'
  on-tertiary-container: '#f5fff6'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#004395'
  secondary-fixed: '#d3e4fe'
  secondary-fixed-dim: '#b7c8e1'
  on-secondary-fixed: '#0b1c30'
  on-secondary-fixed-variant: '#38485d'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f6fafe'
  on-background: '#171c1f'
  surface-variant: '#dfe3e7'
typography:
  h1:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  h2:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  stat-number:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
    letterSpacing: -0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 16px
  gutter: 12px
---

## Brand & Style

The design system is engineered for high-utility vehicle management, prioritizing clarity, trust, and precision. It targets vehicle enthusiasts and daily commuters who value an organized digital space for their assets. 

The aesthetic is rooted in **Modern Corporate** principles with a focus on **Tonal Layering**. It avoids the clutter often found in automotive apps by utilizing a spacious, airy layout and a refined color palette. The emotional response is one of "calm control"—the interface feels as well-maintained as the vehicles it tracks. Every interaction is designed to feel intentional and fluid, using subtle transitions and clear visual feedback.

## Colors

This design system utilizes a "Cool Slate" palette to achieve a professional, mechanical feel without appearing cold. 

- **Primary Blue**: A vibrant, high-visibility blue used exclusively for primary actions and the Floating Action Button (FAB).
- **Secondary Slate**: Used for secondary information, icons, and non-essential labels.
- **Surface & Background**: The background is a soft blue-grey (#F8FAFC) to reduce eye strain, while cards use pure white to pop against the canvas.
- **Semantic Accents**: Emerald green is used for positive status indicators (e.g., "Service Complete"), and amber/red for warnings or urgent maintenance.

## Typography

The design system uses **Manrope** for its technical yet approachable character. It provides excellent legibility for numerical data, which is critical for vehicle mileage and dates.

- **Hierarchical Contrast**: Bold weights are used for vehicle names and primary headings, while Medium weights are preferred for body text to maintain a premium feel.
- **Data Clarity**: Use the "stat-number" style for odometer readings and costs to ensure they are the first thing a user sees within a card.
- **Labels**: Small-caps labels are used for category headers (e.g., "MOTORCYCLES") to provide clear section breaks without requiring heavy borders.

## Layout & Spacing

This design system follows a strict **8px grid system** for consistent vertical rhythm. 

- **Grid System**: A 4-column fluid grid for mobile views. 
- **Margins**: A standard 16px margin is applied to the left and right of the screen container.
- **Grouping**: Use 8px (xs) for related elements (icon + label) and 16px (md) for spacing between distinct content blocks within a card.
- **Section Spacing**: Large 32px (xl) gaps are used between different vehicle categories to reinforce the visual hierarchy.

## Elevation & Depth

To maintain a modern and "clean" look, this design system uses **Tonal Layers** combined with **Ambient Shadows**.

- **Level 0 (Canvas)**: Background color (#F8FAFC). No shadow.
- **Level 1 (Cards)**: White background with a very soft, diffused shadow (Y: 4px, Blur: 12px, Opacity: 4% Black). Use a 1px stroke in #E2E8F0 for additional definition on high-density displays.
- **Level 2 (Active Elements/FAB)**: The Floating Action Button uses a more pronounced shadow with a slight primary-color tint (Y: 6px, Blur: 16px, Opacity: 20% of Primary Blue) to indicate its interactive priority.
- **Backdrop**: Modals and bottom sheets utilize a 40% opacity black overlay with a 20px backdrop blur.

## Shapes

The shape language is defined by **Soft Geometricism**. 

- **Primary Cards**: Use a 16px (rounded-lg) corner radius to feel friendly and modern.
- **Buttons & Inputs**: Use an 8px (rounded-md) radius for a slightly more precise, "tooled" look compared to the containers.
- **FAB & Badges**: Use fully pill-shaped (rounded-full) corners. This differentiates action-oriented elements from informational containers.
- **Progress Bars**: Use 4px rounded corners for internal tracks to maintain alignment with the outer container.

## Components

- **Vehicle Cards**: Vertical layout. Features a top-aligned circular image placeholder with a subtle status badge (e.g., vehicle type icon). Primary text (Vehicle Name) is followed by secondary meta-data (Year, Model) and a prominent "Chip" for current mileage.
- **Floating Action Button (FAB)**: Large, circular, centered on the right. High-contrast Primary Blue background with a white "plus" icon.
- **Navigation Bar**: A clean, white floating bar at the bottom with a subtle Level 1 shadow. Icons use the Primary color when active and Secondary Slate when inactive.
- **Status Chips**: Small, pill-shaped indicators for "In Service," "Insured," or "Overdue." Use low-saturation background tints with high-saturation text.
- **Segmented Control**: For switching between "All," "Cars," and "Bikes." Uses a pill-shaped container with a sliding white background for the active state.
- **Input Fields**: Border-bottom only or fully outlined with a 1px stroke. The active state is signaled by a Primary Blue border and a subtle glow.