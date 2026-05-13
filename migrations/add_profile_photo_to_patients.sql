-- Add profile_photo_url column to patients table
ALTER TABLE public.patients
ADD COLUMN profile_photo_url text null;

-- Add sertifikat_urls column to fisioterapis table
ALTER TABLE public.fisioterapis
ADD COLUMN sertifikat_urls text null;
