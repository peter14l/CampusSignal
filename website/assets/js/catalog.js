/**
 * CampusSignal — SXUK Academic Catalog & Constants
 * 28 Official Programmes, Semesters, Skills, Categories & Live Mock Events
 */

const SXUK_CATALOG = {
  degreeLevels: {
    'Undergraduate (UG)': {
      'Faculty of Commerce & Management': [
        'B.Com. (Honours)',
        'B.M.S. (Honours)'
      ],
      'Faculty of Arts & Humanities': [
        'B.A. (Honours) in English with Minor in Psychology & Mass Communication',
        'B.A. (Honours) in Economics with Minor in Statistics',
        'B.A. (Honours) in Mass Communication with Minor in Psychology and Film Studies',
        'B.A. (Honours) in Psychology with Minor in Mass Communication & Social Work'
      ],
      'Faculty of Science & Technology': [
        'B.Sc. (Honours) in Statistics and Data Science',
        'B.Tech in CSE',
        'B.Tech in AI & ML',
        'B.Tech in ECE',
        'B.Tech in IT'
      ]
    },
    'Postgraduate & Doctoral (PG / Ph.D.)': {
      'Postgraduate (PG)': [
        'M.A. Economics',
        'M.A. English',
        'M.A. Mass Communication',
        'M.A. Psychology',
        'M.S.W Social Work',
        'M.Com. Commerce',
        'M.Sc. Statistics',
        'LLM. Law',
        'M.Sc. Computer Science'
      ],
      'Doctoral (Ph.D.)': [
        'Ph.D. in Commerce',
        'Ph.D. in Economics',
        'Ph.D. in English',
        'Ph.D. in Law',
        'Ph.D. in Management',
        'Ph.D. in Mass Communication',
        'Ph.D. in Psychology',
        'Ph.D. in Social Work'
      ]
    }
  },

  allBranches: [
    'B.Com. (Honours)',
    'B.M.S. (Honours)',
    'B.A. (Honours) in English with Minor in Psychology & Mass Communication',
    'B.A. (Honours) in Economics with Minor in Statistics',
    'B.A. (Honours) in Mass Communication with Minor in Psychology and Film Studies',
    'B.A. (Honours) in Psychology with Minor in Mass Communication & Social Work',
    'B.Sc. (Honours) in Statistics and Data Science',
    'B.Tech in CSE',
    'B.Tech in AI & ML',
    'B.Tech in ECE',
    'B.Tech in IT',
    'M.A. Economics',
    'M.A. English',
    'M.A. Mass Communication',
    'M.A. Psychology',
    'M.S.W Social Work',
    'M.Com. Commerce',
    'M.Sc. Statistics',
    'LLM. Law',
    'M.Sc. Computer Science',
    'Ph.D. in Commerce',
    'Ph.D. in Economics',
    'Ph.D. in English',
    'Ph.D. in Law',
    'Ph.D. in Management',
    'Ph.D. in Mass Communication',
    'Ph.D. in Psychology',
    'Ph.D. in Social Work'
  ],

  interestPills: [
    'Hackathons', 'AI/ML', 'Workshops', 'Internships',
    'Cultural Fests', 'Robotics & IoT', 'Data Science', 'Sports & E-Sports',
    'Debate & MUN', 'UI/UX Design', 'Entrepreneurship', 'Cybersecurity',
    'Fintech', 'Cloud Computing', 'Competitive Programming', 'Media & Film'
  ],

  skillPills: [
    'Python', 'Flutter', 'React / Next.js', 'FastAPI', 'Node.js',
    'Dart', 'C / C++', 'Java', 'Machine Learning', 'TensorFlow / PyTorch',
    'SQL / Postgres', 'Figma', 'Docker / K8s', 'AWS / Cloudflare',
    'Git & GitHub', 'TailwindCSS', 'Data Analytics', 'R Statistics'
  ],

  categories: [
    { id: 'all', label: 'All Updates', icon: 'sparkles' },
    { id: 'hackathon', label: 'Hackathons', icon: 'code-2' },
    { id: 'internship', label: 'Internships', icon: 'briefcase' },
    { id: 'workshop', label: 'Workshops', icon: 'graduation-cap' },
    { id: 'fest', label: 'Fests & Culture', icon: 'party-popper' },
    { id: 'seminar', label: 'Seminars & Talks', icon: 'presentation' },
    { id: 'club', label: 'Club Activities', icon: 'users' },
    { id: 'sports', label: 'Sports & E-Sports', icon: 'trophy' }
  ],

  // Production dataset of campus events
  events: [
    {
      id: 'ev-1',
      title: 'SXUK GenAI Hackathon 2026: Multimodal Agent Challenge',
      category: 'hackathon',
      organizer: 'Dept. of Computer Science & ACM Student Chapter',
      deadline: '2026-09-08T23:59:59+05:30',
      eventDate: '2026-09-12T09:30:00+05:30',
      endDate: '2026-09-14T18:00:00+05:30',
      venue: 'Fr. Beckers Block, Lab 402',
      format: 'In-Person',
      teamSize: '2 - 4 Members',
      eligibility: 'B.Tech CSE/AI/IT, B.Sc Data Science, M.Sc CS',
      departments: ['B.Tech in CSE', 'B.Tech in AI & ML', 'B.Tech in IT', 'B.Sc. (Honours) in Statistics and Data Science', 'M.Sc. Computer Science'],
      prize: '₹75,000 Cash Pool + Google Cloud Credits',
      tags: ['Gemini 2.5', 'Flutter', 'FastAPI', 'Agentic AI'],
      description: 'Build production-grade multimodal agentic applications solving campus logistics, intelligent document extraction, or automated curriculum indexing. High speed evaluation by industry leaders.',
      posterUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=900&auto=format&fit=crop&q=80',
      applyUrl: 'https://hackathons.sxuk.edu.in/genai-2026',
      contactEmail: 'acm.chapter@sxuk.edu.in',
      isVerified: true
    },
    {
      id: 'ev-2',
      title: 'EY Global Delivery Services: Campus Summer Internship 2027',
      category: 'internship',
      organizer: 'SXUK Central Placement & Career Advisory Cell',
      deadline: '2026-09-10T17:00:00+05:30',
      eventDate: '2026-09-15T10:00:00+05:30',
      endDate: '2026-09-15T16:00:00+05:30',
      venue: 'Main Auditorium & Virtual PPT',
      format: 'Hybrid',
      teamSize: 'Individual',
      eligibility: 'B.Tech (CSE/AI/IT/ECE), B.Com (Hons), BMS, M.Com (Min 7.5 CGPA)',
      departments: ['B.Tech in CSE', 'B.Tech in AI & ML', 'B.Tech in ECE', 'B.Tech in IT', 'B.Com. (Honours)', 'B.M.S. (Honours)', 'M.Com. Commerce'],
      prize: 'Stipend: ₹45,000/month + PPO Track',
      tags: ['Consulting', 'Data Engineering', 'Finance', 'Full Time PPO'],
      description: 'EY GDS Technology and Strategy consulting recruitment drive for penultimate year students. Roles include Associate Tech Consultant, Cloud Architect Intern, and Business Advisory.',
      posterUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=900&auto=format&fit=crop&q=80',
      applyUrl: 'https://placement.sxuk.edu.in/drives/ey-gds-2027',
      contactEmail: 'placement.cell@sxuk.edu.in',
      isVerified: true
    },
    {
      id: 'ev-3',
      title: 'Multimodal AI Vision & Edge LLM Deployment Workshop',
      category: 'workshop',
      organizer: 'Google Developer Student Clubs (GDSC) SXUK',
      deadline: '2026-09-09T20:00:00+05:30',
      eventDate: '2026-09-11T14:00:00+05:30',
      endDate: '2026-09-11T17:30:00+05:30',
      venue: 'Seminar Hall 2, Academic Block A',
      format: 'In-Person Hands-on',
      teamSize: 'Individual',
      eligibility: 'All SXUK Students with basic Python knowledge',
      departments: ['B.Tech in CSE', 'B.Tech in AI & ML', 'B.Tech in IT', 'B.Sc. (Honours) in Statistics and Data Science', 'M.Sc. Computer Science', 'M.Sc. Statistics'],
      prize: 'Google Swag Pack & Certificate of Excellence',
      tags: ['Ollama', 'Quantization', 'ONNX', 'Flutter Embeddings'],
      description: 'Learn how to quantize lightweight Vision-Language Models and deploy them directly on mobile and edge devices without cloud latency. Hands-on coding session.',
      posterUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=900&auto=format&fit=crop&q=80',
      applyUrl: 'https://gdsc.community.dev/events/details/developer-student-clubs-sxuk-presents-edge-llm',
      contactEmail: 'gdsc@sxuk.edu.in',
      isVerified: true
    },
    {
      id: 'ev-4',
      title: 'XAVRANG 2026: Annual Inter-University Cultural & Tech Fest',
      category: 'fest',
      organizer: 'SXUK Student Council & Xavier Cultural Society',
      deadline: '2026-09-20T23:59:59+05:30',
      eventDate: '2026-09-25T10:00:00+05:30',
      endDate: '2026-09-27T22:00:00+05:30',
      venue: 'University Central Grounds & Open Amphitheatre',
      format: 'In-Person',
      teamSize: 'Solo / Band / Group',
      eligibility: 'Open to all SXUK UG & PG departments',
      departments: ['All Departments'],
      prize: '₹2,50,000 Total Prizes across 24 Events',
      tags: ['Battle of Bands', 'Fashion Walk', 'Quiz', 'Gaming LAN'],
      description: 'The flagship 3-day annual university celebration featuring music concerts, pro nights, cinematic drama, robotics arena, and e-sports tournaments.',
      posterUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=900&auto=format&fit=crop&q=80',
      applyUrl: 'https://xavrang.sxuk.edu.in',
      contactEmail: 'council@sxuk.edu.in',
      isVerified: true
    },
    {
      id: 'ev-5',
      title: 'Quantitative Finance & Algorithmic Trading Masterclass',
      category: 'seminar',
      organizer: 'Faculty of Commerce & Bloomberg Finance Lab',
      deadline: '2026-09-14T18:00:00+05:30',
      eventDate: '2026-09-18T11:00:00+05:30',
      endDate: '2026-09-18T13:30:00+05:30',
      venue: 'Bloomberg Financial Markets Lab, 3rd Floor',
      format: 'In-Person / Virtual Stream',
      teamSize: 'Individual',
      eligibility: 'B.Com, BMS, B.Sc Data Science, B.Tech, M.Com, M.A. Economics',
      departments: ['B.Com. (Honours)', 'B.M.S. (Honours)', 'B.A. (Honours) in Economics with Minor in Statistics', 'B.Sc. (Honours) in Statistics and Data Science', 'M.Com. Commerce', 'M.A. Economics'],
      prize: 'Bloomberg Market Concepts (BMC) Certification Voucher',
      tags: ['Python Quants', 'Backtesting', 'Derivatives', 'Risk Models'],
      description: 'Deep dive into high-frequency statistical arbitrage and portfolio optimization led by Senior Quant Portfolio Managers from Dalal Street & Wall Street.',
      posterUrl: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=900&auto=format&fit=crop&q=80',
      applyUrl: 'https://commerce.sxuk.edu.in/quant-masterclass',
      contactEmail: 'finance.club@sxuk.edu.in',
      isVerified: true
    },
    {
      id: 'ev-6',
      title: 'Inter-Departmental Football Championship & Box Cricket',
      category: 'sports',
      organizer: 'SXUK Sports Committee & Athletics Board',
      deadline: '2026-09-16T17:00:00+05:30',
      eventDate: '2026-09-22T08:00:00+05:30',
      endDate: '2026-09-24T18:00:00+05:30',
      venue: 'University Sports Complex & Turf Ground',
      format: 'In-Person Tournament',
      teamSize: '7 + 3 Substitutes',
      eligibility: 'All enrolled undergraduate and postgraduate students',
      departments: ['All Departments'],
      prize: 'Rolling Champions Trophy + Gold Medals + Kit Sponsor',
      tags: ['Football', 'Cricket', 'Athletics', 'Fitness'],
      description: 'The intense autumn clash between Commerce, Engineering, Arts, Law, and Management faculties. Official FIFA rules apply with licensed referees.',
      posterUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=900&auto=format&fit=crop&q=80',
      applyUrl: 'https://sports.sxuk.edu.in/autumn-cup-2026',
      contactEmail: 'sports@sxuk.edu.in',
      isVerified: true
    }
  ],

  // Fetch Events from Supabase for real users or return mock data for guest demo mode
  async fetchEvents(user) {
    const isDemo = window.CS_AUTH?.isDemoUser ? window.CS_AUTH.isDemoUser(user) : (!user || user.is_guest === true || user.id === 'guest-demo-sxuk-2026');
    if (isDemo) {
      return [...this.events];
    }

    const sb = window.CS_AUTH?.getSupabase ? window.CS_AUTH.getSupabase() : null;
    if (!sb) {
      return [];
    }

    try {
      const { data, error } = await sb
        .from('events')
        .select('*')
        .eq('status', 'published')
        .order('starts_at', { ascending: true });

      if (error) {
        console.warn('Supabase fetch events notice:', error.message);
        return [];
      }

      if (data && data.length > 0) {
        return data.map(row => ({
          id: row.id,
          title: row.title || 'Untitled Opportunity',
          category: (row.category || 'other').toLowerCase(),
          organizer: row.organizer_name || 'SXUK Club/Dept',
          deadline: row.deadline_at || row.starts_at || new Date().toISOString(),
          eventDate: row.starts_at || new Date().toISOString(),
          endDate: row.ends_at || row.starts_at || new Date().toISOString(),
          venue: row.venue || 'SXUK Campus',
          format: row.format || 'In-Person',
          teamSize: row.team_size_text || 'Individual',
          eligibility: row.eligibility_text || 'All SXUK Students',
          departments: Array.isArray(row.eligibility_branches) ? row.eligibility_branches : ['All Departments'],
          prize: row.metadata?.prize || 'Verified Event',
          tags: Array.isArray(row.matched_tags) ? row.matched_tags : (row.metadata?.tags || ['SXUK']),
          description: row.description || '',
          posterUrl: row.poster_r2_key || 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=900&auto=format&fit=crop&q=80',
          applyUrl: row.apply_url || '#',
          contactEmail: row.metadata?.contact_email || 'campus@sxuk.edu.in',
          isVerified: true
        }));
      }

      return [];
    } catch (e) {
      console.error('Error fetching live events:', e);
      return [];
    }
  },

  // Compute Match Score based on profile branch & skills
  calculateMatchScore(event, userProfile) {
    if (!userProfile) return 85;
    let score = 50;

    // Check Department Match
    if (userProfile.branch) {
      if (event.departments.includes('All Departments') || event.departments.includes(userProfile.branch)) {
        score += 25;
      }
    }

    // Check Tag/Skill Intersections
    const userTags = [...(userProfile.interests || []), ...(userProfile.skills || [])].map(t => t.toLowerCase());
    const eventTags = (event.tags || []).map(t => t.toLowerCase());

    const matches = eventTags.filter(tag => userTags.some(ut => tag.includes(ut) || ut.includes(tag)));
    score += Math.min(25, matches.length * 10);

    return Math.min(99, Math.max(65, score));
  }
};

window.SXUK_CATALOG = SXUK_CATALOG;
