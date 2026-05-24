{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellApplication {
      name = "synclyrics";
      runtimeInputs = [pkgs.python313Packages.syncedlyrics pkgs.ffmpeg];
      text = ''
        dir="''${1:-.}"
        mapfile -t files < <(find "$dir" -maxdepth 1 -name "*.mp3" | sort)
        total=''${#files[@]}

        if [ "$total" -eq 0 ]; then
          echo "Brak plików .mp3 w: $dir"
          exit 1
        fi

        i=0
        found=0
        for f in "''${files[@]}"; do
          i=$((i+1))
          artist=$(ffprobe -v quiet -show_entries format_tags=artist -of default=nk=1:nw=1 "$f")
          title=$(ffprobe -v quiet -show_entries format_tags=title -of default=nk=1:nw=1 "$f")
          lrc="''${f%.mp3}.lrc"

          if [ -f "$lrc" ]; then
            printf "[%d/%d] SKIP: %s\n" "$i" "$total" "$title"
            continue
          fi

          printf "[%d/%d] %s — %s - %s\n" "$i" "$total" "$(basename "$f")" "$artist" "$title"
          if syncedlyrics "$artist $title" -o "$lrc" --synced-only 2>/dev/null; then
            found=$((found+1))
          else
            printf "       brak wyników\n"
            rm -f "$lrc"
          fi
        done

        echo "Gotowe: $found nowych lyrics z $total plików"
      '';
    })
  ];
}
