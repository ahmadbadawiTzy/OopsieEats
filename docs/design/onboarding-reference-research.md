# NutriView (OopsieEats) — External Onboarding Design Research & Neo-Brutalism Overkill Synthesis

**Author:** Mobile Product Design & Flutter UI/UX Engineering Team  
**Target Module:** `frontend/lib/features/onboarding/`  
**Design Direction:** Neo-Brutalism Overkill (Official NutriView Green, Mint, Yellow, Cream, Orange, Sky Blue & Lavender Identity)  
**Source of Truth:** [`lib/core/neo_tokens.dart`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/OopsieEats/frontend/lib/core/neo_tokens.dart) & [`lib/core/theme.dart`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/OopsieEats/frontend/lib/core/theme.dart)

---

## 1. External Visual Research & Inspiration Sources

Before designing the NutriView onboarding experience, we conducted a targeted visual audit across leading product design and editorial graphic design platforms (**Dribbble**, **Behance**, **Pinterest**, **Mobbin**, **Refero**, and **Figma Community**) and filtered every insight through NutriView's authoritative [`NeoTokens`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/OopsieEats/frontend/lib/core/neo_tokens.dart) brand palette:

### Reference 1 — Neo-Brutalism Mobile Onboarding & Lifestyle Carousels (Dribbble & Figma Community)
- **Visual Characteristics**:
  - High-saturation flat vector backdrops paired with tactile halftone/dot-matrix and architectural blueprint grids.
  - Thick `#111111` structural borders (`2.0px–2.8px`) with zero-blur hard offset shadows (`Offset(4, 4)` to `Offset(6, 6)`).
  - Asymmetrical sticker badges (`-3°` to `+6°` rotation) acting as category kickers, nutrition tags, and interactive callouts.
- **Adaptation for NutriView**:
  - Filtered through NutriView's official `NeoTokens.primaryGreen` (`#16A34A`), `NeoTokens.mintGreen` (`#CCFF00`), and `NeoTokens.vividYellow` (`#FFD600`) stage hierarchy.

### Reference 2 — Editorial Food & Street-Culture Zine Collages (Behance & Pinterest)
- **Visual Characteristics**:
  - Real human photography cut out as die-cut vinyl stickers with a thick white inner contour (`6px–10px`), a crisp black outer stroke (`2.5px–3.5px`), and a hard black offset drop shadow.
  - Surrounding food illustrations treated as collectible stamps and specimen cards rather than floating unanchored clip-art.
  - Jagged torn-paper dividers (`TornPaperCard`) separating the maximalist upper visual stage from the high-legibility warm cream editorial copy deck below.
- **Adaptation for NutriView**:
  - Enhanced all 3 portrait stickers (`onboarding_1_sticker.png`, `onboarding_2_sticker.png`, `onboarding_3_sticker.png`) to crisp high resolution (`1200×1607` and `1152×1594`) with smooth white die-cut contours, solid `#0A0A0A` black outer outlines, and hard offset drop shadows while 100% preserving facial identity and the real plate of Nasi Goreng.

### Reference 3 — High-Conversion Consumer Food & Nutrition Onboarding Flows (Mobbin & Refero)
- **Visual Characteristics**:
  - Clear 3-act narrative progression:
    1. **Act I — Instant Food Discovery** (The joy of scanning real local dishes).
    2. **Act II — Macro & Micronutrient Clarity** (Breaking a meal into actionable nutrition telemetry).
    3. **Act III — Daily Habit Loop** (Streaks, meal checklists, and progress bars).
  - Persistent top-bar orientation (`BrandBadge` + `SkipButton`) and thumb-friendly bottom navigation (`PageIndicator` pills + tactile `Next` / `MULAI SEKARANG` CTA).

---

## 2. 12-Point Design Analysis & Synthesis

