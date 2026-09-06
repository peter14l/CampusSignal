/**
 * CampusSignal — Official Showcase Website
 * Modern Vanilla JS + GSAP Micro-Interactions + Dynamic APK Matrix
 */

document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initMobileNav();
  initVersionData();
  initOpportunityFeed();
  initOcrSimulator();
  initFaqAccordion();
  initCopyButtons();
  initScrollAnimations();
  initArchDetector();
});

/* ==========================================================================
   1. Theme Management (Dark / Light with LocalStorage Persistence)
   ========================================================================== */
function initTheme() {
  const themeToggleBtns = document.querySelectorAll('.theme-toggle');
  const savedTheme = localStorage.getItem('cs_theme');
  const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

  const currentTheme = savedTheme || (systemPrefersDark ? 'dark' : 'dark');
  document.documentElement.setAttribute('data-theme', currentTheme);
  updateThemeIcons(currentTheme);

  themeToggleBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const activeTheme = document.documentElement.getAttribute('data-theme');
      const newTheme = activeTheme === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', newTheme);
      localStorage.setItem('cs_theme', newTheme);
      updateThemeIcons(newTheme);
    });
  });
}

function updateThemeIcons(theme) {
  const themeToggles = document.querySelectorAll('.theme-toggle');
  themeToggles.forEach(btn => {
    if (theme === 'dark') {
      btn.innerHTML = '<i data-lucide="sun" style="width:20px;height:20px;"></i>';
      btn.setAttribute('aria-label', 'Switch to Light Mode');
    } else {
      btn.innerHTML = '<i data-lucide="moon" style="width:20px;height:20px;"></i>';
      btn.setAttribute('aria-label', 'Switch to Dark Mode');
    }
  });
  if (window.lucide) {
    window.lucide.createIcons();
  }
}

/* ==========================================================================
   2. Mobile Navigation Drawer
   ========================================================================== */
function initMobileNav() {
  const menuToggle = document.querySelector('.menu-toggle');
  const mobileDrawer = document.querySelector('.mobile-drawer');
  const drawerOverlay = document.querySelector('.drawer-overlay');
  const drawerClose = document.querySelector('.drawer-close');
  const drawerLinks = document.querySelectorAll('.drawer-link');

  if (!menuToggle || !mobileDrawer) return;

  function openDrawer() {
    mobileDrawer.classList.add('open');
    if (drawerOverlay) drawerOverlay.classList.add('active');
    document.body.style.overflow = 'hidden';
  }

  function closeDrawer() {
    mobileDrawer.classList.remove('open');
    if (drawerOverlay) drawerOverlay.classList.remove('active');
    document.body.style.overflow = '';
  }

  menuToggle.addEventListener('click', openDrawer);
  if (drawerClose) drawerClose.addEventListener('click', closeDrawer);
  if (drawerOverlay) drawerOverlay.addEventListener('click', closeDrawer);

  drawerLinks.forEach(link => {
    link.addEventListener('click', closeDrawer);
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && mobileDrawer.classList.contains('open')) {
      closeDrawer();
    }
  });
}

/* ==========================================================================
   3. Dynamic Version & Release Notes Fetcher
   ========================================================================== */
