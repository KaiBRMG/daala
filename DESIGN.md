---
name: Daala
description: A dark, flat, trust-forward gig marketplace for South Africa's informal economy, where one account both earns and hires.
colors:
  night-green: "#003716"
  night-canvas: "#002A10"
  stall-card: "#114424"
  placeholder-green: "#1B4C2C"
  raised-green: "#225232"
  cream: "#F5F5DC"
  market-orange: "#ED7D31"
  ink-body: "#F5F5DCC7"
  ink-soft: "#F5F5DCBD"
  ink-muted: "#F5F5DCB0"
  ink-faint: "#F5F5DC66"
  ink-hairline: "#F5F5DC26"
  green-muted: "#003716B3"
  cream-tint: "#F5F5DC1A"
  cream-tint-strong: "#F5F5DC29"
  orange-tint: "#ED7D312E"
  divider: "#F5F5DC14"
  divider-strong: "#F5F5DC1F"
  track: "#F5F5DC12"
  scrim: "#001A0A99"
  selection: "#ED7D314D"
typography:
  display:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "52px"
    fontWeight: 800
    lineHeight: 1.0
    letterSpacing: "-1px"
  money:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "30px"
    fontWeight: 800
    letterSpacing: "-0.5px"
  headline:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "30px"
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: "-0.5px"
  headline-post:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "28px"
    fontWeight: 800
    lineHeight: 1.25
    letterSpacing: "-0.4px"
  headline-page:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "26px"
    fontWeight: 800
    letterSpacing: "-0.3px"
  input-value:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 700
  figure:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 800
  app-bar:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "18px"
    fontWeight: 700
  section:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 700
  price:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 800
  title:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 700
  value:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 600
  row-title:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 700
  meta-strong:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 600
  body:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "13px"
    fontWeight: 500
    lineHeight: 1.6
  label:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "13px"
    fontWeight: 700
  overline:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "13px"
    fontWeight: 700
    letterSpacing: "0.4px"
  caption:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "12px"
    fontWeight: 600
  meta:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "12px"
    fontWeight: 500
  tag:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "12px"
    fontWeight: 700
  status:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "11px"
    fontWeight: 700
  tab:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "10px"
    fontWeight: 600
rounded:
  status: "8px"
  segment: "12px"
  tag: "14px"
  card: "16px"
  track: "16px"
  chip: "20px"
  pill: "24px"
  sheet: "24px"
  button: "28px"
  tabbar: "34px"
  circle: "50%"
spacing:
  xs: "6px"
  sm: "8px"
  md: "10px"
  lg: "12px"
  xl: "14px"
  "2xl": "16px"
  "3xl": "18px"
  "4xl": "22px"
  gutter: "18px"
