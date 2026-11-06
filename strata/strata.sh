#!/usr/bin/env bash
# Strata serving wrapper for systemd.
#
# Context size cannot be set at serve time: strata serve only takes
# host/port/parallel/queue overrides, and the context is baked into the run
# config as --max-context when `strata launch` writes it. So context is a
# setup-time setting, handled by the `setup` mode below.
#
#   ./strata.sh setup            # download + tune, then install and start the unit
#   ./strata.sh serve            # foreground server, what systemd runs
#   ./strata.sh status           # what the run config actually says
#   ./strata.sh tty              # launch by hand, no systemd involved
#
# setup needs sudo for the systemd unit.

MODEL="${STRATA_MODEL:-ud-iq4_xs}"
FAMILY="${STRATA_FAMILY:-unsloth}"
CONTEXT="${STRATA_CONTEXT:-256k}"
PORT="${STRATA_PORT:-8000}"
KV="${STRATA_KV:-int8}"
TUNE="${STRATA_TUNE:-quick}"
STRATA_BIN="${STRATA_BIN:-$HOME/.local/bin/strata}"
PROFILE="${STRATA_PROFILE:-$HOME/.local/share/strata/install/strata-${FAMILY}-${MODEL}.json}"
UNIT="${STRATA_UNIT:-$HOME/Code/kran/llm-experiments/strata/strata.service}"
# strata names its runtime profile launch-<model>-<context>, as `strata profile list` shows.
RUNTIME_PROFILE="launch-$MODEL-$CONTEXT"

cmd="${1:-serve}"

if [[ "$cmd" == tty ]]; then
    # launch daemonises its runtime, so this is a manual step, not a systemd one.
    exec "$STRATA_BIN" launch \
        --family "$FAMILY" --model "$MODEL" --context "$CONTEXT" --kv "$KV" \
        --port "$PORT" --access lan --no-api-key --tune "$TUNE" \
        --yes --no-tui --restart

    return 0
fi

if [[ "$cmd" == setup ]]; then
    "$STRATA_BIN" launch \
        --family "$FAMILY" --model "$MODEL" --context "$CONTEXT" --kv "$KV" \
        --port "$PORT" --access lan --no-api-key --tune "$TUNE" \
        --yes --no-tui --restart
    # launch left a runtime on the port; systemd takes it over from here.
    "$STRATA_BIN" runtime stop --profile "$RUNTIME_PROFILE" ||
        printf 'could not stop the launch runtime: strata runtime status --profile %s\n' "$RUNTIME_PROFILE" >&2
    sudo ln -sf "$UNIT" /etc/systemd/system/strata.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now strata.service
    return 0
fi

if [[ ! -f "$PROFILE" ]]; then
    printf 'no run config at %s\nrun %s setup first\n' "$PROFILE" "$0" >&2
    return 1
fi

if [[ "$cmd" == status ]]; then
    python3 - "$PROFILE" <<'EOF'
import json, sys
args = json.load(open(sys.argv[1]))["args"]
for i, flag in enumerate(args):
    if flag in ("--max-context", "--kv", "--kv-resident"):
        print(flag, args[i + 1])
EOF
    return 0
fi

exec "$STRATA_BIN" serve --profile "$PROFILE" --host 0.0.0.0 --port "$PORT"
