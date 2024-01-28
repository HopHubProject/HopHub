# HopHub - the ride sharing platform

[![HopHub](app/assets/images/logo.png)](https://hophub.xyz)

HopHub is a super simple ride sharing platform that aims to reduce car traffic
of events and make the world a slightly better place. It allows users to create
events and add offers and requests for rides to these events. Users can then
contact each other through the platform to arrange the details.

This project is implemented using Ruby on Rails.

The reference implementation is available at [hophub.xyz](https://hophub.xyz) but you can also host your own instance
as long as you comply with the [AGPL-3.0 License](LICENSE).

## Features

This project takes care to be as data protection friendly as possible. It only stores the data that is necessary to provide the service and does not use 3rd party cookies. It also does not use any tracking or analytics tools.

- Users can create events
- Users can see events if they are provided with the link
- Users can add offers and requests to events
- Users can see the offers and requests of an event
- Users can contact other users through the platform via email
- Events, offers and requests are automatically deleted after they have passed
- Admins can see all users, events, offers and requests
- Admins can delete users, events, offers and requests
- [Altcha](https://altcha.org) is integrated as captcha for all forms

## Installation

### Requirements

- Ruby 3.2.2
- Rails 7.0.0

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
You can set them in some env file magic, export them in your shell or use the Cuberfile
to deploy on k8s.

| Environment variable              | Description                                                                     |
|-----------------------------------|---------------------------------------------------------------------------------|
| `SECRET_KEY_BASE`                 | A secret string for the Rails application. Generate it with `rails secret`      |
| `ALTCHA_HMAC_KEY`                 | A secret string for the Altcha HMAC algorithm. Generate it with `rails secret`  |
| `MAPTILER_API_KEY`                | A MapTiler API key. Obtain one from https://cloud.maptiler.com                  |
| `HOPHUB_BASE_URL`                 | The base URL for the Rails installation                                         |
| `HOPHUB_DATABASE_USERNAME`        | The username for the SQL database                                               |
| `HOPHUB_DATABASE_PASSWORD`        | The passwort for the SQL database                                               |
| `HOPHUB_DATABASE_HOST`            | The SQL database host name                                                      |
| `HOPHUB_DATABASE_PORT`            | The SQL database host port                                                      |
| `HOPHUB_DATABASE_NAME`            | The name of the SQL database                                                    |
| `HOPHUB_MAIL_SERVER`              | The host name of the SMTP server                                                |
| `HOPHUB_MAIL_PORT`                | The port of the SMTP service                                                    |
| `HOPHUB_MAIL_FROM`                | The email address to be used as `From` address in outgoing emails               |
| `HOPHUB_MAIL_DOMAIN`              | The domain to be used in outgoing emails                                        |
| `EXCEPTION_NOTIFIER_SENDER`       | Optional sender for notification emails                                         |
| `EXCEPTION_NOTIFIER_RECIPIENT`    | Optional addresses of recipients for exception notification emails              |

## Run tests

```sh
bundle exec rails test
```

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
2. Create new mailer views in the `app/views/event_mailer` and `app/views/entry_mailer` directories. The file names must contain the language code (e.g. `de` for German). The content should be the same as for the `en` versions.
3. Add the new language to `I18n.available_locales` in the `config/locales.rb` file.
4. Open a pull request.

## License

This project is licensed under the AGPL-3.0 License - see the [LICENSE](LICENSE) file for details
