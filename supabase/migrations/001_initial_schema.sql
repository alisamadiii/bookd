-- ============================================================
-- Bookd — Initial Database Schema
-- 15 tables, 5 triggers, RLS, indexes, storage buckets
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "cube";
CREATE EXTENSION IF NOT EXISTS "earthdistance";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================================
-- 1. PROFILES (extends auth.users)
-- ============================================================
CREATE TABLE public.profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role          TEXT NOT NULL DEFAULT 'client' CHECK (role IN ('client', 'pro')),
  full_name     TEXT NOT NULL DEFAULT '',
  handle        TEXT UNIQUE,
  avatar_url    TEXT,
  palette       TEXT[] DEFAULT '{}',
  phone         TEXT,
  email         TEXT,
  push_token    TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_handle_format
  CHECK (handle IS NULL OR handle ~ '^[a-z0-9._]{3,30}$');

-- ============================================================
-- 2. PRO_PROFILES
-- ============================================================
CREATE TABLE public.pro_profiles (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  business_name       TEXT NOT NULL DEFAULT '',
  bio                 TEXT DEFAULT '',
  category            TEXT NOT NULL CHECK (category IN (
                        'hair','tattoo','fitness','beauty','wellness','photo','coach'
                      )),
  role_title          TEXT DEFAULT '',
  city                TEXT DEFAULT '',
  latitude            DOUBLE PRECISION,
  longitude           DOUBLE PRECISION,
  verified            BOOLEAN NOT NULL DEFAULT FALSE,
  cover_url           TEXT,
  badges              TEXT[] DEFAULT '{}',
  stripe_account_id   TEXT,
  stripe_onboarded    BOOLEAN NOT NULL DEFAULT FALSE,
  rating              NUMERIC(3,2) NOT NULL DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
  reviews_count       INTEGER NOT NULL DEFAULT 0,
  followers_count     INTEGER NOT NULL DEFAULT 0,
  posts_count         INTEGER NOT NULL DEFAULT 0,
  avg_response_minutes INTEGER,
  is_published        BOOLEAN NOT NULL DEFAULT FALSE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 3. SERVICES
-- ============================================================
CREATE TABLE public.services (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pro_id      UUID NOT NULL REFERENCES public.pro_profiles(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  description TEXT,
  price       INTEGER NOT NULL CHECK (price >= 0),
  duration    INTEGER NOT NULL CHECK (duration > 0),
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 4. WORKING_HOURS
-- ============================================================
CREATE TABLE public.working_hours (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pro_id      UUID NOT NULL REFERENCES public.pro_profiles(id) ON DELETE CASCADE,
  day_of_week SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  is_open     BOOLEAN NOT NULL DEFAULT TRUE,
  open_time   TIME NOT NULL DEFAULT '10:00',
  close_time  TIME NOT NULL DEFAULT '19:00',
  UNIQUE (pro_id, day_of_week),
  CHECK (close_time > open_time OR NOT is_open)
);

-- ============================================================
-- 5. TIME_OFF
-- ============================================================
CREATE TABLE public.time_off (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pro_id      UUID NOT NULL REFERENCES public.pro_profiles(id) ON DELETE CASCADE,
  date        DATE NOT NULL,
  all_day     BOOLEAN NOT NULL DEFAULT TRUE,
  start_time  TIME,
  end_time    TIME,
  reason      TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (pro_id, date, start_time)
);

-- ============================================================
-- 6. APPOINTMENTS
-- ============================================================
CREATE TABLE public.appointments (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pro_id              UUID NOT NULL REFERENCES public.pro_profiles(id) ON DELETE RESTRICT,
  client_id           UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  service_id          UUID NOT NULL REFERENCES public.services(id) ON DELETE RESTRICT,
  service_name        TEXT NOT NULL,
  service_price       INTEGER NOT NULL,
  starts_at           TIMESTAMPTZ NOT NULL,
  duration            INTEGER NOT NULL,
  status              TEXT NOT NULL DEFAULT 'confirmed'
                        CHECK (status IN ('pending','confirmed','completed','cancelled','no_show')),
  location            TEXT,
  notes               TEXT CHECK (char_length(notes) <= 280),
  tip_percent          SMALLINT DEFAULT 0 CHECK (tip_percent >= 0 AND tip_percent <= 100),
  tip_amount           INTEGER DEFAULT 0,
  booking_fee          INTEGER NOT NULL DEFAULT 200,
  subtotal             INTEGER NOT NULL,
  total                INTEGER NOT NULL,
  stripe_payment_intent_id TEXT,
  stripe_charge_id         TEXT,
  stripe_transfer_id       TEXT,
  payment_method           TEXT CHECK (payment_method IS NULL OR payment_method IN ('apple_pay','card')),
  payment_status           TEXT DEFAULT 'pending'
                             CHECK (payment_status IN ('pending','authorized','captured','refunded','failed')),
  cancelled_at         TIMESTAMPTZ,
  cancelled_by         UUID REFERENCES public.profiles(id),
  cancellation_reason  TEXT,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 7. PAYOUTS
-- ============================================================
CREATE TABLE public.payouts (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pro_id                UUID NOT NULL REFERENCES public.pro_profiles(id) ON DELETE RESTRICT,
  appointment_id        UUID NOT NULL REFERENCES public.appointments(id) ON DELETE RESTRICT,
  stripe_transfer_id    TEXT NOT NULL,
  amount                INTEGER NOT NULL,
  platform_fee          INTEGER NOT NULL,
  status                TEXT NOT NULL DEFAULT 'pending'
                          CHECK (status IN ('pending','completed','failed')),
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 8. REVIEWS
-- ============================================================
CREATE TABLE public.reviews (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pro_id          UUID NOT NULL REFERENCES public.pro_profiles(id) ON DELETE CASCADE,
  client_id       UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  appointment_id  UUID REFERENCES public.appointments(id) ON DELETE SET NULL,
  rating          SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  text            TEXT CHECK (char_length(text) <= 1000),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (appointment_id)
);

-- ============================================================
-- 9. PORTFOLIO_POSTS
-- ============================================================
CREATE TABLE public.portfolio_posts (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pro_id      UUID NOT NULL REFERENCES public.pro_profiles(id) ON DELETE CASCADE,
  image_url   TEXT NOT NULL,
  caption     TEXT DEFAULT '',
  likes_count INTEGER NOT NULL DEFAULT 0,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 10. PORTFOLIO_LIKES
-- ============================================================
CREATE TABLE public.portfolio_likes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id     UUID NOT NULL REFERENCES public.portfolio_posts(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (post_id, user_id)
);

-- ============================================================
-- 11. MESSAGE_THREADS
-- ============================================================
CREATE TABLE public.message_threads (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pro_id              UUID NOT NULL REFERENCES public.pro_profiles(id) ON DELETE CASCADE,
  client_id           UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  last_message_text   TEXT,
  last_message_at     TIMESTAMPTZ,
  client_unread_count INTEGER NOT NULL DEFAULT 0,
  pro_unread_count    INTEGER NOT NULL DEFAULT 0,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (pro_id, client_id)
);

-- ============================================================
-- 12. MESSAGES (Realtime enabled)
-- ============================================================
CREATE TABLE public.messages (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id   UUID NOT NULL REFERENCES public.message_threads(id) ON DELETE CASCADE,
  sender_id   UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  body        TEXT NOT NULL CHECK (char_length(body) <= 2000),
  read_at     TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 13. PROFILE_VIEWS
-- ============================================================
CREATE TABLE public.profile_views (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pro_id      UUID NOT NULL REFERENCES public.pro_profiles(id) ON DELETE CASCADE,
  viewer_id   UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  viewed_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- 14. FAVORITES
-- ============================================================
CREATE TABLE public.favorites (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id   UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  pro_id      UUID NOT NULL REFERENCES public.pro_profiles(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (client_id, pro_id)
);

-- ============================================================
-- 15. NOTIFICATIONS
-- ============================================================
CREATE TABLE public.notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type        TEXT NOT NULL CHECK (type IN (
                'booking_confirmed','booking_cancelled','booking_reminder',
                'new_message','new_review','new_follower','payment_received',
                'payout_complete','appointment_completed'
              )),
  title       TEXT NOT NULL,
  body        TEXT,
  data        JSONB DEFAULT '{}',
  read_at     TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- TRIGGERS
-- ============================================================

-- 1. Auto-create profile on auth signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 2. Update pro rating on review change
CREATE OR REPLACE FUNCTION public.update_pro_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.pro_profiles SET
    rating = COALESCE((SELECT AVG(rating)::NUMERIC(3,2) FROM public.reviews WHERE pro_id = COALESCE(NEW.pro_id, OLD.pro_id)), 0),
    reviews_count = (SELECT COUNT(*) FROM public.reviews WHERE pro_id = COALESCE(NEW.pro_id, OLD.pro_id)),
    updated_at = now()
  WHERE id = COALESCE(NEW.pro_id, OLD.pro_id);
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_review_change
  AFTER INSERT OR DELETE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION public.update_pro_rating();

-- 3. Update message thread on new message
CREATE OR REPLACE FUNCTION public.handle_new_message()
RETURNS TRIGGER AS $$
DECLARE
  v_thread public.message_threads%ROWTYPE;
BEGIN
  SELECT * INTO v_thread FROM public.message_threads WHERE id = NEW.thread_id;

  UPDATE public.message_threads SET
    last_message_text = LEFT(NEW.body, 100),
    last_message_at = NEW.created_at,
    client_unread_count = CASE
      WHEN NEW.sender_id != v_thread.client_id THEN client_unread_count + 1
      ELSE client_unread_count END,
    pro_unread_count = CASE
      WHEN NEW.sender_id = v_thread.client_id THEN pro_unread_count + 1
      ELSE pro_unread_count END,
    updated_at = now()
  WHERE id = NEW.thread_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_new_message
  AFTER INSERT ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_message();

-- 4. Update followers count
CREATE OR REPLACE FUNCTION public.update_followers_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.pro_profiles SET followers_count = followers_count + 1, updated_at = now()
    WHERE id = NEW.pro_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.pro_profiles SET followers_count = followers_count - 1, updated_at = now()
    WHERE id = OLD.pro_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_favorite_change
  AFTER INSERT OR DELETE ON public.favorites
  FOR EACH ROW EXECUTE FUNCTION public.update_followers_count();

-- 5. Update posts count
CREATE OR REPLACE FUNCTION public.update_posts_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.pro_profiles SET posts_count = posts_count + 1, updated_at = now()
    WHERE id = NEW.pro_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.pro_profiles SET posts_count = posts_count - 1, updated_at = now()
    WHERE id = OLD.pro_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_portfolio_change
  AFTER INSERT OR DELETE ON public.portfolio_posts
  FOR EACH ROW EXECUTE FUNCTION public.update_posts_count();

-- 6. Auto updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.pro_profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.services
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.appointments
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.message_threads
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ============================================================
-- INDEXES
-- ============================================================

-- profiles
CREATE INDEX idx_profiles_handle ON public.profiles (handle);
CREATE INDEX idx_profiles_role ON public.profiles (role);

-- pro_profiles
CREATE INDEX idx_pro_profiles_user_id ON public.pro_profiles (user_id);
CREATE INDEX idx_pro_profiles_category ON public.pro_profiles (category);
CREATE INDEX idx_pro_profiles_city ON public.pro_profiles (city);
CREATE INDEX idx_pro_profiles_published ON public.pro_profiles (is_published) WHERE is_published = TRUE;
CREATE INDEX idx_pro_profiles_rating ON public.pro_profiles (rating DESC);

-- services
CREATE INDEX idx_services_pro_id ON public.services (pro_id, sort_order);

-- working_hours
CREATE INDEX idx_working_hours_pro_id ON public.working_hours (pro_id);

-- appointments
CREATE INDEX idx_appointments_pro_starts ON public.appointments (pro_id, starts_at DESC);
CREATE INDEX idx_appointments_client_starts ON public.appointments (client_id, starts_at DESC);
CREATE INDEX idx_appointments_status ON public.appointments (status);
CREATE INDEX idx_appointments_pro_date_status ON public.appointments (pro_id, starts_at, status);
CREATE INDEX idx_appointments_payment ON public.appointments (payment_status) WHERE payment_status IN ('pending', 'authorized');
CREATE INDEX idx_appointments_stripe ON public.appointments (stripe_payment_intent_id) WHERE stripe_payment_intent_id IS NOT NULL;

-- reviews
CREATE INDEX idx_reviews_pro_id ON public.reviews (pro_id, created_at DESC);
CREATE INDEX idx_reviews_client_id ON public.reviews (client_id);

-- portfolio_posts
CREATE INDEX idx_portfolio_pro_id ON public.portfolio_posts (pro_id, sort_order);

-- portfolio_likes
CREATE INDEX idx_portfolio_likes_post ON public.portfolio_likes (post_id);
CREATE INDEX idx_portfolio_likes_user_post ON public.portfolio_likes (user_id, post_id);

-- message_threads
CREATE INDEX idx_threads_client ON public.message_threads (client_id, last_message_at DESC);
CREATE INDEX idx_threads_pro ON public.message_threads (pro_id, last_message_at DESC);

-- messages
CREATE INDEX idx_messages_thread ON public.messages (thread_id, created_at DESC);
CREATE INDEX idx_messages_sender ON public.messages (sender_id);

-- profile_views
CREATE INDEX idx_profile_views_pro_date ON public.profile_views (pro_id, viewed_at DESC);

-- favorites
CREATE INDEX idx_favorites_client ON public.favorites (client_id);
CREATE INDEX idx_favorites_pro ON public.favorites (pro_id);

-- notifications
CREATE INDEX idx_notifications_user ON public.notifications (user_id, created_at DESC);
CREATE INDEX idx_notifications_unread ON public.notifications (user_id, created_at DESC) WHERE read_at IS NULL;

-- payouts
CREATE INDEX idx_payouts_pro ON public.payouts (pro_id, created_at DESC);
CREATE INDEX idx_payouts_appointment ON public.payouts (appointment_id);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pro_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.working_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.time_off ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- PROFILES
CREATE POLICY "Anyone can read basic profile info" ON public.profiles
  FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- PRO_PROFILES
CREATE POLICY "Published pros visible to all" ON public.pro_profiles
  FOR SELECT USING (is_published = true OR user_id = auth.uid());
CREATE POLICY "Pro can insert own profile" ON public.pro_profiles
  FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Pro can update own profile" ON public.pro_profiles
  FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Pro can delete own profile" ON public.pro_profiles
  FOR DELETE USING (user_id = auth.uid());

-- SERVICES
CREATE POLICY "Services visible for published pros" ON public.services
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = services.pro_id AND (pp.is_published = true OR pp.user_id = auth.uid()))
  );
CREATE POLICY "Pro can manage own services" ON public.services
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = services.pro_id AND pp.user_id = auth.uid())
  );
CREATE POLICY "Pro can update own services" ON public.services
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = services.pro_id AND pp.user_id = auth.uid())
  );
CREATE POLICY "Pro can delete own services" ON public.services
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = services.pro_id AND pp.user_id = auth.uid())
  );

-- WORKING_HOURS
CREATE POLICY "Hours visible for published pros" ON public.working_hours
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = working_hours.pro_id AND (pp.is_published = true OR pp.user_id = auth.uid()))
  );
