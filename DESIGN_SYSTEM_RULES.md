# OKLCH Tiered Design System Specification

> **Target Audience:** Autonomous AI Coding Agents, LLM Code Assistants, and Design System Engineers.  
> **Purpose:** Serves as the definitive, unambiguous, and mathematically deterministic specification for generating themes, surfaces, inputs, text, and overlays in the OKLCH color space.

---

## 1. System Overview & Core Philosophy

This design system uses **OKLCH** (*Lightness*, *Chroma*, *Hue*) as its foundational perceptual color model. Unlike RGB or HSL, OKLCH guarantees uniform perceptual lightness ($L$) across all hues ($H$), eliminating arbitrary brightness shifts when themes change.

```yaml
Color_Space: OKLCH
Lightness_Range: [0.0, 1.0]
Chroma_Range: [0.0, 0.4]
Hue_Range: [0.0, 360.0)
Primary_Anchor: Container 3 (C3)
Default_Anchor_Light: "#F4F5F7" (Cool Neutral Slate Light)
Default_Anchor_Dark: "#101010" or "#181818" (Neutral Dark Anchor)
```

### Depth Paradigm
* **Light Mode (Inward / Sunken Depth)**:
  * Light reflects brightest on the outermost canvas ($C1$).
  * Layered cards descend in lightness towards the anchor surface ($C1 > C2 > C3$).
  * Interactive inputs sink further into the surface as troughs ($TF < C3$).
  * Floating overlays (Dialogs, Menus) subtly elevate ($C4 \ge C3$).
* **Dark Mode (Outward / Elevated Depth)**:
  * Light sources elevate surfaces upward from deep black.
  * Canvas is the darkest ($C1$), cards elevate higher ($C1 < C2 < C3$).
  * Floating overlays elevate highest ($C4 > C3$).
  * Interactive inputs form a soft trough nestled above $C2$ ($C2 < TF < C3$).

---

## 2. Mathematical Formulas & Derivations

All colors are dynamically calculated relative to the **Anchor Color** parameters: `anchorL`, `c` (chroma), and `h` (hue).

### 2.1. Light Mode Formulas

| Token ID | Role | OKLCH Formula | Clamping & Bounds | Typical Value ($L_3 = 0.970$) |
| :--- | :--- | :--- | :--- | :--- |
| `C1` | Canvas Background | $L = \text{anchorL} + (\Delta_{\text{C2}} \times 2.0)$<br>$C = c \times 0.70$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$ | $L \approx 1.000$<br>$\Delta_{\text{C2}} = 0.018$ |
| `C2` | Card Wrapper | $L = \text{anchorL} + \Delta_{\text{C2}}$<br>$C = c \times 0.90$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$ | $L \approx 0.988$<br>$\Delta_{\text{C2}} = 0.018$ |
| `C3` | **Anchor Surface (Card)** | $L = \text{anchorL}$<br>$C = c$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$ | $L = 0.970$<br>$C = 0.003$ |
| `TF` | TextField Sunken Trough | $L = \text{anchorL} - \Delta_{\text{trough}}$<br>$C = c \times 1.2$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$ | $L \approx 0.940$<br>$\Delta_{\text{trough}} = 0.030$ |
| `C4` | Dialog & Context Menu | $L = \text{anchorL} + 0.010$<br>$C = c \times 0.85$<br>$H = h$ | $\text{clamp}(0.0, L, \mathbf{0.985})$ | $L \approx 0.980$<br>*(Prevents glare)* |
| `DIV` | Divider Line | $L = \text{anchorL} - 0.05$<br>$C = c \times 0.5$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$ | $L \approx 0.920$ |
| `TFB` | TextField Border (Default) | $L = \text{anchorL} - 0.10$<br>$C = 0.02$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$ | $L \approx 0.870$ |
| `TFD` | Disabled TextField Fill | Identical to `C3` ($L_3, C_3, H_3$) | *Flattens sunken trough* | $L = 0.970$ |
| `TBF` | Tonal Button Fill (on `C4`) | $L = \text{anchorL} - 0.055$<br>$C = \max(c \times 1.4, 0.018)$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$<br>($C = 0$ if $c \le 0.001$) | $L \approx 0.915$<br>$\Delta L_{\text{C4}} = -0.065$ |

---

### 2.2. Dark Mode Formulas

