defmodule Ebb.Configuration do
  @moduledoc """
  Defines a Configuration struct and decode/encode functions.
  """

  @seconds_per_day 86_400
  @seconds_per_hour 3600
  @seconds_per_minute 60

  @type t :: %__MODULE__{
          time_zone: Calendar.time_zone(),
          start_date: Date.t(),
          time_adjustment_in_seconds: integer,
          working_days: working_days(),
          holidays: date_map(),
          vacation_days: date_map(),
          sick_days: date_map(),
          allowed_days_off: allowed_days_off()
        }

  @type date_map :: %{optional(Date.t()) => String.t()}
  @type allowed_days_off :: %{sick_days: integer, vacation_days: integer}
  @type working_days :: %{
          1 => non_neg_integer,
          2 => non_neg_integer,
          3 => non_neg_integer,
          4 => non_neg_integer,
          5 => non_neg_integer,
          6 => non_neg_integer,
          7 => non_neg_integer
        }

  defstruct time_zone: "Etc/UTC",
            start_date: ~D[3000-01-01],
            time_adjustment_in_seconds: 0,
            working_days: %{},
            holidays: %{},
            vacation_days: %{},
            sick_days: %{},
            allowed_days_off: %{}

  def read_config do
    config_path()
    |> File.read!()
    |> parse!()
    |> validate!()
  end

  defp config_path do
    "EBB_CONFIG_PATH"
    |> System.get_env(default_folder())
    |> Path.join("config.yml")
  end

  defp default_folder do
    Path.expand("~/.config/ebb")
  end

  defp parse!(file) do
    YamlElixir.read_from_string!(file)
  end

  defp validate!(map) do
    allowed_days_off =
      map |> Map.fetch!("allowed_days_off") |> validate_allowed_days_off!()

    working_days = map |> Map.fetch!("working_days") |> validate_working_days!()

    %__MODULE__{
      allowed_days_off: allowed_days_off,
      holidays: map |> Map.fetch!("holidays") |> validate_days!(),
      vacation_days: map |> Map.fetch!("vacation_days") |> validate_days!(),
      sick_days: map |> Map.fetch!("sick_days") |> validate_days!(),
      start_date: map |> Map.fetch!("start_date") |> Date.from_iso8601!(),
      time_adjustment_in_seconds:
        map |> Map.fetch!("time_adjustment") |> validate_duration!(),
      time_zone: map |> Map.fetch!("time_zone") |> validate_time_zone!(),
      working_days: working_days
    }
  end

  defp validate_days!(%{} = days) do
    Enum.into(days, %{}, fn {date_str, description} ->
      {Date.from_iso8601!(date_str), description}
    end)
  end

  defp validate_days!(nil), do: %{}

  defp validate_allowed_days_off!(map) do
    %{
      vacation_days: Map.fetch!(map, "vacation_days"),
      sick_days: Map.fetch!(map, "sick_days")
    }
  end

  defp validate_working_days!(map) do
    %{
      1 => Map.fetch!(map, "monday"),
      2 => Map.fetch!(map, "tuesday"),
      3 => Map.fetch!(map, "wednesday"),
      4 => Map.fetch!(map, "thursday"),
      5 => Map.fetch!(map, "friday"),
      6 => Map.fetch!(map, "saturday"),
      7 => Map.fetch!(map, "sunday")
    }
  end

  defp validate_time_zone!(tz) do
    unless Tzdata.canonical_zone?(tz) do
      raise """
      Invalid time zone

      The configuration file sets an invalid time zone: #{tz}
      """
    end

    tz
  end

  defp validate_duration!(s) do
    parts = String.split(s, " ")

    Enum.reduce(parts, 0, fn part, seconds ->
      case Integer.parse(part) do
        {n, "d"} -> n * @seconds_per_day + seconds
        {n, "h"} -> n * @seconds_per_hour + seconds
        {n, "m"} -> n * @seconds_per_minute + seconds
        {n, "s"} -> n + seconds
      end
    end)
  end
end
