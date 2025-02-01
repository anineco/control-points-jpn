#!/usr/bin/env python3

# grade
# 7: 電子基準点
# 6: 一等三角点
# 5: 二等三角点
# 4: 三等三角点
# 3: 四等三角点
# 2: 標高点

import sys
from lxml import etree as ET

FDG = '{http://fgd.gsi.go.jp/spec/2008/FGD_GMLSchema}'
GML = '{http://www.opengis.net/gml/3.2}';

gcp_class = {'一等三角点': 6, '二等三角点': 5, '三等三角点': 4, '四等三角点': 3}

def main():
    files = sys.argv[1:]
    for f in files:
        tree = ET.parse(f)
        root = tree.getroot()
        for tag in ['GCP', 'ElevPt']:
            for pt in root.findall(FDG + tag):
                lat, lon = pt.find(FDG + 'pos').find(GML + 'Point').find(GML + 'pos').text.split()
                alti = pt.find(FDG + 'alti')
                alt = alti.text if alti is not None else -9999
                name = ''
                grade = 0
                t = pt.find(FDG + 'type').text
                if t.startswith('電子基準点'):
                    name = pt.find(FDG + 'name') .text
                    if not name.endswith('（付）'):
                        continue
                    grade = 7
                elif t.startswith('三角点'):
                    name = pt.find(FDG + 'name') .text
                    grade = gcp_class.get(pt.find(FDG + 'gcpClass').text)
                    if grade is None:
                        continue
                elif t.startswith('標高点'):
                    grade = 2
                else:
                    continue
                print(f"({grade},ST_GeomFromText('POINT({lon} {lat})',4326/*!80003 ,'axis-order=long-lat' */),{alt},'{name}'),")

if __name__ == '__main__':
    main()

# __END__
