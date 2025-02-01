#!/bin/bash -eu

cd results
rm -f x_*.sql

sort ../output/*.txt | uniq | ../bsplit.pl 16
for x in x_*.sql; do
  mv $x $x.bak
  echo 'INSERT INTO `gcp` VALUES' > $x
  sed -e '$s/,$/;/' $x.bak >> $x
  rm -f $x.bak
done
