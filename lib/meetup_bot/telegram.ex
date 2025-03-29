defmodule MeetupBot.Telegram do
  # TODO: add test
  def post(text) do
    # TODO: on local doesn't get the variables from my `.env` file. Read that a library may be needed to automatically load variables. Investigate more.
    token = System.get_env("TELEGRAM_BOT_TOKEN")
    chat_id = System.get_env("TELEGRAM_CHAT_ID")
    url = "https://api.telegram.org/bot#{token}/sendMessage"

    if token && chat_id do
      Req.post!(url,
        json: %{
          chat_id: chat_id,
          text: text,
          parse_mode: "MarkdownV2"
        }
      )
    end
  end

  def build_text([]) do
    "No hay meetups agendados"
  end

  def build_text(meetups) do
    header = "Los próximos meetups son:\n\n"
    meetups_text = to_bullet_list(meetups)
    header <> meetups_text
  end

  defp to_bullet_list(meetups) do
    Enum.map_join(meetups, "\n\n", fn meetup -> to_bullet_item(meetup) end)
  end

  defp to_bullet_item(meetup) do
    # TODO: check if I need to escape some text as in the Slack module.
    "• #{Calendar.strftime(meetup.datetime, "%a, %-d %B \\- %H:%M")} \\- [#{meetup.name}](#{meetup.event_url})"
  end
end
