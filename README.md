# control-points-jpn
日本全国の三角点と標高点のデータベース化

## 概要
国土地理院の[基盤地図情報サイト](https://www.gsi.go.jp/kiban/)で公開されている全国の電子基準点、一等〜四等三角点、標高点の地理情報（緯度、経度、標高、点名）をデータベース化する。

データ点数は、2025年2月現在、下記のとおり。
```
電子基準点:   1277
一等三角点:    968
二等三角点:   4927
三等三角点:  31091
四等三角点:  70132
標高点　　: 411982
```

## 動作環境
次のソフトウェアが必要である。
- ```MySQL```
- ```python```
- ```perl```
- ```7z```

```7z```コマンドは、MacPortsでは次のコマンドでインストールできる。
```
sudo port install p7zip
```

## 手順

### Step 1. データのダウンロード
国土地理院の[基盤地図情報サイト](https://www.gsi.go.jp/kiban/)にアクセスし、［基盤地図情報のダウンロード］→［基盤地図情報 基本項目］を選択、
```
検索条件指定：
　☑️全項目
選択方法指定：
　◉都道府県または市区町村で選択
　☑️全国
```

→［選択リストに追加］→［ダウンロードファイル確認へ］を選択して、ファイル名が```FG-GML-```で始まる cab ファイルをひとつずつダウンロードする。ダウンロードには国土地理院のアカウント（無料で作成可能）が必要。ダウンロード先のディレクトリは```./resource```とする。

### Step 2. cab ファイルの展開とデータの抽出
次の shell スクリプトを実行する。
```
./proc.sh
```

このスクリプトは```./resources```ディレクトリの cab ファイルを読み込み、ファイルの展開とデータの抽出を行なって、```./latest```ディレクトリの下にファイル名が```FG-GML-```で始まる xml ファイルを出力する。

### Step 3. sql ファイルの出力
次の shell スクリプトを実行する。
```
./mksql.sh
```

このスクリプトは```./latest```ディレクトリの xml ファイルを読み込み、```./results```ディレクトリの下に```x_NNN.sql```というファイル名（NNN=000〜）で sql ファイルを出力する。出力ファイルは、それぞれのファイルサイズが16MB以下になるように分割される。

### Step 4. データベースのテーブルの作成
MySQLで次の SQL コマンドを実行し、テーブル```gcp```を作成する。なお、```CHARACTER SET```は```utf8mb4```、```COLLATE```は```utf8mb4_general_ci```とする。
```
CREATE TABLE `gcp` (
  `fid` varchar(255) NOT NULL COMMENT '基盤地図情報レコードID',
  `grade` tinyint NOT NULL COMMENT '等級',
  `pt` point NOT NULL /*!80003 SRID 4326 */ COMMENT '位置',
  `alt` decimal(7,3) NOT NULL COMMENT '標高',
  `name` varchar(255) NOT NULL COMMENT '点名',
  UNIQUE KEY `fid` (`fid`),
  SPATIAL KEY `pt` (`pt`)
);
```

ここで、等級```grade```は0〜7の数値で、以下のような意味を持つ（0〜1はデータベース外で使用）。
```
7 電子基準点
6 一等三角点
5 二等三角点
4 三等三角点
3 四等三角点
2 標高点
1 その他（廃止三角点、水準点）
0 等高線
```

### Step 5. データベースにデータを入力
```./results```ディレクトリの下の SQL ファイルを全て```MySQL```に順次読み込ませて、テーブル```gcp```にデータを入力する。

これでデータベース化は完了です。
