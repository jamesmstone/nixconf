{
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.james-dictation = let
      inherit (pkgs) lib;
      nerd-dictation = self'.packages.nerd-dictation;
      notify = self'.packages.notify;
      model = pkgs.fetchzip {
        url = "https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip";
        hash = "sha256-CIoPZ/krX+UW2w7c84W3oc1n4zc9BBS/fc8rVYUthuY=";
      };
    in
      pkgs.writeShellApplication {
        name = "james-dictation";
        runtimeInputs = [nerd-dictation notify pkgs.wtype pkgs.libnotify pkgs.jq pkgs.playerctl pkgs.tmux pkgs.procps];
        text = ''
          notify() { ${lib.getExe notify} "$@"; }

          if [ -n "''${TMUX:-}" ]; then
            if pgrep -f 'nerd-dictation-wrapped begin' >/dev/null; then
              nerd-dictation end
              notify "Dictation" "Dictation mode ended" low
            else
              notify "Dictation" "Dictation mode active" normal
              nerd-dictation begin \
                   --full-sentence --punctuate-from-previous-timeout=2 \
                   --vosk-model-dir=${model}
            fi
          else
            state_file=/tmp/james-dictation-state.json
            if [ -f "$state_file" ]; then
              id=$(jq -r '.notification_id' "$state_file")
              paused=$(jq -r '.media_paused' "$state_file")
              nerd-dictation end
              notify-send --replace-id="$id" --expire-time=2000 "Dictation" "Dictation mode ended"
              if [ "$paused" = "true" ]; then
                playerctl -a play
              fi
              rm -f "$state_file"
            else
              paused=false
              if playerctl -a status 2>/dev/null | grep -q Playing; then
                playerctl -a pause
                paused=true
              fi
              id=$(notify-send --urgency=critical --print-id --expire-time=0 "Dictation" "Dictation mode active")
              jq -n --arg id "$id" --argjson paused "$paused" '{notification_id: $id, media_paused: $paused}' > "$state_file"
              nerd-dictation begin \
                   --full-sentence --punctuate-from-previous-timeout=2 \
                   --simulate-input-tool WTYPE \
                   --vosk-model-dir=${model}
            fi
          fi
        '';
      };
  };
}
