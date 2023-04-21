merge into public.models t
using (
  select
    %s name, %s title, %s description, %s creator, %s creator_contact_email, %s type, %s grid_width, %s grid_height, %s sigma_levels, %s min_x, %s max_x, %s min_y, %s max_y) s on s.name = t.name
when not matched then
  insert (name, title, description, creator, creator_contact_email, type, grid_width, grid_height, sigma_levels, min_x, max_x, min_y, max_y)
    values (s.name, s.title, s.description, s.creator, s.creator_contact_email, s.type, s.grid_width, s.grid_height, s.sigma_levels, s.min_x, s.max_x, s.min_y, s.max_y)
    when matched then
      update set
        title = s.title, description = s.description, creator = s.creator, creator_contact_email = s.creator_contact_email, type = s.type, grid_width = s.grid_width, grid_height = s.grid_height, sigma_levels = s.sigma_levels, min_x = s.min_x, max_x = s.max_x, min_y = s.min_y, max_y = s.max_y;

