defmodule Ebb.DaysOffTest do
  use ExUnit.Case, async: true

  alias Ebb.Configuration
  alias Ebb.DaysOff

  describe "calculate_vacation_days/2" do
    test "returns a summary of vacation days" do
      year = 2462

      config =
        %Configuration{
          allowed_days_off: %{vacation_days: 50},
          vacation_days: %{
            ~D[2461-12-31] => "New Year's Eve",
            ~D[2462-01-01] => "New Year's Day",
            ~D[2462-06-24] => "Midsummer (h)",
            ~D[2462-12-31] => "Another New Year's Eve",
            ~D[2463-01-01] => "Another New Year's Day"
          }
        }

      assert DaysOff.calculate_vacation_days(year, config) == %{
               allowed: 50,
               taken: 2.5,
               left: 47.5
             }
    end
  end

  describe "calculate_sick_days/2" do
    test "returns a summary of sick days" do
      year = 2462

      config =
        %Configuration{
          allowed_days_off: %{sick_days: 50},
          sick_days: %{
            ~D[2461-12-31] => "New Year's Eve Sickness",
            ~D[2462-01-01] => "New Year's Day Sickness",
            ~D[2462-06-24] => "Midsummer Sickness (h)",
            ~D[2462-12-31] => "Another New Year's Eve Sickness",
            ~D[2463-01-01] => "Another New Year's Day Sickness"
          }
        }

      assert DaysOff.calculate_sick_days(year, config) == %{
               allowed: 50,
               taken: 2.5,
               left: 47.5
             }
    end
  end
end
