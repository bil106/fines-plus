import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// ======================
// Firestore триггер на покупку
// ======================
export const onPurchaseCreate = functions.firestore
   .document("purchases/{purchaseId}")
   .onCreate(async (snap: FirebaseFirestore.DocumentSnapshot, context: functions.EventContext) => {
      const purchase = snap.data() as { uid: string; amount: number };
      const { uid, amount } = purchase;

      const userDoc = await db.collection("users").doc(uid).get();
      if (!userDoc.exists) return;

      const user = userDoc.data();
      const partnerId = user?.partnerId as string | undefined;
      if (!partnerId) return;

      const partnerDocRef = db.collection("partners").doc(partnerId);
      const partnerDoc = await partnerDocRef.get();
      const percent = partnerDoc.exists ? partnerDoc.data()?.percent ?? 0.2 : 0.2;

      const bonus = Math.round(amount * percent * 100) / 100;

      const txId = `bonus_${context.params.purchaseId}`;
      const txRef = db.collection("partnerTx").doc(txId);
      const already = await txRef.get();
      if (already.exists) return;

      await db.runTransaction(async (t) => {
         t.set(txRef, {
            partnerId,
            purchaseId: context.params.purchaseId,
            uid,
            amount,
            bonus,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
         });

         t.set(
            partnerDocRef,
            {
               balance: admin.firestore.FieldValue.increment(bonus),
               updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
         );

         t.set(
            db.collection("partnerStats").doc(partnerId),
            {
               revenue: admin.firestore.FieldValue.increment(amount),
               bonus: admin.firestore.FieldValue.increment(bonus),
               paidUsers: admin.firestore.FieldValue.increment(1),
            },
            { merge: true }
         );
      });

      console.log(
         `✅ Bonus ${bonus} credited to partner ${partnerId} for purchase ${context.params.purchaseId}`
      );
   });

// ======================
// CRON-задача: проверка подписок
// ======================
export const checkExpiredSubscriptions = functions.pubsub
   .schedule("0 3 * * *") // каждый день в 03:00 UTC
   .timeZone("UTC")
   .onRun(async (context) => {
      const now = admin.firestore.Timestamp.now();

      const usersSnap = await db
         .collection("users")
         .where("isSubscribed", "==", true)
         .get();

      if (usersSnap.empty) {
         console.log("Нет активных подписчиков для проверки");
         return null;
      }

      let expiredCount = 0;

      for (const doc of usersSnap.docs) {
         const data = doc.data();
         const end = data.subscriptionEndDate as admin.firestore.Timestamp | undefined;

         if (!end) continue;
         if (end.toDate() < now.toDate()) {
            await db.collection("users").doc(doc.id).update({
               isSubscribed: false,
            });
            expiredCount++;
            console.log(`Подписка пользователя ${doc.id} истекла`);
         }
      }

      console.log(`Проверка завершена. Истекло подписок: ${expiredCount}`);
      return null;
   });
