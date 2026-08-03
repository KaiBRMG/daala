---
name: Daala
description: A warm, trust-forward gig marketplace for South Africa's informal economy — one account that both earns and hires.
colors:
  brand-green: "#003716"
  hustle-orange: "#FF823A"
  screen-cream: "#FAF7EC"
  outer-canvas: "#EFEDE6"
  card-white: "#FFFFFF"
  placeholder-khaki: "#EFE9D4"
  ink: "#111111"
  ink-65: "#111111A6"
  ink-55: "#1111118C"
  ink-40: "#11111166"
  ink-15: "#11111126"
  green-tint: "#00371618"
  green-tint-strong: "#00371622"
  orange-tint: "#FF823A22"
  divider: "#0000000F"
  divider-strong: "#00000014"
  track: "#0000000D"
  scrim: "#111A1466"
typography:
  display:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "52px"
    fontWeight: 800
    lineHeight: 1.0
  money:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "30px"
    fontWeight: 800
    lineHeight: 1.0
  headline:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "30px"
    fontWeight: 800
    lineHeight: 1.2
  headline-page:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "26px"
    fontWeight: 800
    lineHeight: 1.2
  figure:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "22px"
    fontWeight: 800
    lineHeight: 1.0
  app-bar:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "18px"
    fontWeight: 700
    lineHeight: 1.3
  section:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 700
    lineHeight: 1.3
  price:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 800
    lineHeight: 1.3
  title:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 700
    lineHeight: 1.3
  row-title:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 700
    lineHeight: 1.3
  value:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 600
    lineHeight: 1.3
  body:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "13px"
    fontWeight: 500
    lineHeight: 1.6
  label:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "13px"
    fontWeight: 700
    lineHeight: 1.3
  overline:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "13px"
    fontWeight: 700
    letterSpacing: "0.4px"
  caption:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "12px"
    fontWeight: 600
    lineHeight: 1.3
  meta:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "12px"
    fontWeight: 500
    lineHeight: 1.4
  tag:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "12px"
    fontWeight: 700
    lineHeight: 1.2
  status:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "11px"
    fontWeight: 700
    lineHeight: 1.2
  tab:
    fontFamily: "Outfit, system-ui, sans-serif"
    fontSize: "10px"
    fontWeight: 600
    lineHeight: 1.2
rounded:
  status: "10px"
  tag: "14px"
  chip: "16px"
  segment: "18px"
  card: "22px"
  track: "22px"
  pill: "24px"
  button: "28px"
  sheet: "28px"
  tabbar: "34px"
spacing:
  xs: "6px"
  sm: "8px"
  md: "10px"
  lg: "12px"
  xl: "14px"
  "2xl": "16px"
  "3xl": "18px"
  "4xl": "22px"
