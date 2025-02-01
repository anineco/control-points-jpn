#!/bin/bash -eu
# macports: p7zip

ODIR=output

rm -rf temp $ODIR
mkdir -p temp $ODIR

for c in resources/*-01-*.cab; do
  CAB=$(basename $c .cab)
  TMPCAB=temp/$CAB
  7z x -o$TMPCAB $c '*-01-*'
  for z in $TMPCAB/*.zip; do
    set +e
    unzip $z '*-GCP-*' -d $TMPCAB
    set -e
  done
  rm -f $ODIR/$CAB.txt
  for x in $TMPCAB/*.xml; do
    echo $x
    ./xml2txt.py $x >> $ODIR/$CAB.txt
  done
  rm -rf $TMPCAB
done

for c in resources/*-02-*; do
  CAB=$(basename $c .cab)
  TMPCAB=temp/$CAB
  OUTPUT=output/$CAB.txt
  7z x -o$TMPCAB $c '*-09-*'
  for z in $TMPCAB/*.zip; do
    set +e
    unzip $z '*-ElevPt-*' -d $TMPCAB
    set -e
  done
  rm -f $ODIR/$CAB.txt
  for x in $TMPCAB/*.xml; do
    echo $x
    ./xml2txt.py $x >> $ODIR/$CAB.txt
  done
  rm -rf $TMPCAB
done
