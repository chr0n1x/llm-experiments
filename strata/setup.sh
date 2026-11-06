#!/usr/bin/env bash
# Downloads a pack, tunes it, and installs the systemd unit that serves it.
#
# Run it again after changing anything below to serve a different pack or
# context. It prints the run config strata wrote; strata.service has to name
# that same file, because `strata serve` takes no context, KV or model flag.
#
# Needs sudo for the systemd unit.

set -euo pipefail

FAMILY="${STRATA_FAMILY:-unsloth}"
MODEL="${STRATA_MODEL:-ud-iq4_xs}"
CONTEXT="${STRATA_CONTEXT:-256k}"
KV="${STRATA_KV:-int8}"
PORT="${STRATA_PORT:-8000}"
TUNE="${STRATA_TUNE:-quick}"
STRATA_BIN="${STRATA_BIN:-$HOME/.local/bin/strata}"
UNIT="${STRATA_UNIT:-$HOME/Code/kran/llm-experiments/strata/strata.service}"

"$STRATA_BIN" launch \
    --family "$FAMILY" --model "$MODEL" --context "$CONTEXT" --kv "$KV" \
    --port "$PORT" --access lan --no-api-key --tune "$TUNE" \
    --yes --no-tui --restart

# launch leaves a background runtime holding the port; systemd serves from here on.
"$STRATA_BIN" runtime stop --profile "launch-$MODEL-$CONTEXT" ||
    printf 'could not stop the launch runtime: strata runtime status --profile launch-%s-%s\n' \
        "$MODEL" "$CONTEXT" >&2

# strata adds the family to the model key for some providers and not others,
# so ask it for the path instead of building one.
config=""
for name in "$MODEL" "$FAMILY-$MODEL"; do
    found="$("$STRATA_BIN" models inspect "$name" 2>/dev/null | awk '/^Config:/{print $2}')" || found=""
    if [[ -n "$found" ]]; then
        config="$found"
        break
    fi
done

printf '\nrun config: %s\n' "${config:-unknown}"
if [[ -n "$config" ]] && ! grep -qF "$config" "$UNIT"; then
    printf 'WARNING: %s names a different run config. Edit its ExecStart, then:\n' "$UNIT"
    printf '  sudo systemctl daemon-reload && sudo systemctl restart strata\n'
fi

sudo ln -sf "$UNIT" /etc/systemd/system/strata.service
sudo systemctl daemon-reload
sudo systemctl enable --now strata.service
