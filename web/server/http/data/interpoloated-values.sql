;

with
values
  as (
    select
      v.id,
      v.coordinateid,
      v.depth_level,
      v.temperature temp,
      v.salinity salt,
      v.u,
      v.v,
      v.depth,
      -300 selected_depth
    from
    values
      v
    where
      runid = 1
      and time_step = 1
      and modelid = 1
),
bounded_values as (
  select
    b.*,
    row_number() over (partition by b.coordinateid order by interpolation_distance asc) "r#"
  from (
  select
    v.id,
    v.coordinateid,
    v.depth_level,
    v.selected_depth,
    abs(v.depth - v.selected_depth) interpolation_distance,
    case when v.selected_depth between v.depth and coalesce(v_upper.depth, 0) then
      'UP'
    when v.selected_depth between v_lower.depth and v.depth then
      'DOWN'
    else
      'UP' -- I think this will work
    end interp_direction,
    case when v.selected_depth between v.depth and coalesce(v_upper.depth, 0) then
      coalesce(v_upper.depth, 0) - v.depth
    when v.selected_depth between v_lower.depth and v.depth then
      v.depth - v_lower.depth
    else
      0
    end "Δ depth",
    coalesce(v_upper.depth, 0) depth_upper,
  v.depth,
  v_lower.depth depth_lower,
  coalesce(v_upper.temp, v.temp) temp_upper,
  v.temp,
  v_lower.temp temp_lower,
  coalesce(v_upper.salt, v.salt) salt_upper,
  v.salt,
  v_lower.salt salt_lower,
  coalesce(v_upper.u, v.u) u_upper,
  v.u,
  v_lower.u u_lower,
  coalesce(v_upper.v, v.v) v_upper,
  v.v,
  v_lower.v v_lower
from
values v
  left join
values v_upper on v_upper.coordinateid = v.coordinateid
  and v_upper.depth_level = (v.depth_level + 1)
  left join
values v_lower on v_lower.coordinateid = v.coordinateid
  and v_lower.depth_level = case when v.depth_level < 2 then
    v.depth_level
  else
    (v.depth_level - 1)
  end) b
where depth_lower is not null
and selected_depth between b.depth_lower and b.depth_upper
),
interpolated_values as (
  select
    bv.coordinateid,
    -- temperature
    bv.temp + case bv. "Δ depth"
    when 0 then
      0
    else
      case bv.interp_direction
      when 'UP' then
        (coalesce(bv.temp_upper, bv.temp) - bv.temp) / abs(bv. "Δ depth")
      when 'DOWN' then
        (bv.temp_lower - bv.temp) / abs(bv. "Δ depth")
      end
    end temperature,
    -- salinity
    bv.salt + case bv. "Δ depth"
    when 0 then
      0
    else
      case bv.interp_direction
      when 'UP' then
        (coalesce(bv.salt_upper, bv.salt) - bv.salt) / abs(bv. "Δ depth")
      when 'DOWN' then
        (bv.salt_lower - bv.salt) / abs(bv. "Δ depth")
      end
    end salinity,
    -- u
    bv.u + case bv. "Δ depth"
    when 0 then
      0
    else
      case bv.interp_direction
      when 'UP' then
        (coalesce(bv.u_upper, bv.u) - bv.u) / abs(bv. "Δ depth")
      when 'DOWN' then
        (bv.u_lower - bv.u) / abs(bv. "Δ depth")
      end
    end u,
    -- v
    bv.v + case bv. "Δ depth"
    when 0 then
      0
    else
      case bv.interp_direction
      when 'UP' then
        (coalesce(bv.v_upper, bv.v) - bv.v) / abs(bv. "Δ depth")
      when 'DOWN' then
        (bv.v_lower - bv.v) / abs(bv. "Δ depth")
      end
    end v
  from
    bounded_values bv
  where
    "r#" = 1
)
select
  c.coord xy,
  v.temperature,
  v.salinity,
  v.u,
  v.v
from
  interpolated_values v
  join coordinates c on c.id = v.coordinateid
