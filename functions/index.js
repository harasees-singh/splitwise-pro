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
exports.updateGraphOnAdd = functions.firestore.document("transactions/{transactionId}").onCreate(async (snap, context) => {
    try {
        const batch = firestore.batch();

        const transaction = snap.data();
        const paidByEmail = transaction.paidByEmail;
        var splitMap = transaction.split;
        const paidByImageUrl = transaction.paidByImageUrl;
        const paidByUsername = transaction.paidByUsername;
        // console.log("executing for ", paidByEmail);
        console.log(splitMap);

        const listOfDebtorEmails = Object.keys(splitMap);
        var oldTotalMoneyPaid = 0;

        listOfDebtorEmails.forEach((debtorEmail) => {
            splitMap[debtorEmail]['oldDebt'] = 0; 
        })

        // const docSnapshot = await firestore.collection("graph").doc(paidByEmail).get();
        const querySnapshot = await firestore.collection('graph')
            .where(admin.firestore.FieldPath.documentId(), 'in', listOfDebtorEmails)
            .get();

        querySnapshot.forEach((doc) => {
            // Access the data of each document
            const data = doc.data();
            if (doc.id === paidByEmail) {
                if (data['totalMoneyPaid'] != null) {
                    oldTotalMoneyPaid = data['totalMoneyPaid'];
                }
            }
            if (data[removePeriodFromEmail(paidByEmail)] != null) {
                splitMap[doc.id]['oldDebt'] = data[removePeriodFromEmail(paidByEmail)]['debt'] * -1;
            }
        });

        // update totalMoneyPaid by the paidBy user
        batch.set(firestore.collection('graph').doc(paidByEmail), { 'totalMoneyPaid': oldTotalMoneyPaid + transaction.amount }, { merge: true });
        const paidByEmailKey = removePeriodFromEmail(paidByEmail);
        Object.keys(splitMap).forEach((debtorEmail) => {
            if (debtorEmail !== paidByEmail) {
                const debtorEmailKey = removePeriodFromEmail(debtorEmail);
                const oldDebt = splitMap[debtorEmail]['oldDebt'];
                const debt = splitMap[debtorEmail]['amount'];
                const username = splitMap[debtorEmail]['username'];
                const imageUrl = splitMap[debtorEmail]['imageUrl'];
                batch.set(firestore.collection('graph').doc(paidByEmail), { [debtorEmailKey]: { 'debt': debt + oldDebt } }, { merge: true });
                batch.set(firestore.collection('graph').doc(debtorEmail), { [paidByEmailKey]: { 'debt': -oldDebt - debt } }, { merge: true });
            }
        });

        await batch.commit();
        await firestore.collection('transactions').doc(context.params.transactionId).set({ 'status': 'completed' }, { merge: true });
    } catch (e) {
        await firestore.collection('transactions').doc(context.params.transactionId).set({ 'status': 'error' }, { merge: true });
        console.log(e);
    }

    return "ok";
});

// firestore trigger to update graph edges once a transaction is deleted
exports.updateGraphOnDelete = functions.firestore.document("transactions/{transactionId}").onDelete(async (snap, context) => {
    const transaction = snap.data();
    const paidByEmail = transaction.paidByEmail;
    const splitMap = transaction.split;
    const paidByImageUrl = transaction.paidByImageUrl;
    const paidByUsername = transaction.paidByUsername;
    console.log("executing delete transac for ", paidByEmail);

    const docSnapshot = await firestore.collection("graph").doc(paidByEmail).get();
    var totalMoneyPaid = 0;
    if (!docSnapshot.exists) {
        await firestore.collection("graph").doc(paidByEmail).set({ "totalMoneyPaid": 0 });
    }
    else {
        totalMoneyPaid = docSnapshot.get("totalMoneyPaid");
    }

    await firestore.collection('graph').doc(paidByEmail).set({ "totalMoneyPaid": totalMoneyPaid + (transaction.amount * -1) }, { merge: true });


    Object.keys(splitMap).forEach(async (debtorEmail) => {
        var debt = splitMap[debtorEmail]['amount'] * -1;
        var imageUrl = splitMap[debtorEmail]['imageUrl'];
        var username = splitMap[debtorEmail]['username'];
        var debtorEmailKey = removePeriodFromEmail(debtorEmail);
        var edges = await firestore.collection("graph").doc(paidByEmail).get();
        var oldDebt = 0;

        oldDebt = edges.get(debtorEmailKey) == null ? 0 : edges.get(debtorEmailKey)['debt'];

        await firestore.collection("graph").doc(paidByEmail).set({ [debtorEmailKey]: { 'debt': debt + oldDebt, 'imageUrl': imageUrl, 'username': username } }, { merge: true });

        var paidByEmailKey = removePeriodFromEmail(paidByEmail);
        edges = await firestore.collection("graph").doc(debtorEmail).get();
        if (edges.exists) {
            oldDebt = edges.get(paidByEmailKey) == null ? 0 : edges.get(paidByEmailKey)['debt'];
        }
        else {
            await firestore.collection("graph").doc(debtorEmail).set({ "totalMoneyPaid": 0 });
        }
        await firestore.collection("graph").doc(debtorEmail).set({ [paidByEmailKey]: { 'debt': oldDebt - debt, 'imageUrl': paidByImageUrl, 'username': paidByUsername } }, { merge: true });
    });
    return "ok";
});