CREATE POLICY "Pro can manage own hours" ON public.working_hours
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = working_hours.pro_id AND pp.user_id = auth.uid())
  );

-- TIME_OFF
CREATE POLICY "Pro sees own time off" ON public.time_off
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = time_off.pro_id AND pp.user_id = auth.uid())
  );
CREATE POLICY "Pro manages own time off" ON public.time_off
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = time_off.pro_id AND pp.user_id = auth.uid())
  );

-- APPOINTMENTS
CREATE POLICY "Client sees own appointments" ON public.appointments
  FOR SELECT USING (client_id = auth.uid());
CREATE POLICY "Pro sees own appointments" ON public.appointments
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = appointments.pro_id AND pp.user_id = auth.uid())
  );
CREATE POLICY "Client can create appointment" ON public.appointments
  FOR INSERT WITH CHECK (client_id = auth.uid());
CREATE POLICY "Pro can update appointment status" ON public.appointments
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = appointments.pro_id AND pp.user_id = auth.uid())
  );
CREATE POLICY "Client can cancel own appointment" ON public.appointments
  FOR UPDATE USING (client_id = auth.uid());

-- PAYOUTS (service role only for writes)
CREATE POLICY "Pro sees own payouts" ON public.payouts
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = payouts.pro_id AND pp.user_id = auth.uid())
  );

