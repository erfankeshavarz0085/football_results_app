# Shoot Ball — Manual Test Checklist

Use this checklist after meaningful changes and before a release. Test both a real-API scenario and an offline/demo scenario where possible.

## Environment and Startup

- [ ] `.env` exists locally and is not tracked by Git.
- [ ] A valid `API_KEY` is set when testing real requests.
- [ ] `API_ENABLED=true` permits real API requests.
- [ ] `API_ENABLED=false` prevents real API requests.
- [ ] `API_DEMO_FALLBACK_ENABLED=true` makes the in-app demo fallback option available.
- [ ] The splash screen appears, then opens Home without a crash.
- [ ] All five bottom-navigation destinations work: Home, Leagues, Live, Search, and Favorites.

## Home and Live

- [ ] Home loads fixtures for the selected date and groups them by league.
- [ ] Previous/next-day controls and calendar selection change the fixture date.
- [ ] Home filtering matches team, league, or country names.
- [ ] Opening a fixture opens Match Details and saves it to Recently Viewed.
- [ ] Loading, empty, error, and demo states are understandable and usable.
- [ ] Live opens without crashing, groups matches by league, and opens Match Details.
- [ ] The demo banner appears when demo data is being shown.

## Leagues

- [ ] Famous-league list, logos, and league search work.
- [ ] A league opens with its correct name, logo, country, and favourite control.
- [ ] Changing the season updates league tabs that use season data.
- [ ] Overview displays competition information.
- [ ] Fixtures load, round selection works, and fixture cards open Match Details.
- [ ] Standings load and a team row opens Team Details.
- [ ] Player leaders load for Goals, Assists, and Clean sheets; retry/empty states work.
- [ ] History displays champions and the season filter works.
- [ ] World Cup fixtures use the supported 2022 data path.

## Matches and Teams

- [ ] Match Summary shows available venue, referee, events, and lineup information.
- [ ] Events are ordered by minute.
- [ ] Stats show both teams when the API provides statistics.
- [ ] Lineups show formations, coaches, starting XI, and substitutes when available.
- [ ] Team logos in Match Details open the corresponding Team Details page.
- [ ] Team pages show header details, recent form/info, matches, lineup, and squad when data is available.
- [ ] A recent team match opens Match Details.
- [ ] Missing API data produces a clear empty/error state rather than a crash.

## Search and Players

- [ ] Search starts in Teams mode and shows popular teams before a three-character query.
- [ ] Team, League, and Player modes search after three or more characters.
- [ ] Country filter chips appear when applicable and filter the active result type.
- [ ] Recent searches are saved, reusable, and clearable.
- [ ] Recently Viewed items appear only when enabled in Settings.
- [ ] Selecting a player opens Player Details.
- [ ] Player Details shows available profile data, career history, and honours.
- [ ] Player error, not-found, and retry states work.

## Favourites and Settings

- [ ] Teams, leagues, players, and matches can be added to and removed from favourites.
- [ ] Favorites filters correctly show All, Matches, Leagues, Teams, and Players.
- [ ] Saved favourites persist after restarting the app.
- [ ] Home favourites summary respects its Settings switch.
- [ ] Recently Viewed visibility respects its Settings switch.
- [ ] Match-alert controls visibility respects its Settings switch.
- [ ] The Demo fallback switch persists after restarting the app.

## Resilience and Release Checks

- [ ] With real API disabled and demo fallback enabled, Home, Live, Search, league, team, and match flows remain usable with demo data where supported.
- [ ] With both real API and demo fallback disabled, the app shows friendly errors/empty states.
- [ ] Restarting the app preserves settings, favourites, followed matches, and recently viewed items.
- [ ] No raw exception or API key is visible to users or committed to Git.
- [ ] `flutter analyze` passes, or any remaining diagnostics are documented.
- [ ] The app is smoke-tested on Chrome and the intended target device(s).
