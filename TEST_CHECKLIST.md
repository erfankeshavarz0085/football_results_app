# Shoot Ball Test Checklist

Use this checklist after major changes or before a GitHub release.

## Environment

- [ ] `.env` exists in the project root.
- [ ] `API_KEY` is set when testing real API requests.
- [ ] `API_ENABLED=true` loads real API data.
- [ ] `API_ENABLED=false` prevents real API requests.
- [ ] `API_DEMO_FALLBACK_ENABLED=true` allows demo fallback data.

## App Startup

- [ ] Splash screen appears.
- [ ] Splash screen stays visible for the expected duration.
- [ ] App opens to Home after splash.
- [ ] Bottom navigation is visible and usable.

## Home

- [ ] Today's fixtures load for the current date.
- [ ] Previous day button changes the fixture date.
- [ ] Next day button changes the fixture date.
- [ ] Calendar picker opens and selects a date.
- [ ] Fixtures are grouped by league.
- [ ] Match cards open Match Details.
- [ ] Fixture search filters by team, league, or country.
- [ ] Empty state appears when no fixtures match.
- [ ] Loading skeleton appears while fixtures are loading.
- [ ] Demo banner appears when demo fallback data is shown.

## Live

- [ ] Live screen loads without crashing.
- [ ] Live matches are grouped by league.
- [ ] Match cards open Match Details.
- [ ] Empty state appears when no live matches are available.
- [ ] Loading skeleton appears while live fixtures are loading.
- [ ] Demo banner appears when demo live data is shown.

## Leagues

- [ ] Famous leagues are shown in the Leagues screen.
- [ ] League logos load correctly.
- [ ] League search filters the famous league list.
- [ ] Opening a league shows the details screen.

## League Details

- [ ] Overview tab shows league profile data.
- [ ] Overview shows latest champion and history count.
- [ ] Fixtures tab loads fixtures or fallback/demo data.
- [ ] Round selector works.
- [ ] Fixture cards open Match Details.
- [ ] Standings tab loads table data or fallback/demo data.
- [ ] Standings team rows open Team Details.
- [ ] History tab lists previous champions.
- [ ] History season selector filters to the selected season.
- [ ] World Cup uses 2022 fixtures.

## Match Details

- [ ] Summary tab shows venue, referee, events count, and lineup count.
- [ ] Events are sorted by minute.
- [ ] Stats tab shows both teams when statistics are available.
- [ ] Lineups tab shows formations, coach, starting XI, and substitutes when available.
- [ ] Team logos in the score card open Team Details.
- [ ] Empty states appear when events, stats, or lineups are missing.
- [ ] Demo match details open for demo fixtures.

## Team Details

- [ ] Team header shows logo, name, country, and favorite button.
- [ ] Overview tab shows recent form, club info, venue, capacity, and coach.
- [ ] Matches tab shows recent matches.
- [ ] Recent match rows open Match Details.
- [ ] Lineup tab shows latest formation and players.
- [ ] Squad tab shows player list.
- [ ] Demo team details open when API is unavailable and fallback is enabled.

## Search

- [ ] Search defaults to Teams.
- [ ] Popular teams are shown before typing 3 characters.
- [ ] Typing 3 or more characters searches teams.
- [ ] Switching to Leagues searches leagues.
- [ ] Country filter chips appear when multiple countries exist.
- [ ] Country filter limits visible results.
- [ ] Recent searches are saved.
- [ ] Recent searches can be cleared.
- [ ] Recently viewed items are shown when enabled in Settings.
- [ ] Search empty state appears for no results.

## Favorites

- [ ] Favorite teams can be added and removed.
- [ ] Favorite leagues can be added and removed.
- [ ] Followed matches can be added and removed.
- [ ] Favorites screen opens saved items correctly.
- [ ] Home favorites summary respects Settings.

## Settings

- [ ] Data source card shows Real API status.
- [ ] Data source card shows Demo fallback status.
- [ ] Demo fallback switch persists after app restart.
- [ ] Favorites summary switch affects Home.
- [ ] Recently viewed switch affects Search.
- [ ] Match alert controls switch affects match cards.

## Demo And Offline

- [ ] With `API_ENABLED=false` and Demo fallback on, Home shows demo fixtures.
- [ ] With `API_ENABLED=false` and Demo fallback on, Live shows demo live matches.
- [ ] With `API_ENABLED=false` and Demo fallback on, Search returns demo teams/leagues.
- [ ] With `API_ENABLED=false` and Demo fallback off, app shows friendly errors/empty states.

## Final Quality

- [ ] No raw API exceptions are shown directly to users.
- [ ] No API key is committed.
- [ ] `flutter analyze` is clean or remaining warnings are documented.
- [ ] UI works on Chrome.
- [ ] UI works on the target mobile/desktop device.