-- REVIEWS
CREATE POLICY "Reviews are public" ON public.reviews
  FOR SELECT USING (true);
CREATE POLICY "Client can review completed appointment" ON public.reviews
  FOR INSERT WITH CHECK (client_id = auth.uid());
CREATE POLICY "Author can delete own review" ON public.reviews
  FOR DELETE USING (client_id = auth.uid());

-- PORTFOLIO_POSTS
CREATE POLICY "Portfolio posts are public" ON public.portfolio_posts
  FOR SELECT USING (true);
CREATE POLICY "Pro can manage portfolio" ON public.portfolio_posts
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = portfolio_posts.pro_id AND pp.user_id = auth.uid())
  );
CREATE POLICY "Pro can update portfolio" ON public.portfolio_posts
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = portfolio_posts.pro_id AND pp.user_id = auth.uid())
  );
CREATE POLICY "Pro can delete portfolio" ON public.portfolio_posts
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = portfolio_posts.pro_id AND pp.user_id = auth.uid())
  );

-- PORTFOLIO_LIKES
CREATE POLICY "Likes are public" ON public.portfolio_likes
  FOR SELECT USING (true);
CREATE POLICY "User can like" ON public.portfolio_likes
  FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "User can unlike own" ON public.portfolio_likes
  FOR DELETE USING (user_id = auth.uid());

