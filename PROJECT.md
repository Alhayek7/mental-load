# 📦 Mental Load – التوثيق الشامل للمشروع

## USAII Global AI Hackathon 2026 | Undergraduate Track
### تحدي Productivity: "Second Brain for Real Life"

**Team GOAI** | **تاريخ التوثيق: 15 يونيو 2026**

---

## 📑 فهرس المحتويات

| الرقم | القسم |
| :--- | :--- |
| 1 | نظرة عامة عن المشروع |
| 2 | المشكلة والحل |
| 3 | الذكاء الاصطناعي والمعمارية التقنية |
| 4 | تصميم الشاشات وتجربة المستخدم |
| 5 | قاعدة البيانات |
| 6 | Human-in-the-Loop Design |
| 7 | Responsible AI & Guardrails |
| 8 | الأدوات والتقنيات |
| 9 | خطة التنفيذ (7 أيام) |
| 10 | سيناريو فيديو العرض |
| 11 | متطلبات Devpost |
| 12 | قائمة المراجعة النهائية |

---

## 1. نظرة عامة عن المشروع

| العنصر | التفصيل |
| :--- | :--- |
| **اسم المشروع** | Mental Load |
| **الشعار** | Understand Your Mental Load |
| **اسم الفريق** | GOAI |
| **الفكرة الأساسية** | مساعد ذكاء اصطناعي يومي (AI Check-in) يكتشف الإرهاق المعرفي لمستخدمي أدوات الذكاء الاصطناعي، ويقدم تدخلات مخصصة استباقية |

### القيمة المميزة

> *"جهاز مناعة رقمي لعقلك – يكتشف الإرهاق قبل أن تشعر به"*

---

## 2. المشكلة والحل

### المشكلة الأساسية

وفقاً لدراسة **Harvard Business Review (مارس 2026)** بالتعاون مع Boston Consulting Group، وشملت **1,488 موظفاً بدوام كامل**:

> **14% من مستخدمي أدوات الذكاء الاصطناعي يعانون من 'Brain Fry' – إرهاق معرفي حاد يتمثل في ضبابية التفكير، صعوبة التركيز، وبطء اتخاذ القرارات.**

**المصدر:** HBR, "When AI Overloads Your Brain", March 2026

### الفجوة التي يسدها Mental Load

| العائق | الشرح |
| :--- | :--- |
| **أدوات الإنتاجية التقليدية** | تنظم المهام فقط، لا تحلل الحالة الذهنية |
| **أجهزة القياس الحيوي** | تقيس النوم ومعدل القلب، لا تفهم اللغة الطبيعية |
| **المساعدون الصوتيون** | ينفذون أوامر بسيطة، لا يكتشفون الإرهاق |

### الحل المقترح

| الآلية | الوصف | الـ AI المستخدم |
| :--- | :--- | :--- |
| 🟢 **الكشف المبكر** | تحليل النص الحر لاكتشاف مؤشرات الإرهاق | BERT-base-uncased |
| 🟡 **التدخل الاستباقي** | توليد توصيات مخصصة فورية | Gemini 1.5 Flash API |
| 🔵 **التوقع المستقبلي** | التنبؤ بـ "Burnout Score" بعد 3 أيام | ARIMA |

---

## 3. الذكاء الاصطناعي والمعمارية التقنية

### المعمارية العامة

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      واجهة المستخدم (UI) – Flutter                      │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      طبقة المعالجة (Processing Layer)                   │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │
│  │  Whisper API    │───▶│      BERT       │───▶│   Gemini API        │ │
│  │  (صوت → نص)     │    │  (نص → Score)   │    │  (Score → توصية)    │ │
│  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                   قاعدة البيانات (Supabase - PostgreSQL)                │
└─────────────────────────────────────────────────────────────────────────┘
```

### AI Architecture (600 حرف – لـ Devpost)

```
INPUTS: Free text + optional voice + AI tools count + usage pattern

AI PIPELINE:
1. Whisper API (voice → text)
2. BERT-base-uncased → Cognitive Load Score (1-5) + confidence
3. Gemini 1.5 Flash API → personalized recommendations

OUTPUT: Score (1-5) + recommendation text + warning if score > 4

