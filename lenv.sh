
#
# Load location-based shell environment ehnancements.
#
# See https://github.com/dadooda/lenv.
#

#----------------------------- Configuration

# Envfile basename we're looking for in the support directories.
_LENV_BN="env.sh"

#----------------------------- Functions

# Locate and print the envfile path. Return 1 if not found.
_lenv_fn() {
  # Search for a readable envfile up the tree.
  # Testing: `_LENV_FN_ROOT` is an optional root specifier.
  local BN="${_LENV_BN}"
  local D=`realpath "${PWD}"` || return 1

  while [ -n "${D#${_LENV_FN_ROOT:-}}" ]; do
    for TRY in "`realpath "$D/../${D##*/}_support"`/${BN}" "`realpath "${D}/../_support"`/${BN}"; do
      if [ -r "${TRY}" ]; then
        echo "${TRY}"
        return 0
      fi
    done

    D=${D%/*}
  done

  for TRY in "`realpath "$D/../${D##*/}_support"`/${BN}" "`realpath "${D}/../_support"`/${BN}"; do
    if [ -r "${TRY}" ]; then
      echo "${TRY}"
      return 0
    fi
  done

  echo "Error: Support directory with a readable \`${BN}\` not found" >&2
  return 1
}

# Load the envfile from the support directory.
lenv() {
  # NOTE: `local` assignment yields a non-error even if the command has failed. Hence an additional check.
  local FN=$(_lenv_fn); [ -n "${FN}" ] || return 1
  [ -r "${FN}" ] || {
    echo "Error: File is not readable: ${FN}" >&2
    return 1
  }

  # NOTE: The logic below is somewhat "tilted" to generate prettier `set -x` output.
  if [ "${VERBOSE:-}" = "!" ]; then
    set -x
    . "$FN"
    set +x
  else
    echo "Loading '$FN'"
    . "$FN"
  fi
}

# Temporarily step into the support directory via `pushd`.
lenvcd() {
  local FN=$(_lenv_fn); [ -n "${FN}" ] || return 1
  local DIR=${FN%/*}

  echo
  echo "Stepping into: ${DIR}"
  echo "Do a \`popd\` to return"
  echo

  pushd "${DIR}" >/dev/null
}

# Locate, edit and reload the envfile or the specified module.
#
# $1: (optional) module name.
lenvedit() {
  if [ $# != 0 ]; then
    # Edit the module.

    local MOD=$1
    local VN="_ENV_MOD_${MOD}"
    local FN=${!VN}

    if [ -z "${FN}" ]; then
      echo "Special variable not defined or empty: ${VN}" >&2
      echo "In your module, use a:" >&2
      echo >&2
      echo "  ${VN}=\${BASH_SOURCE[0]}" >&2
      echo >&2

      return 1
    fi
  else
    # Edit the "global" envfile.

    # The flag to distinguish "global" mode.
    local MOD=""

    local FN=$(_lenv_fn); [ -n "${FN}" ] || return 1
  fi

  # Edit the envfile.
  ${EDITOR:-nano} "${FN}" || {
    echo "Error editing '${FN}'" >&2
    return 1
  }

  # NOTE: Some editors output a newline here. Not our glitch.

  # If a successful global edit, print module names as a hint.
  if [ -z "${MOD}" ]; then
    local MODS=$(lenvmod)
    [ -n "${MODS}" ] && echo -e "Also, these modules have been found:\n\n${MODS}" >&2
  fi

  # Finally, source the envfile.
  . "${FN}"
}

# List loaded modules.
lenvmod() {
  declare -p \
  | grep "declare -- _ENV_MOD_" \
  | sed "s/^declare -- _ENV_MOD_//"
}
