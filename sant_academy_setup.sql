-- ============================================================
-- SANT ACADEMY - SUPABASE DATABASE CONFIGURATION
-- Schema for Study Materials, Quizzes, Performance, and Auth
-- ============================================================

-- 1. SETUP EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. PROFILES TABLE (Linked to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  phone TEXT UNIQUE,
  board TEXT CHECK (board IN ('BSEB', 'CBSE')),
  class_level TEXT CHECK (class_level IN ('9th', '10th', '11th', '12th')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. PROFILE CREATION TRIGGER
-- Automatically creates a profile row in public.profiles when a new user registers in auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, phone, board, class_level)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', 'Student'),
    new.phone,
    'BSEB', -- Default board for local Bihar area
    '10th'  -- Default class level
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger execution link
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. STUDY MATERIALS (PDF Files bucket mappings)
CREATE TABLE IF NOT EXISTS public.study_materials (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  pdf_url TEXT NOT NULL, -- Public link to Supabase Storage bucket
  board TEXT NOT NULL CHECK (board IN ('BSEB', 'CBSE')),
  class_level TEXT NOT NULL CHECK (class_level IN ('9th', '10th', '11th', '12th')),
  subject TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. QUIZZES & TESTS
CREATE TABLE IF NOT EXISTS public.quizzes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  duration_minutes INTEGER DEFAULT 30,
  board TEXT NOT NULL CHECK (board IN ('BSEB', 'CBSE')),
  class_level TEXT NOT NULL CHECK (class_level IN ('9th', '10th', '11th', '12th')),
  subject TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. QUIZ QUESTIONS
CREATE TABLE IF NOT EXISTS public.quiz_questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  quiz_id UUID REFERENCES public.quizzes(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  options TEXT[] NOT NULL, -- Array of exactly 4 choices
  correct_option_index INTEGER NOT NULL CHECK (correct_option_index BETWEEN 0 AND 3),
  explanation TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. USER QUIZ ATTEMPTS (For stats and performance metrics)
CREATE TABLE IF NOT EXISTS public.user_attempts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  quiz_id UUID REFERENCES public.quizzes(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  time_taken_seconds INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 8. SECURITY & RLS POLICIES
-- ============================================================

ALTER TABLE public.study_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_attempts ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Allow users to read their own profiles" 
  ON public.profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Allow users to update their own profiles" 
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Study Materials Policies (Public Read, Admin Write)
CREATE POLICY "Allow public read on study materials" 
  ON public.study_materials FOR SELECT USING (true);

-- Quizzes & Questions Policies (Authenticated student Read, Admin Write)
CREATE POLICY "Allow authenticated read on quizzes" 
  ON public.quizzes FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated read on questions" 
  ON public.quiz_questions FOR SELECT USING (auth.role() = 'authenticated');

-- User Attempts Policies (User specific CRUD)
CREATE POLICY "Allow users to view own attempts" 
  ON public.user_attempts FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Allow users to log own attempts" 
  ON public.user_attempts FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- 9. INITIAL SEED DATA
-- ============================================================

-- Seed Study Materials (BSEB & CBSE Class 10/12)
INSERT INTO public.study_materials (title, description, pdf_url, board, class_level, subject) VALUES
('BSEB Class 10 Science Objective Notes', 'Bihar board Class 10 Science Chapter-wise objective questions with solutions.', 'https://raw.githubusercontent.com/mozilla/pdf.js/ba2edeae/web/compressed.tracemonkey-pldi-09.pdf', 'BSEB', '10th', 'Science'),
('CBSE Class 10 Maths Formula Sheet', 'All important mathematical formulas for Class 10 CBSE Board Exams.', 'https://raw.githubusercontent.com/mozilla/pdf.js/ba2edeae/web/compressed.tracemonkey-pldi-09.pdf', 'CBSE', '10th', 'Mathematics'),
('BSEB Class 12 Physics VVI Subjective', 'Class 12 Bihar Board Physics subjective questions & conceptual notes.', 'https://raw.githubusercontent.com/mozilla/pdf.js/ba2edeae/web/compressed.tracemonkey-pldi-09.pdf', 'BSEB', '12th', 'Physics');

-- Seed Quizzes
INSERT INTO public.quizzes (id, title, description, duration_minutes, board, class_level, subject) VALUES
('a1111111-1111-1111-1111-111111111111', 'BSEB Class 10 Science Objective Test 1', 'Important board objective questions for Science.', 10, 'BSEB', '10th', 'Science'),
('b2222222-2222-2222-2222-222222222222', 'CBSE Class 10 Quadratic Equations Test', 'Practice questions on Quadratic Equations.', 15, 'CBSE', '10th', 'Mathematics');

-- Seed Quiz Questions
INSERT INTO public.quiz_questions (quiz_id, question_text, options, correct_option_index, explanation) VALUES
('a1111111-1111-1111-1111-111111111111', 'Which acid is present in tomato (टमाटर में कौन सा अम्ल पाया जाता है)?', ARRAY['Citric Acid (साइट्रिक अम्ल)', 'Oxalic Acid (ऑक्सेलिक अम्ल)', 'Lactic Acid (लैक्टिक अम्ल)', 'Tartaric Acid (टार्टरिक अम्ल)'], 1, 'Oxalic acid is present in tomato. (टमाटर में ऑक्सेलिक अम्ल पाया जाता है।)'),
('a1111111-1111-1111-1111-111111111111', 'What is the focal length of a flat mirror (समतल दर्पण की फोकस दूरी होती है)?', ARRAY['Zero (शून्य)', 'Infinite (अनंत)', '25 cm', '50 cm'], 1, 'The focal length of a flat mirror is infinite because its reflecting surface is flat. (समतल दर्पण की फोकस दूरी अनंत होती है।)'),
('b2222222-2222-2222-2222-222222222222', 'What is the discriminant of the quadratic equation x^2 - 4x + 4 = 0?', ARRAY['4', '0', '-4', '8'], 1, 'D = b^2 - 4ac = (-4)^2 - 4(1)(4) = 16 - 16 = 0.');