| # | Design Dimension | Research Insight | NutriView Implementation Strategy (`NeoTokens` Single Source of Truth) |
| :--- | :--- | :--- | :--- |
| **1** | **Color Psychology** | Fresh green + high-voltage acid lime/mint + hazard yellow stimulates appetite, health vitality, and instant visual recall. | Anchor Slide 1 in `NeoTokens.primaryGreen` (`#16A34A`), Slide 2 in `NeoTokens.vividYellow` (`#FFD600`) with concentric `primaryGreen` + `mintGreen` target rings, and Slide 3 in `NeoTokens.mintGreen` (`#CCFF00`) with a `primaryGreen` + `vividYellow` radial sunburst. |
| **2** | **Typography Hierarchy** | Display headlines need tight negative tracking (`-0.8` to `-1.0`), `FontWeight.w900`, and boxed highlight spans. | Pair `NeoTokens.black` (`#111111`) display text on `NeoTokens.warmBackground` (`#FBF9F4`) with bordered highlight spans (`Piringmu!`, `Punya Arti!`, `Kebiasaanmu!`) using `vividYellow` and `mintGreen`. |
| **3** | **Layout Structure** | Full-bleed `65% / 38%` split with overlapping jagged torn-paper transition prevents static horizontal seams. | Maintain responsive `LayoutBuilder` split (`artHeight = 0.65h`, `cardHeight = 0.38h`) with triple-layer jagged `TornPaperCard` (`mintGreen` / `primaryGreen` / `vividYellow` accent ridge + `black` border + `warmBackground` fill). |
| **4** | **Card & Frame Styling** | Floating elements look richer when framed like specimen cards, stamps, or taped notes. | Wrap key food items on Slide 1 in rotated brutalist stamp frames (`warmBackground`, `vividYellow`, `orangeCarb`, `white`), upgrade Slide 2 `NutritionCalloutCard`s with macro chips, and upgrade Slide 3's sticky note & chart card. |
| **5** | **Shadow & Border System** | Authentic Neo-Brutalism strictly forbids Gaussian blur (`blurRadius: 0.0`). | Use `NeoTokens.borderWidth` (`2.0px`) / `NeoTokens.borderWidthThick` (`2.8px`) and `NeoTokens.shadowOffsetMedium` (`Offset(4, 4)`) across every badge, card, sticker, and button. |
| **6** | **Visual Rhythm Across Slides** | Each slide must have a distinct geometric centerpiece behind the character. | Slide 1: 22-point `vividYellow` Starburst + `mintGreen` diagonal strip + `lavender` circle. Slide 2: Concentric `primaryGreen` & `mintGreen` target bullseye + blueprint grid + `lavender` triangle. Slide 3: Radial 12-ray `vividYellow` & `primaryGreen` Sunburst + dot matrix. |
| **7** | **CTA Placement** | Primary action must sit in the natural bottom thumb zone with physical press feedback. | Slides 1–2: 58×58 circular `vividYellow` arrow button. Slide 3: Full-width 58px `primaryGreen` pill button (`MULAI SEKARANG`) with a circular `vividYellow` arrow badge. |
| **8** | **Slide Indicator Design** | Active pill should expand horizontally with a hard offset shadow. | 38×12 `NeoTokens.primaryGreen` active pill with `2px` black border and `Offset(2, 2)` hard shadow; 12×12 `NeoTokens.white` inactive pills. |
| **9** | **Image Cropping & Framing** | Portrait cutouts must have uniform, high-DPI die-cut sticker outlines and hard shadows. | All 3 portrait PNGs enhanced to `1200×1607` / `1152×1594` with smooth white die-cut borders, solid `#0A0A0A` outlines, and hard offset drop shadows. |
| **10** | **Food Presentation** | All 13 Indonesian food assets should be showcased with zero overlap on human faces. | Utilize all 13 food assets (`nasi_goreng`, `sate`, `bakso`, `pisang_goreng`, `martabak`, `klepon`, `cabai`, `tomat`, `mangga`, `semangka`, `ayam_goreng`, `rendang`, `wortel`) with `FilterQuality.high`. |
| **11** | **Decorative Layering** | 5 distinct depth planes create "Overkill" richness without cluttering the focal point. | Plane 1: Stage color + grid/dots -> Plane 2: Geometric shapes (`mintGreen`, `lavender`, `vividYellow`) -> Plane 3: Central starburst/bullseye/sunburst -> Plane 4: Framed food stamps & telemetry cards -> Plane 5: Hero portrait sticker. |
| **12** | **Mobile Ergonomics & Safe Zones** | Zero `RenderFlex` overflow across `360×800` to `430×932` viewports and strict Face Safe Zone protection. | Enforce mathematical Face Safe Zones on all 3 slides (`Slide 1: [0.24w..0.70w]×[0.18h..0.48h]`, `Slide 2: [0.27w..0.72w]×[0.20h..0.50h]`, `Slide 3: [0.28w..0.72w]×[0.22h..0.52h]`). |

---

## 3. Official NutriView Brand Palette Mapping (`NeoTokens` Single Source of Truth)

```
┌────────────────────────────────────────────────────────────────────────────┐
│ OFFICIAL NUTRIVIEW NEO-BRUTALISM OVERKILL PALETTE (lib/core/neo_tokens.dart)│
├──────────────────────┬────────────┬────────────────────────────────────────┤
│ Token                │ Hex        │ Role in Onboarding Carousel            │
├──────────────────────┼────────────┼────────────────────────────────────────┤
│ NeoTokens.primaryGreen│ #16A34A   │ Slide 1 Stage, Slide 2 Outer Target,   │
│                      │            │ Slide 3 Sun Core, Active Pill, Final CTA│
│ NeoTokens.mintGreen  │ #CCFF00    │ Slide 3 Stage, Slide 1 Diagonal Strip, │
│                      │            │ Slide 2 Inner Target, Telemetry Pills  │
│ NeoTokens.vividYellow│ #FFD600    │ Slide 2 Stage, Slide 1 Starburst,      │
│                      │            │ Slide 3 Sunburst Rays, Next Button     │
│ NeoTokens.orangeCarb │ #FF6B00    │ Karbohidrat Header, Klepon Frame,      │
│                      │            │ Slide 3 Progress Chart Bar 2           │
│ NeoTokens.skyBlue    │ #1D4ED8    │ Vitamin Specimen Header                │
│ NeoTokens.cyan       │ #06B6D4    │ Slide 3 Progress Chart 100% Bar        │
│ NeoTokens.lavender   │ #C4B5FD    │ Slide 1 Circle, Slide 2 Triangle &     │
│                      │            │ Energi Specimen Header                 │
│ NeoTokens.coralRed   │ #EF4444    │ High-alert / warning token             │
│ NeoTokens.warmBackground│ #FBF9F4 │ Torn-Paper Copy Deck, Skip Pill, Stamps│
│ NeoTokens.white      │ #FFFFFF    │ Specimen Card Surface, Die-Cut Border  │
│ NeoTokens.black      │ #111111    │ 2.0–2.8px Outlines, Hard Shadows, Copy │
└──────────────────────┴────────────┴────────────────────────────────────────┘
```
