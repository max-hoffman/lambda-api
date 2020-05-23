\c test;

create extension if not exists "uuid-ossp";

create schema if not exists schema_private;

create table if not exists schema_private.person (
    id               uuid primary key not null default uuid_generate_v1mc(),
    name             text not null check (char_length(name) < 255),
    email            text not null unique check (char_length(email) < 255),
    created_at       timestamp default now()
);

alter table schema_private.person add column inviter_id uuid references schema_private.person(id);

comment on table schema_private.person is 'A user of the app.';
comment on column schema_private.person.id is 'The primary unique identifier for the person.';
comment on column schema_private.person.name is 'The person''s name.';
comment on column schema_private.person.email is 'The person''s email.';
comment on column schema_private.person.token is 'The person''s access token.';
comment on column schema_private.person.inviter_id is 'The person that referred this person''s primary id.';
comment on column schema_private.person.created_at is 'The time this person was created.';
