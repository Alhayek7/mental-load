# 📦 Mental Load – Complete Project Documentation

## USAII Global AI Hackathon 2026 | Undergraduate Track
### Challenge: Productivity: "Second Brain for Real Life"

**Team GOAI** | **Documentation Date: June 15, 2026**

---

## 📑 Table of Contents

| # | Section |
| :--- | :--- |
| 1 | Project Overview |
| 2 | Problem & Solution |
| 3 | AI & Technical Architecture |
| 4 | Screens & UX Design |
| 5 | Database |
| 6 | Human-in-the-Loop Design |
| 7 | Responsible AI & Guardrails |
| 8 | Tools & Technologies |
| 9 | Development Timeline (7 Days) |
| 10 | Video Pitch Script |
| 11 | Devpost Requirements |
| 12 | Final Checklist |

---

## 1. Project Overview

| Element | Details |
| :--- | :--- |
| **Project Name** | Mental Load |
| **Tagline** | Understand Your Mental Load |
| **Team Name** | GOAI |
| **Core Idea** | An AI-powered daily check-in assistant that detects cognitive overload in heavy AI tool users and provides proactive, personalized interventions. |

### Unique Value Proposition

> *"A digital immune system for your brain – it detects overload before you feel it."*

---

## 2. Problem & Solution

### The Core Problem

According to a **Harvard Business Review study (March 2026)** conducted with Boston Consulting Group, involving **1,488 full-time employees**:

> **14% of AI tool users suffer from 'Brain Fry'** – severe cognitive overload characterized by brain fog, difficulty concentrating, and slowed decision-making.

**Source:** HBR, "When AI Overloads Your Brain", March 2026

### The Gap Mental Load Fills

| Barrier | Explanation |
| :--- | :--- |
| **Traditional productivity tools** | Only organize tasks, don't analyze mental state |
| **Biometric devices** | Measure sleep and heart rate, don't understand natural language |
| **Voice assistants** | Execute simple commands, don't detect cognitive overload |

### Proposed Solution

| Mechanism | Description | AI Technology |
| :--- | :--- | :--- |
| 🟢 **Early Detection** | Analyzes free text to detect overload indicators before the user feels them | BERT-base-uncased |
| 🟡 **Proactive Intervention** | Generates immediate, personalized recommendations | Gemini 1.5 Flash API |
| 🔵 **Future Forecast** | Predicts the "Burnout Score" 3 days in advance | ARIMA |

---

## 3. AI & Technical Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         USER INTERFACE (Flutter)                        │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         PROCESSING LAYER                                │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐ │
│  │  Whisper API    │───▶│      BERT       │───▶│   Gemini API        │ │
│  │  (Voice → Text) │    │  (Text → Score) │    │  (Score → Advice)   │ │
│  └─────────────────┘    └─────────────────┘    └─────────────────────┘ │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    DATABASE (Supabase - PostgreSQL)                     │
└─────────────────────────────────────────────────────────────────────────┘
```

### AI Architecture (600 chars – for Devpost)

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

## 4. Screens & UX Design

### Complete Screen List (13 Screens)

| # | Screen | Description |
| :--- | :--- | :--- |
| 1 | Splash Screen | App launch screen |
| 2 | Onboarding (3 pages) | Explains the app's purpose |
| 3 | Log In | User login |
| 4 | Sign Up | New account creation |
| 5 | Privacy & Consent | Privacy policy agreement |
| 6 | Initial Questionnaire | Collects user's AI usage habits |
| 7 | Home Dashboard | Main dashboard |
| 8 | Check-in Screen | Daily log entry |
| 9 | Result Screen | Displays Score + recommendations |
| 10 | Patterns Screen | "My Patterns" page (forecast & tracker) |
| 11 | Analytics Screen | Charts and statistics |
| 12 | History Screen | Past check-ins log |
| 13 | Settings Screen | App settings |

### Visual Identity (Color Palette)

| Color | Name | Hex | Usage |
| :--- | :--- | :--- | :--- |
| 🔵 | **Deep Blue** | `#1A5F7A` | Trust, primary buttons |
| 🟣 | **Soft Purple** | `#7B2CBF` | Inspiration, focus icons |
| 🟢 | **Calm Mint** | `#2D6A4F` | Calmness, low Scores |
| 🟠 | **Warm Orange** | `#F4A261` | Medium Scores |
| 🔴 | **Gentle Red** | `#E76F51` | High Scores (4-5) |

---

## 5. Database

### Technology: Supabase (PostgreSQL)

### Main Tables

| Table | Key Columns |
| :--- | :--- |
| `users` | id, email, full_name, created_at |
| `checkins` | id, user_id, date, free_text, score, recommendation, followed |
| `recommendations_history` | id, user_id, checkin_id, text, was_followed |

### Security Policy (RLS)

