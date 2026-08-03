# Phase 2

## 1. Architectural Guidelines & Tech Stack
* **Auth Backend:** Firebase Authentication (Phone Auth primary, Email Auth secondary)
* **Authentication Paradigm:** Passwordless (SMS OTP and Email OTP)
* **Primary Identifier:** Verified Phone Number
* **Secondary Identifier:** Verified Email Address
* **UX Philosophy:** Frictionless entry. Data entry is deferred where possible, OS-level autofill is utilized, and legal/permissions are streamlined.

---

## 2. Detailed Screen Specifications & User Flows

### Screen 1: Splash Screen (App Open)
* **Purpose:** Initial app boot, auth token check, brand expression.
* **UI Components:**
  * **Center Container:** Reserved empty space/viewport for Lottie/Rive SVG animation incorporating the **Daala** business logo.
* **Logic & Navigation:**
  * Read local persistent session / Firebase auth state.
  * **State A (Authenticated):** Route directly to **Main Home Screen**.
  * **State B (Unauthenticated / First Launch):** Route to **Screen 2: Value Proposition Carousel**.

---

### Screen 2: Value Proposition Carousel
* **Purpose:** Introduce the platform value proposition to new or unauthenticated users.
* **UI Components:**
  * **Swipeable ViewPager / Carousel:** 3 slides.
    * **Slide 1:** *Title:* Get things done | *Subtext:* Delegate tasks and manage your everyday needs effortlessly.
    * **Slide 2:** *Title:* Earn on your own terms | *Subtext:* Find flexible gigs that fit your skills and schedule.
    * **Slide 3:** *Title:* Pay safely | *Subtext:* Secure in-app payments with complete peace of mind.
  * **Page Indicator:** 3-dot pagination indicator updating on swipe.
  * **Primary CTA Button (Slide 3 only):** "Get Started"
* **Logic & Navigation:**
  * Tapping "Get Started" routes to **Screen 3: Phone Login**.

---

### Screen 3: Phone Login Screen (Streamlined Legal)
* **Purpose:** Primary authentication entry point capturing user's phone number and establishing legal consent in one step.
* **UI Components:**
  * **Header:** "Enter your phone number"
  * **Subtext:** "We'll send you a 4-digit verification code via SMS."
  * **Country Code Selector Dropdown:**
    * Searchable modal/picker containing all countries (`[Flag Emoji] [Name] (+[Code])`).
    * Defaults to detected user locale.
  * **Phone Number Input Field:**
    * Numerical keypad input (`type="tel"`).
    * **UX Optimization:** Utilize OS-level phone number auto-fill (Android Credential Manager / iOS QuickType) to suggest the user's number above the keyboard.
    * Dynamic masking/formatting based on selected country code.
  * **Primary CTA:** "Send Code" (Disabled until valid number length reached).
  * **Legal Consent Text:** Placed directly below the CTA button in smaller text: *"By continuing, you agree to Daala's **Terms of Service**[www.daala.co.za/terms] and acknowledge our **Privacy Notice**[www.daala.co.za/privacy]."* (Hyperlinked).
  * **Secondary Action Button:** "Log in with Email"
* **Logic & Navigation:**
  * Tapping "Send Code" triggers `firebase.auth().signInWithPhoneNumber()` and logs legal consent timestamp.
    * Success -> Navigate to **Screen 4: Phone Verification (OTP)**.
    * Failure -> Show inline error toast.
  * Tapping "Log in with Email" routes to **Screen 7: Email Login**.

---

### Screen 4: Phone Verification (OTP)
* **Purpose:** Validate ownership of the provided phone number.
* **UI Components:**
  * **Header:** "Verify your phone number"
  * **Subtext:** "Sent to `+[Country Code] [Formatted Number]`"
  * **Code Input Fields:**
    * 4 individual, auto-focusing numeric input boxes (`[ ] [ ] [ ] [ ]`).
    * **UX Optimization:** Integrate Native SMS Auto-read APIs (Android SMS Retriever / iOS One-Time Code AutoFill) so the code populates automatically upon receipt.
    * Auto-advances to next field on manual entry; handles backspace deletion seamlessly.
  * **Actions Container:**
    * **Button 1:** "Resend Code via SMS" (Includes a 30-second cooldown timer, e.g., *Resend in 0:29*).
    * **Button 2:** "Change Number"
