-- ============================================================
-- PERBAIKAN: RLS Policy untuk tabel notifications
-- Jalankan di Supabase SQL Editor
-- ============================================================

-- 1. Pastikan RLS enabled pada tabel notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- 2. Hapus policy lama yang mungkin terlalu ketat
DROP POLICY IF EXISTS "Users dapat melihat notifikasi mereka sendiri" ON notifications;
DROP POLICY IF EXISTS "Users dapat insert notifikasi" ON notifications;
DROP POLICY IF EXISTS "Users dapat update notifikasi" ON notifications;
DROP POLICY IF EXISTS "Service role dapat insert notifikasi" ON notifications;

-- 3. CREATE policy untuk SELECT (users bisa lihat notifikasi mereka saja)
CREATE POLICY "Users dapat melihat notifikasi mereka sendiri"
ON notifications
FOR SELECT
USING (auth.uid() = user_id);

-- 4. CREATE policy untuk INSERT dari SECURITY DEFINER functions & service role
--    PENTING: Policy ini memungkinkan trigger untuk insert notifikasi
CREATE POLICY "Sistem dapat insert notifikasi"
ON notifications
FOR INSERT
WITH CHECK (true);

-- 5. CREATE policy untuk UPDATE (users bisa update notifikasi mereka saja)
CREATE POLICY "Users dapat update notifikasi mereka sendiri"
ON notifications
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 6. CREATE policy untuk DELETE (users bisa delete notifikasi mereka saja)
CREATE POLICY "Users dapat delete notifikasi mereka sendiri"
ON notifications
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================================
-- VERIFIKASI
-- ============================================================
-- Jalankan query ini untuk memastikan policies sudah benar:
-- SELECT schemaname, tablename, policyname, permissive, roles, qual, with_check 
-- FROM pg_policies 
-- WHERE tablename = 'notifications';
