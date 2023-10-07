defmodule Ebb.Watson do
  @moduledoc """
  Defines an interface for the Watson CLI.
  """

  alias Ebb.Configuration

  def report(%Configuration{} = config) do
    watson_report = Jason.decode!(run_watson_report(config.start_date))

    %{
      start_date: fetch_start_date!(watson_report, config),
      total_time_in_seconds: fetch_time!(watson_report)
    }
  end

  defp run_watson_report(%Date{} = start_date) do
    from = Date.to_iso8601(start_date)

    {result, 0} =
      System.cmd("watson", ["report", "--json", "--current", "--from", from])

    result
  end

  defp fetch_start_date!(watson_report, config) do
    watson_report
    |> Map.fetch!("timespan")
    |> Map.fetch!("from")
    |> parse_datetime!(config.time_zone)
    |> DateTime.to_date()
  end

  defp fetch_time!(watson_report) do
    Map.fetch!(watson_report, "time")
  end

  defp parse_datetime!(s, time_zone) do
    {:ok, dt, _} = DateTime.from_iso8601(s)
    DateTime.shift_zone!(dt, time_zone)
  end
end
