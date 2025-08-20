
#
# Load location-based shell environment ehnancements.
#
# See https://github.com/dadooda/lenv.
#

#----------------------------- Configuration

# Envfile basename we're looking for in the support directories.
_LENV_BN="env.sh"
_LENV_EDITOR="nano"

#--------------------------------------- The tools

# Load the envfile from the support directory.
le() {
  local FN
  FN=$(_lenv_fn) || return 1

  [[ -r ${FN} ]] || {
    echo "Error: File is not readable: ${FN}" >&2
    return 1
  }

  echo "Loading: ${FN}"
  . "${FN}"
}

# Temporarily step into the support directory via `pushd`.
lecd() {
  local FN
  FN=$(_lenv_fn) || return 1

  local DIR=${FN%/*}

  echo
  echo "Cd to: ${DIR}"
  echo "Do a \`popd\` to return"
  echo

  pushd "${DIR}" >/dev/null
}

# Locate, edit and reload the envfile or the specified module.
#
# $1: (optional) module name.
leed() {
  local FN
  local MOD
  local VN

  if [[ $# -ge 1 ]]; then
    # Edit the module.

    MOD=${1}
    VN="_ENV_MOD_${MOD}"
    FN=${!VN}

    if [[ -z ${FN} ]]; then
      echo "Special variable not defined or empty: ${VN}" >&2
      echo "In your module, use a:" >&2
      echo >&2
      echo "  export ${VN}=\${BASH_SOURCE[0]}" >&2
      echo >&2

      return 1
    fi
  else
    # Edit the global envfile.

    # The flag to distinguish "global" mode.
    MOD=""

    FN=$(_lenv_fn) || return 1
  fi

  # Edit the envfile.
  ${EDITOR:-$_LENV_EDITOR} "${FN}" || {
    echo "Error editing '${FN}'" >&2
    return 1
  }

  # NOTE: Some editors output a newline here. Not our glitch.

  # If a successful global edit, print loaded module names as a hint.
  if [[ -z ${MOD} ]]; then
    local MODS=$(lemod)
    [[ -n ${MODS} ]] && {
      echo -e "Also, these modules have been loaded:\n\n${MODS}" >&2
    }
  fi

  # Finally, source the envfile.
  . "${FN}"
}

# List loaded modules.
lemod() {
  declare -p \
  | egrep "declare .+_ENV_MOD.+=" \
  | sed "s/^declare -.* _ENV_MOD_//"
}

#--------------------------------------- Service

# Locate and print the envfile path. Return 1 if not found.
_lenv_fn() {
  local BN=${_LENV_BN}
  local D
  D=$(realpath "${PWD}") || return 1

  local TRY

  while [[ -n ${D} ]]; do
    for TRY in "$(realpath "${D}/_support")/${BN}" "$(realpath "${D}/../${D##*/}_support")/${BN}"; do
      [[ ${VERBOSE:-} = "!" ]] && echo "Trying: ${TRY}" >&2

      if [[ -r ${TRY} ]]; then
        echo "${TRY}"
        return 0
      fi
    done

    D=${D%/*}
  done

  echo "Error: Support directory with a readable \`${BN}\` not found" >&2
  return 1
}

#
# Implementation notes:
#
# * `local VAR=` assignment yields a non-error even if the command has failed.
#    Hence for result-checking clauses a separate `local VAR` is used.
