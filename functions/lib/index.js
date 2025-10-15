"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkExpiredSubscriptions = exports.onPurchaseCreate = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
const db = admin.firestore();
// ======================
// Firestore триггер на покупку
// ======================
exports.onPurchaseCreate = functions.firestore
    .document("purchases/{purchaseId}")
    .onCreate(async (snap, context) => {
    const purchase = snap.data();
    const { uid, amount } = purchase;
    const userDoc = await db.collection("users").doc(uid).get();
    if (!userDoc.exists)
        return;
    const user = userDoc.data();
    const partnerId = user?.partnerId;
    if (!partnerId)
        return;
    const partnerDocRef = db.collection("partners").doc(partnerId);
    const partnerDoc = await partnerDocRef.get();
    const percent = partnerDoc.exists ? partnerDoc.data()?.percent ?? 0.2 : 0.2;
    const bonus = Math.round(amount * percent * 100) / 100;
    const txId = `bonus_${context.params.purchaseId}`;
    const txRef = db.collection("partnerTx").doc(txId);
    const already = await txRef.get();
    if (already.exists)
        return;
    await db.runTransaction(async (t) => {
        t.set(txRef, {
            partnerId,
            purchaseId: context.params.purchaseId,
            uid,
            amount,
            bonus,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        t.set(partnerDocRef, {
            balance: admin.firestore.FieldValue.increment(bonus),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        t.set(db.collection("partnerStats").doc(partnerId), {
            revenue: admin.firestore.FieldValue.increment(amount),
            bonus: admin.firestore.FieldValue.increment(bonus),
            paidUsers: admin.firestore.FieldValue.increment(1),
        }, { merge: true });
    });
    console.log(`✅ Bonus ${bonus} credited to partner ${partnerId} for purchase ${context.params.purchaseId}`);
});
// ======================
// CRON-задача: проверка подписок
// ======================
exports.checkExpiredSubscriptions = functions.pubsub
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
        const end = data.subscriptionEndDate;
        if (!end)
            continue;
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