components:
  button-primary:
    backgroundColor: "{colors.hustle-orange}"
    textColor: "{colors.card-white}"
    typography: "{typography.section}"
    rounded: "{rounded.button}"
    height: "56px"
    padding: "0 24px"
  button-secondary:
    backgroundColor: "{colors.brand-green}"
    textColor: "{colors.card-white}"
    typography: "{typography.section}"
    rounded: "{rounded.button}"
    height: "56px"
    padding: "0 24px"
  button-header-pill:
    backgroundColor: "{colors.card-white}"
    textColor: "{colors.brand-green}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    height: "44px"
    padding: "0 18px"
  button-round-icon:
    backgroundColor: "{colors.card-white}"
    textColor: "{colors.ink}"
    rounded: "{rounded.tabbar}"
    size: "44px"
  card:
    backgroundColor: "{colors.card-white}"
    textColor: "{colors.ink}"
    rounded: "{rounded.card}"
    padding: "16px 18px"
  card-balance:
    backgroundColor: "{colors.brand-green}"
    textColor: "{colors.card-white}"
    rounded: "{rounded.card}"
    padding: "20px"
  tag-pill:
    backgroundColor: "{colors.green-tint}"
    textColor: "{colors.brand-green}"
    typography: "{typography.tag}"
    rounded: "{rounded.tag}"
    padding: "6px 14px"
  attribute-pill:
    backgroundColor: "{colors.card-white}"
    textColor: "{colors.ink}"
    typography: "{typography.caption}"
    rounded: "{rounded.tag}"
    padding: "8px 14px"
  status-pill:
    backgroundColor: "{colors.green-tint}"
    textColor: "{colors.brand-green}"
    typography: "{typography.status}"
    rounded: "{rounded.status}"
    padding: "4px 10px"
  status-pill-neutral:
    backgroundColor: "{colors.divider}"
    textColor: "{colors.ink-55}"
    typography: "{typography.status}"
    rounded: "{rounded.status}"
    padding: "4px 10px"
  filter-chip:
    backgroundColor: "{colors.card-white}"
    textColor: "{colors.ink}"
    typography: "{typography.caption}"
    rounded: "{rounded.chip}"
    padding: "9px 16px"
  filter-chip-selected:
    backgroundColor: "{colors.brand-green}"
    textColor: "{colors.card-white}"
    typography: "{typography.tag}"
    rounded: "{rounded.chip}"
    padding: "9px 16px"
  segment-active:
    backgroundColor: "{colors.card-white}"
    textColor: "{colors.brand-green}"
    typography: "{typography.label}"
    rounded: "{rounded.segment}"
    padding: "10px 0"
  segment-inactive:
    textColor: "{colors.ink-55}"
    typography: "{typography.label}"
    rounded: "{rounded.segment}"
    padding: "10px 0"
  option-selected:
    textColor: "{colors.brand-green}"
    typography: "{typography.row-title}"
    rounded: "{rounded.track}"
    padding: "14px 0"
  option-unselected:
    backgroundColor: "{colors.divider}"
    textColor: "{colors.ink-55}"
    typography: "{typography.value}"
    rounded: "{rounded.track}"
    padding: "14px 0"
  search-field:
    backgroundColor: "{colors.card-white}"
    textColor: "{colors.ink-55}"
    typography: "{typography.value}"
    rounded: "{rounded.pill}"
    height: "48px"
    padding: "0 16px"
  avatar-initials:
    backgroundColor: "{colors.brand-green}"
    textColor: "{colors.card-white}"
    rounded: "{rounded.tabbar}"
    size: "44px"
  photo-placeholder:
    backgroundColor: "{colors.placeholder-khaki}"
    rounded: "{rounded.tag}"
  tab-bar:
    backgroundColor: "{colors.card-white}"
    rounded: "{rounded.tabbar}"
    height: "68px"
  tab-active:
    backgroundColor: "{colors.green-tint}"
    textColor: "{colors.brand-green}"
    typography: "{typography.tab}"
    rounded: "{rounded.status}"
  tab-inactive:
    textColor: "{colors.ink-40}"
    typography: "{typography.tab}"
  fab-post:
    backgroundColor: "{colors.hustle-orange}"
    textColor: "{colors.card-white}"
    rounded: "{rounded.tabbar}"
    size: "52px"
  speed-dial-item:
    backgroundColor: "{colors.card-white}"
    textColor: "{colors.ink}"
    typography: "{typography.label}"
    rounded: "{rounded.pill}"
    height: "48px"
    padding: "0 18px 0 14px"
  sheet:
    backgroundColor: "{colors.screen-cream}"
    textColor: "{colors.ink}"
    rounded: "{rounded.sheet}"
    padding: "20px 18px 40px"
  toggle-on:
    backgroundColor: "{colors.brand-green}"
    rounded: "{rounded.tag}"
    width: "46px"
    height: "28px"
  toggle-off:
    backgroundColor: "{colors.ink-15}"
    rounded: "{rounded.tag}"
    width: "46px"
    height: "28px"
---

# Design System: Daala


## 1. Overview

**Creative North Star: "The Sunlit Trade Stall"**

Daala is an open-air marketplace rendered in software. The canvas is sun-bleached cream, the objects on it are clean white cards, and two brand colours split the emotional labour between them: a deep, grounded green that reassures, and a vibrant orange that invites. It should feel like a well-run stall on a bright street — someone you can see, run by someone who has your back — not a bank, not a corporation, and emphatically not a classifieds board. Every surface is soft-cornered and generously spaced, because the moment this product has to earn is the moment a stranger hands over money.

