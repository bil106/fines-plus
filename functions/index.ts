import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

export const onPurchaseCreate = onDocumentCreated("purchases/{purchaseId}", async (event) => {
   const snap = event.data;
   if (!snap) return;

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

   const txId = `bonus_${event.params.purchaseId}`;
   const txRef = db.collection("partnerTx").doc(txId);
   const already = await txRef.get();
   if (already.exists) return;

   await db.runTransaction(async (t) => {
      t.set(txRef, {
         partnerId,
         purchaseId: event.params.purchaseId,
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

   console.log(`✅ Bonus ${bonus} credited to partner ${partnerId} for purchase ${event.params.purchaseId}`);
});
