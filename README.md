# GetFROM Working Platform V6

This version is a working static web platform connected to Supabase.

## Working features
- Supabase Login/Register
- User-owned apps saved in database
- Template -> real app creation
- AI-style prompt based app generation (rule-based, no paid AI API required)
- Visual page/component editor
- Save and Publish
- Public published app URL
- Working public form submission
- Submission inbox
- Role-based Super Admin page
- Supabase RLS SQL

## Setup
1. In Supabase SQL Editor run `supabase/GetFROM-WORKING.sql`.
2. Make sure Email/Password auth is enabled.
3. Upload all files to a GitHub repository.
4. Enable GitHub Pages.
5. Register your account.
6. Set your first account role to `super_admin` using the SQL comment at the end.

## Important
The AI Creator in this ZIP is rule-based generation so it works without exposing a paid AI API key in the browser.
For true OpenAI-powered generation, use a secure Supabase Edge Function/API backend.