Density is deliberately low and legibility deliberately high. People use this outdoors, one-handed, in hard South African daylight, on entry-level Android hardware, and they arrive with varied reading confidence. So type runs large and heavy, tap targets run generous, colour does the wayfinding, and copy stays plain. The register is **product, not brand**: the interface has no ambition of its own and should disappear into the task of finding, offering, and completing a gig. Where a marketing surface would reach for an effect, this system reaches for a bigger number and more air.

What it explicitly rejects is the classifieds failure mode PRODUCT.md names by hand: *"the Gumtree/OLX-style dense, spammy listing wall — endless undifferentiated rows, no sense of who is real, and nothing that makes handing over money feel safe."* Daala answers that structurally. Rows are cards with breathing room, every gig carries a named human with initials and a rating, and money is colour-coded by whether it is settled, protected, or moving. Trust is not a badge bolted onto the corner of a screen; it is the layout.

**Key Characteristics:**
- Warm cream (`#FAF7EC`) canvas with white cards floating on it — never a cold white, never a grey app-chrome surface.
- Two brand colours in tension: **green = safe and settled**, **orange = energy and the next action**.
- Rounded-everything (10–34px); the pill is the signature shape — nav bar, CTAs, tags, toggles, search.
- Soft ambient shadows carry all depth. This system is intentionally *not* flat and *not* 1px-bordered.
- One typeface (Outfit) at heavy weights (600–800); hierarchy from weight and size, never a second family.
- One hero-scale figure per primary screen, and money always coloured by meaning.

## 2. Colors

A warm khaki-neutral foundation carrying exactly two saturated brand colours, each with a fixed job.

### Primary
- **Deep Trust Green** (`#003716`): The grounded anchor and the colour of settled money. It carries prices (`R65`), the wallet balance card fill, positive transaction amounts (`+R28.00`), the active navigation tab, tag-pill text, verification and trust cues, the "Confirmed" status pill, the selected filter chip, initials avatars, and the secondary "Post Gig" CTA. Rule of thumb: if money is **held, earned, or protected**, it is green.

### Secondary
- **Hustle Orange** (`#FF823A`): The energy accent and the loudest element on any screen. Its lead job is the single primary forward action — the raised central Post FAB, "Apply Now", and "Withdraw to Bank". Beyond that one action it appears only as a small human-trust or momentum accent: the Home weekly-earnings figure, star ratings (`★ 4.9`), review stars, and the unread-message dot in Inbox. It never fills a large area and never decorates structure.

### Neutral
- **Screen Cream** (`#FAF7EC`): The background of every screen, and the surface of the modal sheet. The system's warmth lives here, not in the brand colours.
- **Outer Canvas** (`#EFEDE6`): A half-step darker cream sitting behind the screen as the device/canvas frame.
- **Card White** (`#FFFFFF`): Every raised card, row, header button, filter chip, speed-dial pill, and the floating nav bar. White is what makes an element read as *a discrete, trustworthy object* against the cream.
- **Placeholder Khaki** (`#EFE9D4`): Photo, thumbnail, and avatar stand-in blocks, and the skeleton-loading fill. The literal khaki of the theme.
- **Ink** (`#111111`): Primary text. Muted text is expressed as **alpha over ink**, never as a separate grey token, so it always composites against the cream at true contrast. Two text steps only: **ink-65%** for descriptive body copy, **ink-55%** for meta, captions, field labels, section overlines, and input placeholders. Steps below that (**ink-40%**, **ink-15%**) are non-text only: inactive nav icons, hairlines, the off state of a toggle track.
- **Structure tints**: dividers are black at 6% (hairlines inside cards, between transaction rows) and 8% (the vertical rule splitting a two-cell card). The segmented-toggle track is black at 5%. The scrim behind sheets and the open FAB is a warm green-black at 40% (`rgba(17,26,20,.4)`) so dimming stays soft rather than funereal.

### Brand tints
- **Green tint** (`#00371618`, green at 9%): translucent green over cream — tag and skill pills (with green text), the active-tab chip, the "Confirmed" status pill, and the small green icon backings on form rows and speed-dial items. Because it is alpha-over-brand, it always reads as cream showing through green rather than as a separate sage swatch.
- **Green tint strong** / **Orange tint** (`#00371622` / `#FF823A22`, both at ~13%): the alternating fills of the category-grid tile headers, and the orange icon backing on Home's next-booking row.