CONFIDENCE PROTECTION: If confidence < 75% → user correction
```

---

## 4. تصميم الشاشات وتجربة المستخدم

### قائمة الشاشات (13 شاشة)

| # | الشاشة | الوصف |
| :--- | :--- | :--- |
| 1 | Splash Screen | شاشة البداية |
| 2 | Onboarding (3 صفحات) | شرح فكرة التطبيق |
| 3 | Log In | تسجيل الدخول |
| 4 | Sign Up | إنشاء حساب |
| 5 | Privacy & Consent | الموافقة على الخصوصية |
| 6 | الاستبيان الأولي | جمع بيانات المستخدم |
| 7 | Home Dashboard | الصفحة الرئيسية |
| 8 | Check-in Screen | تسجيل اليوم |
| 9 | Result Screen | عرض Score + توصيات |
| 10 | Patterns Screen | صفحة "أنماطي" |
| 11 | Analytics Screen | رسوم بيانية |
| 12 | History Screen | سجل Check-ins |
| 13 | Settings Screen | الإعدادات |

### الهوية البصرية

| اللون | الاسم | Hex | الاستخدام |
| :--- | :--- | :--- | :--- |
| 🔵 | **Deep Blue** | `#1A5F7A` | الثقة، الأزرار الرئيسية |
| 🟣 | **Soft Purple** | `#7B2CBF` | الإلهام، أيقونات التركيز |
| 🟢 | **Calm Mint** | `#2D6A4F` | الهدوء، Scores المنخفضة |
| 🟠 | **Warm Orange** | `#F4A261` | Scores المتوسطة |
| 🔴 | **Gentle Red** | `#E76F51` | Scores المرتفعة (4-5) |

---

## 5. قاعدة البيانات

### التقنية: Supabase (PostgreSQL)

### الجداول الرئيسية

| الجدول | الأعمدة الرئيسية |
| :--- | :--- |
| `users` | id, email, full_name, created_at |
| `checkins` | id, user_id, date, free_text, score, recommendation, followed |
| `recommendations_history` | id, user_id, checkin_id, text, was_followed |

### سياسة الأمان (RLS)

```sql
-- المستخدم يرى بياناته فقط
CREATE POLICY "Users can view own data" ON checkins
  FOR SELECT USING (auth.uid() = user_id);
```

---

## 6. Human-in-the-Loop Design

### القرارات التي لا يفعله الـ AI

1. **لا يقرر أبداً** أن المستخدم "يحتاج مساعدة متخصصة" دون تأكيد يدوي
2. **لا ينفذ أي إجراء** (لا يغلق التطبيقات، لا يفرض الراحة)
3. **لا يشارك البيانات** مع أي طرف ثالث دون موافقة

### التصميم المحدد

| الطبقة | الوصف |
| :--- | :--- |
| **تصحيح التصنيف** | بعد عرض Score: "هل هذا دقيق؟" – المستخدم يصحح |
| **متابعة التوصية** | في اليوم التالي: "هل طبقت التوصية أمس؟" |
| **طلب المساعدة** | زر "طلب مساعدة" يتطلب ضغطاً صريحاً |

---

## 7. Responsible AI & Guardrails

| الخطر | الحل |
| :--- | :--- |
| **استبدال الاستشارة الطبية** | تنبيه: "هذه الأداة للتوعية الذاتية وليست بديلاً عن الرعاية الصحية" |
| **خصوصية البيانات** | تشفير شامل + عدم مشاركة + حق الحذف |
| **المستخدمون القاصرون** | موافقة ولي الأمر + تقارير أسبوعية |
| **التحيز (Bias)** | تصحيحات المستخدم + نماذج متعددة اللغات مستقبلاً |

### نص Guardrail لـ Devpost (500 حرف)

```
RISK 1 - Replacing professional care
MITIGATION: Clear disclaimer + professional helplines for high scores

RISK 2 - Data privacy
MITIGATION: End-to-end encryption + no third-party sharing + right to be forgotten

RISK 3 - Underage users
MITIGATION: Parental consent + weekly reports to parents
```

---

## 8. الأدوات والتقنيات

| الطبقة | التقنية | الترخيص |
| :--- | :--- | :--- |
| **واجهة المستخدم** | Flutter | مجاني |
| **قاعدة البيانات** | Supabase (PostgreSQL) | مجاني |
| **تصنيف الإرهاق** | BERT-base-uncased | مجاني |
| **توليد التوصيات** | Gemini 1.5 Flash API | مجاني (رصيد أولي) |
| **تحويل الصوت** | Whisper API | مجاني (رصيد أولي) |
| **التنبؤ** | ARIMA (statsmodels) | مجاني |

---

## 9. خطة التنفيذ (7 أيام)

