defmodule Ebb.CLI do
  @moduledoc """
  Defines the CLI interface.
  """

  alias Ebb.Configuration
  alias Ebb.DaysOff
  alias Ebb.Watson
  alias Ebb.WorkingHours

  @seconds_per_hour 3600
  @seconds_per_minutes 60

  def main(["balance" | _]) do
    config = Configuration.read_config()
    today = config.timezone |> DateTime.now!() |> DateTime.to_date()

    %{start_date: start_date, total_time_in_seconds: total_time_in_seconds} =
      Watson.report(config)

    expected_work_seconds =
      WorkingHours.calculate_expected_work_seconds(today, config)

    diff_seconds = total_time_in_seconds - expected_work_seconds

    IO.puts("Time balance\n")

    print_table([
      {"Start date", Date.to_string(start_date)},
      {"End date", Date.to_string(today)},
      {"Expected", seconds_to_duration(expected_work_seconds)},
      {"Actual", seconds_to_duration(total_time_in_seconds)},
      :divider,
      {"Balance", seconds_to_duration(diff_seconds)}
    ])
  end

  def main(["daysoff" | _]) do
    config = Configuration.read_config()
    year = DateTime.now!(config.timezone).year

    %{
      allowed: allowed_vacation_days,
      taken: taken_vacation_days,
      left: vacation_days_left
    } = DaysOff.calculate_vacation_days(year, config)

    %{
      allowed: allowed_sick_days,
      taken: taken_sick_days,
      left: sick_days_left
    } = DaysOff.calculate_sick_days(year, config)

    print_table([{"Year", to_string(year)}])

    IO.puts("\n\nSick days\n")

    print_table([
      {"Allowed", to_string(allowed_sick_days)},
      {"Taken", to_string(taken_sick_days)},
      :divider,
      {"Left", to_string(sick_days_left)}
    ])

    IO.puts("\n\nVacation days\n")

    print_table([
      {"Allowed", to_string(allowed_vacation_days)},
      {"Taken", to_string(taken_vacation_days)},
      :divider,
      {"Left", to_string(vacation_days_left)}
    ])
  end

  def main(["config" | _]) do
    config = Configuration.read_config()
    IO.puts("#{inspect(config, pretty: true)}")
  end

  def main(_) do
    IO.puts("""
    ebb balance - Print current time balance.
    ebb config - Print configuration.
    """)
  end

  defp print_table(rows) do
    max_key_length = get_max_key_length(rows)
    max_value_length = get_max_value_length(rows)
    key_pad_size = max_key_length + 1
    line_length = key_pad_size + 4 + max_value_length

    Enum.each(rows, fn
      {key, value} ->
        header = String.pad_trailing(key <> ":", key_pad_size)
        value = String.pad_leading(value, max_value_length)
        IO.puts("#{header}    #{value}")

      :divider ->
        IO.puts(String.duplicate("=", line_length))
    end)
  end

  defp get_max_key_length(rows) do
    rows
    |> Enum.map(fn
      {key, _} -> String.length(key)
      _ -> 0
    end)
    |> Enum.max()
  end

  defp get_max_value_length(rows) do
    rows
    |> Enum.map(fn
      {_, value} -> String.length(value)
      _ -> 0
    end)
    |> Enum.max()
  end

  defp seconds_to_duration(seconds) when is_float(seconds) do
    seconds |> Float.round() |> trunc() |> seconds_to_duration
  end

  defp seconds_to_duration(seconds) when is_integer(seconds) do
    hours = div(seconds, @seconds_per_hour)
    remaining_after_hours = rem(seconds, @seconds_per_hour)

    minutes =
      remaining_after_hours
      |> div(@seconds_per_minutes)
      |> pad_zeroes()

    remaining_seconds =
      remaining_after_hours
      |> rem(@seconds_per_minutes)
      |> pad_zeroes()

    "#{hours}h #{minutes}m #{remaining_seconds}s"
  end

  defp pad_zeroes(value) when is_integer(value) do
    value
    |> to_string()
    |> String.pad_leading(2, "0")
  end
end
