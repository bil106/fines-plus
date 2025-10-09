const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const { taskQueue } = require("firebase-functions-tasks");

admin.initializeApp();

const reminderQueue = taskQueue({
   rateLimits: { maxConcurrentDispatches: 5 },
   retryConfig: { maxAttempts: 3 },
});

// Trigger to create a reminder in the items subcollection
exports.onReminderCreated = functions.firestore
   .document("reminders/{carNumber}/items/{reminderId}")
   .onCreate(async (snap, context) => {
      const reminder = snap.data();
      const reminderId = context.params.reminderId;
      const carNumber = context.params.carNumber;

      const time = reminder.dateTime.toDate ? reminder.dateTime.toDate() : new Date(reminder.dateTime);
      const delay = time.getTime() - Date.now();

      console.log("Reminder created:", reminder);
      console.log("Reminder ID:", reminderId);
      console.log("Car number:", carNumber);
      console.log("Scheduled time:", time);
      console.log("Delay (ms):", delay);

      if (delay > 0) {
         await reminderQueue.enqueue(
            { reminderId, carNumber },
            { scheduleDelaySeconds: Math.floor(delay / 1000) }
         );
         console.log(`Task scheduled for ${reminderId} in ${Math.floor(delay / 1000)}s`);
      } else {
         console.log(` Reminder time already passed for ${reminderId}`);
      }
   });

// Trigger to update reminder
exports.onReminderUpdated = functions.firestore
   .document("reminders/{carNumber}/items/{reminderId}")
   .onUpdate(async (change, context) => {
      const before = change.before.data();
      const after = change.after.data();
      const reminderId = context.params.reminderId;
      const carNumber = context.params.carNumber;

      if (before.dateTime !== after.dateTime) {
         const time = after.dateTime.toDate ? after.dateTime.toDate() : new Date(after.dateTime);
         const delay = time.getTime() - Date.now();

         console.log("Reminder updated:", after);
         console.log("Reminder ID:", reminderId);
         console.log("Car number:", carNumber);
         console.log("Scheduled time:", time);
         console.log("Delay (ms):", delay);

         if (delay > 0) {
            await reminderQueue.enqueue(
               { reminderId, carNumber },
               { scheduleDelaySeconds: Math.floor(delay / 1000) }
            );
            console.log(`✅ Updated task scheduled for ${reminderId} in ${Math.floor(delay / 1000)}s`);
         } else {
            console.log(`Reminder time already passed for ${reminderId}`);
         }
      }
   });

// Sending a push notification
exports.sendReminderNotification = reminderQueue.onDispatch(async (data) => {
   const { reminderId, carNumber } = data;
   const doc = await admin.firestore().collection("reminders").doc(carNumber)
      .collection("items").doc(reminderId).get();

   if (!doc.exists) return;

   const reminder = doc.data();
   const carDoc = await admin.firestore().collection("cars").doc(carNumber).get();
   const car = carDoc.data();

   if (!car?.fcmToken) {
      console.log(` No FCM token for car ${carNumber}`);
      return;
   }

   const response = await admin.messaging().sendToDevice(car.fcmToken, {
      notification: {
         title: "Reminder",
         body: reminder.title,
      },
      data: { reminderId },
   });

   response.results.forEach(async (result) => {
      if (result.error) {
         console.error("FCM error:", result.error);
         if (result.error.code === "messaging/registration-token-not-registered") {
            await admin.firestore().collection("cars").doc(carNumber)
               .update({ fcmToken: admin.firestore.FieldValue.delete() });
         }
      }
   });

   console.log(`📩 Reminder ${reminderId} notification sent to car ${carNumber}`);
});
