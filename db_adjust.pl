#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use open qw(:utf8 :std);
use DBI;

my $dsn = 'DBI:mysql:anineco_tozan;mysql_read_default_file=/Users/tad/.my.cnf'; # 🔖
my $dbh = DBI->connect($dsn, undef, undef, {mysql_enable_utf8mb4 => 1}) or die $DBI::errstr;

$dbh->do('SET @EPS=IF(0/*!80003 +1 */,40,0.00036)');

my $sth = $dbh->prepare('SELECT id,name,alt,level FROM geom');
$sth->execute;
while (my $row = $sth->fetch) {
  my ($id, $name, $alt, $level) = @$row;
  print $id, ',', $name, "\n";
  $dbh->do('SELECT ST_Buffer(pt,@EPS) INTO @buf FROM geom WHERE id=?', undef, $id);

  # 近傍の最高等級の基準点を取得して更新
  my $sth1 = $dbh->prepare(<<'EOS');
UPDATE geom,(SELECT * FROM gcp WHERE ST_Within(pt,@buf) AND grade>? ORDER BY grade DESC LIMIT 1) AS s
SET geom.level=(geom.level&7)+(s.grade<<3)
WHERE id=? AND s.grade IS NOT NULL
EOS
  $sth1->execute($level >> 3, $id);
  $sth1->finish;

  # 近傍の最高標高の基準点を取得して更新
  my $sth2 = $dbh->prepare(<<'EOS');
UPDATE geom,(SELECT * FROM gcp WHERE ST_Within(pt,@buf) AND alt>=? ORDER BY alt DESC LIMIT 1) AS s
SET geom.pt=s.pt,geom.alt=s.alt,geom.level=(geom.level&~7)+s.grade
WHERE id=? AND s.grade IS NOT NULL
EOS
  $sth2->execute($level & 7 ? $alt : $alt - 5, $id);
  $sth2->finish;
}
$sth->finish;
$dbh->disconnect;
__END__