```sql
-- Users can only see their own data
CREATE POLICY "Users can view own data" ON checkins
  FOR SELECT USING (auth.uid() = user_id);
```

---

## 6. Human-in-the-Loop Design

### Decisions AI Never Makes

1. **Never decides** the user "needs professional help" without explicit manual confirmation.
2. **Never takes autonomous actions** (does not close apps or force breaks).
3. **Never shares data** with any third party without consent.

### Specific Design

| Layer | Description |
| :--- | :--- |
| **Classification Correction** | After showing Score: "Is this accurate?" – User can correct it. |
| **Recommendation Follow-up** | Next day: "Did you follow yesterday's recommendation?" |
| **Request Help** | "Request Help" button requires an explicit click. |

---

## 7. Responsible AI & Guardrails

| Risk | Mitigation |
| :--- | :--- |
| **Replacing professional care** | Clear disclaimer: "This is for self-awareness, not a substitute for professional care" |
| **Data privacy** | End-to-end encryption + no sharing + right to be forgotten |
| **Underage users** | Parental consent + weekly reports to parents |
| **Model bias** | Manual user corrections + multi-language models planned |

### Guardrail Text for Devpost (500 chars)

```
RISK 1 - Replacing professional care
MITIGATION: Clear disclaimer + professional helplines for high scores

RISK 2 - Data privacy
MITIGATION: End-to-end encryption + no third-party sharing + right to be forgotten

RISK 3 - Underage users
MITIGATION: Parental consent + weekly reports to parents
```

---

## 8. Tools & Technologies

| Layer | Technology | License |
| :--- | :--- | :--- |
| **Frontend** | Flutter | Free |
| **Database** | Supabase (PostgreSQL) | Free |
| **NLP Classification** | BERT-base-uncased | Free |
| **Recommendations** | Gemini 1.5 Flash API | Free (initial credit) |
| **Speech-to-Text** | Whisper API | Free (initial credit) |
| **Forecasting** | ARIMA (statsmodels) | Free |

---

## 9. Development Timeline (7 Days)

| Day | Tasks | Lead(s) |
| :--- | :--- | :--- |
| **June 14** | Environment setup, Supabase, Auth screens | Wesam + Ahmed |
| **June 15** | Dashboard, Check-in screen, Database | Wesam + Ratul |
| **June 16** | BERT + Gemini API integration | Ahmed + Ratul |
| **June 17** | Human-in-the-Loop + Guardrails | Ayat + Raghad |
| **June 18** | Forecast (ARIMA) + Analytics | Ratul + Ayat |
| **June 19** | UI improvements + Comprehensive testing | Raghad + Team |
| **June 20** | Video recording + Devpost submission | Entire Team |

---

## 10. Video Pitch Script (3-5 minutes)

| Time | Content |
| :--- | :--- |
| **0:00-0:30** | Hook: HBR statistic – 14% of AI users suffer from "Brain Fry" |
| **0:30-1:15** | Explain the problem (silent cognitive overload, no dedicated tool) |
| **1:15-2:00** | Introduce the solution: How Mental Load works |
| **2:00-2:45** | Live Demo: Check-in → Score → Recommendation |
| **2:45-3:15** | Human-in-the-Loop: "Is this accurate?" button + follow-up |
| **3:15-3:45** | Responsible AI: Privacy, security, parental consent |
| **3:45-4:00** | Conclusion & Call to action: "A digital immune system for your brain" |

---

## 11. Devpost Requirements (Ready-to-Copy)

### AI Architecture (600 chars)

```
INPUTS: Free text + optional voice + AI tools count + usage pattern

AI PIPELINE:
1. Whisper API (voice → text)
2. BERT-base-uncased → Cognitive Load Score (1-5) + confidence
3. Gemini 1.5 Flash API → personalized recommendations

OUTPUT: Score (1-5) + recommendation text + warning if score > 4

CONFIDENCE PROTECTION: If confidence < 75% → user correction
```

### Human-in-the-Loop (500 chars)

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

### AI Tools Used (800 chars)

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

## 12. Final Pre-Submission Checklist

### Complete 24 hours before the deadline:

| Item | Done ✅ |
| :--- | :--- |
| Qualifier Approval Code entered correctly in Devpost | ☐ |
| All text fields within character limits | ☐ |
| Video duration is between 3 and 5 minutes | ☐ |
| Video link works (no login required) | ☐ |
| GitHub repository link works | ☐ |
| All team members listed in Devpost | ☐ |
| Track = Undergraduate selected | ☐ |
| Challenge = Productivity selected | ☐ |
| AI Architecture section completed | ☐ |
| Human-in-the-Loop section completed | ☐ |
| Responsible AI Guardrail section completed | ☐ |
| Privacy & Consent screen exists in the app | ☐ |
| **Final Submit button clicked** (not Save Draft) | ☐ |

---

## 👥 Team GOAI

| Name | Role | Email |
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
