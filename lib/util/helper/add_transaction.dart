import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:splitwise_pro/util/enums/transaction_status.dart';
import 'package:splitwise_pro/util/enums/transaction_type.dart';

String removePeriodsFromEmail(String email) {
  return email.replaceAll('.', '');
}

Future addTransactionAndUpdateGraph(
    Map<String, dynamic> transactionDetails) async {
  final batch = FirebaseFirestore.instance.batch();
  final transactionsRef = FirebaseFirestore.instance.collection('transactions');
  final graphRef = FirebaseFirestore.instance.collection('graph');
  
  // cash payment or expense
  final type = TransactionType.values.byName(transactionDetails['type']);

  // persist to transactions collection
  final transaction = await transactionsRef.add(transactionDetails);
  try {
    // udpate graph edges
    Map<String, dynamic> splitMap = transactionDetails['split'];
    final num amount = transactionDetails['amount'];
    final String paidByEmail = transactionDetails['paidByEmail'];
    final String paidByEmailKey = removePeriodsFromEmail(paidByEmail);
    final String paidByImageUrl = transactionDetails['paidByImageUrl'];
    final String paidByUsername = transactionDetails['paidByUsername'];
    final List<String> listOfDebtorEmails = splitMap.keys.toList();
    num totalMoneyPaid = 0;
    num totalShare = 0;
    num share = splitMap[paidByEmail] == null ? 0 : splitMap[paidByEmail]['amount'];

    for (final email in listOfDebtorEmails) {
      splitMap[email]['oldDebt'] = 0;
    }

    final querySnapshotGraph = await graphRef
        .where(FieldPath.documentId, whereIn: [...listOfDebtorEmails, paidByEmail])
        .get();

    for (final doc in querySnapshotGraph.docs) {
      final data = doc.data();
      if (doc.id == paidByEmail) {
        if (data.containsKey('totalMoneyPaid')) {
          totalMoneyPaid = data['totalMoneyPaid'];
        }
        if (data.containsKey('totalShare')) {
          totalShare = data['totalShare'];
        }
      }
      if (data.containsKey(paidByEmailKey)) {
        splitMap[doc.id]['oldDebt'] = data[paidByEmailKey]['debt'] * -1;
      }
    }

    if (type == TransactionType.expense) {
      batch.set(graphRef.doc(paidByEmail),
        {'totalMoneyPaid': totalMoneyPaid + amount, 'totalShare': totalShare + share}, SetOptions(merge: true));
    }
  
    for (final debtorEmail in listOfDebtorEmails) {
      if (debtorEmail == paidByEmail) {
        continue;
      }
      final debtorEmailKey = removePeriodsFromEmail(debtorEmail);
      final oldDebt = splitMap[debtorEmail]['oldDebt'];
      final debt = splitMap[debtorEmail]['amount'];
      final username = splitMap[debtorEmail]['username'];
      final imageUrl = splitMap[debtorEmail]['imageUrl'];
      batch.set(
          graphRef.doc(paidByEmail),
          {
            debtorEmailKey: {
              'debt': oldDebt + debt,
              'username': username,
              'imageUrl': imageUrl,
            }
          },
          SetOptions(merge: true));
      batch.set(
        graphRef.doc(debtorEmail),
        {
          paidByEmailKey: {
            'debt': -oldDebt - debt,
            'username': paidByUsername,
            'imageUrl': paidByImageUrl,
          }
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
    await transactionsRef.doc(transaction.id).set(
        {'status': TransactionStatus.completed.name}, SetOptions(merge: true));
  } catch (e) {
    await transactionsRef
        .doc(transaction.id)
        .set({'status': TransactionStatus.error.name}, SetOptions(merge: true));
    rethrow;
  }
}