### Named Rules

**The One-Action Orange Rule.** Orange leads exactly one primary forward action per screen. Its scarcity *as a button* is the "do this next" signal. Two competing orange CTAs on one screen are prohibited. Orange may additionally appear as a small accent (ratings, weekly earnings, unread dot) but never as a second large action and never as decoration of structure.

**The Green Money Rule.** Settled and protected money is green: prices, positive transaction amounts, the wallet balance card, escrow surfaces, fixed payouts. Money leaving or moving forward is orange (Withdraw, Apply). Money lost to the platform — fees, withdrawals in a transaction list — is neutral ink-55%, never red. The single deliberate exception is Home's "earned this week" figure, rendered orange as a motivational energy highlight rather than a settled balance.

**The Warm-Never-White Rule.** No screen background is pure white and no surface is a cold grey. Backgrounds are cream (`#FAF7EC`); objects are white cards on top of it. A grey app-chrome surface reads as a generic tool and is prohibited.

**The Readable-Muted Rule.** Muted text bottoms out at **ink-55%** (4.7:1 on cream — passes). Anything fainter is not text. This is a deliberate correction to the reference mockup, which sets meta at ink-45% (3.3:1) and search placeholders at ink-35% (2.6:1); both fail against cream and both fail hardest in exactly the bright-daylight, varied-literacy conditions this product ships into. Hierarchy below ink-55% is carried by **size and weight**, which this system has in abundance — never by fading text further.

## 3. Typography

**Display / Body / Label Font:** Outfit (with `system-ui, sans-serif` fallback). There is no second family.

**Character:** One geometric sans doing every job. Outfit is built on near-circular bowls and even stroke weights — clean, modern, and confident, with a friendliness that comes from roundness rather than from calligraphic warmth. It is at its best big and heavy, which suits a system whose hierarchy is carried by hero figures and 800-weight numbers. Hierarchy comes from **weight and size**, never from a second face and never from colour alone. Weights run heavy: nothing structural sits below 600, and every number that matters is 800. No serif, no display face, no mono — a product-register decision that keeps labels, data, and prose visually of a piece.

**The trade-off to watch.** Geometric sans faces differentiate less at small sizes than humanist ones — Outfit's `a` / `o` / `e` share a circle, and its apertures close up under glare. The system's floor sizes (Tab Label at 10px, Meta and Status at 11px) are where this bites, on exactly the outdoor, entry-level-Android, varied-literacy reading this product is built for. Hold the 10px floor as an absolute, keep the small roles at w600 or heavier, and honour The Readable-Muted Rule strictly at these sizes — an ink-55% 11px label in Outfit has no margin left to give away.

