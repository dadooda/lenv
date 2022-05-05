
#
# Load location-based shell environment ehnancements.
#
# See https://github.com/dadooda/lenv.
#

# Configuration.
LENV_BN="env.sh"
LENV_EDITOR="vi"

# Locate and print the envfile path. Return 1 if not found.
_lenv_fn() {
  # Search for a readable envfile up the tree.
  # Testing: `_LENV_FN_ROOT` is an optional root specifier.
  local BN="${LENV_BN}"
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
  local FN=`_lenv_fn`; [ -n "${FN}" ] || return 1
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
  local FN=`_lenv_fn`; [ -n "${FN}" ] || return 1
  local DIR=${FN%/*}

  echo
  echo "Stepping into: ${DIR}"
  echo "Do a \`popd\` to return"
  echo

  pushd "${DIR}" >/dev/null
}

# Locate, edit and reload the envfile.
lenvedit() {
  local FN=`_lenv_fn`; [ -n "${FN}" ] || return 1

  # Edit and source the envfile.
  ${EDITOR:-${LENV_EDITOR}} "${FN}" \
  && . $FN
}
