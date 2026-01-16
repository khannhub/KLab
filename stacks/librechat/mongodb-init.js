/**
 * LibreChat MongoDB initialization.
 *
 * This script is executed by the official MongoDB docker entrypoint on FIRST boot
 * (i.e., when the database is empty). It creates a dedicated LibreChat user with
 * read/write access to the LibreChat database.
 *
 * Ref: https://hub.docker.com/_/mongo
 */

const dbName = process.env.MONGO_INITDB_DATABASE || "LibreChat";
const username = process.env.LIBRECHAT_MONGO_USER || "librechat";
const password = process.env.LIBRECHAT_MONGO_PASSWORD || "replace-me";

const adminDb = db.getSiblingDB("admin");

if (adminDb.getUser(username) === null) {
  adminDb.createUser({
    user: username,
    pwd: password,
    roles: [{ role: "readWrite", db: dbName }],
  });
  print(`Created MongoDB user '${username}' with readWrite on '${dbName}'`);
} else {
  print(`MongoDB user '${username}' already exists; skipping`);
}
