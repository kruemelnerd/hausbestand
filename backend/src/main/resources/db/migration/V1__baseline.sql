create table app_installation (
  id smallint primary key,
  baseline_version varchar(32) not null,
  installed_at timestamptz not null default current_timestamp
);

insert into app_installation (id, baseline_version)
values (1, 'V1__baseline');
