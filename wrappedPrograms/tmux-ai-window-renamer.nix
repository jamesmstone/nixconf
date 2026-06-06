{
  perSystem = {pkgs, ...}: {
    packages.tmux-ai-window-renamer = pkgs.writeShellApplication {
      name = "tmux-ai-window-renamer";
      runtimeInputs = [pkgs.tmux pkgs.curl pkgs.jq pkgs.jo pkgs.coreutils];
      text = ''

        api_key="''$(cat /openrouter)"
        model="openrouter/free"

        # Anchor on $TMUX_PANE — tmux sets it to the pane that was active in the
        # client that triggered the binding.
        if [ -n "''${TMUX_PANE:-}" ]; then
          window_id="''$(tmux display-message -p -t "''$TMUX_PANE" -F '#{window_id}')"
        else
          window_id="''$(tmux display-message -p -F '#{window_id}')"
        fi

        # Immediate visual feedback that the key press was registered: append a
        # loading marker to the current window name.
        loading_marker=" ⏳"
        current_name="''$(tmux display-message -p -t "''$window_id" -F '#{window_name}')"
        orig_name="''${current_name%"''$loading_marker"}"
        tmux rename-window -t "''$window_id" -- "''${orig_name}''${loading_marker}"
        restore_on_failure() {
          rc=$?
          if [ "''$rc" -ne 0 ]; then
            tmux rename-window -t "''$window_id" -- "''$orig_name" 2>/dev/null || true
          fi
        }
        trap restore_on_failure EXIT

        panes_json="''$(
          tmux list-panes -t "''$window_id" \
              -F '#{pane_id}	#{pane_index}	#{pane_current_command}	#{pane_title}	#{pane_current_path}' \
            | while IFS=$'\t' read -r id idx cmd title cwd; do
                content="''$(tmux capture-pane -p -t "''$id" -J -S -200)"
                jo index="''$idx" command="''$cmd" title="''$title" cwd="''$cwd" content="''$content"
              done \
            | jo -a
        )"

        properties="''$(jo \
          name="''$(jo type=string description='Short, human-readable tmux window name (1-4 words). Lowercase. Spaces are fine. Reflects the dominant activity across the panes.')" \
          reason="''$(jo type=string description='One short sentence justifying the chosen name.')")"
        schema="''$(jo \
          type=object \
          additionalProperties=false \
          required="''$(jo -a name reason)" \
          properties="''$properties")"
        response_format="''$(jo \
          type=json_schema \
          json_schema="''$(jo name=tmux_window_name strict=true schema="''$schema")")"

        system_msg='You name tmux windows. Given the recent contents of every pane in a window, pick a short (1-4 words), lowercase, human-readable name that captures what the user is doing. Spaces are fine. Prefer the dominant or most recent activity. If unsure, fall back to a short version of the pane cwd (basename, or basename of its parent if the basename is too generic like src/).'

        # Raw JSON in the assistant turns anchors the schema shape, not just
        # the naming style.
        example_user_1='Panes in the current tmux window (JSON array):
        [{"index":"0","command":"nvim","title":"app.py","cwd":"/home/me/code/checkout-api","content":"def handle_request(req):\n    return jsonify({\"ok\": True})\n"},
         {"index":"1","command":"pytest","title":"tests","cwd":"/home/me/code/checkout-api","content":"tests/test_app.py::test_health PASSED\n1 passed in 0.42s\n"}]

        Suggest a name for this window.'
        example_assistant_1='{"name":"checkout api","reason":"Editing a Python handler with the test suite running alongside."}'

        example_user_2='Panes in the current tmux window (JSON array):
        [{"index":"0","command":"fish","title":"fish","cwd":"/home/me/notes","content":"$ ls\nshopping.md  reading-list.md\n$ "}]

        Suggest a name for this window.'
        example_assistant_2='{"name":"notes","reason":"Idle shell in the notes directory; using the cwd basename as a fallback name."}'

        user_msg="Panes in the current tmux window (JSON array):
        ''${panes_json}

        Suggest a name for this window."

        payload="''$(jo \
          model="''$model" \
          temperature=0.3 \
          messages="''$(jo -a \
            "''$(jo role=system content="''$system_msg")" \
            "''$(jo role=user content="''$example_user_1")" \
            "''$(jo -- role=assistant -s content="''$example_assistant_1")" \
            "''$(jo role=user content="''$example_user_2")" \
            "''$(jo -- role=assistant -s content="''$example_assistant_2")" \
            "''$(jo role=user content="''$user_msg")")" \
          response_format="''$response_format")"

        # openrouter/free routes through a pool of upstreams. Two failure modes
        # come back as HTTP 200 with .error set: rate-limits (.error.code == 429)
        # and provider-side aborts — retry both.
        attempt=0
        max_attempts=5
        while :; do
          response="''$(curl -sS https://openrouter.ai/api/v1/chat/completions \
            --connect-timeout 20 \
            --max-time 60 \
            -H "Authorization: Bearer ''${api_key}" \
            -H "Content-Type: application/json" \
            -d "''$payload")"
          content="''$(printf '%s' "''$response" | jq -r '.choices[0].message.content // empty')"
          [ -n "''$content" ] && break

          attempt=''$((attempt + 1))
          err_code="''$(printf '%s' "''$response" | jq -r '.error.code // empty')"
          if [ "''$attempt" -lt "''$max_attempts" ]; then
            if [ "''$err_code" = "429" ]; then
              wait="''$(printf '%s' "''$response" | jq -r '.error.metadata.retry_after_seconds // 5')"
            else
              wait=1
            fi
            sleep "''$wait"
            continue
          fi

          err="''$(printf '%s' "''$response" | jq -r '.error.message // .error // "no content"')"
          echo "tmux-ai-window-renamer: ''$err" >&2
          tmux display-message "tmux-ai-window-renamer: ''$err"
          exit 1
        done

        name="''$(printf '%s' "''$content" | jq -r '.name')"
        reason="''$(printf '%s' "''$content" | jq -r '.reason')"

        if [ -z "''$name" ] || [ "''$name" = "null" ]; then
          tmux display-message "tmux-ai-window-renamer: model returned no name"
          exit 1
        fi

        # -t "$window_id" so the rename lands on the window we sampled.
        tmux rename-window -t "''$window_id" -- "''$name"
        tmux display-message "tmux-ai-window-renamer → ''$name (''$reason)"
      '';
    };
  };
}
