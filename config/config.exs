import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :tzdata, :autoupdate, :disabled
config :tzdata, :data_dir, Path.expand("./.tzdata")
