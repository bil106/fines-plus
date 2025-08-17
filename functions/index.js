const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const { taskQueue } = require("firebase-functions-tasks");

admin.initializeApp();


const reminderQueue = taskQueue({
   rateLimits: { maxConcurrentDispatches: 5 },
   retryConfig: { maxAttempts: 3 },
});


exports.onReminderCreated = functions.firestore
   .document("reminders/{reminderId}")
   .onCreate(async (snap, context) => {
      const reminder = snap.data();
      const reminderId = context.params.reminderId;

     
      const time = new Date(reminder.time);
      const delay = time.getTime() - Date.now();

      if (delay > 0) {
         await reminderQueue.enqueue(
            { reminderId },
            { scheduleDelaySeconds: Math.floor(delay / 1000) }
         );
         console.log(`✅ ЗTask for reminder ${reminderId} put on the waiting list ${reminder.time}`);
      } else {
         console.log(`⚠️ The reminder time has already passed for ${reminderId}`);
      }
   });


exports.sendReminderNotification = reminderQueue.onDispatch(async (data) => {
   const reminderId = data.reminderId;
   const doc = await admin.firestore().collection("reminders").doc(reminderId).get();

   if (!doc.exists) return;

   const reminder = doc.data();
   const carDoc = await admin.firestore().collection("cars").doc(reminder.carNumber).get();
   const car = carDoc.data();

   if (!car?.fcmToken) return;

   await admin.messaging().sendToDevice(car.fcmToken, {
      notification: {
         title: "Reminder",
         body: reminder.title,
      },
      data: {
         reminderId: reminderId,
      },
   });
})
