# Shoot Ball

Shoot Ball is a Flutter football results application inspired by modern match
centers such as SofaScore and FotMob. It uses Provider for state management,
API-Football for live football data, local persistence for user preferences, and
a dark, modern interface.

## Features

- Splash screen with custom app entry
- Dark football-focused UI
- Home screen with date selector and grouped fixtures
- Live matches grouped by important leagues
- League list with famous competitions
- Search for teams and leagues
- League details with Overview, Fixtures, Standings, and History tabs
- Filterable champions history for major leagues and the World Cup
- Team details with Overview, Matches, Lineup, and Squad tabs
- Match details with Summary, Stats, and Lineups tabs
- Match events, statistics, lineups, venue, and referee details
- Favorite teams, leagues, and followed matches
- Recently viewed teams, leagues, and matches
- Settings for personalization and demo fallback
- API safety features: request throttling, cache fallback, and demo fallback
- Offline/demo data for presentation and API outage scenarios
- Loading skeletons and improved empty/error states

## Tech Stack

- Flutter
- Dart
- Provider
- API-Football via API-Sports
- `http`
- `shared_preferences`
- `cached_network_image`
- `flutter_dotenv`
- `intl`

## Project Structure

```text
lib/
  models/       Data models for fixtures, teams, leagues, standings, details
  providers/    Provider state management classes
  screens/      App pages and tab screens
  services/     API service and cache/fallback logic
  utils/        Constants, demo data, league history/profile data, error text
  widgets/      Shared UI widgets
```

## Environment Setup

Create a `.env` file in the project root. Use `.env.example` as the template:

```env
API_KEY=your_api_football_key_here
API_ENABLED=true
API_DEMO_FALLBACK_ENABLED=true
API_REQUEST_INTERVAL_MS=1500
API_DEMO_FIXTURE_DATE=2024-07-14
```

Important:

- Keep `.env` private and do not commit real API keys.
- Set `API_ENABLED=false` when you want to avoid real API requests.
- Keep `API_DEMO_FALLBACK_ENABLED=true` for presentation mode or API outage
  testing.

## Running The App

Install dependencies:

```bash
flutter pub get
```

Run on Chrome:

```bash
flutter run -d chrome
```

Run on Windows desktop:

```bash
flutter run -d windows
```

## API And Demo Fallback

Shoot Ball tries data sources in this order:

1. Fresh in-memory cache
2. Persistent cache from `shared_preferences`
3. Real API-Football request
4. Stale cache fallback
5. Demo fallback data, if enabled

This helps the app remain usable when:

- The API key is missing
- API requests are disabled
- The API account is suspended
- The free plan blocks a date or season
- The network is unavailable

Demo fallback can also be controlled from the Settings screen.

## Main Screens

- Home: today's fixtures, custom date picker, search within fixtures
- Live: currently live matches, grouped by league
- Leagues: famous leagues plus league details
- Search: teams and leagues with country filters and recent items
- Favorites: saved teams, leagues, and followed matches
- Settings: personalization, API/demo status, demo fallback toggle

## Notes

- Some API-Football seasons and endpoints are restricted on free plans.
- World Cup fixtures use the 2022 season because newer seasons may require a
  paid API plan.
- Demo data is intentionally small and presentation-focused. It is not intended
  to replace real football data.

## Testing

Use [TEST_CHECKLIST.md](TEST_CHECKLIST.md) for the manual verification flow.