components:
  button-primary:
    backgroundColor: "{colors.market-orange}"
    textColor: "{colors.night-green}"
    typography: "{typography.section}"
    rounded: "{rounded.button}"
    height: "56px"
    padding: "0 24px"
  button-cream:
    backgroundColor: "{colors.cream}"
    textColor: "{colors.night-green}"
    typography: "{typography.section}"
    rounded: "{rounded.button}"
    height: "56px"
    padding: "0 24px"
  button-disabled:
    backgroundColor: "{colors.raised-green}"
    textColor: "{colors.ink-faint}"
    typography: "{typography.section}"
    rounded: "{rounded.button}"
    height: "56px"
  button-text:
    textColor: "{colors.cream}"
    typography: "{typography.value}"
    height: "48px"
    padding: "0 16px"
  button-round-icon:
    backgroundColor: "{colors.stall-card}"
    textColor: "{colors.cream}"
    rounded: "{rounded.circle}"
    size: "44px"
  button-round-icon-inverted:
    backgroundColor: "{colors.cream}"
    textColor: "{colors.night-green}"
    rounded: "{rounded.circle}"
    size: "44px"
  button-header-pill:
    backgroundColor: "{colors.stall-card}"
    textColor: "{colors.cream}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    height: "44px"
    padding: "0 18px"
  card:
    backgroundColor: "{colors.stall-card}"
    textColor: "{colors.cream}"
    rounded: "{rounded.card}"
    padding: "16px 18px"
  card-balance:
    backgroundColor: "{colors.cream}"
    textColor: "{colors.night-green}"
    rounded: "{rounded.card}"
    padding: "20px"
  field:
    backgroundColor: "{colors.stall-card}"
    textColor: "{colors.cream}"
    typography: "{typography.input-value}"
    rounded: "{rounded.card}"
    padding: "12px 16px"
  search-field:
    backgroundColor: "{colors.stall-card}"
    textColor: "{colors.ink-muted}"
    typography: "{typography.meta-strong}"
    rounded: "{rounded.pill}"
    height: "48px"
    padding: "0 16px"
  tag-pill:
    backgroundColor: "{colors.cream-tint}"
    textColor: "{colors.cream}"
    typography: "{typography.tag}"
    rounded: "{rounded.tag}"
    padding: "6px 14px"
  attribute-pill:
    backgroundColor: "{colors.stall-card}"
    textColor: "{colors.cream}"
    typography: "{typography.caption}"
    rounded: "{rounded.tag}"
    padding: "8px 14px"
  status-pill-positive:
    backgroundColor: "{colors.cream}"
    textColor: "{colors.night-green}"
    typography: "{typography.status}"
    rounded: "{rounded.status}"
    padding: "4px 10px"
  status-pill-neutral:
    backgroundColor: "{colors.cream-tint}"
    textColor: "{colors.ink-body}"
    typography: "{typography.status}"
    rounded: "{rounded.status}"
    padding: "4px 10px"
  filter-chip:
    backgroundColor: "{colors.stall-card}"
    textColor: "{colors.cream}"
    typography: "{typography.caption}"
    rounded: "{rounded.chip}"
    padding: "9px 16px"
  filter-chip-selected:
    backgroundColor: "{colors.cream}"
    textColor: "{colors.night-green}"
    typography: "{typography.tag}"
    rounded: "{rounded.chip}"
    padding: "9px 16px"
  segment-track:
    backgroundColor: "{colors.track}"
    rounded: "{rounded.track}"
    padding: "4px"
  segment-active:
    backgroundColor: "{colors.cream}"
    textColor: "{colors.night-green}"
    typography: "{typography.label}"
    rounded: "{rounded.segment}"
    padding: "10px 0"
  segment-inactive:
    textColor: "{colors.ink-muted}"
    typography: "{typography.label}"
    rounded: "{rounded.segment}"
    padding: "10px 0"
  option-selected:
    textColor: "{colors.cream}"
    typography: "{typography.row-title}"
    rounded: "{rounded.track}"
    padding: "14px 12px"
  option-unselected:
    backgroundColor: "{colors.track}"
    textColor: "{colors.ink-muted}"
    typography: "{typography.meta-strong}"
    rounded: "{rounded.track}"
    padding: "14px 12px"
  avatar-initials:
    backgroundColor: "{colors.raised-green}"
    textColor: "{colors.cream}"
    rounded: "{rounded.circle}"
    size: "44px"
  photo-placeholder:
    backgroundColor: "{colors.placeholder-green}"
    rounded: "{rounded.tag}"
  tab-bar:
    backgroundColor: "{colors.raised-green}"
    rounded: "{rounded.tabbar}"
    height: "68px"
  tab-active:
    backgroundColor: "{colors.cream}"
    textColor: "{colors.night-green}"
    typography: "{typography.tab}"
    width: "34px"
    height: "26px"
  tab-inactive:
    textColor: "{colors.ink-muted}"
    typography: "{typography.tab}"
  fab-post:
    backgroundColor: "{colors.market-orange}"
    textColor: "{colors.night-green}"
    rounded: "{rounded.circle}"
    size: "58px"
  speed-dial-item:
    backgroundColor: "{colors.raised-green}"
    textColor: "{colors.cream}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    height: "48px"
    padding: "0 18px 0 14px"
  sheet:
    backgroundColor: "{colors.night-green}"
    textColor: "{colors.cream}"
    rounded: "{rounded.sheet}"
    padding: "20px 18px 40px"
  toggle-on:
    backgroundColor: "{colors.cream}"
    textColor: "{colors.night-green}"
    rounded: "{rounded.tag}"
    width: "46px"
    height: "28px"
  toggle-off:
    backgroundColor: "{colors.ink-hairline}"
    textColor: "{colors.cream}"
    rounded: "{rounded.tag}"
    width: "46px"
    height: "28px"
  progress-rail:
    backgroundColor: "{colors.track}"
    textColor: "{colors.cream}"
    rounded: "{rounded.status}"
    height: "4px"
