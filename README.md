# Shoot Ball

Shoot Ball is a Flutter football-results app inspired by modern match centres such as SofaScore and FotMob. It presents live and scheduled fixtures, competition data, teams, players, and match details through a dark, football-focused interface.

For Persian documentation, see [README_FA.md](README_FA.md).

## Features

- Home fixtures by date, league grouping, in-page filtering, and a calendar picker
- Live-match view with loading, empty, and demo states
- League discovery and league pages with season selection, fixtures, standings, player leaders, and champions history
- Team pages with club information, recent matches, latest lineup, and squad
- Match pages with summary, events, statistics, lineups, venue, referee, and team navigation
- Search for teams, leagues, and players, including country filters, popular teams, and recent searches
- Player pages with personal information, club career, honours, and favourite support
- Persisted favourites for teams, leagues, players, and followed matches
- Recently viewed teams, leagues, and matches
- Settings for home favourites, recently viewed search items, match-alert controls, and demo fallback
- API request throttling, retries for transient failures, in-flight-request deduplication, memory/persistent cache, and stale-cache fallback
- Optional demo data for offline demonstrations and API outage scenarios

## Tech Stack

- Flutter and Dart
- Provider
- API-Football (API-Sports)
- `http`, `flutter_dotenv`, `shared_preferences`, `cached_network_image`, `intl`, and `flutter_spinkit`

## Project Structure

```text
lib/
  models/       API and view data models
  providers/    Application state and local persistence
  screens/      Application pages and league-detail tabs
  services/     API client, retrying, caching, and fallback logic
  utils/        Configuration, demo data, and shared helpers
  widgets/      Reusable UI components
```

## Setup

1. Install Flutter SDK compatible with Dart `^3.7.0`.
2. Install packages:

   ```bash
   flutter pub get
   ```

3. Copy `.env.example` to `.env` and set the values you need:

   ```env
   API_KEY=your_api_football_key_here
   API_ENABLED=false
   API_DEMO_FALLBACK_ENABLED=true
   API_REQUEST_INTERVAL_MS=250
   API_DEFAULT_SEASON=
   API_DEMO_FIXTURE_DATE=2024-07-14
   ```

`.env` contains secrets and is intentionally ignored by Git. Do not commit an API key.

## Configuration

| Variable | Purpose |
| --- | --- |
| `API_KEY` | API-Football key; required only when real requests are enabled. |
| `API_ENABLED` | Enables/disables real API requests. |
| `API_DEMO_FALLBACK_ENABLED` | Makes demo fallback available; the in-app switch controls whether it is used. |
| `API_REQUEST_INTERVAL_MS` | Minimum delay between API requests; `250` ms is the default. |
| `API_DEFAULT_SEASON` | Optional season start year; empty uses automatic July rollover. |
| `API_DEMO_FIXTURE_DATE` | Optional date used by the demo-fixture data. |

For an offline demo, use `API_ENABLED=false` and `API_DEMO_FALLBACK_ENABLED=true`, then enable **Demo fallback** in Settings. For real data, set a valid key and `API_ENABLED=true`.

## Run

```bash
flutter run -d chrome
```

Or select any configured Flutter device, for example Windows:

```bash
flutter run -d windows
```

## Data Behaviour

For cached fixture and standings requests, the app uses data in this order:

1. Fresh in-memory cache
2. Fresh persistent cache (`shared_preferences`)
3. API-Football request
4. Stale memory or persistent cache when the request fails
5. Demo data when fallback is enabled

Some API-Football endpoints, seasons, and historical data are limited by the selected API plan. Demo data is deliberately small and presentation-focused; it is not a replacement for production data.

## Verification

Run static analysis:

```bash
flutter analyze
```

Use the manual test checklists before release:

- [English checklist](TEST_CHECKLIST.md)
- [Persian checklist](TEST_CHECKLIST_FA.md)
