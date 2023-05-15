merge into public.models t
using (
  select
    $1 name, $2 title, $3 description, $4 creator, $5 creator_contact_email, $6 type, $7::int grid_width, $8::int grid_height, $9::int sigma_levels, $10::float min_x, $11::float max_x, $12::float min_y, $13::float max_y) s on s.name = t.name
when not matched then
  insert (name, title, description, creator, creator_contact_email, type, grid_width, grid_height, sigma_levels, min_x, max_x, min_y, max_y)
    values (s.name, s.title, s.description, s.creator, s.creator_contact_email, s.type, s.grid_width, s.grid_height, s.sigma_levels, s.min_x, s.max_x, s.min_y, s.max_y)
    when matched then
      update set
        title = s.title, description = s.description, creator = s.creator, creator_contact_email = s.creator_contact_email, type = s.type, grid_width = s.grid_width, grid_height = s.grid_height, sigma_levels = s.sigma_levels, min_x = s.min_x, max_x = s.max_x, min_y = s.min_y, max_y = s.max_y;