### Hierarchy
- **Display** (w800, 52px, line-height 1.0): The one hero figure on Home (`24 Gigs`). Centred, one per screen, the emotional anchor of the earn view.
- **Money** (w800, 30px): The wallet balance, set white on the green balance card.
- **Headline** (w800, 30px / 26px, line-height 1.2): Detail-screen titles (`Help moving a 2-bed apartment`) at 30px; the post-gig wizard title steps to 28px at line-height 1.25. Large left-aligned page titles on primary list screens (`Browse Gigs`, `My Gigs`, `Inbox`) sit at 26px.
- **Figure** (w800, 22px / 20px / 18px): The paired numbers inside split stat cards (`R65` payout, `~2 hrs` duration, `40 taskers`, `R72` suggested) and the three profile stat tiles (`62`, `98%`, `2023`). Green when the figure is money, ink when it is not.
- **App-bar Title** (w700, 18px): Centred titles on pushed screens, flanked by round icon buttons (`My Wallet`, `Profile`). The modal sheet header sits one step down at w700/17px.
- **Section** (w700, 16px): Section headers (`Gigs For You`, `Categories`, `Home & Garden`) and CTA button labels. Prices in gig rows use the same 16px at w800 in green.
- **Title** (w700, 15px): Card titles and poster names (`Marlo T.`, `Garden cleanup`). Sheet row labels use 15px at w600.
- **Row Title** (w700, 14px): List-row and speed-dial labels (`Assemble flatpack shelving`, `Post a service`).
- **Value** (w600, 14px): Fact rows on the detail screen (`Braamfontein 2001`, `Fri 12 Jul, 9:00am`) and transaction descriptions. Transaction amounts use 14px at w800.
- **Body** (w500, 13px, line-height 1.6, ink-65%): Descriptive helper copy and profile bios. Review quotes step to 12px/1.5. This is app UI, not long-form — keep prose short rather than reaching for a wide measure.
- **Label** (w700, 13px, ink-55%): Field labels above form rows (`Category`, `Budget`, `Pricing Type`).
- **Overline** (w700, 13px, UPPERCASE, letter-spacing 0.4px, ink-55%): List groupings and section eyebrows on Wallet and My Gigs (`BALANCE`, `RECENT GIGS`, `TOMORROW`, `THIS WEEK`). This is the *only* sanctioned uppercase treatment in the system.
- **Caption** (w600, 12px / 11px, ink-55%): Stat-card captions above a figure (`My Offers`, `Estimated Payout`, `Gigs Done`).
- **Meta** (w500, 12px / 11px, ink-55%): Distances, timestamps, sub-labels (`1.2km · posted 2h ago`, `2m`).
- **Tag** (w700, 12px): Pill labels and small inline actions (`Save`, `Get Help`, skill chips).
- **Status** (w700, 11px): Lifecycle status pills (`Confirmed`, `In progress`).
- **Tab Label** (w600, 10px): Bottom-nav labels only. The floor of the system — nothing else goes this small.

### Named Rules

**The Heavy-Weight Rule.** Hierarchy is carried by weight (700/800) and size, never by colour alone and never by a second typeface. If something needs emphasis it gets heavier or bigger; it does not get a display font, an outline, or a gradient.

**The Big-Number Rule.** Each primary screen earns exactly one hero-scale figure — gigs nearby on Home, the balance on Wallet. Competing large numbers dilute it into a dashboard.

**The Complete-Scale Rule.** Every size and weight a screen needs is a named role in the token file. A screen that reaches for a one-off `fontSize` override has found a missing role — add the role, don't patch the screen. Local overrides are how a documented scale quietly stops being the scale.

## 4. Elevation

This system is **soft-shadow layered — not flat, not bordered**. Depth comes almost entirely from diffuse, low-opacity ambient shadows: cards, chips, the floating nav bar, sheets, and CTAs all lift off the cream on cushioned shadows rather than sitting inside 1px strokes. Borders exist only as *internal dividers* — a hairline between the two cells of a split card, between transaction rows — never as a card's outer edge. Brand CTAs cast a **tinted** shadow in their own hue, an orange glow under the FAB and orange CTA and a green glow under the green CTA, which reads as warmth and importance rather than a hard drop. Opacities stay at or below 16% for neutral shadows; anything darker reads as a 2014 app.

### Shadow Vocabulary
- **card** (`0 2px 10px rgba(0,0,0,.05)`): The default resting lift under white cards, gig rows, and inbox rows.
- **card-quiet** (`0 2px 10px rgba(0,0,0,.04)`): The paired Home stat cards, which sit slightly further back so the hero figure above them stays dominant.
- **sheet-row** (`0 2px 8px rgba(0,0,0,.05)`): Card rows inside the modal sheet, tightened because the sheet is already lifted.
- **soft** (`0 2px 6px rgba(0,0,0,.06)`): Round header buttons, the header pill button, the search field, and the active segment of a toggle.
- **chip** (`0 2px 6px rgba(0,0,0,.05)`): Unselected filter chips and white attribute pills.
- **chip-brand** (`0 2px 6px rgba(0,0,0,.10)`): The green filter/sort button — slightly deeper so a saturated fill still reads as raised.
- **category** (`0 4px 14px rgba(0,0,0,.07)`): The category grid tiles, which carry a touch more presence than a plain card.
- **tabbar** (`0 8px 24px rgba(0,0,0,.12)`): The floating pill navigation bar hovering over scrolling content.
- **speed-item** (`0 8px 18px rgba(0,0,0,.16)`): The speed-dial action pills while the FAB is open, above the scrim.
- **fab** (`0 8px 18px rgba(255,130,58,.40)`): The orange glow beneath the central Post button.
- **cta-orange** (`0 6px 16px rgba(255,130,58,.35)`) / **cta-green** (`0 6px 16px rgba(0,55,22,.30)`): Coloured lift under the two primary CTA fills.

