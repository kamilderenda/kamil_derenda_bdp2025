ZAD 3. CREATE EXTENSION postgis;
ZAD 4.
CREATE TABLE buildings (
    id SERIAL PRIMARY KEY,
    name TEXT,
    geom GEOMETRY(POLYGON)
)

CREATE TABLE roads (
    id SERIAL PRIMARY KEY,
    name TEXT,
    geom GEOMETRY(LINESTRING)
)

CREATE TABLE poi (
    id SERIAL PRIMARY KEY,
    name TEXT,
    geom GEOMETRY(POINT)
)

ZAD 5.
INSERT INTO buildings (name, geom)
VALUES
('BuildingF', ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1,1 2))')),
('BuildingA', ST_GeomFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5,8 4))')),
('BuildingD', ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8,9 9))')),
('BuildingB', ST_GeomFromText('POLYGON((4 7, 6 7, 6 5, 4 5,4 7))')),
('BuildingC', ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6,3 8))'));

INSERT INTO roads (name, geom)
VALUES
('RoadY', ST_GeomFromText('LINESTRING(-7.5 0, 7.5 0)')),
('RoadX', ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)'));

INSERT INTO poi (name, geom)
VALUES
('G', ST_GeomFromText('POINT(1 3.5)')),
('H', ST_GeomFromText('POINT(5.5 1.5)')),
('I', ST_GeomFromText('POINT(9.5 6)')),
('J', ST_GeomFromText('POINT(6.5 6)')),
('K', ST_GeomFromText('POINT(6 9.5)'));

ZAD 6.
a) SELECT SUM(ST_Length(geom)) AS total_road_length
FROM roads;
b) SELECT
    name,
    ST_AsText(geom),
    ST_Area(geom),
    ST_Perimeter(geom)
FROM buildings
WHERE name = 'BuildingA';
c) SELECT
    name,
    ST_Area(geom)
FROM buildings
ORDER BY name;
d) SELECT
    name,
    ST_Perimeter(geom)
FROM buildings
ORDER BY ST_Area(geom) DESC
LIMIT 2;
e)SELECT
    ST_Distance(b.geom, p.geom) 
FROM buildings b
JOIN poi p ON p.name = 'K'
WHERE b.name = 'BuildingC';
f)SELECT
    ST_Area(
        ST_Difference(
            c.geom,
            ST_Buffer(b.geom, 0.5)
        )
    ) AS area_farther_than_0_5
FROM buildings c, buildings b
WHERE c.name = 'BuildingC' AND b.name = 'BuildingB';
g) SELECT b.name
FROM buildings b
JOIN roads r ON r.name = 'RoadX'
WHERE ST_Y(ST_Centroid(b.geom)) > ST_YMax(r.geom);
h) SELECT
    ST_Area(
        ST_SymDifference(
            c.geom,
            ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')
        )
    )
FROM buildings c
WHERE c.name = 'BuildingC'

