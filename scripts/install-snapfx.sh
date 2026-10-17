#!/usr/bin/env bash
# Downloads a SnapFX release jar from GitHub and installs it into the local Maven repository,
# because SnapFX is not published to Maven Central yet.
# Usage: scripts/install-snapfx.sh [version]   (default: 0.8.0; env SNAPFX_VERSION also works)
set -euo pipefail

VERSION="${1:-${SNAPFX_VERSION:-0.8.0}}"
GROUP_ID="org.snapfx"
ARTIFACT_ID="snapfx-core"
REPO="Beowolve/SnapFX"

# Skip when already installed (override with FORCE=1)
M2_REPO="${MAVEN_REPO_LOCAL:-$HOME/.m2/repository}"
INSTALLED="$M2_REPO/${GROUP_ID//.//}/$ARTIFACT_ID/$VERSION/$ARTIFACT_ID-$VERSION.jar"
if [[ -f "$INSTALLED" && "${FORCE:-0}" != "1" ]]; then
  echo "$GROUP_ID:$ARTIFACT_ID:$VERSION already installed ($INSTALLED); FORCE=1 to reinstall"
  exit 0
fi

# Release assets are named snapfx-core-<version>-<build>.jar (build suffix varies), so look the asset up
ASSET_URL="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/tags/v$VERSION" \
  | grep -oE '"browser_download_url": *"[^"]*snapfx-core-[^"]*\.jar"' \
  | grep -oE 'https://[^"]+' | head -n1)"
if [[ -z "$ASSET_URL" ]]; then
  echo "No snapfx-core jar found in release v$VERSION of $REPO" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
JAR="$TMP/$(basename "$ASSET_URL")"

echo "Downloading $ASSET_URL"
curl -fsSL -o "$JAR" "$ASSET_URL"

# Verify checksum when the release publishes one
if curl -fsSL -o "$JAR.sha256" "$ASSET_URL.sha256" 2>/dev/null; then
  EXPECTED="$(awk '{print $1}' "$JAR.sha256")"
  ACTUAL="$(sha256sum "$JAR" | awk '{print $1}')"
  if [[ "$EXPECTED" != "$ACTUAL" ]]; then
    echo "Checksum mismatch: expected $EXPECTED, got $ACTUAL" >&2
    exit 1
  fi
  echo "Checksum OK"
else
  echo "No .sha256 published for this release; skipping verification" >&2
fi

mvn -q org.apache.maven.plugins:maven-install-plugin:3.1.2:install-file \
  -Dfile="$JAR" \
  -DgroupId="$GROUP_ID" -DartifactId="$ARTIFACT_ID" -Dversion="$VERSION" \
  -Dpackaging=jar -DgeneratePom=true

echo "Installed $GROUP_ID:$ARTIFACT_ID:$VERSION"