---

# Design System: Daala

## 1. Overview

**Creative North Star: "Night Market"**

Daala is the stall street after dark: the brand green is not an accent laid on a page, it *is* the page. Every screen sits on deep night green, the objects on it are the same green lifted a step or two toward cream, and cream itself is the light the market is lit by: it is the text, and it is the one bright fill that marks what is selected, settled, or protected. Orange is the single lantern hung over the next thing to do. Nothing casts a shadow; things read as separate because their tone is separate, the way stalls read against a street at night.

Density stays low and legibility stays high, because the conditions have not changed: people use this one-handed, outdoors, often in hard South African daylight, on entry-level Android hardware with expensive data, and they arrive with varied reading confidence. A dark ground helps here rather than hurts: cream on green holds 12.3:1, the muted-text floor still holds 6.4:1 on the ground, and a flat system with no blur, no shadow, and no gradient is cheap to paint on 2GB hardware. Type runs large and heavy, tap targets run generous, and the brightest thing on any screen is always the thing that matters most: the money you hold, the step you're on, or the action to take next.

What it rejects is the classifieds wall PRODUCT.md names: *the Gumtree/OLX-style dense, spammy listing wall, endless undifferentiated rows, no sense of who is real, and nothing that makes handing over money feel safe.* It also refuses its own former self: the cream canvas, white cards, and soft ambient shadows of "The Sunlit Trade Stall" are retired. Trust is still the interface: every gig row carries a named person, a rating, and a status; protected money is the loudest flat object on screen; errors are sentences, never red.

**Key Characteristics:**
- Night green (`night-green`) is the screen; depth comes from tonal steps of cream mixed into green, never from shadows.
- Cream is both the foreground and the one bright fill. Anything sitting on cream or orange is set in green.
- Inversion is the selection grammar: active tab, active segment, selected chip, positive status, and protected money all flip to a solid cream fill with green text.
- One orange forward action per screen; orange CTAs carry green labels.
- Tight containers (card 16px, sheet 24px) and full pills for things you press or read as a label (CTA 28px, nav bar 34px).
- One typeface (Outfit) at heavy weights, one hero figure per primary screen, and money always cream at w800.

## 2. Colors

A single deep green ground, three tonal steps lifted from it, cream as the light, and one orange.

### Primary
- **Night Green** (`night-green`): The screen. Every scaffold, the modal sheets, the app bar, the system navigation bar, and the ring cut around the FAB. It is also the *ink on bright fills*: every label on an orange or cream fill, the glyph in the active tab chip, the balance figure on the wallet card.
- **Cream** (`cream`): The foreground and the one bright fill. As text it is primary ink, prices, and money. As a fill it marks selection and protection: the active tab chip, the active toggle segment, the selected filter chip, the positive status pill, the switch when on, the progress rail's fill, the secondary CTA, and the wallet balance card.

### Secondary
- **Market Orange** (`market-orange`): The lantern. It fills the single forward action on a screen (`Apply Now`, the Post FAB, `Withdraw to Bank`) and appears otherwise only as small accents: star ratings, the unread dot in Inbox, the splash screen's short working rule. Category heads and the next-booking icon are cream tints. Orange on green holds 4.9:1; cream on orange fails, so orange fills always carry green labels.

### Neutral (tonal surfaces)
- **Night Canvas** (`night-canvas`): Half a step darker than the screen, behind it as the device frame.
- **Stall Card** (`stall-card`): The +1 step. Cards, gig rows, field shells, the search field, round header buttons, unselected filter chips, attribute pills.
- **Placeholder Green** (`placeholder-green`): Photo, thumbnail, and media stand-ins, between card and raised so a placeholder reads as "something goes here" inside a card.
- **Raised Green** (`raised-green`): The +2 step. The floating nav bar, speed-dial pills, initials avatars, and the disabled CTA fill.

