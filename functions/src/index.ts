import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

export const onSeatPlanCreated = functions.firestore
  .document("seatPlans/{planId}")
  .onCreate(async (snapshot, context) => {
    const planData = snapshot.data();
    if (!planData) {
      console.log("No data in seat plan, exiting.");
      return null;
    }
    const examName = planData.examName || "Your Exam";
    const seatMap = planData.seatMap || {};
    const assignedStudents: { roll: string; seatId: string }[] = [];
    for (const seatId in seatMap) {
      const seat = seatMap[seatId];
      if (seat.state === "assigned" && seat.roll) {
        assignedStudents.push({
          roll: seat.roll,
          seatId: seatId,
        });
      }
    }

    if (assignedStudents.length === 0) {
      console.log("No students were assigned. No notifications sent.");
      return null;
    }
    const studentTokens: string[] = [];
    const rollIds = assignedStudents.map((s) => s.roll);
    const studentQuery = await db.collection("students")
      .where("roll", "in", rollIds)
      .get();

    for (const doc of studentQuery.docs) {
      const token = doc.data().fcmToken;
      if (token) {
        studentTokens.push(token);
      }
    }
    
    if (studentTokens.length === 0) {
      console.log("Found students, but none have an FCM token. No notifications sent.");
      return null;
    }
    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: "Your Seat Plan is Ready!",
        body: `Your seat for the ${examName} exam has been assigned. Open the app to view your seat.`,
      },
    };
    console.log(`Sending notification to ${studentTokens.length} students...`);
    return fcm.sendToDevice(studentTokens, payload);
  });