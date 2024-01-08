const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

initializeApp();

const firestore = getFirestore();

// firestore trigger to update graph edges once a new transaction is added
exports.updateGraph = functions.firestore.document("transactions/{transactionId}").onCreate(async (snap, context) => {
    const transaction = snap.data();
    const paidByEmail = transaction.paidByEmail;
    const splitMap = transaction.split;
    console.log("executing for ", paidByEmail);

    const docSnapshot = firestore.collection("graph").doc(paidByEmail).get();
    var totalMoneyPaid = 0;
    if (!docSnapshot.exists) {
        await firestore.collection("graph").doc(paidByEmail).set({ "totalMoneyPaid": 0 });
    }
    else {
        totalMoneyPaid = docSnapshot.get("totalMoneyPaid");
    }

    await firestore.collection('graph').doc(paidByEmail).update({ "totalMoneyPaid": totalMoneyPaid + transaction.amount });


    Object.keys(splitMap).forEach(async (debtorEmail) => {
        var debt = splitMap[debtorEmail];
        var edges = await firestore.collection("graph").doc(paidByEmail).collection(debtorEmail).doc("debt").get();
        var oldDebt = 0;
        if (edges.exists) {
            oldDebt = edges.get("debt") ?? 0;
            await firestore.collection("graph").doc(paidByEmail).collection(debtorEmail).doc("debt").update({ "debt": debt + oldDebt });
        }
        else {
            await firestore.collection("graph").doc(paidByEmail).collection(debtorEmail).doc("debt").set({ "debt": debt + oldDebt });
        }

        edges = await firestore.collection("graph").doc(debtorEmail).collection(paidByEmail).doc("debt").get();
        if (edges.exists) {
            oldDebt = edges.get("debt") ?? 0;
            await firestore.collection("graph").doc(debtorEmail).collection(paidByEmail).doc("debt").update({ "debt": oldDebt - debt });
        }
        else {
            await firestore.collection("graph").doc(debtorEmail).collection(paidByEmail).doc("debt").set({ "debt": oldDebt - debt });
        }
    });
    return "ok";
});
