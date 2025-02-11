#!/opt/local/bin/bash -eu
# requires 7z in package 'p7zip' in macports

rm -rf temp latest
mkdir -p temp latest

# Extract GCP xml files from 01 cab files

for c in resources/*-01-*.cab; do
  CAB=$(basename $c .cab)
  TMPCAB=temp/$CAB
  7z x -o$TMPCAB $c '*-01-*'
done

declare -A zip01

for z in temp/*/FG-GML-*-01-*.zip; do
  b=${z##*/}
  if [ -z "${zip01[$b]:-}" ]; then
    set +e
    unzip $z '*-GCP-*' -d latest
    set -e
    zip01[$b]=$z
  fi
done

# Extract ElevPt xml files from 02 cab files

for c in resources/*-02-*.cab; do
  CAB=$(basename $c .cab)
  TMPCAB=temp/$CAB
  7z x -o$TMPCAB $c '*-09-*'
done

declare -A zip09

for z in temp/*/FG-GML-*-09-*.zip; do
  b=${z##*/}
  if [ -z "${zip09[$b]:-}" ]; then
    set +e
    unzip $z '*-ElevPt-*' -d latest
    set -e
    zip09[$b]=$z
  fi
done

rm -rf temp