### Named Rules

**The Cushioned-Card Rule.** Cards are lifted, never outlined. A white card's edge is defined by its shadow against the cream. An outer `border` on a card is prohibited. The only legitimate strokes in this system are a hairline divider *inside* a container and the 2px green outline on a selected two-option pill.

**The Tinted-Glow Rule.** Primary CTAs and the FAB cast a shadow in their own brand hue, not neutral black. The glow is part of the button's identity, not an effect layered on top of it.

**The Shadow-Ceiling Rule.** Neutral shadow opacity never exceeds 16%, and blur never drops below 6px. If a shadow reads as a hard edge rather than as air under an object, it is wrong — go wider and fainter, never darker and tighter.

## 5. Components

### Buttons
- **Shape:** Full pill (28px radius), 56px tall, centred label at w700/16px in white.
- **Primary (orange):** `#FF823A` fill with the `cta-orange` glow. The one forward action on a screen — `Apply Now`, and the central Post FAB.
- **Secondary (green):** `#003716` fill with the `cta-green` glow. Committing and creating actions — `Post Gig`. (`Withdraw to Bank` is the orange fill at a smaller inline size: 10×18px padding, 18px radius, w700/13px, sitting on the green balance card.)
- **Header pill:** White pill, 44px tall, 18px horizontal padding, `soft` shadow, green w700/13px label with an optional leading green icon — `Save`, `Get Help`. Lives top-right on pushed screens.
- **Round icon button:** 44px white circle with the `soft` shadow — back, search, bell, add, edit. The universal chrome affordance, sized to clear both platform touch minimums.
- **Pressed:** scale to 0.97 and drop the shadow one step, 120ms. **Disabled:** fill at 40% opacity, label at ink-40%, no shadow. **Loading:** label swaps for a 20px white spinner; the pill keeps its width so nothing reflows.

### Chips & Tags
- **Tag pill:** Green-tint fill (`#00371618`), 14px radius, 6×14px padding, w700/12px green text — `Moving · One-time`, skill chips.
- **Attribute pill:** White with the `chip` shadow, 14px radius, 8×14px padding, w600/12px ink — neutral gig attributes like `Heavy lifting`, `Own transport`.
- **Status pill:** 10px radius, 4×10px padding, w700/11px. Positive lifecycle states use the green tint with green text (`Confirmed`); neutral in-flight states use a 6%-black fill with ink-55% text (`In progress`).
- **Filter chip:** 16px radius, 9×16px padding. Selected is a solid green fill with white w700/12px; unselected is white with the `chip` shadow and ink w600/12px. Horizontally scrolling row, never wrapped.
- **Segmented toggle:** A 22px-radius track at 5% black with 4px inset padding. The active segment is a white card (18px radius, `soft` shadow, green w700) and the inactive segment is transparent with ink-55% w600. Carries the Home `Earn Moola ⇄ Browse Gigs` switch and the My Gigs `Upcoming / Applied / Completed` tabs.
- **Two-option selector:** Side-by-side pills at 22px radius with 14px vertical padding. Selected is transparent with a 2px green border and green w700/14px; unselected sits on a 6%-black fill with ink-55% w600/14px. Used for Pricing Type and Schedule in the post-gig form.

### Cards / Containers
- **Corner style:** 22px radius, universally.
- **Background:** White on the cream screen. The one variant is the green-filled wallet balance card, which inverts to white text with its caption at white-70%.
- **Shadow strategy:** `card` by default; `category` for grid tiles; `chip`/`soft` for lightweight pills and rows; `card-quiet` for the recessed Home stat pair. See Elevation.
- **Border:** None on the outer edge, ever. Split cards use an 8%-black vertical hairline between their two cells; stacked transaction rows are separated by 6%-black horizontal hairlines with none on the last row.
- **Internal padding:** 16×18px default. 18px all round for split and stat cards, 14×16px for compact rows (inbox, transactions, reviews), and zero padding with `clip` for media-topped cards (category tiles, browse carousel cards).
- **Signature variants:** the **split card** (two equal cells, caption above figure, divided by one hairline); the **category tile** (76px tint header alternating green-tint-strong and orange-tint, then a 10×12px label block with name and gig count); the **carousel card** (140px wide, 88px khaki media header, then title, distance, and price).

