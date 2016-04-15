# zshquery

zshquery is a small set of utilities designed to make creating short scripts
easier, and much easier than typing the same thing over and over in ADS.

## Installation

```sh
# Clone the repository
git clone ssh://git@git.blackrock.com:9102/~bmckelve/zshquery.git ~/zsh/

# Add it to your PATH:
echo 'export PATH="$HOME/zsh/examples:$HOME/zsh/scripts:$PATH"' >> ~/.zshrc
```

## Example script

```zsh
#!/usr/bin/env zsh

# Assuming your file is in ~/zsh/scripts
source ${0:a:h}/../lib/query.zsh

# Describe your utility, its arguments and options
description "Get recent returns for a security and a given hierarchy"

argument cusip 'BRS cusip'

option from f 'from date' $ONE_MONTH_AGO
option to t 'to date' $TODAY
option hier M 'price hierarchy' NAV

parse $0 $@

sql <<SQL
select
    $(format_date date),
    $(format_number 10 4 total_ret),
    $(format_number 10 4 prin_ret),
    $(format_number 10 4 income_ret),
    $(format_number 14 4 price),
    $(format_number 14 4 ai),
    $(format_number 14 4 beg_price),
    $(format_number 14 4 beg_ai)
from returnsdb.dbo.cusip_returns
where
    cusip = "$cusip"
    and price_hierarchy = "$hier"
    and date between "$from" and "$to"
go
SQL
```
