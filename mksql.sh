#!/opt/local/bin/bash -eu

cd results
rm -f x_*.sql

(
../xml2txt.py ../latest/*-GCP-*.xml
../xml2txt.py ../latest/*-ElevPt-*.xml
) | ../bsplit.pl 16

for x in x_*.sql; do
  mv $x $x.bak
  echo 'INSERT INTO `gcp` VALUES' > $x
  sed -e '$s/,$/;/' $x.bak >> $x
  rm -f $x.bak
done