const DEFAULT_VERSION_DATA = {
  version: "1.0.9",
  versionCode: 10,
  apkUrl: "https://pub-a56b2096b15c42f3b81606f43267e8c8.r2.dev/updates/CampusSignal-v1.0.9.apk",
  archApkUrls: {
    "arm64-v8a": "https://pub-a56b2096b15c42f3b81606f43267e8c8.r2.dev/updates/CampusSignal-v1.0.9-arm64-v8a.apk",
    "armeabi-v7a": "https://pub-a56b2096b15c42f3b81606f43267e8c8.r2.dev/updates/CampusSignal-v1.0.9-armeabi-v7a.apk",
    "x86_64": "https://pub-a56b2096b15c42f3b81606f43267e8c8.r2.dev/updates/CampusSignal-v1.0.9-x86_64.apk",
    "universal": "https://pub-a56b2096b15c42f3b81606f43267e8c8.r2.dev/updates/CampusSignal-v1.0.9.apk"
  },
  archSizes: {
    "arm64-v8a": "29.4 MB",
    "armeabi-v7a": "27.1 MB",
    "x86_64": "30.9 MB",
    "universal": "67.4 MB"
  },
  sha256: {
    "arm64-v8a": "c433f7a4f059e0a5756cc5ce3ac8e8383ad4e4c83ad574ebfb70f9343f346ff1",
    "armeabi-v7a": "e6bef9f6c92601463b021538c0e48aa4f04c3729f8d395e89accc6b13b58aa57",
    "x86_64": "7821c83c729120899a13f9032f519369291df09d3839cb51ed612a3389198017",
    "universal": "66706954f4c322317cf4a52ec47e240fb28df6b2f96544a52845b7d0766e525e"
  },
  publishedAt: "2026-09-06",
  releaseNotes: "• Integrated animated Lottie hero illustration on Login & Sign-up screen\n• Cleaned email input placeholders without OTP clutter\n• Fixed Saved & Bookmarks screen to reactively bind to user's real saved items and reminders\n• Public published campus signals fetching support without auth barriers\n• Premium Material 3 makeover modal sheets for Sign Out and Clear Local Cache\n• Unified v1.0.9 (Build 10) stability release"
};

async function initVersionData() {
  let versionData = DEFAULT_VERSION_DATA;
  const pathsToTry = [
    './updates/version.json',
    '../updates/version.json',
    '/updates/version.json'
  ];

  for (const path of pathsToTry) {
    try {
      const res = await fetch(path);
      if (res.ok) {
        versionData = await res.json();
        break;
      }
    } catch (e) {
      // fallback smoothly
    }
  }

  // Update dynamic elements
  document.querySelectorAll('.app-version-text').forEach(el => {
    el.textContent = `v${versionData.version}`;
  });

  document.querySelectorAll('.app-version-badge').forEach(el => {
    el.textContent = `v${versionData.version} (Build ${versionData.versionCode})`;
  });

  const downloadArm64 = document.getElementById('btn-download-arm64');
  if (downloadArm64 && versionData.archApkUrls && versionData.archApkUrls['arm64-v8a']) {
    downloadArm64.href = versionData.archApkUrls['arm64-v8a'];
  }

  const downloadUniversal = document.getElementById('btn-download-universal');
  if (downloadUniversal && versionData.apkUrl) {
    downloadUniversal.href = versionData.apkUrl;
  }

  // Update Download Matrix Links if present
  Object.keys(versionData.archApkUrls || {}).forEach(arch => {
    const link = document.querySelector(`.apk-download-link[data-arch="${arch}"]`);
    if (link) {
      link.href = versionData.archApkUrls[arch];
    }
    const sizeEl = document.querySelector(`.apk-size-val[data-arch="${arch}"]`);
    if (sizeEl && versionData.archSizes && versionData.archSizes[arch]) {
      sizeEl.textContent = versionData.archSizes[arch];
    }
    const shaEl = document.querySelector(`.sha-val[data-arch="${arch}"]`);
    if (shaEl && versionData.sha256 && versionData.sha256[arch]) {
      shaEl.textContent = versionData.sha256[arch];
    }
  });
}

/* ==========================================================================
   4. Live Opportunity Feed Simulator
   ========================================================================== */
