---
name: CampusSignal
colors:
  surface: '#fbf8ff'
  surface-dim: '#DED8E1'
  surface-bright: '#FEF7FF'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f2fd'
  surface-container: '#efecf8'
  surface-container-high: '#e9e7f2'
  surface-container-highest: '#e4e1ec'
  on-surface: '#1b1b23'
  on-surface-variant: '#454554'
  inverse-surface: '#303038'
  inverse-on-surface: '#f2effb'
  outline: '#767685'
  outline-variant: '#c6c5d6'
  surface-tint: '#484ecf'
  primary: '#353abd'
  on-primary: '#ffffff'
  primary-container: '#4f55d6'
  on-primary-container: '#e2e1ff'
  inverse-primary: '#bfc1ff'
  secondary: '#5b5b7b'
  on-secondary: '#ffffff'
  secondary-container: '#dbd9ff'
  on-secondary-container: '#5e5e7e'
  tertiary: '#7e3900'
  on-tertiary: '#ffffff'
  tertiary-container: '#a34c00'
  on-tertiary-container: '#ffdcc9'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#bfc1ff'
  on-primary-fixed: '#03006d'
  on-primary-fixed-variant: '#2e32b6'
  secondary-fixed: '#e1dfff'
  secondary-fixed-dim: '#c4c3e8'
  on-secondary-fixed: '#181935'
  on-secondary-fixed-variant: '#444462'
  tertiary-fixed: '#ffdbc8'
  tertiary-fixed-dim: '#ffb68b'
  on-tertiary-fixed: '#321300'
  on-tertiary-fixed-variant: '#743400'
  background: '#fbf8ff'
  on-background: '#1b1b23'
  surface-variant: '#e4e1ec'
  tertiary-accent: '#82524A'
  error-alert: '#BA1A1A'
typography:
  display-sm:
    fontFamily: Roboto Flex
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.5px
  headline-md:
    fontFamily: Roboto Flex
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-sm:
    fontFamily: Roboto Flex
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Roboto Flex
    fontSize: 22px
    fontWeight: '400'
    lineHeight: 28px
  title-md:
    fontFamily: Roboto Flex
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0.15px
  title-sm:
    fontFamily: Roboto Flex
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.1px
  body-md:
    fontFamily: Roboto Flex
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Roboto Flex
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-sm:
    fontFamily: Roboto Flex
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
  headline-md-mobile:
    fontFamily: Roboto Flex
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  gutter: 16px
  margin-mobile: 16px
  margin-tablet: 24px
  margin-desktop: 32px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style
The design system is built on the **Material 3 Expressive** philosophy, characterized by a "signal, not noise" approach. It balances the rigor of an information-dense platform with the approachability of a student-centric tool. The brand personality is **Calm, Organized, and Trustworthy**, prioritizing cognitive clarity and intentional focus.

The visual style is **Corporate / Modern** with **Expressive / Organic** accents. It utilizes the core tenets of the Android design language—fluid motion, tonal hierarchy, and adaptive shapes—while introducing organic, "blob-like" decorative elements to soften the utility and add a layer of youthful energy. The experience should feel native, responsive, and intelligently filtered.

## Colors
The color system is a dynamic tonal scheme generated from a single **Vivid Indigo-Violet** seed. This seed represents "Clarity" and serves as the primary engine for the interface's hierarchy.

- **Primary (#4F55D6)**: Used for the most critical actions and active states. It represents the "Signal."
- **Secondary**: A muted, desaturated indigo used for auxiliary controls and neutral interactions.
- **Tertiary**: An accent hue used for category-specific coding and organic decorative moments.
- **Surface Tones**: Hierarchy is established through **Tonal Elevation** rather than shadows. Components use `surface-container` levels (Low to Highest) to sit on the base `surface` color, creating a natural sense of depth.

## Typography
The system exclusively uses **Roboto Flex**, a variable font that allows for precise weight adjustments to emphasize information hierarchy. 

Headlines and Titles utilize **Emphasized Weights** (600-700) to grab attention and anchor the page layout. Body text remains at standard weights for maximum legibility in dense descriptions. Metadata and secondary labels use higher letter-spacing and medium weights to ensure they remain readable at small scales. Large display sizes should be scaled down for mobile views to prevent excessive line-breaking.

## Layout & Spacing
This design system follows an **8dp/4dp grid rhythm**, optimized for native Android environments. The layout philosophy is centered on **Generous Whitespace** to ensure the "Signal" is never crowded.

- **Grid**: A fluid grid system with a 16px margin on mobile devices, increasing to 32px on larger screens.
- **Vertical Rhythm**: Elements are stacked using increments of 8px (e.g., 8px between a title and its subtitle, 24px between distinct sections).
- **Safe Areas**: All layouts must respect system bars (status and navigation) with a minimum 16px safety margin from the screen edge.

## Elevation & Depth
Elevation is primarily conveyed through **Tonal Layering**. Instead of traditional drop shadows, we use a tiered background system where higher-priority components are placed on lighter or more saturated tonal containers.

- **Level 0 (Surface)**: The base application background.
- **Level 1-3 (Containers)**: Used for cards, search bars, and unselected chips.
- **Level 4-5 (High Elevation)**: Reserved for Modal Dialogs and Bottom Sheets.
- **Shadow Exceptions**: Only the **Floating Action Button (FAB)** and **Bottom Sheets** utilize soft, ambient shadows to signify their position at the top of the Z-index and their ability to move over content.

## Shapes
The shape language is highly expressive and functional, using varied radii to categorize component types.

- **Sharp (0dp)**: Used only for dividers and full-bleed images.
- **Extra-Small (4dp)**: Chips and input fields.
- **Medium (12dp)**: Compact secondary cards and small dialogs.
- **Large (16dp)**: Primary event cards and bottom sheets.
- **Extra-Large (28dp)**: FABs and primary CTA buttons.
- **Full (Pill)**: Search bars and navigation indicators.
- **Expressive**: Decorative backgrounds use asymmetric, organic "blob" shapes to distinguish them from functional UI elements.

## Components

### Buttons & Chips
- **Primary Buttons**: Extra-large (28dp) or Pill-shaped. Use `primary` fill with `on-primary` text.
- **Filter Chips**: Extra-small (4dp) radius. Use `outline` for unselected and `primary-container` for selected states.
- **FAB**: Always Extra-large (28dp) with a `primary-container` fill, morphing into an Extended FAB on scroll.

### Input Fields
- **Text Fields**: Use the "Small" (8dp) shape. Outlined style is preferred for a clean, "un-noisy" look. Leading icons should be used to provide visual context (e.g., a magnifying glass for search).

### Cards
- **Event Cards**: Use "Large" (16dp) rounded corners. Backgrounds should be `surface-container-low`.
- **Conflict States**: When events overlap in the calendar, use a distinctive bracket border or tonal shift to highlight the "Conflict Detection."

### Lists & Modals
- **Lists**: Separated by `outline-variant` dividers. Standard 16px horizontal padding.
- **Bottom Sheets**: Use "Large" (16dp) top-rounded corners and `surface-container-highest` tonal fill.

### Feedback & Motion
- **Indicators**: Use `primary` for active progress and `error` for urgency.
- **States**: Use a subtle tonal overlay (5-10% opacity) on press states to provide tactile feedback without relying on heavy shadows.