| Token ID | Role | OKLCH Formula | Clamping & Bounds | Typical Value ($L_3 = 0.173$) |
| :--- | :--- | :--- | :--- | :--- |
| `C1` | Canvas Background | $L = \text{anchorL} - (\Delta_{\text{C2}} \times 2.5)$<br>$C = c \times 0.82$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$ | $L \approx 0.118$<br>$\Delta_{\text{C2}} = 0.022$ |
| `C2` | Card Wrapper | $L = \text{anchorL} - \Delta_{\text{C2}}$<br>$C = c \times 0.94$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$ | $L \approx 0.151$<br>$\Delta_{\text{C2}} = 0.022$ |
| `C3` | **Anchor Surface (Card)** | $L = \text{anchorL}$<br>$C = c$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$ | $L = 0.173$<br>$C = 0.000$ |
| `TF` | TextField Soft Trough | $L = \text{anchorL} - \Delta_{\text{trough}}$<br>$C = c \times 0.88$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$ | $L \approx 0.155$<br>$\Delta_{\text{trough}} = 0.018$ |
| `C4` | Dialog & Context Menu | $L = \text{anchorL} + 0.070$<br>$C = c \times 1.0$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$ | $L \approx 0.243$<br>*(Floating surface)* |
| `DIV` | Divider Line | $L = \text{anchorL} + 0.05$<br>$C = c \times 0.5$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$ | $L \approx 0.223$ |
| `TFB` | TextField Border (Default) | $L = \text{anchorL} + 0.08$<br>$C = 0.02$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$ | $L \approx 0.253$ |
| `TFD` | Disabled TextField Fill | Identical to `C3` ($L_3, C_3, H_3$) | *Flattens sunken trough* | $L = 0.173$ |
| `TBF` | Tonal Button Fill (on `C4`) | $L = L_{\text{C4}} + 0.065$<br>$C = \max(c \times 1.3, 0.025)$<br>$H = h$ | $\text{clamp}(0.0, L, 1.0)$<br>($C = 0$ if $c \le 0.001$) | $L \approx 0.308$<br>$\Delta L_{\text{C4}} = +0.065$ |

---

## 3. Typography & Text Derivation Architecture

### 3.1. Single Source of Truth: `textMain`
All text tokens and disabled states originate from **one single root token**: `textMain`.

```
textMain = OKLCH(
  Lightness: Fixed calibrated constant (WCAG AAA guaranteed),
  Chroma: Fixed subtle saturation (chromatic ambient tint),
  Hue: Inherited directly from anchorHue (chromatic unity)
)
```

```yaml
Text_Rules:
  Light_Mode:
    Lightness: 0.20 # Off-black; prevents halation / stark contrast eye strain
    Chroma: 0.030   # Subtle tint; avoids lifeless monochrome gray
    Hue: anchorHue  # Unifies text color temperature with the theme
    Contrast_Ratio: "> 10:1 against C1, C2, C3, C4 (Exceeds WCAG AAA 7:1)"
  Dark_Mode:
    Lightness: 0.93 # Soft off-white; prevents irradiation / astigmatism glare
    Chroma: 0.015   # Very subtle tint; accounts for eye sensitivity in low light
    Hue: anchorHue  # Ambient color harmony
    Contrast_Ratio: "> 8:1 against dark surfaces (Exceeds WCAG AAA 7:1)"
```

### 3.2. Alpha Opacity Hierarchy
Never define new arbitrary hex colors for text states. Modulate `textMain` via alpha channels:

| Level | Token / Expression | Alpha | Use Case |
| :--- | :--- | :--- | :--- |
| **High Emphasis** | `palette.textMain` | `1.00` ($100\%$) | Card titles, active input text, main labels, modal titles. |
| **Tonal Text** | `palette.tonalButtonText` | `1.00` ($100\%$) | Label inside Tonal Buttons on `C4` surface (`== textMain`). |
| **Medium Emphasis** | `textMain.withValues(alpha: 0.72)` | `0.65`–`0.75` | Subtitles, helper text, descriptions, keyboard shortcuts. |
| **Low Emphasis** | `textMain.withValues(alpha: 0.50)` | `0.50`–`0.55` | Placeholders, captions, footnotes, metadata badges. |
| **Disabled Inactive** | `palette.textDisabled` | `0.38` ($38\%$) | Disabled input text, disabled icons, disabled buttons. |
| **Subtle Border** | `palette.textFieldDisabledBorder`| `0.08` ($8\%$) | Disabled input outlines, hairline surface dividers. |

---

## 4. Component Rules & Interaction Matrix