const SAMPLE_EVENTS = [
  {
    id: 'ev-1',
    title: 'SXUK GenAI Hackathon 2026: Multimodal Agent Challenge',
    category: 'hackathon',
    categoryLabel: 'Hackathon',
    organizer: 'Dept. of Computer Science & ACM Student Chapter',
    deadline: 'In 3 days (Sept 8)',
    date: 'Sept 12 - 14, 2026',
    venue: 'Fr. Beckers Block, Lab 402',
    eligibility: 'B.Tech CSE/AI, B.Sc Data Science, M.Sc CS',
    prize: '₹75,000 Cash Pool + Cloud Credits',
    tags: ['Gemini 2.5', 'Flutter', 'FastAPI', 'Agentic AI']
  },
  {
    id: 'ev-2',
    title: 'EY Global Delivery Services: Campus Summer Internship 2027',
    category: 'internship',
    categoryLabel: 'Internship',
    organizer: 'University Placement Cell & EY GDS',
    deadline: 'In 5 days (Sept 10)',
    date: 'Summer 2027 (Stipend ₹45,000/mo)',
    venue: 'St. Xavier’s University Kolkata Campus',
    eligibility: 'B.Com, B.M.S, B.Tech (3rd Year Students)',
    prize: 'Pre-Placement Interview (PPI) Offer',
    tags: ['Audit', 'Analytics', 'Finance', 'Consulting']
  },
  {
    id: 'ev-3',
    title: 'Hands-On Flutter & M3E UI Engineering Workshop',
    category: 'workshop',
    categoryLabel: 'Workshop',
    organizer: 'Google Developer Student Club (GDSC SXUK)',
    deadline: 'In 24 hours',
    date: 'Sept 7, 2026 • 2:00 PM',
    venue: 'Seminar Hall 2, Academic Block',
    eligibility: 'Open to All 28 SXUK Degree Programmes',
    prize: 'Official Certificate & Swag Kit',
    tags: ['Flutter', 'Material 3', 'Riverpod', 'Mobile Dev']
  },
  {
    id: 'ev-4',
    title: 'Xavotsav 2026: Annual Inter-College Cultural Fest',
    category: 'fest',
    categoryLabel: 'Fest',
    organizer: 'SXUK Student Council & Cultural Committee',
    deadline: 'Sept 15, 2026',
    date: 'Sept 25 - 27, 2026',
    venue: 'University Central Ground & Main Auditorium',
    eligibility: 'All SXUK UG & PG Students & External Colleges',
    prize: 'Trophies & ₹2,00,000 Total Prizes',
    tags: ['Battle of Bands', 'Fashion', 'Dance', 'Dramatics']
  },
  {
    id: 'ev-5',
    title: 'National Economics & Data Analytics Colloquium',
    category: 'seminar',
    categoryLabel: 'Seminar',
    organizer: 'Faculty of Arts & Humanities (Economics Dept)',
    deadline: 'Sept 18, 2026',
    date: 'Sept 22, 2026 • 10:30 AM',
    venue: 'Conference Hall A',
    eligibility: 'B.A. / M.A. Economics, B.Sc. Statistics',
    prize: 'Publication in University Journal',
    tags: ['Macroeconomics', 'R & Python', 'Public Policy']
  },
  {
    id: 'ev-6',
    title: 'St. Xavier’s National Moot Court Competition 2026',
    category: 'fest',
    categoryLabel: 'Competition',
    organizer: 'Xavier Law School (XLS) Moot Society',
    deadline: 'Sept 20, 2026',
    date: 'Oct 03 - 05, 2026',
    venue: 'Moot Court Hall, Law Block',
    eligibility: 'LL.B. & LL.M. Law Students',
    prize: '₹50,000 + Internship at Supreme Court Chamber',
    tags: ['Constitutional Law', 'Litigation', 'Advocacy']
  }
];

