# spinner.sh

Display an awesome 'spinner' while running your long shell commands.

Do *NOT* call `_spinner` function directly. Use `{start,stop}_spinner` wrapper functions

## Usage

1. source this script in your's
2. start the spinner: `start_spinner [display-message-here]`
3. run your command
4. stop the spinner: `stop_spinner [your command's exit status]`

Also see: `test.sh`

## Source

https://github.com/tlatsas/bash-spinner and https://github.com/tlatsas/bash-spinner/pull/3/files