### 4.1. TextFields
* **Active / Unfocused**:
  * `fillColor`: `palette.textFieldFill` ($TF$).
  * `border`: 1px solid `palette.textFieldBorder` ($TFB$).
  * `textColor`: `palette.textMain`.
  * *Visual Effect*: Sunken trough with clear boundary.
* **Disabled / Inactive**:
  * `fillColor`: `palette.textFieldDisabledFill` (Identical to $C3$).
  * `border`: 1px solid `palette.textFieldDisabledBorder` (`textMain` @ 0.08$\alpha$).
  * `textColor`: `palette.textDisabled` (`textMain` @ 0.38$\alpha$).
  * *Visual Effect*: Surface trough disappears; element becomes completely flat with $C3$.

### 4.2. Dividers
* `color`: `palette.dividerLine` ($DIV$).
* `thickness`: 1.0px.
* *Rule*: Low-contrast division without cutting visual hierarchy.

### 4.3. Floating Overlays (Container 4)
* **Surface Background**: `palette.container4` ($C4$).
* **Scope**: Dialog modals, context menus, dropdown popovers, tooltips.
* **Elevation**:
  * Light Mode: Soft drop shadow ($\text{alpha} \approx 0.04$, blur: 12px), border `textMain` @ 0.08$\alpha$.
  * Dark Mode: Deep elevation shadow ($\text{alpha} \approx 0.45$, blur: 16px), border `white` @ 0.12$\alpha$.

### 4.4. Tonal Buttons
* **Scope**: Exclusively situated inside **Container 4** (or high-elevation popovers).
* **Active State**:
  * `fillColor`: `palette.tonalButtonFill` ($TBF$).
  * `textColor`: `palette.tonalButtonText` (`textMain`).
  * Contrast on $C4$: $|\Delta L| = 0.065$ (Guarantees WCAG AA/AAA legibility).
* **Disabled State**:
  * `fillColor`: `palette.tonalButtonFill` with $\alpha = 0.35$.
  * `border`: 1px solid `palette.textFieldDisabledBorder`.
  * `textColor`: `palette.textDisabled`.

