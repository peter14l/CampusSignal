/**
 * CampusSignal — App Core Navigation and Shell Components
 * Handles Sidebar, Active Link State, Header Search, and Modals
 */

function renderAppSidebar(activeTab = 'feed') {
  const sidebar = document.getElementById('app-sidebar-container');
  if (!sidebar) return;

  // Compute root prefix based on current pathname
  const path = window.location.pathname.replace(/\\/g, '/');
  const isSubRoute = path.includes('/app/calendar/') ||
                     path.includes('/app/saved/') ||
                     path.includes('/app/studio/') ||
                     path.includes('/app/notifications/') ||
                     path.includes('/app/profile/');

  const appRoot = isSubRoute ? '../' : './';
  const siteRoot = isSubRoute ? '../../' : '../';

  sidebar.innerHTML = `
    <div class="sidebar-header">
      <img src="${siteRoot}assets/img/app_logo.png" alt="CampusSignal" class="sidebar-logo">
      <div>
        <div class="sidebar-brand-name">CampusSignal</div>
        <div style="font-size:0.6875rem; font-weight:700; color:var(--primary); letter-spacing:0.04em;">SXUK OFFICIAL</div>
      </div>
    </div>

    <nav class="sidebar-nav">
      <a href="${appRoot}index.html" class="sidebar-link ${activeTab === 'feed' ? 'active' : ''}">
        <i data-lucide="compass" style="width:18px;height:18px;"></i>
        <span>Discover Feed</span>
      </a>
      <a href="${appRoot}calendar/index.html" class="sidebar-link ${activeTab === 'calendar' ? 'active' : ''}">
        <i data-lucide="calendar" style="width:18px;height:18px;"></i>
        <span>Calendar & Deadlines</span>
        <span class="sidebar-badge">4</span>
      </a>
      <a href="${appRoot}saved/index.html" class="sidebar-link ${activeTab === 'saved' ? 'active' : ''}">
        <i data-lucide="bookmark" style="width:18px;height:18px;"></i>
        <span>Saved Opportunities</span>
      </a>
      <a href="${appRoot}studio/index.html" class="sidebar-link ${activeTab === 'studio' ? 'active' : ''}">
        <i data-lucide="scan-line" style="width:18px;height:18px;"></i>
        <span>AI Flyer Studio</span>
      </a>
      <a href="${appRoot}notifications/index.html" class="sidebar-link ${activeTab === 'notifications' ? 'active' : ''}">
        <i data-lucide="bell" style="width:18px;height:18px;"></i>
        <span>Broadcast Signals</span>
        <span class="sidebar-badge" style="background:var(--accent-amber);color:#000;">2</span>
      </a>
      <a href="${appRoot}profile/index.html" class="sidebar-link ${activeTab === 'profile' ? 'active' : ''}">
        <i data-lucide="user" style="width:18px;height:18px;"></i>
        <span>Academic Profile</span>
      </a>
      
      <div style="margin-top:auto; padding-top:16px; border-top:1px solid var(--border-subtle);">
        <a href="${siteRoot}index.html" class="sidebar-link">
          <i data-lucide="globe" style="width:18px;height:18px;"></i>
          <span>Showcase Portal</span>
        </a>
      </div>
    </nav>

    <div class="sidebar-user" id="sidebar-user-box">
      <div class="user-avatar" id="sidebar-user-avatar">SX</div>
      <div class="user-info">
        <div class="user-name" id="sidebar-user-name">Loading...</div>
        <div class="user-dept" id="sidebar-user-dept">SXUK Student</div>
      </div>
      <button id="btn-sidebar-signout" title="Sign Out" style="background:none; border:none; color:var(--text-muted); cursor:pointer; padding:6px; border-radius:6px; display:flex; align-items:center; justify-content:center;">
        <i data-lucide="log-out" style="width:16px;height:16px;"></i>
      </button>
    </div>
  `;

  // Render Mobile Bottom Bar
  renderMobileNav(activeTab, appRoot);

  // Hook Sign Out
  const signOutBtn = document.getElementById('btn-sidebar-signout');
  if (signOutBtn) {
    signOutBtn.addEventListener('click', () => {
      if (confirm('Are you sure you want to sign out?')) {
        CS_AUTH.signOutUser();
      }
    });
  }
}

