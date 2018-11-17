# README

This API is developed using Ruby v2.5.1, Rails v5.2.1, and SQLite3 as database back-end.

## Installation

 1. Clone or download this repo to a directory.

 2. Run `bundle install` in that directory.

 3. Create `config/database.yml` or copy & edit from `config/database.yml-example`.

 4. Run `rake db:setup` to create the database for development and test envs.

## Running

 1. Run `rails s` to start the server at the default port 3000.

## Testing

For Rails unit and request specs, run `rake spec`.

## Files & Directories

The files for Rails are located in `app` directory as usual, and the specs are in `spec`.

## API Documentation

I've added `apipie-rails` gem to handle the API documentation, please visit `http://localhost:3000/apipie` to view the list.

## Miscellaneous

The code is written based on certain `rubocop` recommendations, run `rubocop` to verify if there are any offenses.

## Problems

Some tests from Postman are checking the ids and titles of certain records, they need to be modified to reflect the real test environment.