### Neutral (ink steps)
Ink is cream at fixed alphas over the ground, never a separate grey, so every step stays the same hue.
- **Ink Body** (`ink-body`, 78%): Descriptive copy, bios, emphasised inline notices, neutral status text.
- **Ink Soft** (`ink-soft`, 74%): Secondary amounts: outgoing transactions and fees, booking sub-lines.
- **Ink Muted** (`ink-muted`, 69%): The text floor. Meta, captions, field labels, overlines, placeholders, inactive segment and nav labels. Holds 4.8:1 on `stall-card` and 6.4:1 on `night-green`.
- **Ink Faint** (`ink-faint`, 40%) and **Ink Hairline** (`ink-hairline`, 15%): Non-text only. Faint is for disabled labels, the search glyph, and the idle `Done` action; hairline is the off track of a switch and the sheet grab handle.
- **Green Muted** (`green-muted`, 70% green): Secondary text on a cream fill (the wallet card's caption, the escrow card's overline).

### Structure and tints
- **Divider** (`divider`, 8%) separates stacked rows inside a card; **Divider Strong** (`divider-strong`, 12%) is the vertical rule in a split card. Neither ever outlines a card.
- **Track** (`track`, 7%) is the segmented-toggle track, the unselected two-option tile, and the progress rail's empty track.
- **Cream Tint** (`cream-tint`, 10%) backs tag pills, neutral status pills, and small icon circles; **Cream Tint Strong** (16%) and **Orange Tint** (18%) alternate on the category-tile heads.
- **Scrim** (`scrim`): 60% night green behind the open speed-dial and every sheet.
- **Selection** (`selection`): orange at 30% for selected text; the cursor is cream and the handles orange.

### Named Rules

**The Flat-Tone Rule.** Depth is tone, never shadow. A surface one step up is `stall-card`; two steps up is `raised-green`. `AppShadows` no longer exists and nothing in the system may cast a shadow, glow, or blur.

**The Green-On-Bright Rule.** Anything set on a cream or orange fill is green: labels, glyphs, figures, spinners. Cream on orange is prohibited (it fails contrast), and white does not exist in this system.

**The Inversion Rule.** Selection, settlement, and protection are shown by inverting: a solid cream fill with green content. Active tab, active segment, selected filter chip, positive status, switch on, secondary CTA, and the wallet balance card all use it. Nothing else may be a solid cream block, or the grammar stops meaning "this one".

**The One-Action Orange Rule.** Orange fills exactly one primary forward action per screen. Two orange CTAs on one screen are prohibited. Orange's other appearances (ratings, unread dot, the splash rule) stay small and never decorate structure.

**The Cream Money Rule.** Money is cream at w800. Prices, payouts, incoming transactions, and suggested prices are cream; protected money (the wallet balance, held-in-escrow) is the loudest flat object on screen, a solid cream block with the figure in green. Money leaving (fees, withdrawals in a list) steps down to `ink-soft`, never red. Orange is reserved for actions that move money; no figure is ever orange, weekly earnings included.

**The Readable-Muted Rule.** Text bottoms out at `ink-muted`. `ink-faint` and `ink-hairline` are for shapes, disabled states, and glyphs only. Below the floor, hierarchy is carried by size and weight, never by fading text further.

## 3. Typography

**Display / Body / Label Font:** Outfit (with `system-ui, sans-serif` fallback), loaded through `google_fonts`. There is no second family.

**Character:** One geometric sans doing every job, at heavy weights. Outfit's round bowls read friendly without calligraphic warmth, and it is best big and heavy, which suits a system carried by hero figures and w800 money. Large display roles carry slight negative tracking (-1px at 52px, -0.5px at 30px, down to -0.3px at 26px) so they close up into solid shapes on the dark ground. Geometric faces close their apertures under glare, so the floor sizes (10px tab labels, 11px status) stay at w600 or heavier and never drop below `ink-muted`.

