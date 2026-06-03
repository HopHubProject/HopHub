![CI](https://github.com/HopHubProject/HopHub/actions/workflows/rubyonrails.yml/badge.svg)

# HopHub

<img src="app/assets/images/hophub.png" />

HopHub is private ride coordination for events — no sign-up required. Post a ride
offer or a ride request — no tracking, no third-party cookies — and HopHub matches
them automatically and emails everyone when something fits, whether you're filling
the car, sharing a train ticket, taking the bus, biking, or walking.

This project is implemented using Ruby on Rails.

The reference implementation is available at [hophub.xyz](https://hophub.xyz) but you can also host your own instance
as long as you comply with the [AGPL-3.0 License](LICENSE).

## How it works

### Create an event
You create a new event and share the link with potential attendees.
Only people with the link can see the event.

### Add an offer
People that want to propose a ride can now add an offer. This works for free seats in
a car as well for a common train ride, a bus trip, a bike tour or a walk.
No login is required, only an email address. As soon as the email address is
confirmed, the offer is shown on the website so others can see it.

### Looking for a ride
People that need a ride can submit a lightweight ride request: a direction
(way there or way back), a zip code, a search radius, and a deadline for when
they want to be there at the latest. The event page shows an anonymous,
aggregated count of how many people are looking for a ride and from which
regions, but no personal data. When a matching offer is posted later, all
requesters whose location falls within their chosen radius of the offer are
notified by email automatically. The driver gets a confirmation that says how
many people their offer just notified.

### Get in touch
If you've posted a ride request, you'll be automatically emailed as soon as an
offer matching your route and time window is posted, so you don't have to keep
checking the page. When two parties match, they can get in touch with each
other. Offers may list messengers, so you can reach out directly there. You can
also use a form on the website; the email address of the person reaching out is
used as the Reply-To address, so the recipient can reply directly for further
coordination.

### Leave no traces
Offers, ride requests, and events that are no longer valid are automatically
and permanently removed from the database.

## Features

This project takes care to be as data protection friendly as possible. It only stores the data that is necessary to provide the service and does not use 3rd party cookies. It also does not use any tracking or analytics tools.

- Users can create events
- Users can see events if they are provided with the link
- Users can add offers to events
- Users can see the offers of an event
- Users can submit ride requests indicating where they are, how far they will
  travel, and by when they want to be there
- The event page shows an anonymous demand signal (per-direction counts and
  per-region aggregates) so drivers can see if their offer is wanted
- When a new offer is confirmed, all matching ride requests within their
  chosen radius are notified by email
- Users can contact other users through the platform via email
- Offers can carry messenger contacts (phone, SMS, Signal, WhatsApp,
  Telegram, Instagram) so people can reach out off-platform directly
- "Clean driver" feature: Offers by car can be set to "driver needed"
- Events, offers, and ride requests are automatically deleted after they
  have passed
- Geonames is used to resolve postal codes to latitude and longitude
- An ActiveAdmin interface at `/admin` lets operators view and delete
  events, offers, ride requests, and CMS content
- [Altcha](https://altcha.org) is integrated as captcha for all forms
- Localized in English, German, Spanish, and French

## Installation

### Requirements

- Ruby 4
- Rails 8

### Setup

1. Clone the repository

2. Install the dependencies
```sh
bundle config set --local path 'vendor/gems'
bundle install
```

3. Create the database
```sh
bundle exec rails db:create
bundle exec rails db:migrate
```

4. Start the server
```sh
bundle exec rails server
```

## Configuration

The following table lists all environment variables that are used by the application.
Set them in an env file, export them in your shell, or wire them into your deployment
mechanism of choice.

| Environment variable              | Description                                                                     |
|-----------------------------------|---------------------------------------------------------------------------------|
| `SECRET_KEY_BASE`                 | A secret string for the Rails application. Generate it with `rails secret`      |
| `ALTCHA_HMAC_KEY`                 | A secret string for the Altcha HMAC algorithm. Generate it with `rails secret`  |
| `GEONAMES_USERNAME`               | A Geonames username. Obtain one from https://www.geonames.org/login             |
| `HOPHUB_BASE_URL`                 | The base URL for the Rails installation                                         |
| `HOPHUB_DATABASE_USERNAME`        | The username for the SQL database                                               |
| `HOPHUB_DATABASE_PASSWORD`        | The password for the SQL database                                               |
| `HOPHUB_DATABASE_HOST`            | The SQL database host name                                                      |
| `HOPHUB_DATABASE_PORT`            | The SQL database host port                                                      |
| `HOPHUB_DATABASE_NAME`            | The name of the SQL database                                                    |
| `HOPHUB_MAIL_SERVER`              | The host name of the SMTP server                                                |
| `HOPHUB_MAIL_PORT`                | The port of the SMTP service                                                    |
| `HOPHUB_MAIL_FROM`                | The email address to be used as `From` address in outgoing emails               |
| `HOPHUB_MAIL_DOMAIN`              | The domain to be used in outgoing emails                                        |
| `HOPHUB_MAIL_USERNAME`            | If your mail server requires authentication, set the username in this setting   |
| `HOPHUB_MAIL_PASSWORD`            | If your mail server requires authentication, set the password in this setting   |
| `HOPHUB_SINGLE_EVENT_ID`          | Optional ID of a single event that is always shown on the landing page          |
| `HOPHUB_REDIS_CACHE`              | Optional Redis instance for caching                                             |
| `EXCEPTION_NOTIFIER_SENDER`       | Optional sender for notification emails                                         |
| `EXCEPTION_NOTIFIER_RECIPIENT`    | Optional addresses of recipients for exception notification emails              |
| `PLAUSIBLE_DOMAIN`                | The domain of the Plausible instance for the privacy policy                     |
| `PLAUSIBLE_SRC`                   | The source of the JavaScript script for Plausible                               |

### HTTP routes

Please make sure to protect the `/admin` path through something like HTTP basic auth or other methods in your deployed HTTP server.
The application itself does not manage user accounts and roles, and without external protection all data is public.

Similarly, the `/metrics` and `/up` paths are probably also something you want to protect.

## Deploying with Docker Compose

A reference [`docker-compose.yaml`](docker-compose.yaml) is included for self-hosting the app together with its runtime dependencies. It brings up three services — a Postgres database, a Valkey instance for the Rails cache, and the app itself from the prebuilt image `ghcr.io/hophubproject/hophub:main` (exposed on port 3000). Before bringing the stack up, edit the file (or supply an env file) to replace the placeholder values for at minimum `SECRET_KEY_BASE`, `ALTCHA_HMAC_KEY`, `GEONAMES_USERNAME`, `HOPHUB_BASE_URL`, `HOPHUB_DATABASE_PASSWORD`, and your SMTP credentials — see [Configuration](#configuration) for the full list. Then run `docker compose up -d`, and on first boot prepare the database with `docker compose exec app bin/rails db:prepare`.

The app is then reachable at [http://localhost:3000](http://localhost:3000) for demo purposes. Put a TLS-terminating reverse proxy in front of that port for any real deployment.

Note that the `/admin` route **must be protected** at the ingress level (e.g. HTTP Basic auth, an IP allowlist, or your provider's auth) — the app itself has no user accounts or roles, so without external protection the admin interface is wide open. The `/metrics` and `/up` endpoints are also worth restricting.

## Updating vendored JavaScript and CSS

Third-party JS, CSS, and fonts are vendored under `vendor/javascript/` and
`vendor/assets/`. JS deps are pinned in `config/importmap.rb` with a
`# @<version>` comment recording the version of the file currently on disk.
CSS deps have no pin file — the version is recorded in the table below and in
git history. The file on disk *is* the pin: nothing reaches out to a CDN at
runtime, and a vendored file only changes when you re-download.

To upgrade a dependency:

1. Re-download the new version into the matching directory below.
2. For JS deps: update the `# @<version>` comment in `config/importmap.rb`.
3. Run `bin/rails test` and start the app to verify nothing broke.

Source URLs (replace `<ver>` to upgrade):

| File                                              | Source                                                                                                          |
|---------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
| `vendor/javascript/bootstrap.js`                  | `https://cdn.jsdelivr.net/npm/bootstrap@<ver>/dist/js/bootstrap.min.js`                                         |
| `vendor/javascript/popper.js`                     | `https://cdn.jsdelivr.net/npm/@popperjs/core@<ver>/dist/umd/popper.min.js`                                      |
| `vendor/javascript/tempus-dominus.js`             | `https://cdn.jsdelivr.net/npm/@eonasdan/tempus-dominus@<ver>/dist/js/tempus-dominus.min.js`                     |
| `vendor/javascript/tempus-dominus-bi-one.js`      | `https://cdn.jsdelivr.net/npm/@eonasdan/tempus-dominus@<ver>/dist/plugins/bi-one.js`                            |
| `vendor/javascript/altcha.js`                     | `https://cdn.jsdelivr.net/npm/altcha@<ver>/+esm`                                                                |
| `vendor/javascript/confetti.js`                   | `https://cdn.jsdelivr.net/npm/canvas-confetti@<ver>/dist/confetti.browser.min.js`                               |
| `vendor/javascript/es-module-shims.js`            | `https://cdn.jsdelivr.net/npm/es-module-shims@<ver>/dist/es-module-shims.min.js` *(loaded conditionally — see `app/views/layouts/application.html.haml`)* |
| `vendor/assets/stylesheets/tempus-dominus.css`    | `https://cdn.jsdelivr.net/npm/@eonasdan/tempus-dominus@<ver>/dist/css/tempus-dominus.min.css`                   |
| `vendor/assets/stylesheets/bootstrap-icons.css.erb` | `https://cdn.jsdelivr.net/npm/bootstrap-icons@<ver>/font/bootstrap-icons.min.css` *(after download, replace the `url("fonts/...")` references with `<%= asset_path("bootstrap-icons.woff2") %>` / `.woff`)* |
| `vendor/assets/fonts/bootstrap-icons.woff2`       | `https://cdn.jsdelivr.net/npm/bootstrap-icons@<ver>/font/fonts/bootstrap-icons.woff2`                           |
| `vendor/assets/fonts/bootstrap-icons.woff`        | `https://cdn.jsdelivr.net/npm/bootstrap-icons@<ver>/font/fonts/bootstrap-icons.woff`                            |

Once vendored, these files are served by Sprockets from `/assets/<name>-<hash>.<ext>`
with fingerprinted filenames, so cache busting on upgrade is automatic.
Subresource-Integrity (SRI) hashes are computed by Sprockets and emitted by
`stylesheet_link_tag ..., integrity: true` and by importmap-rails for JS pins,
so the browser will refuse to execute or apply a tampered file.

## Run tests

```sh
bundle exec rails test
```

## Geonames

The project uses the [Geonames](https://www.geonames.org/) API to resolve postal codes to latitude and longitude. You need to create a Geonames account and set the `GEONAMES_USERNAME` environment variable to your username. The Geonames API is called server-side with the postal code, country code, and the Geonames username, so the IP address of the client is never sent to Geonames — it only ever sees the application's IP.

## Caching

The project uses the Rails cache to store the results of expensive operations, such as geocoding locations. The cache can be configured with the `HOPHUB_REDIS_CACHE` environment variable, which should point to a Redis instance. If this variable is not set, the cache is not used.

## Micro CMS

The project features a very minimalistic content management system for static text rendering with [Markdown](https://daringfireball.net/projects/markdown/). These texts are stored in a model called 'Content' and are rendered by the `ContentsController`. The content is stored in the database and can most easily be edited through the admin interface. Each entry has a unique key that is used to identify the content in the view and a locale attribute that is used to determine the language of the content. A fallback flag can be set to determine if the content should be used as a fallback for other languages.

The following keys are used in the project:

- `tos`: Terms of Service
- `privacy`: Data privacy policy
- `imprint`: Imprint
- `instance-info`: Information about the instance, displayed on the landing page

## Single event deployment

If you want to deploy the project with a single event that is always shown on the landing page, you can set the `HOPHUB_SINGLE_EVENT_ID` environment variable to the ID of the event. Request to the landing page will then be redirected to the event page of the event with the given ID.

Note that the creation of events is not possible in this mode. The event with the given ID must be created manually through the admin interface or the Rails console.

## Plausible analytics

The project features an integration with [Plausible](https://plausible.io/) for privacy-friendly analytics. Plausible is a lightweight and open-source web analytics tool that doesn’t use cookies and is fully compliant with GDPR, CCPA and PECR. The application scaffold includes the Plausible JavaScript script with the domain and source that are set in the `PLAUSIBLE_DOMAIN` and `PLAUSIBLE_SRC` environment variables. If these variables are not set, the Plausible script is not included in the application layout.

## Cleanup task

The project features a cleanup task that has to be run periodically to remove old events, offers, and ride requests from the database.
The task is defined in the `lib/tasks/cleanup.rake` file and can be executed with the following command:

```sh
bundle exec rails hophub:cleanup
```

Wire it into cron, a systemd timer, or your deployment platform's scheduler.

## Data privacy

If you host the project yourself you should be aware of the data privacy implications and legal requirements in your jurisdiction.

Consider the following aspects when crafting the privacy policy for your instance:

- The project does not use any cookies except for the session cookie that is required for the functionality of the website.
- The project does not use any tracking or analytics tools.
- For events, the following data is stored in the database:
  - The title of the event
  - The ID of the event, derived from the title
  - The description of the event
  - The end date and time of the event
  - The email address of the creator of the event
- Events are automatically deleted from the database after they have passed
- Events can be deleted manually by their creators
- For offers, the following data is stored in the database:
  - The ID of the offer
  - The email address of the creator of the offer
  - The name/pseudonym of the creator of the offer
  - For each messenger contact the creator added: the kind (phone, SMS,
    Signal, WhatsApp, Telegram, or Instagram) and the value the creator
    provided
  - The event ID of the event the offer belongs to
  - The direction (way there / way back)
  - The number of seats available or needed
  - The mode of transportation (car, train, bus, bicycle, walk, other)
  - The departure/arrival location and country
  - The departure/arrival date and time
  - The departure/arrival latitude and longitude
  - The notes of the creator of the offer
  - The "clean driver" flag
- Offers are automatically deleted from the database after they have passed
- Offers can be deleted manually by their creators
- For ride requests, the following data is stored in the database:
  - The ID of the ride request
  - The email address of the requester
  - The event ID of the event the request belongs to
  - The direction (way there / way back)
  - The location (zip code) and country
  - The latitude and longitude resolved from the zip code
  - The search radius (how far the requester is willing to travel)
  - The latest acceptable arrival time
  - The locale of the requester at submission time
- Ride requests are automatically deleted from the database after their
  latest acceptable arrival time has passed, or when the event ends
- Ride requests can be deleted manually by their creators through a tokenized
  link sent in the confirmation email
- When a new offer is confirmed, ride requests for the same event and
  direction whose chosen radius covers the offer's location receive a
  notification email. The driver's email address is not shared with the
  requester in this notification.
- When a user contacts another user through the platform, the email address of the sender is used as the Reply-To address in the email. Neither the email address of the sender nor the text they write is stored in the database.
- The GDPR information tool allows users to query the data stored in the database for a given email address. The tool sends an email to the given email address, containing a list of all events and offers that are associated with the email address with links to delete the data.
- Geonames is used to resolve locations to latitude and longitude. The Geonames API is called with the location name and the Geonames username. The IP address of the client is not sent to the Geonames API. More information can be found in the [Geonames privacy policy](https://www.geonames.org/export/privacy.html).
- All third-party JavaScript, CSS, and fonts are vendored under `vendor/javascript/` and `vendor/assets/` and served from the same host as the application. The browser does not contact any third-party CDN at runtime.
- If you use the Plausible analytics integration, you should inform your users about the data that is collected by Plausible. More information can be found in the [Plausible privacy policy](https://plausible.io/privacy-policy).

## GDPR information tool

The project features a GDPR information tool that allows users to query the data stored in the database for a given email address. The tool sends an email to the given email address, containing a list of all events and offers that are associated with the email address with links to delete the data.

## Metrics

The `/metrics` route can be used to query statistical data from the HopHub instance in a format suitable for consumption by [Prometheus](https://prometheus.io/).
The `/up` route can be used for health checks of the instance with something like [Kubernetes](https://kubernetes.io/).

## Contributing

### Reporting issues

If you find a bug or have a feature request, please report it in the issue tracker.

### Contributing code

1. Fork it
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

### Add localization

If you want to add a new language, please follow these steps:

1. Add a new file in the `config/locales` directory. The file should be named after the language code (e.g. `en.yml` for English, `de.yml` for German, etc.). The file should contain a hash with the translations. The keys should be the same as in the `en.yml` file.
2. Create new mailer views in the `app/views/event_mailer`, `app/views/offer_mailer`, `app/views/ride_request_mailer`, and `app/views/gdpr_inquiry_mailer` directories. The file names must contain the language code (e.g. `de` for German). The content should be the same as for the `en` versions.
3. Add the new language to `I18n.available_locales` in `config/initializers/locale.rb`.
4. Open a pull request.

## Donations

If you like the project and want to support its development, you can donate through Ko-fi:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/E1E5WTMM4)

## License

This project is licensed under the AGPL-3.0 License - see the [LICENSE](LICENSE) file for details
