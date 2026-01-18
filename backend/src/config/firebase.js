import admin from "firebase-admin";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const serviceAccountPath = path.join(
  __dirname,
  "../../../bingogame-ac21c-firebase-adminsdk-fbsvc-e8e248c49c.json",
);

const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, "utf8"));

serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, "\n");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

console.log("Firebase Admin initialized");

export default admin;
