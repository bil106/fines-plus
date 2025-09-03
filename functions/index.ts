import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

export const onPurchaseCreate = functions.firestore
   .document("purchases/{purchaseId}")
   .onCreate(async (snap, ctx) => {
      const purchase = snap.data();
      if (!purchase) return;

      const { uid, amount } = purchase as { uid: string; amount: number };
      const userDoc = await db.collection("users").doc(uid).get();
      if (!userDoc.exists) return;

      const user = userDoc.data();
      const partnerId = user?.partnerId as string | undefined;
      if (!partnerId) return; 

      const partnerDocRef = db.collection("partners").doc(partnerId);
      const partnerDoc = await partnerDocRef.get();
      const percent = partnerDoc.exists ? partnerDoc.data()?.percent ?? 0.2 : 0.2; 

      const bonus = Math.round(amount * percent * 100) / 100; 

      const txId = `bonus_${ctx.params.purchaseId}`;

      
      const txRef = db.collection("partnerTx").doc(txId);
      const already = await txRef.get();
      if (already.exists) return;

      await db.runTransaction(async (t) => {
         // Write the transaction
         t.set(txRef, {
            partnerId,
            purchaseId: ctx.params.purchaseId,
            uid,
            amount,
            bonus,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
         });

         // Update partner balance
         t.set(partnerDocRef, {
            balance: admin.firestore.FieldValue.increment(bonus),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
         }, { merge: true });

         // Статистика партнёра
         t.set(db.collection("partnerStats").doc(partnerId), {
            revenue: admin.firestore.FieldValue.increment(amount),
            bonus: admin.firestore.FieldValue.increment(bonus),
            paidUsers: admin.firestore.FieldValue.increment(1),
         }, { merge: true });
      });

      console.log(`✅ Bonus ${bonus} credited to partner ${partnerId} for purchase ${ctx.params.purchaseId}`);
   });