-- MESSAGE_THREADS
CREATE POLICY "Participant can see thread" ON public.message_threads
  FOR SELECT USING (
    client_id = auth.uid() OR
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = message_threads.pro_id AND pp.user_id = auth.uid())
  );
CREATE POLICY "Participant can create thread" ON public.message_threads
  FOR INSERT WITH CHECK (client_id = auth.uid());
CREATE POLICY "Participant can update thread" ON public.message_threads
  FOR UPDATE USING (
    client_id = auth.uid() OR
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = message_threads.pro_id AND pp.user_id = auth.uid())
  );

-- MESSAGES
CREATE POLICY "Thread participant can read messages" ON public.messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.message_threads t
      LEFT JOIN public.pro_profiles pp ON pp.id = t.pro_id
      WHERE t.id = messages.thread_id
      AND (t.client_id = auth.uid() OR pp.user_id = auth.uid())
    )
  );
CREATE POLICY "Thread participant can send messages" ON public.messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.message_threads t
      LEFT JOIN public.pro_profiles pp ON pp.id = t.pro_id
      WHERE t.id = messages.thread_id
      AND (t.client_id = auth.uid() OR pp.user_id = auth.uid())
    )
  );

-- PROFILE_VIEWS
CREATE POLICY "Pro sees own views" ON public.profile_views
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.pro_profiles pp WHERE pp.id = profile_views.pro_id AND pp.user_id = auth.uid())
  );