### Hierarchy
- **Display** (w800, 52px, 1.0): The one hero figure on a primary screen: Home's `24 Gigs`, the carousel's weekly-earnings figure.
- **Money** (w800, 30px): The wallet balance and the escrow amount, green on the cream card.
- **Headline** (w800, 30px, 1.2): Detail-screen titles. The post-gig wizard title uses **Headline Post** (28px, 1.25).
- **Page Headline** (w800, 26px): Left-aligned titles on primary list screens and every auth screen.
- **Input Value** (w700, 22px) / **Figure** (w800, 22px): A typed phone number or email; one OTP or date cell, and the paired numbers in a split card.
- **App-bar Title** (w700, 18px): Centred titles on pushed screens, between round icon buttons.
- **Section** (w700, 16px): Section headers and CTA labels. **Price** is the same size at w800 in cream.
- **Title** (w700, 15px): Card titles and poster names. **Value** (w600, 15px): fact rows, sheet rows, text actions at w700.
- **Row Title** (w700, 14px): List-row and speed-dial labels. **Meta Strong** (w600, 14px): transaction descriptions, option-tile labels, search placeholder.
- **Body** (w500, 13px, 1.6, `ink-body`): Helper copy, subtitles, bios, inline notices.
- **Label** (w700, 13px, `ink-muted`): Field labels and toggle-segment labels.
- **Overline** (w700, 13px, +0.4px, UPPERCASE, `ink-muted`): List groupings (`TOMORROW`, `THIS WEEK`, `BALANCE`) and the caption over a single figure (`HELD IN ESCROW`). Never above a headline.
- **Caption** (w600, 12px, `ink-muted`): Stat-card captions over a figure. **Meta** (w500, 12px, `ink-muted`): distances, timestamps, consent line.
- **Tag** (w700, 12px): Pill labels and small inline actions (`See all`, `Save`).
- **Status** (w700, 11px): Lifecycle pills.
- **Tab Label** (w600, 10px): Bottom-nav labels only. The floor of the system.

### Named Rules

**The Heavy-Weight Rule.** Hierarchy is carried by weight (700/800) and size, never by colour alone and never by a second typeface. Emphasis gets heavier or bigger, not a display face, an outline, or a gradient.

**The Big-Number Rule.** Each primary screen earns exactly one hero-scale figure: gigs nearby on Home, the balance on Wallet. Competing large numbers turn it into a dashboard.

**The Complete-Scale Rule.** Every size and weight a screen needs is a named role in `AppText`. A screen reaching for a one-off `fontSize` override has found a missing role: add the role, don't patch the screen.

## 4. Elevation

This system is **fully flat**. There are no shadows, glows, or blurs anywhere: `AppShadows` was removed, the `ThemeData` zeroes every Material elevation and sets the shadow colour transparent, and splash and highlight ink are off. Depth is conveyed by three tonal steps above the ground (`stall-card`, `placeholder-green`, `raised-green`) and by inversion to cream for the few objects that must be loudest. Strokes exist only as hairline dividers *inside* a card, the 2px cream outline on a selected two-option tile, the 2px cream focus outline on a field, and the 4px ground-coloured ring around the FAB.

### Named Rules

**The Tone-Step Rule.** Something that sits on something else is one tone lighter. Cards on the ground are `stall-card`; the nav bar and speed-dial pills that float over cards are `raised-green`; a sheet drops back to the ground tone above the scrim so its cards read as cards again.

**The Cut-Out Rule.** "Raised" in a flat system is said with a gap, not a shadow: the FAB is lifted half out of the nav bar and wrapped in a 4px ring of the ground colour, which cuts it cleanly out of the bar.

**The Hairline-Inside Rule.** A card's edge is its tone change. An outer border on a card is prohibited; dividers live only between rows or cells within one card.

## 5. Components

### Buttons
- **Shape:** Full pill (`rounded.button`), 56px tall, centred Section-weight label. Pressed scales to 0.97 over 120ms (skipped under reduced motion); fill changes animate over 150ms.
- **Primary (orange):** `market-orange` fill, green label. The one forward action: `Apply Now`, `Send Code`, `Verify`, `Continue`.
- **Cream:** `cream` fill, green label. Committing and creating actions: finishing a form (`Complete Setup`, `Post Gig`), agreeing (`I Agree`), or the alternative route on a fork (`Log in with Email` on the email-conflict screen). Never beside an orange CTA of equal weight.
- **Disabled:** drops to `raised-green` with an `ink-faint` label, never a grey. **Loading:** a 20px green spinner in a pill that keeps its width.
- **Text action:** cream Value-weight label at w700 in a 48dp hit area, for secondary routes (`Log in with Email`, `Change number`, `Skip`). Never competes with the CTA.
- **Round icon button:** 44px `stall-card` circle, cream glyph: back, search, add. The inverted variant (`cream` circle, green glyph) is the search filter button.
- **Header pill:** 44px `stall-card` pill with a cream glyph and label (`Save`).
- **Inline money action:** `Withdraw to Bank` is a compact orange pill with a green label, sitting on the cream balance card.

