defmodule MeetupBot.Meetup do
  @meetup_names [
    "ember-montevideo",
    "ReactJS-Uruguay",
    "Angular-MVD",
    "montevideojs",
    "Front-end-MVD",
    "Elixir-Montevideo",
    "Montevideo-Web-Developers",
    "Rust-Uruguay",
    "py-mvd",
    "Loop-Talks",
    "Laravel-UY",
    "Montevideo-Vue-JS-Meetup",
    "NahualUY",
    "AETERNITY-URUGUAY",
    "mujeresituy",
    "IBM-Developers-Montevideo",
    "Testing-Uy",
    "dribbblemvd",
    "Colaboradores-en-Gestion-de-Proyectos",
    "PyLadiesUy",
    "ruby-montevideo",
    "Montevideo-Applied-Data-Science-and-Big-Data",
    "montevideo-leadership-development-meetup-group",
    "OWASP-Uruguay-Chapter",
    "react-native-uruguay",
    "agileuy",
    "AWS-UG-Montevideo",
    "AI-for-Devs-Montevideo",
    "abstractatechtalks"
  ]

  def fetch_upcoming_meetups() do
    q =
      @meetup_names
      |> Enum.with_index()
      |> Enum.map_join("\n", fn {meetup, index} ->
        ~s/g#{index}: groupByUrlname(urlname: "#{meetup}") {...F}/
      end)

    query = """
      query {
        #{q}
      }

      fragment F on Group {
        name
        upcomingEvents(input: { first: 1 }) {
          edges {
            node {
              id
              title
              going
              waiting
              dateTime
              endTime
              timezone
              eventUrl
            }
          }
        }
      }
    """

    response =
      Req.new(base_url: "https://api.meetup.com")
      |> OpentelemetryReq.attach(span_name: "meetup_bot.req", no_path_params: true)
      |> Req.post!(url: "/gql", json: %{query: query})

    response.body["data"]
    |> Map.values()
    |> Enum.map(&process_response/1)
    |> Enum.filter(& &1)
    |> Enum.sort_by(& &1.datetime, NaiveDateTime)
  end

  # Non existent meetup
  defp process_response(nil), do: nil
  # Meetup with no upcoming event
  defp process_response(%{"upcomingEvents" => %{"edges" => []}}), do: nil

  defp process_response(meetup) do
    [
      %{
        "node" => %{
          "id" => id,
          "eventUrl" => event_url,
          "title" => title,
          "dateTime" => dt,
          "endTime" => edt
        }
      }
    ] = get_in(meetup, ["upcomingEvents", "edges"])

    # Revisit
    {:ok, dt} =
      dt
      |> String.replace(~r/T(.*)-/, "T\\1:00-")
      |> NaiveDateTime.from_iso8601()

    {:ok, edt} =
      edt
      |> String.replace(~r/T(.*)-/, "T\\1:00-")
      |> NaiveDateTime.from_iso8601()

    %{
      id: id,
      name: meetup["name"],
      title: title,
      event_url: event_url,
      datetime: dt,
      end_datetime: edt
    }
  end
end
