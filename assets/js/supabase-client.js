const { createClient } = supabase;
window.sb = createClient(window.GETFROM_SUPABASE_URL, window.GETFROM_SUPABASE_KEY);
