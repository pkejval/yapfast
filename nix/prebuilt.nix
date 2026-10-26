# nix/package.nix's output around a binary built elsewhere, which
# nix/appimage.nix takes in its place: the dev build compiles with cargo
# outside the sandbox, where cargo's target folder can be cached.
{ pkgs, binary }:
let
  id = "io.github.yapfast.Yapfast";
  inherit ((pkgs.lib.importTOML ../Cargo.toml).package) version;
in
pkgs.runCommand "yapfast-prebuilt-${version}" { inherit version; } ''
  install -Dm755 ${binary} "$out/bin/.yapfast-wrapped"
  install -Dm644 ${../packaging/icon.svg} "$out/share/icons/hicolor/scalable/apps/${id}.svg"
  # Named in full: a file in the store carries a hash prefix, which Flatpak
  # won't export and the AppImage's links don't follow.
  install -Dm644 ${../packaging/linux/${id}.desktop} "$out/share/applications/${id}.desktop"
  install -Dm644 ${../packaging/linux/${id}.metainfo.xml} "$out/share/metainfo/${id}.metainfo.xml"
''
