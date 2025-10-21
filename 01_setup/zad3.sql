ZAD 3. EWKT
1) CREATE TABLE obiekty(
	id SERIAL PRIMARY KEY,
	name TEXT,
	polygons GEOMETRY(POLYGON),
	lines GEOMETRY(LINESTRING),
	points GEOMETRY(POINT)
)

a)

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
