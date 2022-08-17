
;with 

model as (select 1 modelid),
depth as (select 1 depth_level),
time as (select 1 time_step)

,depths as (
  select
  	(select * from model),
  	(select * from depth),
  	(select * from time),
    pixel,
    value
  from
    public.get_values (modelid => 1, depth_level => 1, time_step => 1, variable => 'm_rho')
)


,temperatures as (
  select
  	(select * from model),
  	(select * from depth),
  	(select * from time),
    pixel,
    value
  from
    public.get_values (modelid => 1, depth_level => 1, time_step => 1, variable => 'temperature')
)

,salinity as (
  select
  	(select * from model),
  	(select * from depth),
  	(select * from time),
    pixel,
    value
  from
    public.get_values (modelid => 1, depth_level => 1, time_step => 1, variable => 'salt')
)

,u as (
  select
  	(select * from model),
  	(select * from depth),
  	(select * from time),
    pixel,
    value
  from
    public.get_values (modelid => 1, depth_level => 1, time_step => 1, variable => 'u')
)

,v as (
  select
  	(select * from model),
  	(select * from depth),
  	(select * from time),
    pixel,
    value
  from
    public.get_values (modelid => 1, depth_level => 1, time_step => 1, variable => 'v')
)

,values as (
	select
	d.modelid,
	d.depth_level,
	c.id coordinateid,
	st_makepoint(c.longitude,c.latitude,d.value) xyz,
	d.value depth,
	t.value temperature,
	s.value salinity,
	u.value u,
	v.value v
	from depths d
	join temperatures t on t.pixel = d.pixel
	join salinity s on s.pixel = d.pixel
	join u on u.pixel = d.pixel
	join v on v.pixel = d.pixel
	join coordinates c on c.modelid = d.modelid and c.pixel = d.pixel
)

select
*
from values
limit 1