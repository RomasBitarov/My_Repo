# Copyright © 2012 Christian Persch
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Not bash or zsh?
[ -n "${BASH_VERSION:-}" -o -n "${ZSH_VERSION:-}" ] || return 0

# Not an interactive shell?
[[ $- == *i* ]] || return 0

# Not running under vte?
[ "${VTE_VERSION:-0}" -ge 3405 ] || return 0

__vte_osc7 () {
  printf "\033]7;file://%s%s\033\\" "${HOSTNAME}" "$(/usr/libexec/vte-urlencode-cwd)"
}

__vte_prompt_command() {
  local command=$(HISTTIMEFORMAT= history 1 | sed 's/^ *[0-9]\+ *//')
  command="${command//;/ }"
  local pwd='~'
  [ "$PWD" != "$HOME" ] && pwd=${PWD/#$HOME\//\~\/}
  pwd="${pwd//[[:cntrl:]]}"
  printf '\033]777;notify;Command completed;%s\033\\\033]777;precmd\033\\\033]0;%s@%s:%s\033\\' "${command}" "${USER}" "${HOSTNAME%%.*}" "${pwd}"
  __vte_osc7
}

case "$TERM" in
  xterm*|vte*)
    [ -n "${BASH_VERSION:-}" ] && PROMPT_COMMAND="__vte_prompt_command" && PS0=$(printf "\033]777;preexec\033\\")
    [ -n "${ZSH_VERSION:-}"  ] && precmd_functions+=(__vte_osc7)
    ;;
esac

true