function renderMobileNav(activeTab = 'feed', appRoot = './') {
  const bottomNav = document.getElementById('mobile-bottom-nav-container');
  if (!bottomNav) return;

  bottomNav.innerHTML = `
    <a href="${appRoot}index.html" class="mobile-nav-item ${activeTab === 'feed' ? 'active' : ''}">
      <i data-lucide="compass" style="width:20px;height:20px;"></i>
      <span>Feed</span>
    </a>
    <a href="${appRoot}calendar/index.html" class="mobile-nav-item ${activeTab === 'calendar' ? 'active' : ''}">
      <i data-lucide="calendar" style="width:20px;height:20px;"></i>
      <span>Calendar</span>
    </a>
    <a href="${appRoot}saved/index.html" class="mobile-nav-item ${activeTab === 'saved' ? 'active' : ''}">
      <i data-lucide="bookmark" style="width:20px;height:20px;"></i>
      <span>Saved</span>
    </a>
    <a href="${appRoot}studio/index.html" class="mobile-nav-item ${activeTab === 'studio' ? 'active' : ''}">
      <i data-lucide="scan-line" style="width:20px;height:20px;"></i>
      <span>Studio</span>
    </a>
    <a href="${appRoot}profile/index.html" class="mobile-nav-item ${activeTab === 'profile' ? 'active' : ''}">
      <i data-lucide="user" style="width:20px;height:20px;"></i>
      <span>Profile</span>
    </a>
  `;
}

// Update User UI Elements across topbar & sidebar
async function populateUserInfo(user) {
  if (!user) return;
  const profile = await CS_AUTH.getUserProfile(user.id);
  const fullName = profile?.full_name || user.user_metadata?.full_name || user.email?.split('@')[0] || 'SXUK Student';
  const branch = profile?.branch || 'Department not set';
  const semester = profile?.metadata?.semester ? `Sem ${profile.metadata.semester}` : '';

  const avatarText = fullName.split(' ').map(n => n[0]).slice(0, 2).join('').toUpperCase() || 'SX';

  // Sidebar
  const sidebarAvatar = document.getElementById('sidebar-user-avatar');
  const sidebarName = document.getElementById('sidebar-user-name');
  const sidebarDept = document.getElementById('sidebar-user-dept');
  if (sidebarAvatar) sidebarAvatar.textContent = avatarText;
  if (sidebarName) sidebarName.textContent = fullName;
  if (sidebarDept) sidebarDept.textContent = semester ? `${branch} • ${semester}` : branch;

  // Header Avatar if present
  const headerAvatar = document.getElementById('header-user-avatar');
  if (headerAvatar) headerAvatar.textContent = avatarText;

  return { user, profile };
}

