#!/bin/bash

# Load environment variables
export $(grep -v '^#' .env | xargs)

# Print loaded variables for debugging
echo "Loaded TELEGRAM_BOT_TOKEN: ${TELEGRAM_BOT_TOKEN:0:5}..."
echo "Loaded TELEGRAM_CHAT_ID: $TELEGRAM_CHAT_ID"

# Start the application
iex -S mix

# Run test command inside iex console

# test_meetup = %{name: "Test Meetup", datetime: DateTime.utc_now(), event_url: "https://meetup.com/test"}; message = MeetupBot.Telegram.build_text([test_meetup]); MeetupBot.Telegram.post(message)
