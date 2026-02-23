# Kinder World 🌍👨‍👩‍👧‍👦

مشروع تخرج متكامل لإدارة تجربة تعليمية للأطفال (5-12 سنة) مع تطبيق Flutter للوالد/الطفل + Backend بـ FastAPI.

## ✨ نظرة عامة

المستودع يحتوي على جزئين رئيسيين:

- `kinder_world_child_mode`: تطبيق Flutter (واجهات الطفل وولي الأمر)
- `kinderbackend`: API Backend مع قاعدة بيانات SQLite

## 🧱 البنية العامة

```text
Graduation Project/
├─ kinder_world_child_mode/   # Flutter app
└─ kinderbackend/             # FastAPI backend
```

## 🚀 المميزات الفعلية (الموجودة في الكود)

### 📱 التطبيق (Flutter)

- ✅ تسجيل/دخول ولي الأمر.
- ✅ تسجيل/دخول الطفل عبر `picture password` (3 عناصر).
- ✅ إدارة الأطفال (إضافة/تعديل/حذف).
- ✅ وضع الطفل: Home / Learn / Play / AI Buddy / Profile.
- ✅ وضع ولي الأمر: Dashboard / Reports / Controls / Notifications / Settings / Subscription.
- ✅ دعم اللغتين العربية والإنجليزية.
- ✅ ثيمات (Light / Dark) وتبديل داخل التطبيق.
- ✅ حراسة المسارات بحسب الدور (Parent/Child) والجلسة.
- ✅ صفحات نظام: No Internet / Error / Maintenance / Help / Legal / Data Sync.

### 🤖 AI Buddy (الحالة الحالية)

- ✅ موجود كشاشة محادثة داخل التطبيق.
- ✅ ردود محاكاة محلية (mocked responses) + Quick Actions.
- ℹ️ ليس متصلًا حاليًا بمزود ذكاء اصطناعي خارجي.

### 🧩 الـ Backend (FastAPI)

- ✅ Auth للأب: Register / Login / Refresh / Me / Logout / Change Password.
- ✅ Auth للطفل: Register / Login / Change Picture Password.
- ✅ إدارة الأطفال مع التحقق من العمر (5-12) وحدود الخطة.
- ✅ Subscription plans: `FREE` / `PREMIUM` / `FAMILY_PLUS`.
- ✅ Feature gating حسب الخطة (basic vs premium features).
- ✅ Notifications APIs (عرض + تعليم كمقروء).
- ✅ Parental Controls APIs (قراءة/تعديل الإعدادات).
- ✅ Privacy settings APIs.
- ✅ Support contact ticket API.
- ✅ Billing methods APIs (إضافة/عرض/حذف طريقة دفع).

### 💳 حالة الدفع والبوابة

- ✅ إدارة طرق الدفع موجودة.
- ⚠️ Billing portal endpoint موجود لكنه غير مُفعّل بعد (يرجع `501`).

## 🛠️ التقنيات المستخدمة

### Flutter App

- Flutter + Dart
- Riverpod
- GoRouter
- Dio + Connectivity Plus
- Freezed + JSON Serializable
- Lottie / FL Chart / Secure Storage

### Backend

- FastAPI
- SQLAlchemy
- SQLite
- Pydantic
- JWT (python-jose)
- bcrypt

## ▶️ التشغيل المحلي

### 1) تشغيل الـ Backend

من داخل `kinderbackend`:

```bash
python -m venv .venv
# Windows:
.venv\Scripts\activate
# macOS/Linux:
source .venv/bin/activate

pip install fastapi uvicorn sqlalchemy pydantic email-validator python-jose bcrypt
uvicorn main:app --reload
```

الـ API تعمل افتراضيًا على:

`http://127.0.0.1:8000`

### 2) تشغيل تطبيق Flutter

من داخل `kinder_world_child_mode`:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## 🧪 الاختبارات

### Backend

من داخل `kinderbackend`:

```bash
pytest
```

### Flutter

من داخل `kinder_world_child_mode`:

```bash
flutter test
```

## 📌 ملاحظات مهمة

- ملف `kinder_world_child_mode/.env` موجود داخل المشروع. لا تضعي فيه أسرار حقيقية قبل النشر العام.
- `kinderbackend/auth.py` يحتوي `SECRET_KEY` افتراضي (`CHANGE_ME...`) ويجب تغييره في بيئة الإنتاج.

## 👥 فريق المشروع

Graduation Project - Kinder World  
Made with care ❤️ for kids and parents.