### Inputs / Fields
The system is **picker-first, not keyboard-first** — the audience is one-handed, outdoors, on expensive data, and a tap beats typing every time.
- **Field row:** A w700/13px ink-55% label sits above a white card that displays the current value and opens a picker on tap. Value on the right at w800/16px ink for money, w600/15px for text.
- **Search field:** 48px tall, 24px radius, white with the `soft` shadow, 16px horizontal padding, leading 16px search glyph. Placeholder at w500/14px **ink-55%** — see The Readable-Muted Rule; the mockup's ink-35% placeholder is not to be reproduced.
- **Toggle switch:** A 46×28 pill track with a 24px white thumb and 2px inset. Green fill when on, ink-15% when off; the thumb crosses in 180ms.
- **Focus:** a 2px green ring offset 2px from the control, always visible on keyboard focus and never suppressed. **Error:** the value text stays ink, a w500/12px message in ink-55% sits below the row, and the row gains a 2px `#003716` outline — this system has no red; errors are stated in words, not alarm colour.

### Navigation
- **Floating pill tab bar:** A 68px white bar at 34px radius with the `tabbar` shadow, inset 16px from the screen edges and 16px from the bottom, floating above content rather than docked. Four destinations — **Home · My Gigs · Inbox · Profile** — flanking a raised central Post button. Scroll views pad 110px at the bottom so the last card always clears the bar.
- **Active tab:** a filled green icon inside a 34×26 green-tint chip (13px radius), label green w600/10px. **Inactive:** an outline icon at ink-40% with a matching label. Icons are 16–18px at 2.2 stroke weight; the icon set is one family throughout, never mixed.
- **Central Post FAB:** A 52px orange circle raised 26px above the bar with the `fab` glow. One FAB, one purpose — it is never repurposed for a secondary action on any screen.
- **Safe areas and system gestures:** the bar sits inside the bottom safe-area inset, clearing the iOS home indicator and Android gesture bar. The iOS left-edge back gesture and the Android system Back are never intercepted, and both must dismiss the sheet and close the FAB before they pop a route.

### Post FAB Speed-Dial (signature)
Tapping the FAB rotates its `+` 45° over 250ms and raises three white action pills from behind the bar — **Post a service · Post a request · Post to media** — stacked upward at 60px intervals, right-aligned 16px from the edge. Each is a 48px-tall 24px-radius white pill with the `speed-item` shadow, a 30px green-tint circular icon backing, and a w700/13px ink label. They enter from `translateY(18px) scale(0.85)` with a 220ms `cubic-bezier(.2,.9,.3,1.4)` transform and a 180ms opacity fade, staggered 0 / 30 / 60ms bottom-up, over a 200ms scrim fade. Tapping the scrim, the FAB, or any item closes it in reverse. Under reduced motion, the pills and scrim cross-fade in 120ms with no transform and no stagger.

### Modal Sheet
Bottom sheets rise over the scrim to a maximum 88% of screen height, with a 28px top radius, a cream (`#FAF7EC`) surface, and 20×18×40px padding. The header is a three-part row — a green w700/15px `Cancel`, a centred ink w700/17px title, and a `Done` action that is ink-40% until the form is dirty and green once it is. Below it stack value rows and toggle rows as sheet-shadowed cards, with an optional centred w500/12px ink-55% footnote closing the sheet. Slide-up in 220ms `easeOutCubic`; tap-scrim, swipe-down, or `Done` dismisses along the reverse curve. Reserve sheets for a self-contained sub-task with a clear commit point — anything that can be edited in place, is.

