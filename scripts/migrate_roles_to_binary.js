/**
 * scripts/migrate_roles_to_binary.js
 * 
 * Safely unifies all legacy roles in Firestore (super_admin, dietitian, editor)
 * into exactly TWO official roles: 'user' and 'admin'.
 * 
 * Target Database: Cloud Firestore project nutriview-943cd
 * 
 * Usage:
 *   node scripts/migrate_roles_to_binary.js --dry-run
 *   node scripts/migrate_roles_to_binary.js --apply
 */

const fs = require('fs');
const os = require('os');
const path = require('path');
const https = require('https');

const isDryRun = process.argv.includes('--dry-run') || !process.argv.includes('--apply');
const configPath = path.join(os.homedir(), '.config/configstore/firebase-tools.json');

if (!fs.existsSync(configPath)) {
  console.error('[Error] Firebase CLI config not found at:', configPath);
  process.exit(1);
}

const conf = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const accessToken = conf.tokens?.access_token;
if (!accessToken) {
  console.error('[Error] No OAuth access token found in firebase-tools.json');
  process.exit(1);
}

const PROJECT_ID = 'nutriview-943cd';
const BASE_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/users`;

function request(url, options = {}) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const req = https.request(
      {
        hostname: u.hostname,
        path: u.pathname + u.search,
        method: options.method || 'GET',
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
          ...(options.headers || {}),
        },
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          try {
            resolve({ statusCode: res.statusCode, body: JSON.parse(data) });
          } catch (e) {
            resolve({ statusCode: res.statusCode, raw: data });
          }
        });
      }
    );
    req.on('error', reject);
    if (options.body) {
      req.write(JSON.stringify(options.body));
    }
    req.end();
  });
}

async function run() {
  console.log(`=======================================================`);
  console.log(` NutriView Role Unification Migration: ONLY 2 ROLES   `);
  console.log(` Target Project : ${PROJECT_ID}                       `);
  console.log(` Mode           : ${isDryRun ? 'DRY-RUN (Preview Only)' : 'APPLY (Live Updates)'} `);
  console.log(`=======================================================\n`);

  // 1. Fetch all users
  const listRes = await request(BASE_URL);
  if (!listRes.body || !listRes.body.documents) {
    console.error('[Error] Failed to fetch users:', listRes.body);
    process.exit(1);
  }

  const users = listRes.body.documents;
  console.log(`[Info] Retrieved ${users.length} user records from Firestore.\n`);

  // 2. Create timestamped backup of current users state
  const backupDir = path.join(__dirname, 'backups');
  if (!fs.existsSync(backupDir)) {
    fs.mkdirSync(backupDir, { recursive: true });
  }
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const backupFile = path.join(backupDir, `users_backup_${timestamp}.json`);
  fs.writeFileSync(backupFile, JSON.stringify(users, null, 2), 'utf8');
  console.log(`[Backup] Original users backup saved to: ${backupFile}\n`);

  // 3. Evaluate each user
  const migrationPlan = [];

  for (const doc of users) {
    const fields = doc.fields || {};
    const uid = doc.name.split('/').pop();
    const currentRole = fields.role?.stringValue || 'user';
    const email = fields.email?.stringValue || 'no-email';
    const name = fields.full_name?.stringValue || 'no-name';

    let targetRole = currentRole;
    let needsUpdate = false;

    // Unification logic: ONLY 'user' and 'admin' allowed
    if (['super_admin', 'dietitian', 'editor', 'staff'].includes(currentRole)) {
      targetRole = 'admin';
      needsUpdate = true;
    } else if (currentRole !== 'admin' && currentRole !== 'user') {
      targetRole = 'user';
      needsUpdate = true;
    }

    migrationPlan.push({
      docName: doc.name,
      uid,
      email,
      name,
      currentRole,
      targetRole,
      needsUpdate,
    });
  }

  // Print migration table
  console.log('--- Migration Analysis ---');
  let updateCount = 0;
  for (const item of migrationPlan) {
    const status = item.needsUpdate
      ? `CHANGE: [${item.currentRole}] -> [${item.targetRole}]`
      : `KEEP:   [${item.currentRole}]`;
    console.log(`* ${item.email.padEnd(32)} | ${item.name.padEnd(25)} | ${status}`);
    if (item.needsUpdate) updateCount++;
  }
  console.log(`\nTotal accounts needing role unification: ${updateCount} of ${migrationPlan.length}\n`);

  if (isDryRun) {
    console.log(`[Dry-Run Complete] No documents were modified.`);
    console.log(`To execute live migration, re-run with: node scripts/migrate_roles_to_binary.js --apply\n`);
    return;
  }

  // 4. Execute updates
  console.log('[Executing Live Updates]...');
  for (const item of migrationPlan) {
    if (!item.needsUpdate) continue;

    console.log(`- Updating ${item.email} (UID: ${item.uid}) to role 'admin'...`);
    const patchUrl = `https://firestore.googleapis.com/v1/${item.docName}?updateMask.fieldPaths=role&updateMask.fieldPaths=updated_at`;
    const patchBody = {
      fields: {
        role: { stringValue: item.targetRole },
        updated_at: { stringValue: new Date().toISOString() },
      },
    };

    const patchRes = await request(patchUrl, {
      method: 'PATCH',
      body: patchBody,
    });

    if (patchRes.statusCode === 200) {
      console.log(`  ✔ Successfully updated ${item.email} to '${item.targetRole}'`);
    } else {
      console.error(`  ✘ FAILED updating ${item.email}:`, patchRes.body);
    }
  }

  // 5. Verification
  console.log('\n[Verifying Migration Result]...');
  const verifyRes = await request(BASE_URL);
  const verifyDocs = verifyRes.body.documents || [];
  let allClean = true;

  for (const doc of verifyDocs) {
    const role = doc.fields?.role?.stringValue;
    const email = doc.fields?.email?.stringValue;
    if (role !== 'user' && role !== 'admin') {
      console.error(`  ✘ Account ${email} still has non-binary role: '${role}'!`);
      allClean = false;
    } else {
      console.log(`  ✔ Verified ${email} -> role: '${role}'`);
    }
  }

  if (allClean) {
    console.log('\n✔ ALL ACCOUNTS SUCCESSFULLY MIGRATED TO STRICT BINARY ROLES (user / admin)!\n');
  } else {
    console.error('\n✘ Some accounts failed verification!\n');
    process.exit(1);
  }
}

run().catch((err) => {
  console.error('[Fatal Error]', err);
  process.exit(1);
});
