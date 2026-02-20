# Cucharada

AI-powered recipe app for the Argentine market. Upload a photo or paste a link to any recipe and Gemini extracts ingredients and steps automatically. Includes a database of 10,000 Argentine ingredients, search by ingredients, and a favorites system.

## Tech Stack

- **Backend**: Ruby on Rails 8.1
- **Frontend**: HTML/ERB + Tailwind CSS
- **Database**: SQLite
- **AI**: Google Gemini API (free tier)

## Prerequisites

- Ruby 3.3.6 (managed via asdf)
- Bundler

## Setup

```bash
# 1. Install Ruby 3.3.6 with asdf
asdf plugin add ruby
asdf install ruby 3.3.6

# 2. Install dependencies
bundle install

# 3. Create and seed the database
rails db:create db:migrate db:seed

# 4. Configure the Gemini API key
# Create a .env file in the project root:
echo "GEMINI_API_KEY=your_key_here" > .env
# Get a free key at: https://aistudio.google.com/apikey

# 5. Start the server
bin/dev
```

Then open `http://localhost:3000`.

`bin/dev` uses `Procfile.dev` to run Rails + Tailwind CSS watcher together.

## Features

- Import recipes from photos (AI-powered extraction)
- Import recipes from URLs (scraping + AI parsing)
- Manual recipe creation
- Search recipes by ingredients you have at home
- Favorites system
- User authentication
