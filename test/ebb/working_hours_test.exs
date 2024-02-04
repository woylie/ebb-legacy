defmodule Ebb.WorkingHoursTest do
  use ExUnit.Case, async: true

  alias Ebb.Configuration
  alias Ebb.WorkingHours

  describe "calculate_expected_work_seconds/2" do
    test "counts the whole end date" do
      config =
        %Configuration{
          start_date: ~D[2024-01-01],
          working_days: %{
            1 => 8,
            2 => 6,
            3 => 0,
            4 => 0,
            5 => 0,
            6 => 0,
            7 => 0
          }
        }

      assert WorkingHours.calculate_expected_work_seconds(
               ~D[2024-01-01],
               config
             ) == 8 * 60 * 60

      assert WorkingHours.calculate_expected_work_seconds(
               ~D[2024-01-02],
               config
             ) == 8 * 60 * 60 + 6 * 60 * 60

      assert WorkingHours.calculate_expected_work_seconds(
               ~D[2024-01-03],
               config
             ) == 8 * 60 * 60 + 6 * 60 * 60
    end

    test "covers multiple weeks" do
      config =
        %Configuration{
          start_date: ~D[2024-01-01],
          working_days: %{
            1 => 8,
            2 => 6,
            3 => 0,
            4 => 0,
            5 => 0,
            6 => 0,
            7 => 0
          }
        }

      assert WorkingHours.calculate_expected_work_seconds(
               ~D[2024-01-14],
               config
             ) == (8 * 60 * 60 + 6 * 60 * 60) * 2
    end

    test "handles mid-week end date" do
      config =
        %Configuration{
          start_date: ~D[2024-01-01],
          working_days: %{
            1 => 8,
            2 => 6,
            3 => 5,
            4 => 0,
            5 => 0,
            6 => 0,
            7 => 0
          }
        }

      assert WorkingHours.calculate_expected_work_seconds(
               ~D[2024-01-16],
               config
             ) ==
               (8 * 60 * 60 + 6 * 60 * 60 + 5 * 60 * 60) * 2 +
                 (8 * 60 * 60 + 6 * 60 * 60)
    end

    test "considers vacation days" do
      config =
        %Configuration{
          start_date: ~D[2024-01-01],
          working_days: %{
            1 => 8,
            2 => 6,
            3 => 5,
            4 => 0,
            5 => 0,
            6 => 0,
            7 => 0
          },
          vacation_days: %{
            ~D[2024-01-03] => "Vacation"
          }
        }

      assert WorkingHours.calculate_expected_work_seconds(
               ~D[2024-01-16],
               config
             ) ==
               (8 * 60 * 60 + 6 * 60 * 60 + 5 * 60 * 60) * 2 +
                 (8 * 60 * 60 + 6 * 60 * 60) - 5 * 60 * 60
    end

    test "considers holidays" do
      config =
        %Configuration{
          start_date: ~D[2024-01-01],
          working_days: %{
            1 => 8,
            2 => 6,
            3 => 5,
            4 => 0,
            5 => 0,
            6 => 0,
            7 => 0
          },
          holidays: %{
            ~D[2024-01-03] => "Holiday"
          }
        }

      assert WorkingHours.calculate_expected_work_seconds(
               ~D[2024-01-16],
               config
             ) ==
               (8 * 60 * 60 + 6 * 60 * 60 + 5 * 60 * 60) * 2 +
                 (8 * 60 * 60 + 6 * 60 * 60) - 5 * 60 * 60
    end

    test "considers sick days" do
      config =
        %Configuration{
          start_date: ~D[2024-01-01],
          working_days: %{
            1 => 8,
            2 => 6,
            3 => 5,
            4 => 0,
            5 => 0,
            6 => 0,
            7 => 0
          },
          sick_days: %{
            ~D[2024-01-03] => "Sick"
          }
        }

      assert WorkingHours.calculate_expected_work_seconds(
               ~D[2024-01-16],
               config
             ) ==
               (8 * 60 * 60 + 6 * 60 * 60 + 5 * 60 * 60) * 2 +
                 (8 * 60 * 60 + 6 * 60 * 60) - 5 * 60 * 60
    end
  end
end