CREATE POLICY "Anyone can log a view" ON public.profile_views
  FOR INSERT WITH CHECK (true);

-- FAVORITES
CREATE POLICY "User sees own favorites" ON public.favorites
  FOR SELECT USING (client_id = auth.uid());
CREATE POLICY "User can favorite" ON public.favorites
  FOR INSERT WITH CHECK (client_id = auth.uid());
CREATE POLICY "User can unfavorite" ON public.favorites
  FOR DELETE USING (client_id = auth.uid());

-- NOTIFICATIONS
CREATE POLICY "User sees own notifications" ON public.notifications
  FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "User can mark read" ON public.notifications
  FOR UPDATE USING (user_id = auth.uid());

-- ============================================================
-- ENABLE REALTIME ON MESSAGES
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;

-- ============================================================
-- STORAGE BUCKETS
-- ============================================================
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('covers', 'covers', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('portfolio', 'portfolio', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('chat-attachments', 'chat-attachments', false);

-- Storage policies: avatars
CREATE POLICY "Public read avatars" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "Owner upload avatar" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::TEXT);
CREATE POLICY "Owner update avatar" ON storage.objects FOR UPDATE USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::TEXT);
CREATE POLICY "Owner delete avatar" ON storage.objects FOR DELETE USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::TEXT);

-- Storage policies: covers
CREATE POLICY "Public read covers" ON storage.objects FOR SELECT USING (bucket_id = 'covers');
CREATE POLICY "Owner upload cover" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'covers' AND (storage.foldername(name))[1] = auth.uid()::TEXT);
CREATE POLICY "Owner update cover" ON storage.objects FOR UPDATE USING (bucket_id = 'covers' AND (storage.foldername(name))[1] = auth.uid()::TEXT);
CREATE POLICY "Owner delete cover" ON storage.objects FOR DELETE USING (bucket_id = 'covers' AND (storage.foldername(name))[1] = auth.uid()::TEXT);

-- Storage policies: portfolio
CREATE POLICY "Public read portfolio" ON storage.objects FOR SELECT USING (bucket_id = 'portfolio');
CREATE POLICY "Owner upload portfolio" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'portfolio' AND (storage.foldername(name))[1] = auth.uid()::TEXT);
CREATE POLICY "Owner update portfolio" ON storage.objects FOR UPDATE USING (bucket_id = 'portfolio' AND (storage.foldername(name))[1] = auth.uid()::TEXT);
CREATE POLICY "Owner delete portfolio" ON storage.objects FOR DELETE USING (bucket_id = 'portfolio' AND (storage.foldername(name))[1] = auth.uid()::TEXT);

-- Storage policies: chat-attachments (participant only)
CREATE POLICY "Thread participant read attachments" ON storage.objects FOR SELECT USING (
  bucket_id = 'chat-attachments' AND EXISTS (
    SELECT 1 FROM public.message_threads t
    LEFT JOIN public.pro_profiles pp ON pp.id = t.pro_id
    WHERE t.id::TEXT = (storage.foldername(name))[1]
    AND (t.client_id = auth.uid() OR pp.user_id = auth.uid())
  )
);
CREATE POLICY "Auth user upload attachment" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'chat-attachments' AND auth.uid() IS NOT NULL);