function initOpportunityFeed() {
  const feedGrid = document.getElementById('sim-feed-grid');
  const filterPills = document.querySelectorAll('.filter-pill');
  const searchInput = document.getElementById('sim-search-input');

  if (!feedGrid) return;

  let activeCategory = 'all';
  let searchQuery = '';

  function renderFeed() {
    const filtered = SAMPLE_EVENTS.filter(event => {
      const matchCat = activeCategory === 'all' || event.category === activeCategory;
      const matchQuery = searchQuery === '' ||
        event.title.toLowerCase().includes(searchQuery) ||
        event.organizer.toLowerCase().includes(searchQuery) ||
        event.eligibility.toLowerCase().includes(searchQuery) ||
        event.tags.some(t => t.toLowerCase().includes(searchQuery));
      return matchCat && matchQuery;
    });

    if (filtered.length === 0) {
      feedGrid.innerHTML = `
        <div style="grid-column: 1 / -1; text-align: center; padding: 48px 16px; color: var(--text-secondary);">
          <i data-lucide="search-x" style="width: 44px; height: 44px; margin: 0 auto 12px; color: var(--text-muted);"></i>
          <p style="font-weight: 600; font-size: 1.1rem; color: var(--text-primary);">No matching campus signals found</p>
          <p style="font-size: 0.875rem;">Try refining your search keyword or selecting a different category filter.</p>
        </div>
      `;
      if (window.lucide) window.lucide.createIcons();
      return;
    }

    feedGrid.innerHTML = filtered.map(ev => `
      <div class="sim-event-card" data-id="${ev.id}">
        <div class="sim-card-top">
          <span class="category-chip ${ev.category}">${ev.categoryLabel}</span>
          <span class="deadline-pill">
            <i data-lucide="clock" style="width:14px;height:14px;"></i>
            ${ev.deadline}
          </span>
        </div>
        <div>
          <h3 class="sim-card-title">${ev.title}</h3>
          <p class="sim-card-org">${ev.organizer}</p>
        </div>
        <div class="sim-card-details">
          <div class="detail-row">
            <i data-lucide="calendar" style="width:15px;height:15px;color:var(--primary);"></i>
            <span>${ev.date}</span>
          </div>
          <div class="detail-row">
            <i data-lucide="map-pin" style="width:15px;height:15px;color:var(--accent-amber);"></i>
            <span>${ev.venue}</span>
          </div>
          <div class="detail-row">
            <i data-lucide="graduation-cap" style="width:15px;height:15px;color:var(--emerald);"></i>
            <span>${ev.eligibility}</span>
          </div>
        </div>
        <div class="feature-tag-list" style="margin-top: 4px;">
          ${ev.tags.map(t => `<span class="feature-tag">#${t}</span>`).join('')}
        </div>
        <div class="sim-card-footer">
          <span style="font-size: 0.8125rem; font-weight: 700; color: var(--accent-amber); font-family: var(--font-mono);">${ev.prize}</span>
          <button class="btn btn-sm btn-primary save-btn" data-id="${ev.id}" title="Save to Campus Calendar">
            <i data-lucide="bookmark" style="width:14px;height:14px;"></i> Save
          </button>
        </div>
      </div>
    `).join('');

    if (window.lucide) window.lucide.createIcons();

    // Attach bookmark handlers
    document.querySelectorAll('.save-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const icon = btn.querySelector('svg') || btn.querySelector('i');
        const isSaved = btn.classList.toggle('btn-accent');
        btn.classList.toggle('btn-primary');
        btn.innerHTML = isSaved 
          ? '<i data-lucide="bookmark-check" style="width:14px;height:14px;"></i> Saved' 
          : '<i data-lucide="bookmark" style="width:14px;height:14px;"></i> Save';
        if (window.lucide) window.lucide.createIcons();
      });
    });
  }

  filterPills.forEach(pill => {
    pill.addEventListener('click', () => {
      filterPills.forEach(p => p.classList.remove('active'));
      pill.classList.add('active');
      activeCategory = pill.getAttribute('data-category');
      renderFeed();
    });
  });

  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      searchQuery = e.target.value.toLowerCase().trim();
      renderFeed();
    });
  }

  renderFeed();
}

/* ==========================================================================
   5. Multimodal Vision OCR Scanner Simulator
   ========================================================================== */
const OCR_PRESETS = {
  hackathon: {
    raw: `ST. XAVIER'S UNIVERSITY, KOLKATA
Department of Computer Science & ACM Student Chapter
PRESENTS
"SXUK GenAI Hackathon 2026"
Themes: Agentic Workflows, Education Tech, Multimodal Search
Date: September 12-14, 2026
Venue: Fr. Beckers Block Lab 402
Registration Deadline: September 08, 2026 11:59 PM IST
Eligibility: B.Tech (CSE, AI&ML, ECE, IT), B.Sc Statistics & Data Science, M.Sc CS
Prize Pool: INR 75,000 Cash + AWS/Google Cloud Credits
Apply Link: https://forms.sxuk.edu.in/genai-hackathon-2026
Contact: acm@sxuk.edu.in`,
    json: {
      "title": "SXUK GenAI Hackathon 2026",
      "category": "hackathon",
      "organizer": "Dept. of Computer Science & ACM Student Chapter",
      "starts_at": "2026-09-12T09:00:00+05:30",
      "ends_at": "2026-09-14T18:00:00+05:30",
      "deadline_at": "2026-09-08T23:59:59+05:30",
      "venue": "Fr. Beckers Block Lab 402",
      "format": "in_person",
      "eligibility": ["B.Tech in CSE", "B.Tech in AI & ML", "B.Sc. Data Science", "M.Sc. CS"],
      "prize_pool": "INR 75,000 Cash + Cloud Credits",
      "apply_url": "https://forms.sxuk.edu.in/genai-hackathon-2026",
      "ocr_confidence": 0.994,
      "calendar_alarm_triggers": ["-24h", "-2h"]
    }
  },
  internship: {
    raw: `CAMPUS PLACEMENT NOTICE 2026-27
ERNST & YOUNG (EY GDS)
Opportunity: Global Tax & Technology Internship
Target Batch: 2027 Graduating Class
Eligibility: B.Com (Hons), B.M.S, B.Tech CSE (Min 7.0 CGPA)
Stipend: INR 45,000 / month + PPI Opportunity
Application Closes: September 10, 2026
Selection: Online Assessment -> Technical Interview -> HR Round
Venue: University Career Center & Online Portal`,
    json: {
      "title": "EY Global Delivery Services Tax & Tech Internship",
      "category": "internship",
      "organizer": "University Placement Cell & EY GDS",
      "starts_at": "2027-05-01T09:00:00+05:30",
      "deadline_at": "2026-09-10T17:00:00+05:30",
      "venue": "University Career Center & Online Portal",
      "eligibility": ["B.Com. (Honours)", "B.M.S. (Honours)", "B.Tech in CSE"],
      "stipend": "INR 45,000 / month",
      "ocr_confidence": 0.988,
      "calendar_alarm_triggers": ["-24h", "-2h"]
    }
  }
};

function initOcrSimulator() {
  const triggerBtn = document.getElementById('btn-run-ocr');
  const flyerContainer = document.getElementById('flyer-preview-box');
  const rawFlyerText = document.getElementById('ocr-raw-text');
  const parsedJsonOutput = document.getElementById('ocr-json-output');
  const flyerSelectBtns = document.querySelectorAll('.flyer-preset-btn');

  if (!triggerBtn || !parsedJsonOutput) return;

  let currentPreset = 'hackathon';

  flyerSelectBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      flyerSelectBtns.forEach(b => b.classList.remove('btn-primary'));
      flyerSelectBtns.forEach(b => b.classList.add('btn-secondary'));
      btn.classList.remove('btn-secondary');
      btn.classList.add('btn-primary');

      currentPreset = btn.getAttribute('data-preset');
      if (rawFlyerText) {
        rawFlyerText.textContent = OCR_PRESETS[currentPreset].raw;
      }
      parsedJsonOutput.innerHTML = `<span style="color:var(--text-muted)">// Click "Analyze with Gemini 2.5 Vision" to trigger multimodal parsing</span>`;
    });
  });

  triggerBtn.addEventListener('click', () => {
    if (flyerContainer) flyerContainer.classList.add('scanning');
    triggerBtn.disabled = true;
    triggerBtn.innerHTML = `<i data-lucide="loader-2" class="spin" style="width:16px;height:16px;"></i> Scanning Flyer with Gemini 2.5...`;
    if (window.lucide) window.lucide.createIcons();

    parsedJsonOutput.innerHTML = `<span style="color:var(--accent-amber)">Processing multimodal vision tokens... Extracting structured SXUK schema...</span>`;

    setTimeout(() => {
      if (flyerContainer) flyerContainer.classList.remove('scanning');
      triggerBtn.disabled = false;
      triggerBtn.innerHTML = `<i data-lucide="sparkles" style="width:16px;height:16px;"></i> Re-Scan Flyer`;
      
      const formattedJson = JSON.stringify(OCR_PRESETS[currentPreset].json, null, 2);
      parsedJsonOutput.innerHTML = `<pre style="color:var(--emerald); margin:0;">${syntaxHighlightJson(formattedJson)}</pre>`;
      if (window.lucide) window.lucide.createIcons();
    }, 1200);
  });
}

