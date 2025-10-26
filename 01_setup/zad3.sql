ZAD 3. EWKT
a)
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE IF NOT EXISTS obiekty(
    id serial PRIMARY KEY,
    nazwa text,
    geom geometry
);

INSERT INTO obiekty (nazwa, geom)
VALUES ('obiekt1',
  ST_Collect(ARRAY[
    ST_MakeLine(ST_MakePoint(0,1), ST_MakePoint(1,1)), 
    ST_GeomFromText('CIRCULARSTRING(1 1, 2 0, 3 1)'), 
    ST_GeomFromText('CIRCULARSTRING(3 1, 4 2, 5 1)'),
    ST_MakeLine(ST_MakePoint(5,1), ST_MakePoint(6,1))      
  ])
);

b)
WITH outer_ring AS (
  SELECT ST_MakePolygon(
    ST_LineMerge(ST_Collect(ARRAY[
      ST_MakeLine(ST_MakePoint(10,6), ST_MakePoint(14,6)),
      ST_GeomFromText('CIRCULARSTRING(14 6, 16 4, 14 2)'),
      ST_GeomFromText('CIRCULARSTRING(14 2, 12 0, 10 2)'),
      ST_MakeLine(ST_MakePoint(10,2), ST_MakePoint(10,6))
    ]))
  ) AS geom
),
inner_hole AS (
  SELECT ST_Buffer(ST_MakePoint(12,2), 1) AS geom
)
INSERT INTO obiekty (nazwa, geom)
SELECT 
  'obiekt2',
  ST_Difference(outer_ring.geom, inner_hole.geom)
FROM outer_ring, inner_hole;


c)
INSERT INTO obiekty(nazwa, geom)
VALUES ('obiekt3',
  ST_GeomFromText('POLYGON((7 15, 10 17, 12 13, 7 15))')
);

d)
INSERT INTO obiekty(nazwa, geom)
VALUES ('obiekt4',
  ST_GeomFromText('LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)')
);

e)
INSERT INTO obiekty(nazwa, geom)
VALUES ('obiekt5',
  ST_Collect(ARRAY[
    ST_GeomFromText('POINT Z(30 30 59)'),
    ST_GeomFromText('POINT Z(38 32 234)')
  ])
);

f)
INSERT INTO obiekty(nazwa, geom)
VALUES ('obiekt6',
  ST_Collect(ARRAY[
    ST_GeomFromText('LINESTRING(1 1, 3 2)'),
    ST_GeomFromText('POINT(4 2)')
  ])
);



2. 
SELECT ST_Area(
         ST_Buffer(
           ST_ShortestLine(
             (SELECT geom FROM obiekty WHERE nazwa='obiekt3'),
             (SELECT geom FROM obiekty WHERE nazwa='obiekt4')
           ),
           5
         )
       ) AS pole_powierzchni;

3. 
UPDATE obiekty
SET geom = ST_MakePolygon(
  ST_AddPoint(geom, ST_StartPoint(geom))
)
WHERE nazwa = 'obiekt4';
4. 
INSERT INTO obiekty (nazwa, geom)
SELECT 'obiekt7',
       ST_Union(
         (SELECT geom FROM obiekty WHERE nazwa = 'obiekt3'),
         (SELECT geom FROM obiekty WHERE nazwa = 'obiekt4')
       );

5. 
SELECT SUM(ST_Area(ST_Buffer(geom, 5))) AS suma_pol_buforow
FROM obiekty
WHERE NOT ST_HasArc(geom);




ZAD 3. HERE
1. SELECT left_table.*
FROM t2019_kar_buildings AS left_table
LEFT JOIN t2018_kar_buildings AS right_table 
ON left_table.geom = right_table.geom AND left_table.height = right_table.height
WHERE right_table.geom IS NULL;
2. WITH buildings AS (
	SELECT left_table.*
	FROM T2019_KAR_BUILDINGS AS left_table
	LEFT JOIN T2018_KAR_BUILDINGS AS right_table 
	ON left_table.geom = right_table.geom AND left_table.height = right_table.height
	WHERE right_table.geom IS NULL
), buffer AS (
	SELECT ST_Buffer(ST_Union(geom), 0.005) AS geom FROM buildings
), new_poi AS (
	SELECT left_table.*
	FROM T2019_KAR_POI_TABLE AS left_table
	LEFT JOIN T2018_KAR_POI_TABLE AS right_table
	ON left_table.geom = right_table.geom
	WHERE right_table.geom IS NULL
), count_poi AS (
	SELECT COUNT(CASE WHEN ST_Contains(left_table.geom, right_table.geom) THEN 1 END) AS count, type
	FROM new_poi AS right_table
	CROSS JOIN buffer AS left_table
	GROUP BY type
)

SELECT * 
FROM count_poi
WHERE count != 0
ORDER BY count DESC;

3. CREATE TABLE streets_reprojected AS
SELECT
    st_name,
    ref_in_id,
    nref_in_id,
    func_class,
    speed_cat,
    fr_speed_l,
    to_speed_l,
    dir_travel,
    ST_Transform(geom, 3068) AS geom 
FROM T2019_KAR_STREETS;

4.CREATE TABLE input_points (
	id SERIAL PRIMARY KEY,
	geometry geometry
);

INSERT INTO input_points(geometry)
VALUES
('POINT(8.36093 49.03174)'),
('POINT(8.39876 49.00644)');
5. ALTER TABLE input_points
  ALTER COLUMN geometry
  TYPE geometry(Point)
  USING ST_Transform(ST_SetSRID(geometry, 4326), 3068);
6. WITH intersections AS (
	SELECT node_id, ST_Transform(geom, 3068) as geometry
	FROM T2019_KAR_STREET_NODE AS a
	WHERE a."intersect" = 'Y'
), new_line AS (
	SELECT ST_MakeLine(geometry) AS geometry FROM input_points
)

SELECT DISTINCT(left_table.*)
FROM intersections AS left_table
CROSS JOIN new_line AS right_table
WHERE ST_Contains(ST_Buffer(right_table.geometry, 0.002), left_table.geometry)
7. WITH buffer AS (
	SELECT ST_Buffer(ST_Union(geom), 0.003) AS geom
	FROM T2019_KAR_LAND_USE_A
	WHERE "type" ILIKE '%park%'
), sport_pois AS (
	SELECT geom FROM T2019_KAR_POI_TABLE WHERE "type" LIKE 'Sporting Goods Store'
)

SELECT COUNT(CASE WHEN ST_Contains(left_table.geom, right_table.geom) THEN 1 END) AS count
FROM sport_pois AS right_table
CROSS JOIN buffer AS left_table;
8. SELECT DISTINCT(ST_Intersection(left_table.geom, right_table.geom)) AS geom
INTO T2019_KAR_BRIDGES
FROM T2019_KAR_RAILWAYS AS left_table
CROSS JOIN T2019_KAR_WATER_LINES AS right_table
WHERE ST_Intersects(left_table.geom, right_table.geom)