### Chips & Tags
- **Tag pill:** `cream-tint` fill, cream Tag label, `rounded.tag`, 6×14px. Categories and skills.
- **Attribute pill:** `stall-card` fill, cream w600/12px, 8×14px: `Heavy lifting`, `Own transport`.
- **Status pill:** `rounded.status`, 4×10px, Status type. Positive states (`Confirmed`) are solid cream with green text, the brightest small object on a row; neutral in-flight states (`In progress`) use `cream-tint` with `ink-body` text.
- **Filter chip:** `rounded.chip`, 9×16px, horizontally scrolling. Selected inverts to cream with green w700; unselected is `stall-card` with cream w600.
- **Segmented toggle:** a `track` fill at `rounded.track` with 4px inset; the active segment inverts to a cream `rounded.segment` block with a green Label; inactive is transparent with `ink-muted`. Carries Home's `Earn Moola / Browse Gigs` and My Gigs' `Upcoming / Applied / Completed`.
- **Two-option selector:** side-by-side tiles at `rounded.track`, 14px vertical padding. Selected is transparent with a 2px cream outline and cream w700; unselected sits on `track` with `ink-muted` w600.

### Cards / Containers
- **Corner style:** `rounded.card`.
- **Background:** `stall-card` on the ground. The one bright variant is the protected-money card: solid cream, `green-muted` caption, green Money figure, and the orange withdraw action.
- **Shadow strategy:** none (see Elevation). **Border:** none on the outer edge.
- **Internal padding:** 16×18px default; 18px for split and stat cards; 14×16px for compact rows; zero with clipping for media-topped cards.
- **Signature variants:** the **split card** (two equal cells, caption over a 22px figure, one `divider-strong` rule between); the **category tile** (a flexible tint head alternating `cream-tint-strong` and `cream-tint`, then name and count); the **carousel card** (140px wide, 88px `placeholder-green` media head, title, distance, price).

### Inputs / Fields
- **Field shell:** a Label above a `stall-card` block at `rounded.card`, 12×16px padding. It always carries a 2px border, transparent at rest and cream when focused, so focus never shifts layout. Typed values use Input Value.
- **Search field:** 48px `stall-card` pill at `rounded.pill`, `ink-faint` leading glyph, `ink-muted` placeholder.
- **Toggle switch:** 46×28 track at `rounded.tag`, 2px inset, 24px thumb. On: cream track, green thumb. Off: `ink-hairline` track, cream thumb. Thumb crosses in 180ms.
- **Progress rail:** a 4px `track` bar with a cream fill and `rounded.status` ends, for multi-step auth flows.
- **Errors:** there is no red. An error is an `InlineNotice`: a sentence in `ink-body` led by a small cream info glyph; a hint is the same sentence in `ink-muted` with no glyph.

### Navigation
- **Floating pill tab bar:** a 68px `raised-green` bar at `rounded.tabbar`, inset 16px from the sides and bottom, floating over content. **Home · My Gigs · [+] · Inbox · Profile.** Scroll views pad ~120px at the bottom to clear it.
- **Active tab:** inverted: a 34×26 cream chip with a filled 16px green glyph, label cream. **Inactive:** an 18px outline glyph and label at `ink-muted`, because the labels are text.
- **Post FAB:** a 58px orange circle with a green `+`, lifted 13px out of the bar and ringed 4px in the ground colour. It rotates 45° over 250ms when open. One FAB, one purpose.
- **Speed-dial:** three `raised-green` pills (48px, `rounded.pill`) with a 30px `cream-tint` icon circle and a cream 13px w700 label: `Post a listing · Post a task · Post to media`. They slide up with a slight overshoot and fade over the scrim, staggered 30ms apart.

