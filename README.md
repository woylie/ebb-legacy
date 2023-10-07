# Ebb

A shabby CLI tool built on [Watson CLI](https://github.com/TailorDev/Watson) for
calculating the time balance in a flex time working environment.

## Features

- Prints time balance.
- Considers vacation days, holidays and sick days.
- Supports half days off.
- Allows to configure working hours per weekday.
- Time adjustment for the current window.
- No documentation.
- No tests.
- Not extensible.
- No helpful error messages.

## Prerequisites

[Elixir](https://elixir-lang.org/install.html) and
[Watson CLI](https://tailordev.github.io/Watson/#installation) need to be
installed on your system.

## Installation

Build the binary:

```bash
git clone https://github.com/woylie/ebb
cd ebb
mix install
```

Copy the default configuration to a local folder:

```bash
mkdir -p ~/.config/ebb
cp ./config.yml ~/.config/ebb
```

Adjust the configuration to your needs.

You can override the default config folder by setting the `EBB_CONFIG_PATH`
environment variable.

Note: Direct installation from GitHub using `mix escript.install` is not
supported due to the need to copy the `tzdata` data folder from `deps`.

## Other mix aliases

- `mix setup`
- `mix build`

## Usage

- `ebb balance` - Print current time balance
- `ebb daysoff` - Prints the taken and remaining days off for the current year.
- `ebb config` - Print current configuration.

## Example output

```
> ebb balance

Start date:     2023-10-02
End date:       2023-10-07
Expected:      40h 00m 00s
Actual:        44h 08m 17s
==========================
Balance:        4h 08m 17s
```

```
> ebb daysoff

Year:    2023


Sick days

Allowed:   10
Taken:      3
=============
Left:       7


Vacation days

Allowed:    30
Taken:      22
==============
Left:        8
```

## Why Elixir?

Because it's what I know.

## Contributions

On the off-chance you find this tool in any way useful and feel the inexplicable
urge to improve it, PRs are begrudgingly welcomed.