function syntaxHighlightJson(jsonStr) {
  return jsonStr
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
      let cls = 'color: #93C5FD;'; // string default
      if (/^"/.test(match)) {
        if (/:$/.test(match)) {
          cls = 'color: #F59E0B; font-weight: 600;'; // key
        } else {
          cls = 'color: #34D399;'; // string value
        }
      } else if (/true|false/.test(match)) {
        cls = 'color: #F43F5E;'; // boolean
      } else if (/null/.test(match)) {
        cls = 'color: #A78BFA;';
      } else {
        cls = 'color: #FBBF24;'; // number
      }
      return '<span style="' + cls + '">' + match + '</span>';
    });
}

/* ==========================================================================
   6. Architecture & System Detection
   ========================================================================== */
function initArchDetector() {
  const detectedBadge = document.getElementById('detected-arch-badge');
  if (!detectedBadge) return;

  const ua = navigator.userAgent.toLowerCase();
  let archGuess = 'arm64-v8a';
  let deviceName = 'Android 64-bit Device';

  if (ua.includes('x86_64') || ua.includes('win64') || ua.includes('wow64') || ua.includes('x64')) {
    archGuess = 'x86_64';
    deviceName = 'x86_64 Emulator / Desktop';
  } else if (ua.includes('armv7') || ua.includes('armeabi')) {
    archGuess = 'armeabi-v7a';
    deviceName = 'Android 32-bit Legacy Device';
  } else if (ua.includes('android')) {
    archGuess = 'arm64-v8a';
    deviceName = 'Android ARM64 (Modern Smartphone)';
  } else {
    archGuess = 'arm64-v8a';
    deviceName = 'Recommended: Android ARM64';
  }

  detectedBadge.innerHTML = `<i data-lucide="cpu" style="width:14px;height:14px;"></i> Detected: <strong>${deviceName}</strong>`;

  // Highlight recommended card
  const recommendedCard = document.querySelector(`.apk-card[data-arch="${archGuess}"]`);
  if (recommendedCard) {
    document.querySelectorAll('.apk-card').forEach(c => c.classList.remove('recommended'));
    recommendedCard.classList.add('recommended');
  }

  if (window.lucide) window.lucide.createIcons();
}

