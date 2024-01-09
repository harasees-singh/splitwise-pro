const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

initializeApp();

const firestore = getFirestore();

const removePeriodFromEmail = (email) => {
    let newEmail = email.replace(/\./g, "");
    console.log(newEmail);
    return newEmail;
  }
// firestore trigger to update graph edges once a new transaction is added
exports.updateGraph = functions.firestore.document("transactions/{transactionId}").onCreate(async (snap, context) => {
    const transaction = snap.data();
    const paidByEmail = transaction.paidByEmail;
    const splitMap = transaction.split;
    const paidByImageUrl = transaction.paidByImageUrl;
    const paidByUsername = transaction.paidByUsername;
    console.log("executing for ", paidByEmail);

    const docSnapshot = await firestore.collection("graph").doc(paidByEmail).get();
    var totalMoneyPaid = 0;
    if (!docSnapshot.exists) {
        await firestore.collection("graph").doc(paidByEmail).set({ "totalMoneyPaid": 0 });
    }
    else {
        totalMoneyPaid = docSnapshot.get("totalMoneyPaid");
    }

    await firestore.collection('graph').doc(paidByEmail).set({ "totalMoneyPaid": totalMoneyPaid + transaction.amount }, { merge: true });


    Object.keys(splitMap).forEach(async (debtorEmail) => {
        var debt = splitMap[debtorEmail]['amount'];
        var imageUrl = splitMap[debtorEmail]['imageUrl'];
        var username = splitMap[debtorEmail]['username'];
        var debtorEmailKey = removePeriodFromEmail(debtorEmail);
        var edges = await firestore.collection("graph").doc(paidByEmail).get();
        var oldDebt = 0;
        
        oldDebt = edges.get(debtorEmailKey) == null ? 0 : edges.get(debtorEmailKey)['debt'];
        
        await firestore.collection("graph").doc(paidByEmail).set({[debtorEmailKey] : { 'debt': debt + oldDebt, 'imageUrl' : imageUrl, 'username' : username }}, { merge: true });

        var paidByEmailKey = removePeriodFromEmail(paidByEmail);
        edges = await firestore.collection("graph").doc(debtorEmail).get();
        if (edges.exists) {
            oldDebt = edges.get(paidByEmailKey) == null ? 0 : edges.get(paidByEmailKey)['debt'];
        }
        else {
            await firestore.collection("graph").doc(debtorEmail).set({ "totalMoneyPaid": 0 });
        }
        await firestore.collection("graph").doc(debtorEmail).set({[paidByEmailKey] : { 'debt': oldDebt - debt, 'imageUrl' : paidByImageUrl, 'username' : paidByUsername }}, { merge: true });
    });
    return "ok";
});