* **Logic & Navigation:**
  * On 4th digit entered -> Auto-submit verification code.
  * **Post-Validation Account Check:**
    * Query database for an existing account bound to this phone number.
    * **New User:** Route to **Screen 5: Profile Details**.
    * **Existing User:** Route to **Main Home Screen** (or Screen 6B if a Terms update requires a fresh signature).

---

## 3. New User Onboarding Flow

### Screen 5: Profile Details Setup (Deferred Email OTP)
* **Purpose:** Collect basic identity data, user intent, and email address without breaking momentum.
* **UI Components:**
  * **Progress Indicator:** Subtle progress bar at the top (e.g., "Final Step").
  * **Header:** "We need a few more things to complete your profile"
  * **Input Fields:**
    * **First Name:** Text input.
    * **Last Name:** Text input.
    * **Email Address:** Email input (`type="email"`). *(No immediate OTP required).*
    * **Birth Date:** 
      * **UX Optimization:** Three auto-advancing text fields (`DD` | `MM` | `YYYY`) or a native scrolling date wheel to prevent tedious calendar swiping.
  * **Single-Select Option Group ("My goals"):**
    * Radio card / Toggle selection:
      * Option A: `Make Money`
      * Option B: `Get Things Done`
    * *(Note: Enforce single selection only).*
  * **Primary CTA:** "Complete Setup"
* **Logic & Navigation:**
  * Write profile fields (including unverified email) to database user record.
  * Trigger a silent backend process to send an email verification link to the user's inbox for later.
  * Navigate to **Main Home Screen**. Onboarding complete.

---

## 4. Contextual Prompts (Post-Onboarding)

### Screen 6A: Notification Setup (Deferred)
* **Purpose:** Request system-level push notification permissions *only* when relevant to the user's actions, maximizing opt-in rates.
* **Trigger Event:** e.g., Applying for a gig, hiring a worker, or messaging a user for the first time.
* **UI Components (Modal/Bottom Sheet):**
  * **Main Header:** "Turn on Notifications?"
  * **Subtext:** "Don't miss important alerts like gig updates or account activity."
  * **Toggle Section:**
    * *Label:* "Get personalised recommendations, Profile advice, and more"
    * *Control:* Switch/Toggle component (Defaults to **ON**).
  * **Primary CTA Button:** "Yes, notify me"
  * **Secondary Button:** "Skip"
* **Logic:**
  * Tapping "Yes, notify me" triggers the native OS Notification Permission Dialog. Save preference state based on toggle.

### Screen 6B: Returning User Terms Update (Only if terms changed)
* **Purpose:** Verify acceptance of legal terms *only* if the terms have been updated since the user's last login.
* **UI Components:**
  * **Main Header:** "Update to our Terms"
  * **Content:** Display brief statement of what changed + mandatory check box + "I Agree" button.
* **Logic:** Updates consent timestamp and forwards to Main Home Screen.

---

## 5. Secondary Flow: Log in via Email

### Screen 7: Email Login
* **Purpose:** Secondary login route for existing users who cannot access their phone number.
* **UI Components:**
  * **Header:** "Log in with Email"
  * **Subtext:** "Enter the email associated with your Daala account."
  * **Input Field:** Email address input (`type="email"`). (Use OS auto-fill hint for email).
  * **Primary CTA:** "Continue"
  * **Secondary Button:** "Log in with Phone Number" (Navigates back to **Screen 3**).

### Flow Logic & Database Check:
```text
                       [User Enters Email & Clicks "Continue"]
                                          │
                                          ▼
                       [Database Query: Does Email Exist?]
                                 /                 \
                                /                   \
                             YES                     NO
                              │                       │
                              ▼                       ▼
            [Screen 7A: Email OTP Verification]     [Display Inline Error Block]
            • User enters 4-digit email code.       • Message: "There is no account 
            • On successful verification:             associated with this email."
              Route to Main Home Screen (or         • CTA Button: "Create Account"
              Terms Update if needed).                        │
                                                              ▼
                                                    [Route to Screen 3:
                                                     Phone Login Screen]






