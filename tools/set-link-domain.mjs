/**
 * Points Firebase Auth's link generation at the Daala Hosting domain.
 *
 * WHY THIS EXISTS
 * ---------------
 * Firebase Dynamic Links shut down on 25 Aug 2025. Email sign-in links survived
 * the shutdown but moved to Firebase Hosting domains. Setting `linkDomain` in
 * the app's ActionCodeSettings is NOT enough on its own — the Auth backend keeps
 * generating links on the old default until this project-level config is
 * updated, and there is no console UI for it. Hence a script.
 *
 * Run once per project. Idempotent.
 *
 * USAGE
 * -----
 *   npm install firebase-admin
 *   # Firebase Console -> Project Settings -> Service accounts
 *   #   -> Generate new private key  ->  save as tools/service-account.json
 *   node tools/set-link-domain.mjs
 *
 * The service account key is a FULL-ADMIN credential. It is git-ignored. Delete
 * it once this has run.
 *
 * ROLLBACK
 * --------
 * Pass `--rollback` to hand link generation back to the legacy default. Only
 * useful if something is badly wrong; the legacy path is unsupported.
 */

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

/**
 * `mobileLinksConfig.domain` is an ENUM, not a domain string.
 *
 * The API accepts exactly two values — 'HOSTING_DOMAIN' or
 * 'FIREBASE_DYNAMIC_LINK_DOMAIN' — and it selects the *mode*: generate links on
 * Firebase Hosting, or on the (now dead) Dynamic Links infrastructure. Passing
 * an actual hostname here is rejected.
 *
 * Which specific Hosting domain gets used is chosen per-request by
 * `linkDomain` in the app's ActionCodeSettings — see `kEmailLinkDomain` in
 * lib/auth/auth_repository.dart. This script flips the mode; the app picks the
 * domain.
 */
const MODE_HOSTING = 'HOSTING_DOMAIN';
const MODE_LEGACY = 'FIREBASE_DYNAMIC_LINK_DOMAIN';

// The custom domain the app requests via `linkDomain`. Referenced here only
// to print an accurate verification hint.
const APP_LINK_DOMAIN = 'login.daala.co.za';

const here = dirname(fileURLToPath(import.meta.url));
const keyPath = join(here, 'service-account.json');

let serviceAccount;
try {
  serviceAccount = JSON.parse(readFileSync(keyPath, 'utf8'));
} catch {
  console.error(
    `\nCould not read ${keyPath}\n\n` +
      'Firebase Console -> Project Settings -> Service accounts\n' +
      '  -> Generate new private key -> save it at that path, then re-run.\n',
  );
  process.exit(1);
}

const rollback = process.argv.includes('--rollback');
const domain = rollback ? MODE_LEGACY : MODE_HOSTING;

initializeApp({ credential: cert(serviceAccount) });

try {
  const manager = getAuth().projectConfigManager();

  await manager.updateProjectConfig({ mobileLinksConfig: { domain } });

  const config = await manager.getProjectConfig();
  console.log(
    `\n✅ Auth link mode set to: ${domain}\n` +
      `   project: ${serviceAccount.project_id}\n` +
      `   backend reports: ${JSON.stringify(config.mobileLinksConfig ?? {})}\n`,
  );

  if (!rollback) {
    console.log(
      'Now verify empirically — this is the step that actually proves it:\n' +
        '  1. Trigger an email sign-in link from the app.\n' +
        '  2. Open the email and inspect the link URL. Expected:\n' +
        `       https://${APP_LINK_DOMAIN}/__/auth/links?...\n` +
        '  3. If the host is the default (daala-69a44.firebaseapp.com or\n' +
        '     .web.app) instead, the mode is right but the custom domain was\n' +
        `     not applied — check kEmailLinkDomain in auth_repository.dart and\n` +
        `     that ${APP_LINK_DOMAIN} is a verified Hosting custom domain.\n` +
        '     Whichever host actually appears MUST match the intent-filter host\n' +
        '     in android/app/src/main/AndroidManifest.xml, or the app will not\n' +
        '     receive the link.\n' +
        '  4. Delete tools/service-account.json.\n',
    );
  }
} catch (error) {
  console.error('\n❌ Failed to update project config:\n', error.message ?? error);
  console.error(
    '\nCommon causes:\n' +
      '  - The value passed was not one of the two accepted enum values\n' +
      `    ('${MODE_HOSTING}' or '${MODE_LEGACY}').\n` +
      '  - The service account lacks the Firebase Authentication Admin role.\n' +
      `  - ${APP_LINK_DOMAIN} is not yet a verified Hosting custom domain.\n`,
  );
  process.exit(1);
}
