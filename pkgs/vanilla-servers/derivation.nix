{
  lib,
  stdenvNoCC,
  fetchurl,
  nixosTests,
  jre25_minimal,
  version,
  url,
  sha1,
}:
stdenvNoCC.mkDerivation {
  pname = "minecraft-server";
  inherit version;

  src = fetchurl { inherit url sha1; };

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/lib/minecraft
    cp -v $src $out/lib/minecraft/server.jar

    cat > $out/bin/minecraft-server << EOF
    #!/bin/sh
    exec ${jre25_minimal}/bin/java \$@ -jar $out/lib/minecraft/server.jar nogui
    EOF

    chmod +x $out/bin/minecraft-server
  '';

  dontUnpack = true;

  passthru = {
    java = jre25_minimal;
    tests = { inherit (nixosTests) minecraft-server; };
    updateScript = ./update.py;
  };

  meta = with lib; {
    description = "Minecraft Server";
    homepage = "https://minecraft.net";
    license = licenses.unfreeRedistributable;
    platforms = platforms.unix;
    maintainers = with maintainers; [ infinidoge ];
    mainProgram = "minecraft-server";
  };
}