// Global Event Detail Modal Opener
function openEventModal(eventId) {
  const event = SXUK_CATALOG.events.find(e => e.id === eventId);
  if (!event) return;

  const modalBackdrop = document.getElementById('cs-event-modal-backdrop');
  const modalBody = document.getElementById('cs-event-modal-body');
  if (!modalBackdrop || !modalBody) return;

  const isSaved = CS_AUTH.isEventSaved(event.id);
  const formattedDate = new Date(event.eventDate).toLocaleDateString('en-US', {
    weekday: 'short', month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit'
  });
  const deadlineDate = new Date(event.deadline).toLocaleDateString('en-US', {
    month: 'short', day: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit'
  });

  modalBody.innerHTML = `
    <div style="position:relative; height:240px; background:var(--bg-tertiary); overflow:hidden;">
      <img src="${event.posterUrl}" alt="${event.title}" style="width:100%; height:100%; object-fit:cover;">
      <div style="position:absolute; inset:0; background:linear-gradient(to top, var(--bg-secondary) 5%, transparent 60%);"></div>
      <div style="position:absolute; bottom:16px; left:24px; right:24px; display:flex; justify-content:space-between; align-items:flex-end;">
        <span class="event-cat-tag cat-${event.category}" style="font-size:0.8125rem; padding:4px 10px;">${event.category.toUpperCase()}</span>
        <button id="modal-save-btn" class="btn btn-sm btn-outline" style="backdrop-filter:blur(8px); background:rgba(15,20,28,0.85); color:#fff; border-color:rgba(255,255,255,0.2);">
          <i data-lucide="${isSaved ? 'bookmark-check' : 'bookmark'}" style="width:16px;height:16px;margin-right:6px; color:${isSaved ? 'var(--primary-hover)' : 'inherit'};"></i>
          <span>${isSaved ? 'Bookmarked' : 'Save Drive'}</span>
        </button>
      </div>
    </div>

    <div style="padding:24px 28px;">
      <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px; color:var(--text-secondary); font-size:0.875rem;">
        <i data-lucide="building-2" style="width:16px;height:16px;color:var(--primary);"></i>
        <span>${event.organizer}</span>
      </div>

      <h2 style="font-size:1.4rem; font-weight:800; line-height:1.3; color:var(--text-primary); margin-bottom:18px;">
        ${event.title}
      </h2>

      <!-- Details Matrix Grid -->
      <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(200px, 1fr)); gap:14px; background:var(--bg-tertiary); padding:16px; border-radius:var(--radius-md); margin-bottom:20px; border:1px solid var(--border-subtle);">
        <div>
          <div style="font-size:0.75rem; color:var(--text-muted); text-transform:uppercase; font-weight:600;">Event Date</div>
          <div style="font-size:0.875rem; font-weight:600; color:var(--text-primary); margin-top:2px;">${formattedDate}</div>
        </div>
        <div>
          <div style="font-size:0.75rem; color:var(--text-muted); text-transform:uppercase; font-weight:600;">Registration Deadline</div>
          <div style="font-size:0.875rem; font-weight:700; color:var(--accent-amber); margin-top:2px;">${deadlineDate}</div>
        </div>
        <div>
          <div style="font-size:0.75rem; color:var(--text-muted); text-transform:uppercase; font-weight:600;">Venue & Format</div>
          <div style="font-size:0.875rem; font-weight:600; color:var(--text-primary); margin-top:2px;">${event.venue} (${event.format})</div>
        </div>
        <div>
          <div style="font-size:0.75rem; color:var(--text-muted); text-transform:uppercase; font-weight:600;">Team Configuration</div>
          <div style="font-size:0.875rem; font-weight:600; color:var(--text-primary); margin-top:2px;">${event.teamSize}</div>
        </div>
      </div>

      <!-- Description & Eligibility -->
      <div style="margin-bottom:20px;">
        <h3 style="font-size:0.9375rem; font-weight:700; color:var(--text-primary); margin-bottom:8px;">About this Opportunity</h3>
        <p style="font-size:0.875rem; line-height:1.6; color:var(--text-secondary);">${event.description}</p>
      </div>

      <div style="margin-bottom:20px;">
        <h3 style="font-size:0.9375rem; font-weight:700; color:var(--text-primary); margin-bottom:8px;">Eligibility & Disciplines</h3>
        <div style="background:var(--bg-tertiary); padding:12px 16px; border-radius:var(--radius-sm); font-size:0.84rem; color:var(--text-secondary);">
          <strong style="color:var(--text-primary);">Target:</strong> ${event.eligibility}
        </div>
      </div>

      <!-- Tags & Prizes -->
      <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; margin-bottom:28px;">
        <div style="display:flex; flex-wrap:wrap; gap:6px;">
          ${event.tags.map(t => `<span class="event-mini-tag">#${t}</span>`).join('')}
        </div>
        <div style="font-size:0.875rem; font-weight:700; color:var(--emerald);">
          🏆 ${event.prize}
        </div>
      </div>

      <!-- CTAs: Calendar Sync & Apply Direct -->
      <div style="display:flex; gap:12px; flex-wrap:wrap;">
        <button id="btn-sync-cal" class="btn btn-outline" style="flex:1; height:46px; border-radius:var(--radius-md); font-weight:600;">
          <i data-lucide="calendar-plus" style="width:18px;height:18px;margin-right:8px;"></i>
          <span>Add to Calendar (.ics / Google)</span>
        </button>

        <a href="${event.applyUrl}" target="_blank" class="btn btn-primary" style="flex:1.2; height:46px; border-radius:var(--radius-md); font-weight:700; text-decoration:none; display:flex; align-items:center; justify-content:center;">
          <span>Apply Directly</span>
          <i data-lucide="external-link" style="width:16px;height:16px;margin-left:8px;"></i>
        </a>
      </div>
    </div>
  `;

  modalBackdrop.classList.add('active');
  if (window.lucide) lucide.createIcons();

  // Save button inside modal
  const modalSaveBtn = document.getElementById('modal-save-btn');
  modalSaveBtn.addEventListener('click', () => {
    const newlySaved = CS_AUTH.toggleSaveEvent(event.id);
    modalSaveBtn.innerHTML = `
      <i data-lucide="${newlySaved ? 'bookmark-check' : 'bookmark'}" style="width:16px;height:16px;margin-right:6px; color:${newlySaved ? 'var(--primary-hover)' : 'inherit'};"></i>
      <span>${newlySaved ? 'Bookmarked' : 'Save Drive'}</span>
    `;
    if (window.lucide) lucide.createIcons();
    if (window.refreshFeedSavedStates) window.refreshFeedSavedStates();
  });

  // Calendar .ics download generator
  const calBtn = document.getElementById('btn-sync-cal');
  calBtn.addEventListener('click', () => {
    generateIcsDownload(event);
  });
}

function closeEventModal() {
  const modalBackdrop = document.getElementById('cs-event-modal-backdrop');
  if (modalBackdrop) modalBackdrop.classList.remove('active');
}

// Generate .ics calendar download
function generateIcsDownload(event) {
  const startDate = new Date(event.eventDate).toISOString().replace(/-|:|\.\d\d\d/g, "");
  const endDate = new Date(event.endDate || event.eventDate).toISOString().replace(/-|:|\.\d\d\d/g, "");

  const icsContent = [
    "BEGIN:VCALENDAR",
    "VERSION:2.0",
    "PRODID:-//CampusSignal//SXUK Event Engine//EN",
    "BEGIN:VEVENT",
    `UID:${event.id}-sxuk@campussignal.edu`,
    `DTSTAMP:${startDate}`,
    `DTSTART:${startDate}`,
    `DTEND:${endDate}`,
    `SUMMARY:${event.title}`,
    `DESCRIPTION:${event.description}\\n\\nApply: ${event.applyUrl}`,
    `LOCATION:${event.venue}`,
    "END:VEVENT",
    "END:VCALENDAR"
  ].join("\r\n");

  const blob = new Blob([icsContent], { type: "text/calendar;charset=utf-8" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.setAttribute("download", `${event.id}-sxuk-event.ics`);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

// Theme Management across Web App suite
function initAppTheme() {
  const savedTheme = localStorage.getItem('cs_theme') || 'dark';
  document.documentElement.setAttribute('data-theme', savedTheme);
  updateAppThemeIcons(savedTheme);

  document.querySelectorAll('.theme-toggle').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      const activeTheme = document.documentElement.getAttribute('data-theme') || 'dark';
      const newTheme = activeTheme === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', newTheme);
      localStorage.setItem('cs_theme', newTheme);
      updateAppThemeIcons(newTheme);
    });
  });
}

function updateAppThemeIcons(theme) {
  document.querySelectorAll('.theme-toggle').forEach(btn => {
    if (theme === 'dark') {
      btn.innerHTML = '<i data-lucide="sun" style="width:18px;height:18px;"></i>';
      btn.setAttribute('aria-label', 'Switch to Light Mode');
    } else {
      btn.innerHTML = '<i data-lucide="moon" style="width:18px;height:18px;"></i>';
      btn.setAttribute('aria-label', 'Switch to Dark Mode');
    }
  });
  if (window.lucide) {
    lucide.createIcons();
  }
}

// Global close listeners and theme initializer
document.addEventListener('DOMContentLoaded', () => {
  initAppTheme();

  const modalBackdrop = document.getElementById('cs-event-modal-backdrop');
  const modalClose = document.getElementById('cs-modal-close-btn');

  if (modalClose) {
    modalClose.addEventListener('click', closeEventModal);
  }
  if (modalBackdrop) {
    modalBackdrop.addEventListener('click', (e) => {
      if (e.target === modalBackdrop) closeEventModal();
    });
  }
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeEventModal();
  });
});

window.CS_NAV = {
  renderAppSidebar,
  populateUserInfo,
  openEventModal,
  closeEventModal,
  generateIcsDownload,
  initAppTheme
};
