# Smart Exam Seat Allocation System

<img width="1200" height="360" alt="smart_exam_seat_allocation_banner" src="https://github.com/user-attachments/assets/1b04aa86-929c-4088-9582-c6494fdf2ef8" />

## 🔍 Problem — What we're solving
Universities often spend hours manually creating seating charts for exams, which is error-prone and unfair. Common issues include:
- Time-consuming manual work
- Double allocations or empty seats
- Friends or consecutive roll numbers placed together (increases malpractice risk)
- Students confused and stressed waiting for printed charts

This project automates the process to make exam seat allocation **fast, fair, and transparent**.

---

## 💡 Solution — How the project solves the problem
We build a **mobile application (Flutter)** with a **Firebase** backend (Firestore) that:
- Lets admins upload student lists and define exam halls
- Generates fair, randomized seating plans (with constraints as needed)
- Stores assignments in Firestore for real-time sync
- Sends push notifications to students when seats change
- Exports printable PDF/Excel seating charts for invigilators

(Design and motivation based on project proposal). fileciteturn0file0

---

## 📜 Description
**Smart Exam Seat Allocation System** is a cross-platform Flutter app that automates seating plan generation for university exams. It focuses on fairness (randomized distribution), administrative efficiency (one-click generation and export), and student convenience (view seat and hall instantly via mobile and get notifications).

Key capabilities:
- Role-based access (Admin / Student)
- CSV upload for bulk student import
- Hall management and capacity settings
- Constraint-aware seat allocator (avoid adjacent roll numbers/department clustering)
- Real-time updates and FCM notifications
- Exportable seating charts (PDF / Excel)

---

## 🛠️ Technology & Tools

| Technology | Icon |
|---|---:|
| Flutter | ![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white) |
| Dart | ![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white) |
| Firebase | ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black) |
| Firestore | ![Firestore](https://img.shields.io/badge/Firestore-FFA000?logo=google-cloud&logoColor=white) |
| Firebase Messaging | ![FCM](https://img.shields.io/badge/FCM-4285F4?logo=google&logoColor=white) |
| GitHub | ![GitHub](https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=white) |
| Figma | ![Figma](https://img.shields.io/badge/Figma-F24E1E?logo=figma&logoColor=white) |

---

## ✅ Contributions & Impact (Detailed)
This project provides several concrete contributions:

1. **Administrative Efficiency**
   - Reduces hours of manual work by automatically assigning seats and generating printable charts.
   - Bulk CSV import and hall-capacity settings speed up pre-exam preparation.

2. **Fairness & Anti-Malpractice**
   - Randomized allocation prevents predictable seating patterns (no consecutive roll clustering).
   - Configurable constraints (e.g., separate same-department students, avoid known friend pairs) reduce cheating opportunities.

3. **Real-time Transparency**
   - Firestore ensures all changes are synced instantly to students and invigilators.
   - Audit logs record who generated or changed seating plans for traceability.

4. **Student Convenience**
   - Students receive push notifications and can view seat & hall details on their mobile device — no need to crowd notice boards.

5. **Scalability & Portability**
   - Using Firebase allows the system to scale across faculties and campuses without major backend changes.

6. **Extensible Architecture**
   - Modular Flutter codebase and a clear Firestore schema make it easy to add features later (web admin panel, analytics, QR check-ins).

---

## 👥 Who will use this project?
- **Administrators / Exam Coordinators** — upload students, create halls, run allocation, export plans.
- **Invigilators** — receive printable hall-wise seating lists and check-in helpers.
- **Students** — log in to see seat number and hall, receive updates.
- **University IT / Maintainers** — manage the app, security rules, and deployment.

---

## 🗂️ Firestore Collections (Overview)
- `users` — {{ uid, name, email, role }}
- `students` — {{ studentId, name, roll, department }}
- `exams` — {{ examId, subject, date, time }}
- `halls` — {{ hallId, name, capacity }}
- `seatingPlans` — per-exam/hall assignment documents
- `notifications` — user-targeted messages

(Full schema & queue design in the project proposal). fileciteturn0file0

---

## 🚀 Quick Start (for developers)
1. Clone repo
2. Install Flutter SDK & Android Studio
3. Create Firebase project, add Android app, place `google-services.json` in `android/app/`
4. Run `flutter pub get`
5. Start app: `flutter run`

---

## 📸 Project Image
<img width="1200" height="360" alt="smart_exam_seat_allocation_banner" src="https://github.com/user-attachments/assets/30c43719-b1d8-4058-a957-1bad1d7f4cb5" />


## 📄 License & Contact
This project is open for academic use. For contributions or questions, contact:

**Md. Ehashanul Haque**  
Course: Software Development Project II (BAUST)  
Email: *(ehasanul133@gmail.ccom)*

---

*This README was generated from the project proposal.* fileciteturn0file0