### States
The reference mockup shows only populated, resting screens. Every list and data surface still owes three more, built from tokens already here:
- **Loading:** khaki (`#EFE9D4`) skeleton blocks in the exact geometry of the card they replace — same radius, same card shadow, same row heights. No spinners inside content, and no shimmer sweep (it burns frames on 2GB hardware).
- **Empty:** a plain w700/15px line naming what will appear here and the one action that starts it, using the screen's own primary CTA. Never a decorative illustration, never the word "empty".
- **Error:** an inline w500/13px ink-65% sentence in plain language with a `Try again` header pill. Offline and slow connections are the expected case here, not the exception — never a full-screen error takeover that discards the user's place.

## 6. Do's and Don'ts

### Do:
- **Do** put every colour, radius, shadow, spacing step, and text style through the tokens in `lib/theme/app_theme.dart` (`AppColors` / `AppRadius` / `AppShadows` / `AppText`). A raw hex or a bare number in a screen is a bug.
- **Do** add a named role to the token file when a screen needs a size the scale doesn't have. Never a local `fontSize` override — see The Complete-Scale Rule.
- **Do** keep every screen background cream (`#FAF7EC`) and float white cards on top of it.
- **Do** lead exactly one primary forward action per screen in orange, and keep orange's other appearances (ratings, weekly earnings, unread dot) small and sparing.
- **Do** colour money by meaning: green for settled, held, and positive; ink-55% for fees and outgoing; orange only for the Home weekly-earnings highlight and for actions that move money.
- **Do** write **all** money in South African Rand through the shared formatter — `R1 250`, `R450`, `R37.50` — stored as integer minor units.
- **Do** use South African places in every example, label, and fixture: suburb and city, `Braamfontein 2001`, `within 5km of Melville`.
- **Do** lift cards with the `card` / `soft` shadows and let the shadow define the edge; use strokes only as internal hairline dividers or the selected two-option outline.
- **Do** carry hierarchy with Outfit weights (700/800) and size, and keep exactly one hero-scale number per primary screen.
- **Do** give primary CTAs and the FAB their tinted brand-hue glow.
- **Do** surface people, status, and protected-money cues on every list: initials avatar, name, rating, lifecycle status.
- **Do** ship every interactive component with pressed, disabled, and loading states, and every list with loading, empty, and error states.
- **Do** keep copy plain, warm, and legible at a glance — `Earn Moola`, `Browse Gigs`, `Apply Now`, `tasker`, `helper`.

### Don't:
- **Don't** build the classifieds wall. PRODUCT.md names the failure mode exactly: *"the Gumtree/OLX-style dense, spammy listing wall — endless undifferentiated rows, no sense of who is real, and nothing that makes handing over money feel safe."* If a list has no named humans, no status, and no breathing room, it is that wall.
- **Don't** use a pure-white or cold-grey screen background, or put an outer border on a card. (Violates The Warm-Never-White and The Cushioned-Card Rules.)
- **Don't** show any currency but Rand. The symbol is `R`, prefixed. No other currency symbol appears anywhere in this product.
- **Don't** carry the reference mockup's placeholder content into real screens. Its foreign-currency amounts and Australian locations exist only because it was a mockup; none of it transfers.
- **Don't** run two orange *actions* on one screen, use orange to fill a large area, or use it to decorate structure.
- **Don't** set text below ink-55%, and don't hard-code a grey for muted text — muted is always alpha over ink so it composites truly against the cream. (The Readable-Muted Rule.)
- **Don't** introduce a second typeface, a serif or display face, or set structural text below weight 600.
- **Don't** use `border-left`-style side stripes, gradient text, or glassmorphism. None exist in this system and none may be added.
- **Don't** deepen a shadow past 16% neutral opacity or invent a heavier elevation step. If it reads as a hard edge, it is wrong.
- **Don't** exceed 250ms on any transition, animate anything continuously, or animate for decoration. Motion conveys state — tab change, sheet, FAB expand — and nothing else. Every animation has a reduced-motion fallback.
- **Don't** reach for a modal first. Sheets are for self-contained sub-tasks with a commit point; anything editable in place is edited in place.
- **Don't** reinvent platform affordances. The iOS edge-swipe back and the Android system Back always work, content always sits inside safe-area and window insets, and touch targets never fall below 44pt / 48dp.
- **Don't** use red, or any colour outside these tokens, to signal an error. Errors are stated in plain words.
