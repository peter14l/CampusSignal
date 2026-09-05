/**
 * CampusSignal — Onboarding Controller
 * Interactive 2-Step SXUK Department & Personalization Setup
 */

document.addEventListener('DOMContentLoaded', async () => {
  // Auth Guard
  const user = await CS_AUTH.requireAuth({ requireCompleteOnboarding: false });
  if (!user) return;

  if (window.lucide) lucide.createIcons();

  // Load existing profile if any
  const existingProfile = await CS_AUTH.getUserProfile(user.id);
  
  // UI State
  let currentStep = 1;
  let selectedBranch = existingProfile?.branch || '';
  let selectedSemester = existingProfile?.metadata?.semester || 1;
  let selectedInterests = new Set(existingProfile?.interests || ['Hackathons', 'AI/ML', 'Internships']);
  let selectedSkills = new Set(existingProfile?.skills || ['Python', 'Flutter', 'React / Next.js']);

  // Elements
  const step1Container = document.getElementById('step-1-container');
  const step2Container = document.getElementById('step-2-container');
  const stepIndicator1 = document.getElementById('step-indicator-1');
  const stepIndicator2 = document.getElementById('step-indicator-2');
  const degreeSelect = document.getElementById('degree-select');
  const branchSelect = document.getElementById('branch-select');
  const semesterGrid = document.getElementById('semester-grid');
  const computedYearDisplay = document.getElementById('computed-year-display');
  const interestsWrap = document.getElementById('interests-chips-wrap');
  const skillsWrap = document.getElementById('skills-chips-wrap');
  const customSkillInput = document.getElementById('custom-skill-input');
  const addSkillBtn = document.getElementById('btn-add-custom-skill');

  const btnStep1Next = document.getElementById('btn-step1-next');
  const btnStep2Back = document.getElementById('btn-step2-back');
  const btnStep2Submit = document.getElementById('btn-step2-submit');
  const onboardingAlert = document.getElementById('onboarding-alert');

  function showAlert(msg, isError = true) {
    onboardingAlert.textContent = msg;
    onboardingAlert.style.display = 'block';
    onboardingAlert.style.background = isError ? 'var(--rose-container)' : 'var(--emerald-container)';
    onboardingAlert.style.color = isError ? 'var(--rose)' : 'var(--emerald)';
    onboardingAlert.style.border = `1px solid ${isError ? 'var(--rose)' : 'var(--emerald)'}`;
  }

  // 1. Populate Branches Grouped by Degree
  function renderBranchOptions() {
    branchSelect.innerHTML = '<option value="">-- Select Your Academic Programme --</option>';

    Object.keys(SXUK_CATALOG.degreeLevels).forEach(degreeGroup => {
      const optGroupLevel = document.createElement('optgroup');
      optGroupLevel.label = `━━━ ${degreeGroup} ━━━`;
      
      const faculties = SXUK_CATALOG.degreeLevels[degreeGroup];
      Object.keys(faculties).forEach(faculty => {
        const subGroup = document.createElement('optgroup');
        subGroup.label = `  ${faculty}`;
        
        faculties[faculty].forEach(branch => {
          const opt = document.createElement('option');
          opt.value = branch;
          opt.textContent = branch;
          if (branch === selectedBranch) opt.selected = true;
          subGroup.appendChild(opt);
        });
        branchSelect.appendChild(subGroup);
      });
    });
  }

  // 2. Render Semester Selector Buttons
  function renderSemesterButtons() {
    semesterGrid.innerHTML = '';
    const totalSemesters = 8; // default standard

    for (let s = 1; s <= totalSemesters; s++) {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = `sem-pill ${selectedSemester === s ? 'active' : ''}`;
      btn.textContent = `Sem ${s}`;
      btn.addEventListener('click', () => {
        selectedSemester = s;
        updateSemesterView();
      });
      semesterGrid.appendChild(btn);
    }
    updateComputedYear();
  }

  function updateSemesterView() {
    document.querySelectorAll('.sem-pill').forEach((el, idx) => {
      if (idx + 1 === selectedSemester) {
        el.classList.add('active');
      } else {
        el.classList.remove('active');
      }
    });
    updateComputedYear();
  }

  function updateComputedYear() {
    const calculatedYear = Math.ceil(selectedSemester / 2);
    const suffix = calculatedYear === 1 ? 'st' : calculatedYear === 2 ? 'nd' : calculatedYear === 3 ? 'rd' : 'th';
    computedYearDisplay.textContent = `${calculatedYear}${suffix} Academic Year`;
  }

  // 3. Render Interest Chips
  function renderInterests() {
    interestsWrap.innerHTML = '';
    SXUK_CATALOG.interestPills.forEach(interest => {
      const chip = document.createElement('button');
      chip.type = 'button';
      chip.className = `filter-chip ${selectedInterests.has(interest) ? 'active' : ''}`;
      chip.innerHTML = `<span>${interest}</span>`;
      chip.addEventListener('click', () => {
        if (selectedInterests.has(interest)) {
          selectedInterests.delete(interest);
          chip.classList.remove('active');
        } else {
          selectedInterests.add(interest);
          chip.classList.add('active');
        }
      });
      interestsWrap.appendChild(chip);
    });
  }

  // 4. Render Skills Chips
  function renderSkills() {
    skillsWrap.innerHTML = '';
    
    // Combine standard pills with any custom user skills
    const allSkills = Array.from(new Set([...SXUK_CATALOG.skillPills, ...Array.from(selectedSkills)]));

    allSkills.forEach(skill => {
      const chip = document.createElement('button');
      chip.type = 'button';
      chip.className = `filter-chip ${selectedSkills.has(skill) ? 'active' : ''}`;
      chip.innerHTML = `<span>${skill}</span>`;
      chip.addEventListener('click', () => {
        if (selectedSkills.has(skill)) {
          selectedSkills.delete(skill);
          chip.classList.remove('active');
        } else {
          selectedSkills.add(skill);
          chip.classList.add('active');
        }
      });
      skillsWrap.appendChild(chip);
    });
  }

  // Custom skill adding
  addSkillBtn.addEventListener('click', () => {
    const val = customSkillInput.value.trim();
    if (val && !selectedSkills.has(val)) {
      selectedSkills.add(val);
      customSkillInput.value = '';
      renderSkills();
    }
  });

  customSkillInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      addSkillBtn.click();
    }
  });

  // Step 1 -> Step 2 Navigation
  btnStep1Next.addEventListener('click', () => {
    selectedBranch = branchSelect.value;
    if (!selectedBranch) {
      showAlert('Please select your official SXUK Degree / Programme to continue.');
      branchSelect.focus();
      return;
    }

    onboardingAlert.style.display = 'none';
    currentStep = 2;
    step1Container.style.display = 'none';
    step2Container.style.display = 'block';

    stepIndicator1.classList.remove('active');
    stepIndicator1.classList.add('completed');
    stepIndicator2.classList.add('active');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });

  // Step 2 -> Step 1 Navigation
  btnStep2Back.addEventListener('click', () => {
    currentStep = 1;
    step2Container.style.display = 'none';
    step1Container.style.display = 'block';

    stepIndicator1.classList.add('active');
    stepIndicator2.classList.remove('active');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });

  // Final Step 2 Submission
  btnStep2Submit.addEventListener('click', async () => {
    btnStep2Submit.disabled = true;
    btnStep2Submit.innerHTML = '<span>Saving Profile to Supabase...</span>';

    try {
      const calculatedYear = Math.ceil(selectedSemester / 2);

      const profilePayload = {
        branch: selectedBranch,
        year: calculatedYear,
        interests: Array.from(selectedInterests),
        skills: Array.from(selectedSkills),
        metadata: {
          semester: selectedSemester,
          academic_year: calculatedYear,
          onboarding_completed: true,
          completed_at: new Date().toISOString()
        }
      };

      await CS_AUTH.saveUserProfile(profilePayload);
      
      showAlert('Profile configured successfully! Redirecting to App...', false);
      setTimeout(() => {
        window.location.href = '../app/index.html';
      }, 700);
    } catch (err) {
      showAlert(err.message || 'Failed to save academic profile. Please try again.');
      btnStep2Submit.disabled = false;
      btnStep2Submit.innerHTML = '<span>Complete & Launch Feed</span><i data-lucide="sparkles" style="width:16px;height:16px;margin-left:6px;"></i>';
      if (window.lucide) lucide.createIcons();
    }
  });

  // Initialize
  renderBranchOptions();
  renderSemesterButtons();
  renderInterests();
  renderSkills();
});
