# Role: Senior Apple TV (tvOS) Software Architect & Product Manager

# Mission
Act as a Master-Level Developer to create a comprehensive Product Requirements Document (PRD) and a high-fidelity SwiftUI prototype for a cinematic tvOS Discovery App called "CineBrowse."

# App Concept
A premium tvOS app for browsing movies/TV shows across all major streaming platforms. The app must feel like a "Super-Aggregator" that helps users decide what to watch based on real-time trends, rankings, and streaming availability.

# Core Requirements & Features
1. Cinematic UI: Implement a "High-End" aesthetic. Use large Hero Headers with parallax scrolling, 1.2x scale-on-focus effects for cards, and glassmorphism (material backgrounds).
2. Data Aggregation (The "Union" Logic): Architect a service that merges data from multiple FREE APIs:
   - TMDB API: For core metadata, posters, trending lists, and new releases.
   - OMDb API: To fetch specific Rotten Tomatoes (Critics & Audience) and IMDb scores.
   - Watchmode or Streaming Availability API (Free Tiers): To identify which platform (Netflix, Hulu, etc.) a title is on.
3. Filtering System: Implement a robust filtering engine for:
   - Streaming Service (Provider filtering)
   - Top Ranked (Metacritic/RT scores)
   - Trending Now
   - New Arrivals
4. Persistence ("Want to Watch"): Use SwiftData to allow users to save titles locally. Provide a schema design that could scale to a Supabase backend for cross-device syncing.

# Deliverables
Part 1: PRD
- Detailed User Stories.
- Technical Stack Breakdown (SwiftUI, SwiftData, Combined API Architecture).
- Data Model Schema (The "UnifiedMovie" object).
- API Integration Strategy (How to handle rate limits and data merging).

Part 2: Technical Architecture & Code
- SwiftUI View Hierarchy optimized for the tvOS Focus Engine.
- A "HeroHeaderView" with parallax effects.
- A "MovieGridView" with custom focused-state animations.
- The "DataCoordinator" class logic for fetching and merging the three API sources.

# Constraints
- Language: Swift (SwiftUI).
- OS: tvOS 17+.
- No-Cost: Prioritize API endpoints that offer free tiers for individual developers.
- Navigation: Use a TabView or Sidebar approach consistent with modern Apple TV design.
- Use the tvOS skills in the ~/.claude/skills/ directory for front end design choices.