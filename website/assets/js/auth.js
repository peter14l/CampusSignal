/**
 * CampusSignal — Supabase Auth & State Management Module
 * Production-ready standard vanilla ES6+ with @supabase/supabase-js v2
 */

// Supabase Configuration
const SUPABASE_URL = 'https://ksyvklijnkxfpiasncyr.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_VR_FIPoe9sLE4qGVLwF1tg_XW3Xuv9S';

// Global Supabase Client
let supabaseClient = null;

if (window.supabase) {
  supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true,
      storage: window.localStorage
    }
  });
} else {
  console.warn('Supabase SDK not yet loaded from CDN. Retrying on load...');
}

// Ensure getter
function getSupabase() {
  if (!supabaseClient && window.supabase) {
    supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
        storage: window.localStorage
      }
    });
  }
  return supabaseClient;
}

// Guest Demo User Key
const GUEST_STORAGE_KEY = 'cs_guest_user';
const SAVED_EVENTS_STORAGE_KEY = 'cs_saved_events';

// Default Demo User for Guest / Instant Preview Mode
const DEMO_GUEST_USER = {
  id: 'guest-demo-sxuk-2026',
  email: 'student.demo@sxuk.edu.in',
  college_email: 'student.demo@sxuk.edu.in',
  full_name: 'St. Xavier Student (Guest Preview)',
  branch: 'B.Tech in CSE',
  year: 3,
  interests: ['Hackathons', 'AI/ML', 'Internships', 'Workshops', 'Cloud/DevOps'],
  skills: ['Flutter', 'Python', 'React', 'FastAPI', 'UI/UX Design'],
  is_guest: true,
  metadata: {
    semester: 5,
    onboarding_completed: true,
    is_guest: true
  }
};

/**
 * Get current authenticated user (Supabase or Demo Guest)
 */
async function getCurrentUser() {
  const sb = getSupabase();
  if (sb) {
    try {
      const { data: { session }, error } = await sb.auth.getSession();
      if (session?.user) {
        return session.user;
      }
    } catch (e) {
      console.error('Error fetching session:', e);
    }
  }

  // Check guest fallback
  const guestData = localStorage.getItem(GUEST_STORAGE_KEY);
  if (guestData) {
    try {
      return JSON.parse(guestData);
    } catch (e) {
      localStorage.removeItem(GUEST_STORAGE_KEY);
    }
  }

  return null;
}

/**
 * Fetch Profile from `public.profiles` or fallback
 */
async function getUserProfile(userId) {
  if (!userId) return null;
  
  if (userId === DEMO_GUEST_USER.id) {
    const guestData = localStorage.getItem(GUEST_STORAGE_KEY);
    return guestData ? JSON.parse(guestData) : DEMO_GUEST_USER;
  }

  const sb = getSupabase();
  if (!sb) return null;

  try {
    const { data, error } = await sb
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .maybeSingle();

    if (error) {
      console.warn('Could not fetch remote profile:', error.message);
    }
    return data || null;
  } catch (e) {
    console.error('Error querying profile table:', e);
    return null;
  }
}

/**
 * Upsert/Update user profile
 */
async function saveUserProfile(profileData) {
  const currentUser = await getCurrentUser();
  if (!currentUser) throw new Error('Not authenticated');

  // If Guest mode, save to localStorage
  if (currentUser.is_guest || currentUser.id === DEMO_GUEST_USER.id) {
    const updatedGuest = {
      ...DEMO_GUEST_USER,
      ...profileData,
      id: DEMO_GUEST_USER.id,
      is_guest: true,
      metadata: {
        ...(DEMO_GUEST_USER.metadata || {}),
        ...(profileData.metadata || {}),
        onboarding_completed: true
      }
    };
    localStorage.setItem(GUEST_STORAGE_KEY, JSON.stringify(updatedGuest));
    return updatedGuest;
  }

  const sb = getSupabase();
  if (!sb) throw new Error('Supabase client unavailable');

  const payload = {
    id: currentUser.id,
    full_name: profileData.full_name || currentUser.user_metadata?.full_name || currentUser.email?.split('@')[0] || 'SXUK Student',
    college_email: profileData.college_email || currentUser.email || '',
    branch: profileData.branch || null,
    year: profileData.year || (profileData.metadata?.semester ? Math.ceil(profileData.metadata.semester / 2) : 1),
    interests: profileData.interests || [],
    skills: profileData.skills || [],
    metadata: {
      ...(currentUser.user_metadata || {}),
      ...(profileData.metadata || {}),
      semester: profileData.metadata?.semester || (profileData.year ? (profileData.year * 2 - 1) : 1),
      onboarding_completed: true,
      updated_at: new Date().toISOString()
    },
    updated_at: new Date().toISOString()
  };

  const { data, error } = await sb
    .from('profiles')
    .upsert(payload, { onConflict: 'id' })
    .select()
    .single();

  if (error) {
    console.error('Supabase profile upsert error:', error);
    // Cache locally as backup so flow never breaks
    localStorage.setItem(`cs_cached_profile_${currentUser.id}`, JSON.stringify(payload));
    return payload;
  }

  return data;
}

