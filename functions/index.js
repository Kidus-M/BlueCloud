/**
 * Blue Cloud - Firebase Cloud Functions
 *
 * Sends push notifications to approved users when a new incident report
 * is submitted to Firestore.
 */

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

/**
 * Triggered when a new report document is created in the 'reports' collection.
 * Sends an FCM notification to all users with canReceiveNotifications == true.
 */
exports.onNewReport = onDocumentCreated("reports/{reportId}", async (event) => {
  const report = event.data?.data();
  if (!report) {
    console.log("No report data found.");
    return;
  }

  const db = getFirestore();
  const messaging = getMessaging();

  // Build notification payload
  const incidentType = report.incidentType || "Incident Report";
  const location = report.location || "Unknown location";
  const district = report.district || "";
  const time = report.time || "";

  const title = `🚨 ${incidentType}`;
  const body = `${district} • ${location} • ${time}`;

  try {
    // Get all users who can receive notifications
    const usersSnapshot = await db
      .collection("users")
      .where("canReceiveNotifications", "==", true)
      .get();

    if (usersSnapshot.empty) {
      console.log("No users with notification permission found.");
      return;
    }

    // Collect FCM tokens
    const tokens = [];
    usersSnapshot.forEach((doc) => {
      const userData = doc.data();
      if (userData.fcmToken && userData.fcmToken.length > 0) {
        tokens.push(userData.fcmToken);
      }
    });

    if (tokens.length === 0) {
      console.log("No valid FCM tokens found.");
      return;
    }

    // Send multicast notification
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        reportId: event.params.reportId,
        incidentType: incidentType,
        location: location,
        district: district,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      tokens: tokens,
    };

    const response = await messaging.sendEachForMulticast(message);

    console.log(
      `Successfully sent ${response.successCount}/${tokens.length} notifications.`
    );

    // Log any failures
    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.error(`Failed to send to token ${tokens[idx]}:`, resp.error);
        }
      });
    }

    // Also send to 'new_reports' topic for topic-based subscribers
    const topicMessage = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        reportId: event.params.reportId,
        incidentType: incidentType,
        location: location,
        district: district,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      topic: "new_reports",
    };

    await messaging.send(topicMessage);
    console.log("Topic notification sent successfully.");
  } catch (error) {
    console.error("Error sending notifications:", error);
  }
});
