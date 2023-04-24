merge into public.models t
using (
  select
    t.id, st_convexhull(t.coords)::geometry(Polygon, 3857) convexhull,(st_makeenvelope(t.min_x, t.min_y, t.max_x, t.max_y, 4326))::geometry(Polygon, 4326) envelope
          from (
            select
              m.id, m.min_x, m.max_x, m.max_y, m.min_y, st_collect(c.coord) coords
              from
                public.coordinates c
                join public.models m on m.id = c.modelid
              where
                m.name = $1
              group by
                m.id, m.min_x, m.max_x, m.min_y, m.max_y) t) s on s.id = t.id
when matched then
    update
      set
        convexhull = s.convexhull, envelope = s.envelope;

