#!/usr/bin/env python3

# grade
# 7: 電子基準点
# 6: 一等三角点
# 5: 二等三角点
# 4: 三等三角点
# 3: 四等三角点
# 2: 標高点
# 1: その他（水準点、廃止三角点）
# 0: 等高線

import sys
from xml.etree import ElementTree as ET

namespaces = {
    "gml": "http://www.opengis.net/gml/3.2",
    "": "http://fgd.gsi.go.jp/spec/2008/FGD_GMLSchema",
}

gcp_class = {"一等三角点": 6, "二等三角点": 5, "三等三角点": 4, "四等三角点": 3}


def main():
    files = sys.argv[1:]
    for f in files:
        tree = ET.parse(f)
        root = tree.getroot()
        for tag in ["GCP", "ElevPt"]:
            for pt in root.findall(tag, namespaces):
                fid = pt.find("fid", namespaces).text  # 基盤地図情報レコードID
                lat, lon = pt.find(
                    "pos/gml:Point/gml:pos", namespaces
                ).text.split()  # 地点
                alti = getattr(pt.find("alti", namespaces), "text", -9999)  # 標高
                t = pt.find("type", namespaces).text  # 種別
                if t == "電子基準点":
                    name = pt.find("name", namespaces).text  # 点名称
                    if not name.endswith("（付）"):
                        continue
                    grade = 7
                elif t == "三角点":
                    name = pt.find("name", namespaces).text  # 点名称
                    grade = gcp_class.get(
                        pt.find("gcpClass", namespaces).text
                    )  # 等級種別
                    if grade is None:
                        continue
                elif t == "標高点（測点）":
                    name = ""
                    grade = 2
                else:
                    continue
                print(
                    f"('{fid}',{grade},ST_GeomFromText('POINT({lon} {lat})',4326,'axis-order=long-lat'),{alti},'{name}'),"
                )


if __name__ == "__main__":
    main()

# __END__