### 4.5. Primary Brand Action & Focus States
* **Token IDs**: `PRI` (`palette.primary`), `onPrimary` (`palette.onPrimary`).
* **Source**: Configurable via NeoColorPicker or design brand token (default: `#2563EB`).
* **Light Mode Derivation**:
  * Lightness: $L_{\text{pri}} = L_p.\text{clamp}(0.35, 0.65)$. Ensures deep, saturated color that stays clear against light canvas without washing out.
  * `onPrimary`: If $L_{\text{pri}} > 0.62 \implies \text{Dark Off-Black } (\#0F172A)$, else $\text{Pure White } (\#FFFFFF)$ (WCAG AAA/AA $> 4.5:1$).
* **Dark Mode Derivation**:
  * Lightness: $L_{\text{pri}} = (L_p < 0.55 ? L_p + 0.22 : L_p).\text{clamp}(0.55, 0.78)$. Lightness is elevated so primary buttons, badges, and focus borders pop against dark background surfaces ($C1/C2/C3$).
  * `onPrimary`: If $L_{\text{pri}} > 0.62 \implies \text{Dark Off-Black } (\#090D16)$, else $\text{Pure White } (\#FFFFFF)$.
* **Scope & Usage**:
  * `focusedBorder`: Active input outline (width: 1.5px).
  * `ElevatedButton` & `FilledButton`: Primary call-to-action buttons.
  * Active indicators, focus rings, selected radio/checkbox accents.

### 4.6. Semantic Status Tokens (Success, Warning, Error, Info)
* **Tokens**:
  * `success` / `onSuccess` (Default: `#10B981` Emerald)
  * `warning` / `onWarning` (Default: `#F59E0B` Amber)
  * `error` / `onError` (Default: `#EF4444` Rose Red)
  * `info` / `onInfo` (Default: `#06B6D4` Cyan)
* **Light Mode Derivations**:
  * For `success`, `error`, `info`: $L = L_s.\text{clamp}(0.35, 0.65)$
  * For `warning`: $L = L_s.\text{clamp}(0.40, 0.72)$ (preserves sunny amber luminance)
  * `on<Status>`: If $L > 0.62 \implies \text{Dark Off-Black } (\#0F172A)$, else $\text{Pure White } (\#FFFFFF)$
* **Dark Mode Derivations**:
  * For `success`, `error`, `info`: $L = (L_s < 0.55 ? L_s + 0.22 : L_s).\text{clamp}(0.55, 0.78)$
  * For `warning`: $L = (L_s < 0.60 ? L_s + 0.20 : L_s).\text{clamp}(0.60, 0.82)$
  * `on<Status>`: If $L > 0.62 \implies \text{Dark Off-Black } (\#090D16)$, else $\text{Pure White } (\#FFFFFF)$
* **TextField Error & Validation State**:
  * `inputDecorationTheme.errorBorder`: 1.2px solid `palette.error`.
  * `inputDecorationTheme.focusedErrorBorder`: 1.8px solid `palette.error`.
  * `inputDecorationTheme.errorStyle`: text color `palette.error`, 11.5px, weight 500.
  * Error suffix icon: `palette.error`.

---

## 5. Machine-Readable Schema (JSON Summary)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "name": "OKLCH_Tiered_Palette_Rules",
  "version": "1.4.0",
  "anchor": {
    "role": "Container 3 (Card Surface)",
    "lightDefaultHex": "#F4F5F7",
    "darkDefaultHex": "#101010",
    "primaryDefaultHex": "#2563EB",
    "successDefaultHex": "#10B981",
    "warningDefaultHex": "#F59E0B",
    "errorDefaultHex": "#EF4444",
    "infoDefaultHex": "#06B6D4"
  },
  "lightMode": {
    "C1": { "l": "clamp(0.0, anchorL + 0.036, 1.0)", "c": "c * 0.70" },
    "C2": { "l": "clamp(0.0, anchorL + 0.018, 1.0)", "c": "c * 0.90" },
    "C3": { "l": "anchorL", "c": "c" },
    "TF": { "l": "clamp(0.0, anchorL - 0.030, 1.0)", "c": "c * 1.20" },
    "C4": { "l": "clamp(0.0, anchorL + 0.010, 0.985)", "c": "c * 0.85" },
    "DIV": { "l": "clamp(0.0, anchorL - 0.050, 1.0)", "c": "c * 0.50" },
    "TFB": { "l": "clamp(0.0, anchorL - 0.100, 1.0)", "c": "0.020" },
    "TFD": { "l": "anchorL", "c": "c" },
    "TBF": { "l": "clamp(0.0, anchorL - 0.055, 1.0)", "c": "max(c * 1.4, 0.018)" },
    "PRI": { "l": "clamp(0.35, primaryL, 0.65)", "c": "primaryC", "h": "primaryH" },
    "onPrimary": { "condition": "PRI_L > 0.62 ? #0F172A : #FFFFFF" },
    "SUC": { "l": "clamp(0.35, successL, 0.65)", "c": "successC", "h": "successH" },
    "WAR": { "l": "clamp(0.40, warningL, 0.72)", "c": "warningC", "h": "warningH" },
    "ERR": { "l": "clamp(0.35, errorL, 0.65)", "c": "errorC", "h": "errorH" },
    "INF": { "l": "clamp(0.35, infoL, 0.65)", "c": "infoC", "h": "infoH" },
    "textMain": { "l": 0.20, "c": 0.03, "h": "anchorH" }
  },
  "darkMode": {
    "C1": { "l": "clamp(0.0, anchorL - 0.055, 1.0)", "c": "c * 0.82" },
    "C2": { "l": "clamp(0.0, anchorL - 0.022, 1.0)", "c": "c * 0.94" },
    "C3": { "l": "anchorL", "c": "c" },
    "TF": { "l": "clamp(0.0, anchorL - 0.018, 1.0)", "c": "c * 0.88" },
    "C4": { "l": "clamp(0.0, anchorL + 0.070, 1.0)", "c": "c * 1.00" },
    "DIV": { "l": "clamp(0.0, anchorL + 0.050, 1.0)", "c": "c * 0.50" },
    "TFB": { "l": "clamp(0.0, anchorL + 0.080, 1.0)", "c": "0.020" },
    "TFD": { "l": "anchorL", "c": "c" },
    "TBF": { "l": "clamp(0.0, C4_L + 0.065, 1.0)", "c": "max(c * 1.3, 0.025)" },
    "PRI": { "l": "clamp(0.55, primaryL < 0.55 ? primaryL + 0.22 : primaryL, 0.78)", "c": "primaryC", "h": "primaryH" },
    "onPrimary": { "condition": "PRI_L > 0.62 ? #090D16 : #FFFFFF" },
    "SUC": { "l": "clamp(0.55, successL < 0.55 ? successL + 0.22 : successL, 0.78)" },
    "WAR": { "l": "clamp(0.60, warningL < 0.60 ? warningL + 0.20 : warningL, 0.82)" },
    "ERR": { "l": "clamp(0.55, errorL < 0.55 ? errorL + 0.22 : errorL, 0.78)" },
    "INF": { "l": "clamp(0.55, infoL < 0.55 ? infoL + 0.22 : infoL, 0.78)" },
    "textMain": { "l": 0.93, "c": 0.015, "h": "anchorH" }
  },
  "textAlphaScale": {
    "primary": 1.0,
    "secondary": 0.72,
    "tertiary": 0.50,
    "disabled": 0.38,
    "faintBorder": 0.08
  }
}
```

---

## 6. Implementation Checklist for AI Agents

When implementing or extending this design system in Flutter or web components:
1. **Never hardcode hex values** for text, borders, surface tiers, or status indicators. Always derive them via `LayerPalette.fromAnchor(...)`.
2. **Never change $L_{\text{textMain}}$ arbitrarily**. Its constants ($0.20$ and $0.93$) are mathematically proven to satisfy WCAG AAA without glare or halation.
3. **Always inherit $H$ into $textMain$** so that text naturally integrates with the ambient theme temperature.
4. **Preserve C4 ceiling clamp ($0.985$)** in Light Mode to prevent washed-out dialogs.
5. **Always wrap flexible row contents** with `Expanded` + `TextOverflow.ellipsis` or `Wrap` to prevent `RenderFlex` overflow errors on compact responsive views.
6. **Map `primary`, `onPrimary`, `error`, and `onError`** to `colorScheme` and `inputDecorationTheme` in `toThemeData()`.

---

## 7. Flutter Global ThemeData Override (`toThemeData()`)

Rather than configuring every widget's styling properties manually, `LayerPalette.toThemeData()` converts the OKLCH color tokens into standard Flutter `ThemeData` properties.

### 7.1. Global Property Mapping Matrix

```yaml
Flutter_Theme_Mapping:
  scaffoldBackgroundColor: palette.container1 (C1)
  cardTheme.color: palette.container3 (C3)
  dialogTheme.backgroundColor: palette.container4 (C4)
  popupMenuTheme.color: palette.container4 (C4)
  dividerTheme.color: palette.dividerLine (DIV)
  elevatedButtonTheme:
    backgroundColor: palette.primary (PRI)
    foregroundColor: palette.onPrimary
  filledButtonTheme:
    backgroundColor: palette.primary (PRI)
    foregroundColor: palette.onPrimary
  inputDecorationTheme:
    filled: true
    fillColor: palette.textFieldFill (TF)
    enabledBorder.color: palette.textFieldBorder (TFB)
    focusedBorder.color: palette.primary (PRI)
    disabledBorder.color: palette.textFieldDisabledBorder (textMain @ 0.08a)
    errorBorder.color: palette.error (ERR)
    focusedErrorBorder.color: palette.error (ERR)
    errorStyle.color: palette.error (ERR)
  colorScheme:
    primary: palette.primary (PRI)
    onPrimary: palette.onPrimary
    error: palette.error (ERR)
    onError: palette.onError
    surface: palette.container3 (C3)
    onSurface: palette.textMain
    onSurfaceVariant: palette.textMain @ 0.72a
    surfaceContainerLowest: palette.container1 (C1)
    surfaceContainer: palette.container2 (C2)
    surfaceContainerHigh: palette.container3 (C3)
    surfaceContainerHighest: palette.container4 (C4)
    secondaryContainer: palette.tonalButtonFill (TBF)
    onSecondaryContainer: palette.tonalButtonText (TBT)
```

### 7.2. Standard Usage Example

```dart
// In your MaterialApp setup:
MaterialApp(
  theme: LayerPalette.fromAnchor(anchorL: 0.970, c: 0.003, h: 264.5, isDark: false).toThemeData(),
  darkTheme: LayerPalette.fromAnchor(anchorL: 0.173, c: 0.0, h: 0.0, isDark: true).toThemeData(),
  home: const HomeScreen(),
);

// In any screen widget - ZERO manual styling boilerplate required:
const TextField();                                  // Automatically gets sunken trough TF, border TFB & focusedBorder PRI!
const TextField(enabled: false);                    // Automatically flat with C3 & disabled border!
const TextField(decoration: InputDecoration(errorText: 'Invalid!')); // Automatically gets errorBorder & errorStyle in palette.error!
const ElevatedButton(...);                          // Automatically uses palette.primary & onPrimary!
const Divider();                                    // Automatically uses dividerLine!
const Card(child: ...);                             // Automatically gets C3 surface!
showDialog(...);                                    // Automatically gets C4 floating surface!
```

