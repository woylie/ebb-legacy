defmodule Ebb.ConfigTest do
  use ExUnit.Case, async: true

  alias Ebb.Configuration

  describe "read_config/0" do
    test "reads the configuration from file" do
      System.put_env("EBB_CONFIG_PATH", ".")
      assert %Configuration{} = Configuration.read_config()
    end
  end
end
