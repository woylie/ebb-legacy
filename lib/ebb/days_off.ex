defmodule Ebb.DaysOff do
  @moduledoc """
  Defines functions for calculations regarding the days off.
  """

  alias Ebb.Configuration

  def calculate_vacation_days(year, %Configuration{
        allowed_days_off: %{vacation_days: allowed_vacation_days},
        vacation_days: vacation_days
      }) do
    calculate_taken_and_left_days(year, allowed_vacation_days, vacation_days)
  end

  def calculate_sick_days(year, %Configuration{
        allowed_days_off: %{sick_days: allowed_sick_days},
        sick_days: sick_days
      }) do
    calculate_taken_and_left_days(year, allowed_sick_days, sick_days)
  end

  defp calculate_taken_and_left_days(year, allowed_days, dates) do
    taken_days = dates |> Enum.map(&day_factor(&1, year)) |> Enum.sum()
    days_left = allowed_days - taken_days
    {allowed_days, taken_days, days_left}
  end

  defp day_factor({date, description}, year) do
    if date.year == year do
      if String.ends_with?(description, " (h)"),
        do: 0.5,
        else: 1
    else
      0
    end
  end
end
