# TamuKu — Design System & Visual Identity

> **Digital Guest Book for Government Offices, Mosques, Apartments, Schools & Communities**
> Version 1.0 · July 2026

---

## 1. Brand Identity

| Attribute | Value |
|-----------|-------|
| **App Name** | TamuKu |
| **Tagline** | Buku Tamu Digital — Cepat, Mudah, Terpercaya |
| **Platform** | Flutter (Android mobile admin + PWA/guest web view) |
| **Roles** | Admin (receptionist, security, RT head) · Guest (visitor) |
| **Target Venues** | Government offices, mosques, apartments, schools, RT/RW |
| **Language** | Indonesian (Bahasa Indonesia) |

### Logo

- **Shape**: Rounded square (24px radius) filled with `primary-green-900` (#1B5E20)
- **Letterform**: White capital "T" centered, Medium weight, ~60% of square height
- **App Icon**: The same rounded square at 1024×1024 with no padding, used as Flutter adaptive icon foreground
- **Logo Text**: "TamuKu" set in system bold, `text-primary` on light backgrounds, white on dark/green

### Brand Personality

| Trait | Expression |
|-------|-----------|
| **Professional** | Clean layouts, structured data, no playful excess |
| **Trustworthy** | Green palette (safety, govt-grade), clear status indicators |
| **Approachable** | Rounded corners, generous whitespace, simple language |
| **Indonesian** | Bahasa-first UI, WIB time format, local venue types (RT/RW, Masjid) |

### Tone of Voice

- **Admin UI**: Direct, efficient — "42 Tamu Hari Ini", "Daftar Tamu", "Pengaturan"
- **Guest UI**: Warm, polite — "Terima kasih!", "Silakan isi data kunjungan Anda"
- **Errors**: Clear, non-alarming — "QR Code Tidak Dikenal. Silakan hubungi resepsionis."
- **No jargon**: Avoid English UI text; keep all labels in Bahasa Indonesia

---

## 2. Color System

### Primary Palette

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `primary-green-900` | #1B5E20 | 27, 94, 32 | App bars, primary buttons, header banners |
| `primary-green-700` | #2E7D32 | 46, 125, 50 | Hover/pressed states, secondary elements, success |
| `primary-green-500` | #43A047 | 67, 160, 71 | Intermediate states |
| `primary-green-100` | #C8E6C9 | 200, 230, 201 | Light fills |
| `primary-green-50` | #E8F5E9 | 232, 245, 233 | Selected chip backgrounds, light card tint |

### Neutral Palette

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `background` | #FAFAF5 | 250, 250, 245 | Screen background (warm off-white) |
| `surface` | #FFFFFF | 255, 255, 255 | Cards, modals, input fields |
| `text-primary` | #1A1A1A | 26, 26, 26 | Headings, body text |
| `text-secondary` | #757575 | 117, 117, 117 | Subtitles, captions, timestamps |
| `text-disabled` | #BDBDBD | 189, 189, 189 | Placeholder text, disabled labels |
| `border` | #E0E0E0 | 224, 224, 224 | Input borders, dividers, card outlines |
| `border-light` | #F0F0F0 | 240, 240, 240 | Subtle separators |

### Accent Palette

| Token | Hex | RGB | Usage |
|-------|-----|-----|-------|
| `accent-red` | #D32F2F | 211, 47, 47 | Checkout button, destructive actions, "Pulang" |
| `accent-red-light` | #FFEBEE | 255, 235, 238 | Error background tint |
| `accent-amber` | #F9A825 | 249, 168, 37 | "Aktif" status badge, warning states |
| `accent-amber-light` | #FFF8E1 | 255, 248, 225 | Error/warning card backgrounds |
| `accent-blue` | #4285F4 | 66, 133, 244 | Google sign-in button |

### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | #2E7D32 | Confirmation checkmark, "Selesai" status |
| `success-bg` | #E8F5E9 | Success card backgrounds |
| `warning` | #F9A825 | Caution states |
| `warning-bg` | #FFF8E1 | Warning card backgrounds |
| `error` | #D32F2F | Error states, destructive actions |
| `error-bg` | #FFEBEE | Error card backgrounds |
| `info` | #4285F4 | Informational states |

### Color Usage Rules

1. **Green on green is forbidden** — never place white text on `primary-green-50` or `primary-green-100`
2. **Red = destructive only** — checkout, logout, delete. Never for neutral actions.
3. **Amber = status only** — "Aktif" badge, warnings. Never for primary actions.
4. **Contrast requirement** — all text must pass WCAG AA (4.5:1 minimum) against its background

---

## 3. Typography Scale

**Font Family**: System default (Roboto on Android, San Francisco on iOS). No custom fonts for MVP.

### Type Scale

| Name | Size | Weight | Line Height | Letter Spacing | Usage |
|------|------|--------|-------------|----------------|-------|
| `display` | 48sp | Bold (700) | 56sp | -0.5 | Dashboard stat numbers |
| `stats` | 36sp | Bold (700) | 44sp | -0.3 | Secondary stat numbers |
| `h1` | 28sp | Bold (700) | 36sp | 0 | Screen titles (inside green banner) |
| `h2` | 22sp | SemiBold (600) | 28sp | 0 | Section headers |
| `h3` | 18sp | Medium (500) | 24sp | 0.15 | Card titles, list item names |
| `body-large` | 16sp | Regular (400) | 24sp | 0.5 | Primary body text, form labels |
| `body` | 14sp | Regular (400) | 20sp | 0.25 | Default body, descriptions |
| `caption` | 12sp | Regular (400) | 16sp | 0.4 | Metadata, timestamps, helper text |
| `button` | 16sp | SemiBold (600) | 24sp | 0.5 | Button labels, chip text |
| `overline` | 10sp | Medium (500) | 16sp | 1.5 | Section labels (uppercase): "PROFIL LOKASI" |

### Typography Rules

1. **Maximum 3 sizes per screen** — avoids visual noise
2. **Bold = hierarchy signal** — only titles and key numbers use Bold
3. **Gray = secondary** — captions and timestamps always in `text-secondary`
4. **No all-caps except** section overlines ("PROFIL LOKASI", "PREFERENSI")
5. **Numbers in stats** — use tabular figures if available; fallback to default

---

## 4. Spacing System

| Token | Value | px | Usage |
|-------|-------|----|-------|
| `space-2xs` | 2dp | 2 | Tight inline spacing (icon-to-text) |
| `space-xs` | 4dp | 4 | Minimal gap (badge padding, chip internal) |
| `space-sm` | 8dp | 8 | Between related items (label-to-field) |
| `space-md` | 12dp | 12 | Between card elements, list item gaps |
| `space-lg` | 16dp | 16 | Card padding, standard gap, screen margin |
| `space-xl` | 24dp | 24 | Between sections, header-to-content |
| `space-2xl` | 32dp | 32 | Screen top/bottom padding |
| `space-3xl` | 48dp | 48 | Large vertical separation |

### Spacing Rules

- **Screen horizontal padding**: 16dp (consistent across all screens)
- **Card internal padding**: 16dp all sides
- **Between cards**: 12dp
- **Between header banner and content**: 0dp (banner flows into content)
- **Bottom safe area**: Respect system insets (minimum 16dp padding)

---

## 5. Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-xs` | 4dp | Badges, small chips |
| `radius-sm` | 8dp | Chips, small buttons, filter pills |
| `radius-md` | 12dp | Input fields, medium buttons, dialogs |
| `radius-lg` | 16dp | Cards, large buttons, bottom sheets |
| `radius-xl` | 24dp | Full-width action buttons |
| `radius-full` | 999dp | Avatar circles, status pills, FABs |

### Radius Rules

- **Cards**: Always `radius-lg` (16dp) — no exceptions
- **Inputs**: Always `radius-md` (12dp)
- **Buttons**: `radius-xl` (24dp) for primary full-width, `radius-sm` (8dp) for compact chips
- **Avatars**: Always `radius-full` (circular)

---

## 6. Elevation & Shadow

| Level | Shadow Value | Opacity | Usage |
|-------|-------------|---------|-------|
| `elevation-0` | none | — | Flat backgrounds, green banner |
| `elevation-1` | `0 1px 3px 0 rgba(0, 0, 0, 0.12), 0 1px 2px -1px rgba(0, 0, 0, 0.08)` | 12% | Cards at rest |
| `elevation-2` | `0 2px 6px 0 rgba(0, 0, 0, 0.16), 0 1px 3px 0 rgba(0, 0, 0, 0.1)` | 16% | Cards pressed, focused inputs |
| `elevation-3` | `0 4px 12px 0 rgba(0, 0, 0, 0.2), 0 2px 4px 0 rgba(0, 0, 0, 0.12)` | 20% | FABs, floating elements |
| `elevation-4` | `0 8px 24px 0 rgba(0, 0, 0, 0.24), 0 4px 8px 0 rgba(0, 0, 0, 0.14)` | 24% | Modals, bottom sheets |

### Shadow Rules

- **Cards**: Always `elevation-1` at rest, `elevation-2` on press
- **Green banners**: No shadow (`elevation-0`) — flat by design
- **Inputs**: `elevation-0` by default, `elevation-2` on focus
- **Dark mode**: Shadows less visible — add subtle border instead

---

## 7. Component Specifications

### 7.1 Button — Primary

| Property | Value |
|----------|-------|
| **Widget** | `ElevatedButton` |
| **Height** | 52dp |
| **Min Width** | Full-width (screen padding applied) |
| **Padding** | Horizontal: 24dp, Vertical: 14dp |
| **Background** | `primary-green-900` (#1B5E20) |
| **Text Color** | White (#FFFFFF) |
| **Text Style** | `button` (16sp, SemiBold) |
| **Border Radius** | `radius-xl` (24dp) |
| **Shadow** | `elevation-1` |

**States:**
| State | Background | Text | Shadow |
|-------|-----------|------|--------|
| Default | #1B5E20 | #FFFFFF | elevation-1 |
| Pressed | #2E7D30 | #FFFFFF | elevation-2, scale 0.98 |
| Disabled | #E0E0E0 | #BDBDBD | elevation-0 |
| Loading | #1B5E20 (70% opacity) | — | Circular progress (white) |

### 7.2 Button — Secondary (Outlined)

| Property | Value |
|----------|-------|
| **Widget** | `OutlinedButton` |
| **Height** | 52dp |
| **Border Color** | `primary-green-900` |
| **Border Width** | 1.5dp |
| **Text Color** | `primary-green-900` |
| **Text Style** | `button` (16sp, SemiBold) |
| **Border Radius** | `radius-xl` (24dp) |
| **Background** | Transparent |

**States:** Same as Primary, but border/text darken to `primary-green-700` on press.

### 7.3 Button — Destructive (Red)

| Property | Value |
|----------|-------|
| **Widget** | `ElevatedButton` |
| **Background** | `accent-red` (#D32F2F) |
| **Text Color** | White |
| **Border Radius** | `radius-xl` (24dp) |
| **Usage** | Checkout confirmation ("Saya Pulang"), logout |

### 7.4 Button — Chip / Compact

| Property | Value |
|----------|-------|
| **Widget** | `ActionChip` or custom `InkWell` + `Container` |
| **Height** | 36dp |
| **Padding** | Horizontal: 12dp, Vertical: 6dp |
| **Border Radius** | `radius-full` (pill shape) |
| **Selected Fill** | `primary-green-900` |
| **Selected Text** | White |
| **Unselected Fill** | Transparent |
| **Unselected Border** | `border` (#E0E0E0) |
| **Unselected Text** | `text-secondary` |
| **Text Style** | `caption` (12sp, Medium) |

### 7.5 Card

| Property | Value |
|----------|-------|
| **Widget** | `Card` or `Container` with `BoxDecoration` |
| **Background** | `surface` (#FFFFFF) |
| **Border Radius** | `radius-lg` (16dp) |
| **Padding** | 16dp all sides |
| **Shadow** | `elevation-1` |
| **Border** | None (shadow provides separation) |
| **Margin** | Horizontal: 16dp screen edge, Vertical: 6dp between cards |

**Variants:**
- **Stat Card**: Horizontal row, number + label, 16dp padding
- **Guest Card**: Avatar + text column + status badge, 12dp internal spacing
- **Info Card**: Light green background (`primary-green-50`), green text, no shadow

### 7.6 Input Field

| Property | Value |
|----------|-------|
| **Widget** | `TextFormField` with `InputDecoration` |
| **Height** | 52dp (intrinsic with content padding) |
| **Border** | 1dp solid `border` (#E0E0E0) |
| **Border Radius** | `radius-md` (12dp) |
| **Padding** | Horizontal: 16dp, Vertical: 14dp |
| **Background** | `surface` (#FFFFFF) |
| **Text Style** | `body-large` (16sp, Regular) |
| **Placeholder Color** | `text-disabled` (#BDBDBD) |
| **Label Color** | `text-secondary` (#757575), 12sp |

**States:**
| State | Border | Background | Shadow |
|-------|--------|------------|--------|
| Default | #E0E0E0 | #FFFFFF | none |
| Focused | #1B5E20 (2dp) | #FFFFFF | elevation-2 |
| Error | #D32F2F | #FFFFFF | none |
| Disabled | #F0F0F0 | #F5F5F5 | none |

**Error state**: Red border + red helper text below field.

### 7.7 Badge — Status

| Property | Value |
|----------|-------|
| **Widget** | `Container` with `DecoratedBox` + `Text` |
| **Height** | 24dp |
| **Padding** | Horizontal: 8dp, Vertical: 2dp |
| **Border Radius** | `radius-xs` (4dp) |
| **Text Style** | `caption` (10sp, Medium) |

| Status | Background | Text Color | Label |
|--------|-----------|------------|-------|
| Active | `accent-amber-light` (#FFF8E1) | `accent-amber` (#F9A825) | "Aktif" |
| Returned | `primary-green-50` (#E8F5E9) | `primary-green-700` (#2E7D32) | "Pulang" |
| Pending | `accent-blue` (10% opacity) | `accent-blue` (#4285F4) | "Menunggu" |

### 7.8 Avatar

| Property | Value |
|----------|-------|
| **Widget** | `CircleAvatar` |
| **Size (list)** | 40dp |
| **Size (profile)** | 64dp |
| **Background** | `primary-green-50` (#E8F5E9) |
| **Text Color** | `primary-green-700` (#2E7D32) |
| **Text Style** | `h3` (18sp, SemiBold) for initials |
| **Fallback** | First two characters of name, uppercased |

### 7.9 Toggle Switch

| Property | Value |
|----------|-------|
| **Widget** | `Switch` (Material 3) |
| **Active Color** | `primary-green-700` (#2E7D32) |
| **Inactive Color** | `border` (#E0E0E0) |
| **Track (Active)** | `primary-green-100` (#C8E6C9) |
| **Track (Inactive)** | `border-light` (#F0F0F0) |
| **Size** | 52dp × 32dp (standard) |

### 7.10 App Bar / Header Banner

| Property | Value |
|----------|-------|
| **Widget** | `Container` (custom, not standard AppBar) |
| **Background** | `primary-green-900` (#1B5E20) |
| **Height** | 120dp (fixed, includes status bar) |
| **Padding** | Horizontal: 16dp, Top: 48dp (status bar), Bottom: 16dp |
| **Title Color** | White (#FFFFFF) |
| **Title Style** | `h1` (28sp, Bold) |
| **Subtitle Color** | White 70% opacity |
| **Subtitle Style** | `body` (14sp, Regular) |
| **Border Radius** | Bottom: 0dp (flat against screen edge) |

**Behavior**: Scrolls away with content (no persistent sticky).

### 7.11 Search Bar

| Property | Value |
|----------|-------|
| **Widget** | `TextField` with custom decoration |
| **Height** | 48dp |
| **Background** | `surface` (#FFFFFF) |
| **Border** | 1dp `border` (#E0E0E0) |
| **Border Radius** | `radius-full` (pill shape) |
| **Prefix Icon** | Search icon (24dp, `text-disabled`) |
| **Padding** | Horizontal: 16dp (inside), 16dp (outside screen margin) |
| **Text Style** | `body` (14sp) |

### 7.12 FAB (Floating Action Button)

| Property | Value |
|----------|-------|
| **Widget** | `FloatingActionButton` |
| **Size** | 56dp |
| **Background** | `primary-green-900` |
| **Icon** | White, 24dp |
| **Shadow** | `elevation-3` |
| **Border Radius** | `radius-full` (circular) |
| **Position** | Bottom-right: 16dp from edges |

### 7.13 Divider

| Property | Value |
|----------|-------|
| **Widget** | `Divider` |
| **Color** | `border` (#E0E0E0) |
| **Thickness** | 1dp |
| **Margin** | Vertical: 16dp |
| **With Text** | "atau" centered, `text-secondary` caption, horizontal padding 16dp |

### 7.14 Bottom Sheet

| Property | Value |
|----------|-------|
| **Widget** | `showModalBottomSheet` or `DraggableScrollableSheet` |
| **Background** | `surface` (#FFFFFF) |
| **Border Radius** | Top: `radius-xl` (24dp) |
| **Handle** | 32dp × 4dp bar, `border` color, centered, 12dp from top |
| **Padding** | 24dp top (below handle), 16dp sides |
| **Shadow** | `elevation-4` |
| **Barrier Color** | Black 50% opacity |

### 7.15 QR Code Display

| Property | Value |
|----------|-------|
| **Widget** | `Container` wrapping `QrImage` (qr_flutter package) |
| **Size** | 240dp × 240dp |
| **Background** | `surface` (#FFFFFF) |
| **QR Color** | `text-primary` (#1A1A1A) |
| **Border Radius** | `radius-lg` (16dp) |
| **Padding** | 24dp |
| **Shadow** | `elevation-1` |

### 7.16 Camera Viewfinder Overlay (Guest Scanner)

| Property | Value |
|----------|-------|
| **Widget** | `Stack` with camera + overlay |
| **Background** | Black (camera feed) |
| **Overlay Frame** | 260dp × 260dp centered, white 2dp border with `radius-lg` |
| **Corner Brackets** | 40dp L-shaped, white 3dp, at each corner |
| **Instruction Text** | White, `body` (14sp), centered below frame |
| **Mask** | Semi-transparent black (60%) outside the scan area |

---

## 8. Screen Layouts

### 8.1 Login Screen

```
┌──────────────────────────────────┐
│         [Background: cream]       │
│                                   │
│         ┌──────────────┐          │
│         │  Logo (T)    │          │
│         └──────────────┘          │
│         TamuKu                    │
│    Masuk sebagai Admin           │
│                                   │
│  ┌────────────────────────────┐   │
│  │ 📧  Email                 │   │
│  └────────────────────────────┘   │
│         (12dp gap)                │
│  ┌────────────────────────────┐   │
│  │ 🔒  Password              │   │
│  └────────────────────────────┘   │
│         (24dp gap)                │
│  ┌────────────────────────────┐   │
│  │         Masuk             │   │ ← Primary button
│  └────────────────────────────┘   │
│         (16dp gap)                │
│      ── atau ──                  │
│         (16dp gap)                │
│  ┌────────────────────────────┐   │
│  │ G  Masuk dengan Google    │   │ ← Outlined button
│  └────────────────────────────┘   │
│                                   │
└──────────────────────────────────┘
```

**Specs:**
- Centered column, max-width: 320dp
- Screen padding: 32dp horizontal, 48dp top
- Logo: 80dp × 80dp, centered
- "TamuKu": `h1` (28sp, Bold), `text-primary`
- "Masuk sebagai Admin": `body` (14sp), `text-secondary`
- Input fields: 52dp height, full-width within container
- Primary button: Full-width within container
- Divider: thin line + "atau" caption
- Google button: White fill, `border` outline, Google logo 24dp

### 8.2 Dashboard Screen

```
┌──────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │ ← Green banner
│ ▓  Dashboard                   ▓ │
│ ▓  Kantor Desa Cakrawala       ▓ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│                                   │
│  ┌──────────┐  ┌──────────┐      │
│  │ 42       │  │ 7        │      │ ← Stat cards
│  │ Tamu     │  │ Tamu     │      │
│  │ Hari Ini │  │ Aktif    │      │
│  └──────────┘  └──────────┘      │
│         (16dp gap)                │
│  ┌────────────────────────────┐   │
│  │ Kunjungan 7 Hari Terakhir │   │ ← Chart card
│  │  ▂▂▃▂▅▇▅                 │   │
│  │  S  S  R  K  J  S  M     │   │
│  └────────────────────────────┘   │
│         (16dp gap)                │
│  ┌──────┐ ┌──────┐ ┌──────────┐  │
│  │Daftar│ │QR    │ │Export    │  │ ← Action chips
│  │Tamu  │ │Code  │ │CSV       │  │
│  └──────┘ └──────┘ └──────────┘  │
│                                   │
└──────────────────────────────────┘
```

**Specs:**
- Banner: 120dp height, full-width
- Stats row: 2 cards, equal width, `space-md` (12dp) gap
  - Number: `display` (48sp, Bold) — green for "Tamu Hari Ini", amber for "Tamu Aktif"
  - Label: `caption` (12sp), `text-secondary`
  - Card padding: 16dp, `radius-lg`
- Chart card: Full-width, 16dp padding
  - Title: `h3` (18sp, Medium), 12dp bottom margin
  - Bars: `primary-green-700`, max height 100dp, 8dp width, 6dp gap
  - Day labels: `caption` (12sp), `text-secondary`
- Action row: Horizontal scroll or flex wrap, `space-sm` (8dp) gap
  - Each chip: `Button — Chip` spec, `radius-full`

### 8.3 Guest List Screen

```
┌──────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ▓  Daftar Tamu                 ▓ │
│ ▓  Jumat, 4 Juli 2026         ▓ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│                                   │
│  ┌🔍 Cari nama tamu...────────┐   │ ← Search bar
│  └────────────────────────────┘   │
│         (12dp gap)                │
│  [Hari Ini] [Minggu Ini] [Semua] │ ← Filter chips
│         (12dp gap)                │
│  ┌────────────────────────────┐   │
│  │ ┌──┐ Budi Santoso         │   │ ← Guest card
│  │ │BS│ Kunjungan Dinas      │   │
│  │ └──┘              09:30   │   │
│  │            [Aktif]         │   │
│  └────────────────────────────┘   │
│         (8dp gap)                 │
│  ┌────────────────────────────┐   │
│  │ ┌──┐ Siti Rahayu          │   │
│  │ │SR│ Konsultasi           │   │
│  │ └──┘              10:15   │   │
│  │           [Pulang]         │   │
│  └────────────────────────────┘   │
│                                   │
└──────────────────────────────────┘
```

**Specs:**
- Banner: Standard spec
- Search bar: `space-lg` (16dp) horizontal margin, full-width
- Filter chips: Horizontal row, `space-sm` (8dp) gap, `space-md` (12dp) top margin
- Guest card:
  - Row layout: Avatar (40dp) → Text column (flex) → Time + Status (column, right-aligned)
  - Padding: 16dp
  - Between avatar and text: `space-md` (12dp)
  - Name: `h3` (18sp, Medium), `text-primary`
  - Purpose: `body` (14sp), `text-secondary`
  - Time: `caption` (12sp), `text-secondary`, right-aligned
  - Status badge: Below time, right-aligned

### 8.4 QR Code Generator Screen

```
┌──────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ▓  QR Code Lokasi             ▓ │
│ ▓  Cetak & tempel di pintu    ▓ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│                                   │
│  ┌────────────────────────────┐   │
│  │                            │   │
│  │      ┌──────────────┐      │   │
│  │      │              │      │   │
│  │      │   [QR CODE]  │      │   │ ← QR card
│  │      │              │      │   │
│  │      └──────────────┘      │   │
│  │   Kantor Desa Cakrawala   │   │
│  │  Scan untuk isi buku tamu  │   │
│  └────────────────────────────┘   │
│         (16dp gap)                │
│    [A4] [A5] [Tampil di Layar]   │ ← Size selector
│         (24dp gap)                │
│  ┌────────────────────────────┐   │
│  │   Unduh / Cetak Poster    │   │ ← Primary button
│  └────────────────────────────┘   │
│                                   │
└──────────────────────────────────┘
```

**Specs:**
- QR display card: Centered, `surface` background, `radius-lg`, `elevation-1`
  - QR image: 200dp × 200dp, centered
  - Location name: `h3` (18sp), `text-primary`, 12dp top margin
  - Subtitle: `caption` (12sp), `text-secondary`, 4dp top margin
  - Card padding: 24dp
- Size selector: Centered row of chips, `space-sm` (8dp) gap
- Button: Full-width, 16dp horizontal padding

### 8.5 Settings Screen

```
┌──────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ▓  Pengaturan                 ▓ │
│ ▓  Profil lokasi & preferensi ▓ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│                                   │
│  PROFIL LOKASI                   │ ← Overline label
│  ┌────────────────────────────┐   │
│  │ Nama Lokasi               │   │
│  │ Kantor Desa Cakrawala     │   │
│  └────────────────────────────┘   │
│         (8dp gap)                 │
│  ┌────────────────────────────┐   │
│  │ Alamat                    │   │
│  │ Jl. Merdeka No. 10        │   │
│  └────────────────────────────┘   │
│         (8dp gap)                 │
│  ┌────────────────────────────┐   │
│  │ No. WhatsApp Host         │   │
│  │ +6281234567890            │   │
│  └────────────────────────────┘   │
│         (24dp gap)                │
│  PREFERENSI                      │
│  ┌────────────────────────────┐   │
│  │ Notifikasi WhatsApp  [ON] │   │ ← Toggle row
│  └────────────────────────────┘   │
│         (8dp gap)                 │
│  ┌────────────────────────────┐   │
│  │ Mode Gelap           [OFF]│   │ ← Toggle row
│  └────────────────────────────┘   │
│         (32dp gap)                │
│  ┌────────────────────────────┐   │
│  │         Keluar            │   │ ← Red outlined button
│  └────────────────────────────┘   │
│                                   │
└──────────────────────────────────┘
```

**Specs:**
- Section labels: `overline` (10sp, Medium, uppercase), `text-secondary`, 24dp top, 12dp bottom
- Input fields: Standard spec, read-only appearance (no focus ring unless tapped)
- Toggle rows: Row — label (left, `body-large`) + Switch (right), 16dp vertical padding, `surface` background card
- Logout button: `Button — Destructive`, outlined variant (red border, red text, transparent fill)

### 8.6 Guest QR Scanner Screen

```
┌──────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ▓  TamuKu                      ▓ │
│ ▓  Scan QR untuk isi buku tamu ▓ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│                                   │
│  ┌────────────────────────────┐   │
│  │░░░░░░░░░░░░░░░░░░░░░░░░░░░│   │
│  │░░┌──────────────────┐░░░░░│   │
│  │░░│                  │░░░░░│   │ ← Camera viewfinder
│  │░░│    [ QR SCAN ]   │░░░░░│   │
│  │░░│                  │░░░░░│   │
│  │░░└──────────────────┘░░░░░│   │
│  │░░░░░░░░░░░░░░░░░░░░░░░░░░░│   │
│  └────────────────────────────┘   │
│         (16dp gap)                │
│    Arahkan kamera ke QR Code     │
│         (16dp gap)                │
│  ┌────────────────────────────┐   │
│  │     Input Kode Manual     │   │ ← White outlined button
│  └────────────────────────────┘   │
│                                   │
└──────────────────────────────────┘
```

**Specs:**
- Camera area: `Expanded` widget filling remaining space
- Viewfinder overlay: 260dp × 260dp, centered
  - Corner brackets: White, 3dp stroke, 40dp length
  - Scan area border: White 2dp, `radius-lg`
- Instruction text: `body` (14sp), white, centered, 16dp from scan area
- "Input Kode Manual" button: White fill, `text-primary` text, `radius-full`, 48dp height
- Mask: Semi-transparent black overlay outside scan area

### 8.7 Guest Form Screen

```
┌──────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ▓  Isi Buku Tamu              ▓ │
│ ▓  Kantor Desa Cakrawala      ▓ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│                                   │
│  Nama Lengkap *                  │
│  ┌────────────────────────────┐   │
│  │ Masukkan nama lengkap     │   │
│  └────────────────────────────┘   │
│         (12dp gap)                │
│  No. WhatsApp *                  │
│  ┌────────────────────────────┐   │
│  │ 08xxxxxxxxxx              │   │
│  └────────────────────────────┘   │
│         (12dp gap)                │
│  Keperluan *                     │
│  ┌────────────────────────────┐   │
│  │ Pilih keperluan     ▼     │   │ ← Dropdown
│  └────────────────────────────┘   │
│         (12dp gap)                │
│  Instansi (opsional)             │
│  ┌────────────────────────────┐   │
│  │ Nama instansi/organisasi  │   │
│  └────────────────────────────┘   │
│         (16dp gap)                │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐   │
│  │  + Tambah Foto (opsional)│   │ ← Dashed border
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘   │
│         (24dp gap)                │
│  ┌────────────────────────────┐   │
│  │          Kirim            │   │ ← Primary button
│  └────────────────────────────┘   │
│                                   │
└──────────────────────────────────┘
```

**Specs:**
- Labels: `body-large` (16sp), `text-primary`, 4dp bottom margin to field
- Fields: Standard input spec, 52dp height
- Required indicator: Asterisk `*` in `accent-red` after label
- Dropdown: Same styling as text input, dropdown arrow icon (24dp) right-aligned
- Photo upload area: 120dp height, dashed border (2dp, `border` color), centered "+" icon + text
- Submit button: Full-width, `primary-green-900`, 16dp horizontal screen padding

### 8.8 Confirmation Screen

```
┌──────────────────────────────────┐
│                                   │
│                                   │
│         ┌──────────────┐          │
│         │     ✓        │          │ ← Green circle
│         └──────────────┘          │
│                                   │
│         Terima kasih!             │ ← h1
│                                   │
│    Data kunjungan Anda sudah     │ ← body
│    tercatat.                      │
│                                   │
│  ┌────────────────────────────┐   │
│  │   Waktu Check-in          │   │ ← Info card
│  │   09:24 WIB               │   │
│  └────────────────────────────┘   │
│         (24dp gap)                │
│  ┌────────────────────────────┐   │
│  │    Check-Out Sekarang     │   │ ← Outlined green
│  └────────────────────────────┘   │
│                                   │
└──────────────────────────────────┘
```

**Specs:**
- Vertically centered layout (Column + MainAxisAlignment.center)
- Checkmark circle: 80dp, `primary-green-700` fill, white checkmark icon 40dp
- "Terima kasih!": `h1` (28sp, Bold), `text-primary`, 16dp top margin
- Subtitle: `body` (14sp), `text-secondary`, 8dp top margin
- Info card: `surface` background, `radius-lg`, `elevation-1`, centered, 16dp padding
  - Label: `caption` (12sp), `text-secondary`
  - Value: `h2` (22sp, SemiBold), `text-primary`
- Button: Outlined green, full-width, 16dp horizontal padding

### 8.9 Checkout Confirmation Screen

```
┌──────────────────────────────────┐
│                                   │
│                                   │
│         ┌──────────────┐          │
│         │     ←        │          │ ← Red/pink circle
│         └──────────────┘          │
│                                   │
│    Konfirmasi Check-Out          │ ← h1
│                                   │
│    Tekan tombol di bawah untuk   │ ← body
│    mencatat waktu kepulangan     │
│    Anda.                         │
│                                   │
│  ┌────────────────────────────┐   │
│  │   Durasi kunjungan        │   │ ← Info card
│  │   1j 12m                  │   │
│  └────────────────────────────┘   │
│         (24dp gap)                │
│  ┌────────────────────────────┐   │
│  │        Saya Pulang        │   │ ← Red filled
│  └────────────────────────────┘   │
│                                   │
└──────────────────────────────────┘
```

**Specs:**
- Same centered layout as Confirmation screen
- Circle: 80dp, `accent-red-light` (#FFEBEE) fill, red arrow-left icon
- Button: `accent-red` fill, white text, full-width

### 8.10 Error / Invalid QR Screen

```
┌──────────────────────────────────┐
│                                   │
│                                   │
│         ┌──────────────┐          │
│         │      !       │          │ ← Yellow/amber circle
│         └──────────────┘          │
│                                   │
│    QR Code Tidak Dikenal         │ ← h1
│                                   │
│    QR tidak valid atau sudah     │ ← body
│    kedaluwarsa. Silakan hubungi  │
│    resepsionis untuk bantuan.    │
│                                   │
│         (24dp gap)                │
│  ┌────────────────────────────┐   │
│  │        Scan Ulang         │   │ ← Primary green
│  └────────────────────────────┘   │
│                                   │
└──────────────────────────────────┘
```

**Specs:**
- Same centered layout
- Circle: 80dp, `accent-amber-light` (#FFF8E1) fill, amber exclamation icon
- Button: `primary-green-900` fill, full-width

---

## 9. Accessibility Requirements

### 9.1 Touch Targets

| Element | Minimum Size | TamuKu Size |
|---------|-------------|-------------|
| Buttons | 48×48dp | 52dp height (meets) |
| Toggle switches | 48×48dp | 52×32dp (meets) |
| Chips / filter pills | 48×36dp | 36dp height (needs padding) |
| List items | 48dp height | 72dp+ with card (meets) |
| Input fields | 48dp height | 52dp (meets) |

### 9.2 Color Contrast (WCAG AA)

| Foreground | Background | Ratio | Pass? |
|-----------|-----------|-------|-------|
| #1A1A1A (text) | #FFFFFF (surface) | 17.4:1 | ✅ |
| #1A1A1A (text) | #FAFAF5 (bg) | 16.8:1 | ✅ |
| #757575 (secondary) | #FFFFFF (surface) | 4.6:1 | ✅ |
| #757575 (secondary) | #FAFAF5 (bg) | 4.4:1 | ⚠️ Borderline |
| #FFFFFF (white) | #1B5E20 (green) | 7.1:1 | ✅ |
| #BDBDBD (disabled) | #FFFFFF (surface) | 2.0:1 | ⚠️ Intentionally low |
| #F9A825 (amber) | #FFF8E1 (amber bg) | 2.4:1 | ⚠️ Icon + text always |

**Rule**: Disabled text intentionally has low contrast. All active status indicators always pair color with text labels (never color alone).

### 9.3 Font Scaling

- Support up to 200% system text scale (Android `textScaleFactor`)
- Use `sp` for all text sizes (not `dp`)
- Test at 200%: no horizontal overflow, no text clipping
- Wrap long text with `Flexible` / `Expanded` widgets
- Cards and list items should expand vertically with scaled text

### 9.4 Screen Reader (Semantics)

- All buttons: `Semantics(label: "Masuk", button: true)`
- Input fields: `Semantics(label: "Email", textField: true)`
- Status badges: `Semantics(label: "Status: Aktif")`
- Images: `Semantics(label: "QR Code Kantor Desa Cakrawala")`
- Decorative icons: `Semantics(hidden: true)`
- Header banners: `Semantics(header: true)`

### 9.5 Focus Order

1. Top to bottom, left to right (default for Column layouts)
2. Search bar → Filter chips → List items (guest list)
3. Input fields: Nama → WhatsApp → Keperluan → Instansi → Submit
4. Toggle switches: Label has focus, not just the switch widget

### 9.6 Error Handling

- Error messages always appear below the related input field
- Error text: `caption` (12sp), `accent-red` (#D32F2F)
- Input border turns red on error
- Never rely on color alone — error state includes icon + text

---

## 10. Animation Guidelines

### 10.1 Page Transitions

| Transition | Type | Duration | Curve |
|-----------|------|----------|-------|
| Same-level push (screen → screen) | Slide from right | 300ms | `Curves.easeInOut` |
| Modal present (bottom sheet) | Slide from bottom | 300ms | `Curves.easeOutCubic` |
| Dialog | Scale + fade | 200ms | `Curves.easeOutBack` |
| Back navigation | Slide from left | 300ms | `Curves.easeInOut` |
| Guest confirmation screen | Fade in | 400ms | `Curves.easeIn` |

### 10.2 Micro-interactions

| Interaction | Animation | Duration |
|------------|-----------|----------|
| Button press | Scale to 0.98 | 100ms |
| Button release | Scale back to 1.0 | 100ms |
| Card tap | Material ripple | 200ms |
| Toggle switch | Thumb slide + color transition | 200ms |
| Filter chip selection | Fill color fade-in | 150ms |
| Input focus | Border color transition | 200ms |
| Status badge appear | Fade + slight slide up | 200ms |

### 10.3 Loading States

| State | Animation | Duration |
|-------|-----------|----------|
| Page loading | Circular progress indicator (green) | Continuous |
| Button loading | Circular progress (white) replacing text | Continuous |
| Pull-to-refresh | Material refresh indicator | Continuous |
| Skeleton loading | Shimmer effect on placeholder rectangles | 1.5s loop |

### 10.4 Success / Error Animations

| State | Animation | Duration |
|-------|-----------|----------|
| Form submitted | Green checkmark draw animation | 500ms |
| QR scanned successfully | Haptic feedback + green flash | 200ms |
| Error occurred | Red shake (horizontal) | 400ms |
| Checkout confirmed | Red circle + arrow animation | 500ms |

### 10.5 Animation Rules

1. **Never block interaction** — animations run in parallel with user flow
2. **Respect reduced motion** — check `MediaQuery.disableAnimations` and skip non-essential animations
3. **Performance** — use `AnimationController` with `TickerProviderStateMixin`, dispose properly
4. **Duration cap** — no animation exceeds 500ms (except loading indicators)
5. **Consistent easing** — `easeInOut` for navigation, `easeOutCubic` for entrances, `easeIn` for exits

---

## 11. Dark Mode Specifications

### 11.1 Dark Mode Color Overrides

| Token | Light Value | Dark Value |
|-------|------------|------------|
| `background` | #FAFAF5 | #121212 |
| `surface` | #FFFFFF | #1E1E1E |
| `surface-variant` | — | #2D2D2D |
| `text-primary` | #1A1A1A | #FFFFFF |
| `text-secondary` | #757575 | #B0B0B0 |
| `text-disabled` | #BDBDBD | #616161 |
| `border` | #E0E0E0 | #404040 |
| `border-light` | #F0F0F0 | #333333 |
| `primary-green-900` | #1B5E20 | #4CAF50 |
| `primary-green-700` | #2E7D32 | #66BB6A |
| `primary-green-50` | #E8F5E9 | #1B3A1D |
| `accent-red` | #D32F2F | #EF5350 |
| `accent-red-light` | #FFEBEE | #3E2020 |
| `accent-amber` | #F9A825 | #FFD54F |
| `accent-amber-light` | #FFF8E1 | #3E3520 |

### 11.2 Dark Mode Rules

1. **Green palette shifts lighter** — `primary-green-900` becomes #4CAF50 for 4.5:1 contrast on dark bg
2. **Cards get subtle border** — 1dp `border` (#404040) instead of relying solely on shadow
3. **Shadows reduced** — Use `elevation-0` with borders; shadows are invisible on dark backgrounds
4. **Header banner** — Same `primary-green-900` (#1B5E20) or shift to #2E7D32 for better visibility
5. **Status badges** — Darker background tints, brighter text colors

### 11.3 Dark Mode Toggle

- Setting: `Mode Gelap` toggle in Settings screen
- Storage: `SharedPreferences` key `darkMode`
- Application: `ThemeData` switching via `Consumer` or `ValueNotifier`
- System default: Follow system theme on first launch

---

## 12. Flutter Theme Implementation Guide

### 12.1 Color Constants

**File: `lib/theme/app_colors.dart`**

```dart
import 'package:flutter/material.dart';

/// TamuKu Color System
/// Complete design token palette extracted from mockups.
abstract final class AppColors {
  // ── Primary Green ──
  static const Color primary900 = Color(0xFF1B5E20);
  static const Color primary700 = Color(0xFF2E7D32);
  static const Color primary500 = Color(0xFF43A047);
  static const Color primary100 = Color(0xFFC8E6C9);
  static const Color primary50  = Color(0xFFE8F5E9);

  // ── Neutral ──
  static const Color background    = Color(0xFFFAFAF5);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled  = Color(0xFFBDBDBD);
  static const Color border        = Color(0xFFE0E0E0);
  static const Color borderLight   = Color(0xFFF0F0F0);

  // ── Accent ──
  static const Color accentRed      = Color(0xFFD32F2F);
  static const Color accentRedLight = Color(0xFFFFEBEE);
  static const Color accentAmber    = Color(0xFFF9A825);
  static const Color accentAmberLight = Color(0xFFFFF8E1);
  static const Color accentBlue     = Color(0xFF4285F4);

  // ── Semantic ──
  static const Color success   = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color warning   = Color(0xFFF9A825);
  static const Color warningBg = Color(0xFFFFF8E1);
  static const Color error     = Color(0xFFD32F2F);
  static const Color errorBg   = Color(0xFFFFEBEE);
  static const Color info      = Color(0xFF4285F4);
}
```

### 12.2 Dark Mode Colors

**File: `lib/theme/app_colors_dark.dart`**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Dark mode overrides — applied when ThemeMode.dark is active.
abstract final class AppColorsDark {
  static const Color background    = Color(0xFF121212);
  static const Color surface       = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2D2D2D);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled  = Color(0xFF616161);
  static const Color border        = Color(0xFF404040);
  static const Color borderLight   = Color(0xFF333333);

  // Shifted lighter for dark backgrounds
  static const Color primary900 = Color(0xFF4CAF50);
  static const Color primary700 = Color(0xFF66BB6A);
  static const Color primary50  = Color(0xFF1B3A1D);

  static const Color accentRed      = Color(0xFFEF5350);
  static const Color accentRedLight = Color(0xFF3E2020);
  static const Color accentAmber    = Color(0xFFFFD54F);
  static const Color accentAmberLight = Color(0xFF3E3520);
}
```

### 12.3 Typography Text Theme

**File: `lib/theme/app_text_styles.dart`**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// TamuKu Typography Scale
/// Uses system default fonts (Roboto / SF Pro).
abstract final class AppTextStyles {
  // ── Display / Stats ──
  static const TextStyle display = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 56 / 48,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle stats = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  // ── Headings ──
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 24 / 18,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  // ── Body ──
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );

  // ── Caption / Overline ──
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 16 / 10,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  // ── Button ──
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    letterSpacing: 0.5,
    color: Colors.white,
  );
}
```

### 12.4 Spacing & Radius Constants

**File: `lib/theme/app_dimensions.dart`**

```dart
/// TamuKu spacing and border radius tokens.
abstract final class AppSpacing {
  static const double xs2 = 2;
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

abstract final class AppRadius {
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 24;
  static const double full = 999;

  static BorderRadius get xsBorder   => BorderRadius.circular(xs);
  static BorderRadius get smBorder   => BorderRadius.circular(sm);
  static BorderRadius get mdBorder   => BorderRadius.circular(md);
  static BorderRadius get lgBorder   => BorderRadius.circular(lg);
  static BorderRadius get xlBorder   => BorderRadius.circular(xl);
  static BorderRadius get fullBorder => BorderRadius.circular(full);
}
```

### 12.5 ThemeData Configuration

**File: `lib/theme/app_theme.dart`**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// TamuKu complete theme configuration.
/// Usage: MaterialApp(theme: AppTheme.light, darkTheme: AppTheme.dark, ...)
abstract final class AppTheme {
  // ──────────────────────────── Light Theme ────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary900,
      onPrimary: Colors.white,
      secondary: AppColors.primary700,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.border,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.display,
      headlineLarge: AppTextStyles.h1,
      headlineMedium: AppTextStyles.h2,
      titleMedium: AppTextStyles.h3,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.body,
      labelSmall: AppTextStyles.caption,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary900,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary900,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        textStyle: AppTextStyles.button,
        elevation: 1,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary900,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        side: const BorderSide(color: AppColors.primary900, width: 1.5),
        textStyle: AppTextStyles.button.copyWith(color: AppColors.primary900),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary900, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textDisabled),
      labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.primary900,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      labelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      showCheckmark: false,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary700;
        return AppColors.border;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary100;
        return AppColors.borderLight;
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary900,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: CircleBorder(),
      size: 56,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      elevation: 4,
    ),
  );

  // ──────────────────────────── Dark Theme ─────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColorsDark.primary900,
      onPrimary: Colors.black,
      secondary: AppColorsDark.primary700,
      onSecondary: Colors.black,
      surface: AppColorsDark.surface,
      onSurface: AppColorsDark.textPrimary,
      error: AppColorsDark.accentRed,
      onError: Colors.black,
      outline: AppColorsDark.border,
    ),
    scaffoldBackgroundColor: AppColorsDark.background,
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.display,
      headlineLarge: AppTextStyles.h1,
      headlineMedium: AppTextStyles.h2,
      titleMedium: AppTextStyles.h3,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.body,
      labelSmall: AppTextStyles.caption,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsDark.primary900,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsDark.primary900,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        textStyle: AppTextStyles.button.copyWith(color: Colors.black),
        elevation: 1,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColorsDark.surfaceVariant,
      elevation: 0,
      side: const BorderSide(color: AppColorsDark.border, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsDark.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsDark.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsDark.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColorsDark.primary900, width: 2),
      ),
      hintStyle: AppTextStyles.body.copyWith(color: AppColorsDark.textDisabled),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: AppColorsDark.primary900,
      side: const BorderSide(color: AppColorsDark.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColorsDark.primary700;
        return AppColorsDark.border;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColorsDark.primary50;
        return AppColorsDark.borderLight;
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColorsDark.border,
      thickness: 1,
      space: 1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColorsDark.primary900,
      foregroundColor: Colors.black,
      elevation: 3,
      shape: const CircleBorder(),
      size: 56,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColorsDark.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    ),
  );
}
```

### 12.6 Theme File Structure

```
lib/theme/
├── app_colors.dart          # Light mode color constants
├── app_colors_dark.dart     # Dark mode color overrides
├── app_text_styles.dart     # Typography scale
├── app_dimensions.dart      # Spacing + border radius tokens
├── app_theme.dart           # ThemeData (light + dark)
└── widgets/                 # Reusable themed components
    ├── tamu_header_banner.dart
    ├── tamu_status_badge.dart
    ├── tamu_guest_card.dart
    ├── tamu_stat_card.dart
    ├── tamu_filter_chip.dart
    └── tamu_search_bar.dart
```

### 12.7 Usage in MaterialApp

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class TamuKuApp extends StatelessWidget {
  const TamuKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TamuKu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // Toggle to manual via settings
      // ... routes, home, etc.
    );
  }
}
```

---

## 13. Package Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `qr_flutter` | ^4.1.0 | QR code generation |
| `mobile_scanner` | ^5.0.0 | QR code scanning (camera) |
| `fl_chart` | ^0.68.0 | Dashboard bar chart |
| `shared_preferences` | ^2.2.0 | Dark mode toggle persistence |
| `http` | ^1.2.0 | API communication |
| `intl` | ^0.19.0 | Date/time formatting (WIB) |
| `lottie` | ^3.1.0 | Success/checkmark animations |
| `image_picker` | ^1.0.0 | Optional photo upload (guest) |
| `permission_handler` | ^11.0.0 | Camera permission for QR scan |

---

## 14. Responsive Behavior

### Breakpoints

| Width | Name | Adaptation |
|-------|------|-----------|
| < 360dp | Compact | Minimum supported; may truncate |
| 360dp | Baseline | Standard mobile — all mockups designed for this |
| 360–411dp | Regular | Standard phones (Pixel, Samsung) |
| 412–600dp | Expanded | Larger phones, small tablets |
| > 600dp | Large | Tablets — guest web view only |

### Rules

1. **Mobile-first**: All layouts designed for 360dp width baseline
2. **No horizontal scroll** — content reflows vertically
3. **Cards**: Full-width minus 32dp (16dp padding each side)
4. **Buttons**: Always full-width within screen padding
5. **Guest web view**: Max-width 480dp centered on larger screens, same mobile layout
6. **Tablet (admin)**: Not primary target; if used, max-width container at 600dp centered

---

## 15. Asset Guidelines

### Icons

- Use Material Icons where available (default Flutter)
- Custom icons: SVG via `flutter_svg` package
- Tab bar icons: 24dp, active = `primary-green-900`, inactive = `text-secondary`

### Images

- Guest avatar fallback: Initials in circle (no stock photos)
- Venue logo: Optional, displayed in login screen below TamuKu logo
- QR code: Generated programmatically, never from images

### Illustrations

- Empty states: Simple line illustrations (optional for MVP)
- Error states: Icon-based (exclamation, warning triangle) — no illustrations needed

---

*Document version: 1.0 · Created: July 2026 · For: TamuKu Flutter Mobile App (UAS Mobile Computing)*