/* ==========================================================================
   7. Copy to Clipboard Utility
   ========================================================================== */
function initCopyButtons() {
  document.querySelectorAll('.copy-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const targetSelector = btn.getAttribute('data-copy-target');
      const targetEl = document.querySelector(targetSelector);
      if (!targetEl) return;

      const text = targetEl.textContent.trim();
      navigator.clipboard.writeText(text).then(() => {
        const origHtml = btn.innerHTML;
        btn.innerHTML = `<i data-lucide="check" style="width:14px;height:14px;color:var(--emerald);"></i> Copied!`;
        if (window.lucide) window.lucide.createIcons();
        setTimeout(() => {
          btn.innerHTML = origHtml;
          if (window.lucide) window.lucide.createIcons();
        }, 2000);
      });
    });
  });
}

/* ==========================================================================
   8. FAQ Accordion
   ========================================================================== */
function initFaqAccordion() {
  const faqItems = document.querySelectorAll('.faq-item');
  faqItems.forEach(item => {
    const questionBtn = item.querySelector('.faq-question');
    if (!questionBtn) return;

    questionBtn.addEventListener('click', () => {
      const isActive = item.classList.contains('active');
      faqItems.forEach(i => i.classList.remove('active'));
      if (!isActive) {
        item.classList.add('active');
      }
    });
  });
}

/* ==========================================================================
   9. GSAP Micro-Interactions & Scroll Triggers
   ========================================================================== */
function initScrollAnimations() {
  if (typeof gsap === 'undefined') return;

  // Simple entrance animations for hero elements
  gsap.from('.hero-content > *', {
    y: 24,
    opacity: 0,
    duration: 0.8,
    stagger: 0.12,
    ease: 'power3.out'
  });

  gsap.from('.hero-mockup-wrapper', {
    y: 40,
    opacity: 0,
    duration: 1.0,
    delay: 0.2,
    ease: 'power3.out'
  });

  if (typeof ScrollTrigger !== 'undefined') {
    gsap.registerPlugin(ScrollTrigger);

    gsap.utils.toArray('.feature-card').forEach((card, i) => {
      gsap.from(card, {
        scrollTrigger: {
          trigger: card,
          start: 'top 85%'
        },
        y: 30,
        opacity: 0,
        duration: 0.6,
        delay: (i % 3) * 0.1,
        ease: 'power2.out'
      });
    });

    gsap.utils.toArray('.comparison-card').forEach(card => {
      gsap.from(card, {
        scrollTrigger: {
          trigger: card,
          start: 'top 85%'
        },
        y: 35,
        opacity: 0,
        duration: 0.7,
        ease: 'power2.out'
      });
    });
  }
}