/**
 * Login with Google OAuth
 */
async function signInWithGoogle() {
  const sb = getSupabase();
  if (!sb) throw new Error('Supabase client not initialized');

  // Google OAuth requires http:// or https:// protocol (cannot redirect to file://)
  if (window.location.protocol === 'file:') {
    throw new Error('Google OAuth requires a local web server (http://localhost:5500 or http://localhost:8080). Open via Live Server or use "Guest Demo Preview Mode" below to test immediately.');
  }

  // Compute exact return URL to current origin + path
  const currentOrigin = window.location.origin;
  const currentPath = window.location.pathname.replace(/\\/g, '/');
  
  let targetPath = '/app/index.html';
  if (currentPath.includes('/CampusSignal/website/')) {
    targetPath = '/CampusSignal/website/app/index.html';
  } else if (currentPath.includes('/CampusSignal/')) {
    targetPath = '/CampusSignal/app/index.html';
  } else if (currentPath.includes('/website/')) {
    targetPath = '/website/app/index.html';
  }

  const redirectUrl = `${currentOrigin}${targetPath}`;

  const { data, error } = await sb.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: redirectUrl,
      queryParams: {
        access_type: 'offline',
        prompt: 'consent'
      }
    }
  });

  if (error) throw error;
  return data;
}

/**
 * Sign in / Sign up with Email OTP or Magic Link
 */
async function sendOtpMagicLink(email) {
  const sb = getSupabase();
  if (!sb) throw new Error('Supabase client not initialized');

  const redirectUrl = new URL('/app/', window.location.origin).href;

  const { data, error } = await sb.auth.signInWithOtp({
    email: email.trim(),
    options: {
      emailRedirectTo: redirectUrl,
      shouldCreateUser: true
    }
  });

  if (error) throw error;
  return data;
}

/**
 * Verify OTP Code
 */
async function verifyOtpCode(email, token) {
  const sb = getSupabase();
  if (!sb) throw new Error('Supabase client not initialized');

  const { data, error } = await sb.auth.verifyOtp({
    email: email.trim(),
    token: token.trim(),
    type: 'email'
  });

  if (error) throw error;
  return data;
}

/**
 * Activate Instant Guest Preview Mode
 */
function enterGuestMode() {
  localStorage.setItem(GUEST_STORAGE_KEY, JSON.stringify(DEMO_GUEST_USER));
  window.location.href = '../app/index.html';
}

/**
 * Sign Out
 */
async function signOutUser() {
  localStorage.removeItem(GUEST_STORAGE_KEY);
  const sb = getSupabase();
  if (sb) {
    try {
      await sb.auth.signOut();
    } catch (e) {
      console.warn('Sign out error:', e);
    }
  }
  // Redirect to Auth or Root
  window.location.href = '../auth/index.html';
}

/**
 * Auth Guard for Protected Pages (e.g. /app/*, /onboarding/*)
 */