### Modal Sheet
Sheets rise over the `scrim` to at most 88% of screen height, on the **ground tone** (`night-green`) with a `rounded.sheet` top edge, so the `stall-card` rows inside read as cards again. The header is `Cancel` (cream) · centred title · `Done` (`ink-faint` until there's something to commit). Rows are `stall-card` cards; a centred `ink-muted` footnote may close the sheet.

### Logo and Splash
The official wordmark in its cream variant (`kLogoOnDark`, exported from `public/logo/light.svg`) sits straight on the ground with no plate. The splash is the wordmark alone, the tagline (`Get it done. Get paid.`) in `ink-body`, and a 44×3px orange rule in place of a spinner. It is the only screen with nothing but the brand on it. **Shutters open:** the wordmark is clipped into its five glyphs, which rise from behind the baseline left to right (easeOutQuart, no overshoot). The tagline then fades in and the rule draws out from its centre, all within 860ms. If the session is still resolving, the rule drifts slowly side to side as the working signal. Under reduced motion the finished composition shows with no motion.

### States
- **Loading:** `placeholder-green` blocks in the geometry of the card they replace. No shimmer and no spinner inside content.
- **Empty:** a plain Title line naming what will appear and the screen's own CTA to start it.
- **Error:** an inline sentence and a way to try again; never a full-screen takeover, never red.

## 6. Do's and Don'ts

### Do:
- **Do** take every colour, radius, spacing step, and text style from `lib/theme/app_theme.dart` (`AppColors` / `AppSpacing` / `AppRadius` / `AppText`). A raw hex or a bare number in a screen is a bug.
- **Do** set every screen on `night-green` and lift objects by tone: `stall-card` for cards, `raised-green` for what floats over cards.
- **Do** set anything on a cream or orange fill in green (The Green-On-Bright Rule).
- **Do** show selection, positive status, and protected money by inverting to solid cream with green content (The Inversion Rule).
- **Do** fill exactly one forward action per screen in orange, with a green label; use the cream CTA for committing actions that aren't the lead.
- **Do** set money cream at w800, protected balances as the cream block, and fees and outgoing amounts in `ink-soft`.
- **Do** write all money in South African Rand through `formatZar` (`R1 250`, `R450`, `R37.50`), stored as integer minor units, and use South African places in every example.
- **Do** keep text at `ink-muted` or brighter; carry lower hierarchy with size and weight.
- **Do** surface people, status, and protected-money cues on every list: initials avatar, name, rating, lifecycle status.
- **Do** carry hierarchy with Outfit at 700/800, keep one hero figure per primary screen, and add a named `AppText` role instead of a local override.
- **Do** keep copy plain and warm, and use the fixed nouns: `Buyer`, `Merchant`, `Task`, `Listing`.
- **Do** ship pressed, disabled, and loading states on interactive components, and loading, empty, and error states on every list.

### Don't:
- **Don't** build the classifieds wall: *"the Gumtree/OLX-style dense, spammy listing wall, endless undifferentiated rows, no sense of who is real, and nothing that makes handing over money feel safe."*
- **Don't** add a shadow, glow, blur, or gradient to anything, or an outer border to a card (The Flat-Tone and Hairline-Inside Rules).
- **Don't** bring back the cream canvas or white cards, and don't use pure white anywhere.
- **Don't** put cream text on orange, or any colour but green on a bright fill.
- **Don't** use a solid cream fill for anything that isn't selected, settled, protected, or the cream CTA.
- **Don't** run two orange actions on one screen, fill a large area with orange, or use it to decorate structure.
- **Don't** set text in `ink-faint` or `ink-hairline`, or hard-code a grey for muted text.
- **Don't** use red, or any colour outside these tokens, to signal an error. Errors are stated in plain words.
- **Don't** show any currency but Rand.
- **Don't** introduce a second typeface or set structural text below w600.
- **Don't** use emoji or text glyphs as icons; use the one Material rounded/outline icon family.
- **Don't** put an uppercase overline above a headline as a kicker; overlines label a group or a single figure.
- **Don't** exceed 250ms on a state transition or animate for decoration, and give every animation a reduced-motion path.
- **Don't** intercept the iOS edge-swipe back or Android system Back, or let a touch target fall below 44pt / 48dp.
