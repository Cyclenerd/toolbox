# Catch Me If You Can 🏃

This little Bash script tries to copy a file when it has changed.
For this, the last modification date is compared.
A new copy is created for each change.
The file name is `<TIMESTAMP>_<PID>`.

## Installation

### Download

    curl -f https://raw.githubusercontent.com/Cyclenerd/toolbox/master/catch_me_if_you_can/catch_me.sh -o catch_me.sh

### Configuration

Edit `MY_FILE` and `MY_DIR`:

    vi catch_me.sh

### Run

    bash catch_me.sh

### Cron

Execute a cron job every minute:

    crontab -e

Add:

    */1 * * * * bash /path/to/catch_me.sh >> /dev/null