async function requireAuth(options = { requireCompleteOnboarding: true }) {
  const user = await getCurrentUser();
  const currentPath = window.location.pathname;

  if (!user) {
    // Save target path for post-login redirect
    sessionStorage.setItem('cs_auth_redirect', window.location.href);
    // Find relative path to auth
    const authPath = currentPath.includes('/app/') || currentPath.includes('/onboarding/') 
      ? '../auth/index.html' 
      : './auth/index.html';
    window.location.href = authPath;
    return null;
  }

  // Check Onboarding state
  if (options.requireCompleteOnboarding) {
    let profile = await getUserProfile(user.id);
    if (!profile) {
      const cached = localStorage.getItem(`cs_cached_profile_${user.id}`);
      if (cached) profile = JSON.parse(cached);
    }

    const isComplete = profile?.branch && (profile?.metadata?.onboarding_completed || profile?.year);

    if (!isComplete && !currentPath.includes('/onboarding/')) {
      const onboardingPath = currentPath.includes('/app/') ? '../onboarding/index.html' : './onboarding/index.html';
      window.location.href = onboardingPath;
      return null;
    }
  }

  return user;
}

/**
 * Post-Login Routing Logic
 */
async function handlePostLoginRedirect() {
  const user = await getCurrentUser();
  if (!user) return;

  const profile = await getUserProfile(user.id);
  const isComplete = profile?.branch && (profile?.metadata?.onboarding_completed || profile?.year);

  const customRedirect = sessionStorage.getItem('cs_auth_redirect');
  sessionStorage.removeItem('cs_auth_redirect');

  if (!isComplete) {
    window.location.href = '../onboarding/index.html';
  } else if (customRedirect && !customRedirect.includes('/auth/')) {
    window.location.href = customRedirect;
  } else {
    window.location.href = '../app/index.html';
  }
}

/**
 * Check if a user is in Demo / Guest mode
 */
function isDemoUser(user) {
  return !user || user.is_guest === true || user.id === DEMO_GUEST_USER.id;
}

/**
 * Saved / Bookmarked Events Helpers (User-scoped in Supabase or LocalStorage)
 */
function getSavedEventIds(user) {
  try {
    const isGuest = isDemoUser(user);
    const key = isGuest ? SAVED_EVENTS_STORAGE_KEY : `${SAVED_EVENTS_STORAGE_KEY}_${user?.id || 'anon'}`;
    const saved = localStorage.getItem(key);
    if (saved) return JSON.parse(saved);
    return isGuest ? ['ev-1', 'ev-2'] : [];
  } catch (e) {
    return [];
  }
}

function toggleSaveEvent(eventId, user) {
  const isGuest = isDemoUser(user);
  const key = isGuest ? SAVED_EVENTS_STORAGE_KEY : `${SAVED_EVENTS_STORAGE_KEY}_${user?.id || 'anon'}`;
  const savedIds = getSavedEventIds(user);
  const index = savedIds.indexOf(eventId);
  let isSaved = false;

  if (index > -1) {
    savedIds.splice(index, 1);
    isSaved = false;
  } else {
    savedIds.push(eventId);
    isSaved = true;
  }

  localStorage.setItem(key, JSON.stringify(savedIds));

  // Sync with Supabase saves/user_actions if real user
  const sb = getSupabase();
  if (user && !isGuest && sb) {
    if (isSaved) {
      sb.from('saves').insert({
        user_id: user.id,
        event_id: eventId,
        saved_at: new Date().toISOString()
      }).catch(err => console.warn('Save sync note:', err.message));
    } else {
      sb.from('saves').delete()
        .eq('user_id', user.id)
        .eq('event_id', eventId)
        .catch(err => console.warn('Unsave sync note:', err.message));
    }
  }

  return isSaved;
}

function isEventSaved(eventId, user) {
  const saved = getSavedEventIds(user);
  return saved.includes(eventId);
}

// Export to window object for vanilla ES6+ usage across scripts
window.CS_AUTH = {
  getSupabase,
  getCurrentUser,
  getUserProfile,
  saveUserProfile,
  signInWithGoogle,
  sendOtpMagicLink,
  verifyOtpCode,
  enterGuestMode,
  signOutUser,
  requireAuth,
  handlePostLoginRedirect,
  isDemoUser,
  getSavedEventIds,
  toggleSaveEvent,
  isEventSaved,
  DEMO_GUEST_USER
};
