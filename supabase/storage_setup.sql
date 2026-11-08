-- ====================================================================
-- SECOND SHELF - Supabase Storage Buckets & Policies Setup
-- ====================================================================

-- 1. Create Public Storage Buckets for Book Photos and Scrap Photos
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('book-photos', 'book-photos', true),
  ('scrap-photos', 'scrap-photos', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Storage RLS Policies for Book Photos
CREATE POLICY "Public Read Book Photos"
ON storage.objects FOR SELECT
USING (bucket_id = 'book-photos');

CREATE POLICY "Authenticated Upload Book Photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'book-photos');

CREATE POLICY "Users Update Own Book Photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'book-photos' AND auth.uid()::text = (storage.foldername(name))[1]);

-- 3. Storage RLS Policies for Scrap Photos
CREATE POLICY "Public Read Scrap Photos"
ON storage.objects FOR SELECT
USING (bucket_id = 'scrap-photos');

CREATE POLICY "Authenticated Upload Scrap Photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'scrap-photos');

CREATE POLICY "Users Update Own Scrap Photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'scrap-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