| اليوم | المهام | المسؤول |
| :--- | :--- | :--- |
| **14 يونيو** | إعداد البيئة، Supabase، شاشات Auth | Wesam + Ahmed |
| **15 يونيو** | Dashboard، Check-in، قاعدة البيانات | Wesam + Ratul |
| **16 يونيو** | دمج BERT + Gemini APIs | Ahmed + Ratul |
| **17 يونيو** | Human-in-the-Loop + Guardrails | Ayat + Raghad |
| **18 يونيو** | Forecast (ARIMA) + تحليلات | Ratul + Ayat |
| **19 يونيو** | تحسين UI + اختبار شامل | Raghad + الفريق |
| **20 يونيو** | تصوير فيديو + تعبئة Devpost + تسليم | الفريق كاملاً |

---

## 10. سيناريو فيديو العرض

| الوقت | المحتوى |
| :--- | :--- |
| **0:00-0:30** | Hook: إحصائية HBR (14% من مستخدمي AI يعانون من "Brain Fry") |
| **0:30-1:15** | شرح المشكلة (إرهاق معرفي صامت، لا توجد أداة متخصصة) |
| **1:15-2:00** | شرح الحل: Mental Load – كيف يعمل؟ |
| **2:00-2:45** | Demo مباشر: Check-in → Score → توصية |
| **2:45-3:15** | Human-in-the-Loop: زر "هل التحليل دقيق؟" + متابعة التوصية |
| **3:15-3:45** | Responsible AI: خصوصية، أمان، حماية القاصرين |
| **3:45-4:00** | خاتمة ودعوة: "جهاز مناعة رقمي لعقلك" |

---

## 11. متطلبات Devpost (النماذج الجاهزة)

### AI Architecture (600 حرف)

```
INPUTS: Free text + optional voice + AI tools count + usage pattern

AI PIPELINE:
1. Whisper API (voice → text)
2. BERT-base-uncased → Cognitive Load Score (1-5) + confidence
3. Gemini 1.5 Flash API → personalized recommendations

OUTPUT: Score (1-5) + recommendation text + warning if score > 4

CONFIDENCE PROTECTION: If confidence < 75% → user correction
```

### Human-in-the-Loop (500 حرف)

```
DECISIONS AI DOES NOT MAKE:
1. Never decides user needs professional help without explicit confirmation
2. Never enforces actions (closing apps, forcing breaks)
3. No data shared without consent

DESIGN:
- After score: "Is this accurate?" → user can correct
- Next day: "Did you follow recommendation?"
- "Request Help" requires explicit click
- Parental consent for users under 18
```

### AI Tools Used (800 حرف)

```
1. BERT-base-uncased (Hugging Face) - free - Text classification
2. Gemini 1.5 Flash API (Google) - free tier - Recommendations
3. Whisper API (OpenAI) - free tier - Speech-to-text
4. ARIMA (statsmodels) - free - 3-day forecast
5. Supabase - free tier - Database & Auth
6. Flutter - free - UI framework

Used free credits from Google and OpenAI. No actual money paid.
```

---

## 12. قائمة المراجعة النهائية

### قبل التسليم بـ 24 ساعة:

| البند | تم ✅ |
| :--- | :--- |
| Qualifier Approval Code مدخل في Devpost | ☐ |
| جميع النصوص ضمن الحد الأقصى للحروف | ☐ |
| الفيديو مدته بين 3 و 5 دقائق | ☐ |
| رابط الفيديو يعمل | ☐ |
| رابط GitHub يعمل | ☐ |
| جميع أعضاء الفريق مذكورون في Devpost | ☐ |
| Track = Undergraduate | ☐ |
| Challenge = Productivity | ☐ |
| AI Architecture مكتمل | ☐ |
| Human-in-the-Loop مكتمل | ☐ |
| Responsible AI Guardrail مكتمل | ☐ |
| Privacy & Consent موجودة في التطبيق | ☐ |
| تم الضغط على Submit النهائي | ☐ |

---

## 👥 فريق GOAI

| العضو | الدور | البريد الإلكتروني |
| :--- | :--- | :--- |
| Ahmed Eid Abo Baid | AI Engineer | eidez1252002@gmail.com |
| Ayat Zaky Shehada Hamed | Data Scientist | ayat.zaky.hamed@gmail.com |
| Ratul Hasan Ruhan | Machine Learning Engineer | ratulhasan1644@gmail.com |
| Ahmed Wesam Alhayek | Software Developer | aalhayek7@smail.ucas.edu.ps |
| Raghad Mohammad Jawad AlSerhy | UI/UX Designer | raghadmohammad804@gmail.com |

---

<div align="center">
  <p>© 2026 Team GOAI – Mental Load</p>
  <p>USAII Global AI Hackathon 2026</p>
  <hr/>
  <p><strong>GitHub Repository:</strong> <a href="https://github.com/Alhayek7/mental-load">https://github.com/Alhayek7/mental-load</a></p>
</div>
```

---
