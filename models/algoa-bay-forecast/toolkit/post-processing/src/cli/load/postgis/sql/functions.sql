
CREATE OR REPLACE
FUNCTION public.get_models(
            z integer, x integer, y integer)
RETURNS bytea
AS $$
DECLARE
    result bytea;
BEGIN
    with
    bounds AS (
      SELECT ST_TileEnvelope(z, x, y) AS geom
    ),
    mvtgeom AS (
      select
      ST_AsMVTGeom(
		ST_Transform(extent, 3857),
      	bounds.geom
      ) geom
      from 
    metadata m, bounds
    )
    SELECT ST_AsMVT(mvtgeom, 'default')
    INTO result
    FROM mvtgeom;

    RETURN result;
END;
$$
LANGUAGE 'plpgsql'
STABLE
PARALLEL SAFE;