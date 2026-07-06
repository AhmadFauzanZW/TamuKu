const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Trigger: tamu baru check-in
 * Kirim FCM notification ke admin device
 */
exports.notifyHostOnCheckIn = functions.firestore
  .document("guests/{guestId}")
  .onCreate(async (snap, context) => {
    const guest = snap.data();
    const locationId = guest.locationId;

    try {
      // Ambil data lokasi
      const locationDoc = await db.collection("locations").doc(locationId).get();
      if (!locationDoc.exists) {
        console.log("Lokasi tidak ditemukan:", locationId);
        return null;
      }

      const location = locationDoc.data();
      const adminId = location.adminId;

      // Ambil token FCM admin
      const hostDoc = await db.collection("hosts").doc(adminId).get();
      if (!hostDoc.exists) {
        console.log("Admin tidak ditemukan:", adminId);
        return null;
      }

      const host = hostDoc.data();
      const fcmToken = host.fcmToken;

      if (!fcmToken) {
        console.log("FCM token tidak tersedia untuk admin:", adminId);
        return null;
      }

      // Kirim push notification
      const message = {
        token: fcmToken,
        notification: {
          title: "Tamu Baru! 🎉",
          body: `${guest.name} baru saja check-in di ${location.name}`,
        },
        data: {
          type: "guest_check_in",
          guestId: context.params.guestId,
          locationId: locationId,
          guestName: guest.name,
          keperluan: guest.keperluan || "",
        },
      };

      const response = await messaging.send(message);
      console.log("Notifikasi terkirim:", response);
      return response;
    } catch (error) {
      console.error("Gagal kirim notifikasi:", error);
      return null;
    }
  });

/**
 * Trigger: tamu check-out
 * Kirim notifikasi ke admin
 */
exports.notifyHostOnCheckOut = functions.firestore
  .document("guests/{guestId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Hanya trigger jika status berubah ke checked_out
    if (before.status !== "checked_out" && after.status === "checked_out") {
      const locationId = after.locationId;

      try {
        const locationDoc = await db.collection("locations").doc(locationId).get();
        if (!locationDoc.exists) return null;

        const location = locationDoc.data();
        const adminId = location.adminId;

        const hostDoc = await db.collection("hosts").doc(adminId).get();
        if (!hostDoc.exists) return null;

        const host = hostDoc.data();
        const fcmToken = host.fcmToken;

        if (!fcmToken) return null;

        const message = {
          token: fcmToken,
          notification: {
            title: "Tamu Check-Out",
            body: `${after.name} telah check-out dari ${location.name}`,
          },
          data: {
            type: "guest_check_out",
            guestId: context.params.guestId,
            locationId: locationId,
          },
        };

        await messaging.send(message);
        return null;
      } catch (error) {
        console.error("Gagal kirim notifikasi check-out:", error);
        return null;
      }
    }

    return null;
  });
