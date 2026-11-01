#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck source=./packaging/makeself/functions.sh
. "${NETDATA_MAKESELF_PATH}"/functions.sh "${@}" || exit 1

WEB="${NETDATA_INSTALL_PATH}/usr/share/netdata/web"
GATE_SRC="${NETDATA_SOURCE_PATH}/src/web/argus-gate/index.html"
WELCOME="${WEB}/netdata-cloud-welcome.html"
INDEX="${WEB}/index.html"
AUTO_SRC="${NETDATA_SOURCE_PATH}/packaging/web/argus-auto-enter.js"
AUTO_SNIPPET="${WEB}/argus-auto-enter.js"

if [ ! -f "${GATE_SRC}" ]; then
  echo >&2 "Argus gate source missing at ${GATE_SRC}; skipping overlay."
  exit 0
fi

if [ ! -f "${INDEX}" ]; then
  echo >&2 "Dashboard index missing at ${INDEX}; skipping Argus gate overlay."
  exit 0
fi

if [ ! -f "${WELCOME}" ]; then
  run mv "${INDEX}" "${WELCOME}"
fi

run cp "${GATE_SRC}" "${INDEX}"

if [ -f "${AUTO_SRC}" ]; then
  run cp "${AUTO_SRC}" "${AUTO_SNIPPET}"
fi

if ! grep -q 'argus-auto-enter.js' "${WELCOME}" 2>/dev/null; then
  run sed -i 's|</body>|<script src="/argus-auto-enter.js"></script></body>|' "${WELCOME}" || true
fi

# shellcheck disable=SC2015
[ "${GITHUB_ACTIONS}" = "true" ] && echo "::endgroup::" || true
