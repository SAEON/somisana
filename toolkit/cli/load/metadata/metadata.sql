do $$
begin
  if exists (
    select
      1
    from
      pg_matviews
    where
      matviewname = 'metadata') then
  refresh materialized view metadata;
else
  create materialized view metadata as
  select
    modelId,
    min_x,
    max_x,
    min_y,
    max_y,
    st_makeenvelope (min_x, min_y, max_x, max_y, 4326) extent
  from (
    select
      c.modelId,
      min(c.longitude) min_x,
      max(c.longitude) max_x,
      max(c.latitude) max_y,
      min(c.latitude) min_y
    from
      coordinates c
    group by
      modelId) t;
end if;
end
$$;

