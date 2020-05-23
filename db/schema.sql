create extension if not exists "uuid-ossp";

create schema if not exists quarantoned;

create table if not exists quarantoned.person (
    id               uuid primary key default uuid_generate_v1mc(),
    name             text not null check (char_length(name) < 255),
    email            text not null check (char_length(email) < 255),
    token            text check (char_length(token) < 1024),
    created_at       timestamp default now()
);

alter table quarantoned.person add column inviter_id uuid references quarantoned.person(id) not null;

comment on table quarantoned.person is 'A user of the app.';
comment on column quarantoned.person.id is 'The primary unique identifier for the person.';
comment on column quarantoned.person.name is 'The person''s name.';
comment on column quarantoned.person.email is 'The person''s email.';
comment on column quarantoned.person.token is 'The user''s email.';
comment on column quarantoned.person.inviter_id is 'The user that referred this user.';
comment on column quarantoned.person.created_at is 'The time this person was created.';

create table if not exists quarantoned.group (
    id               uuid primary key default uuid_generate_v1mc(),
    name             text not null check (char_length(name) < 255),
    description      text,
    created_at       timestamp default now()
);

comment on table quarantoned.group is 'A group of the app.';
comment on column quarantoned.group.id is 'The primary unique identifier for the group.';
comment on column quarantoned.group.name is 'The group''s name.';
comment on column quarantoned.group.description is 'The groups''s description.';
comment on column quarantoned.group.created_at is 'The time this group was created.';

create table if not exists quarantoned.event (
    id               uuid primary key NOT NULL DEFAULT uuid_generate_v1mc(),
    attended         boolean not null,
    schedule_id      bigint not null,
    name             text not null check (char_length(name) < 255),
    email            text not null check (char_length(email) < 255),
    host_id          uuid not null,
    url              text check (char_length(url) < 1024),
    token            text check (char_length(token) < 1024),
    address          text check (char_length(address) < 1024),
    start_time       timestamp not null,
    duration         bigint not null,
    end_time         timestamp,
    description      text,
    created_at       timestamp default now(),
    foreign key (host_id) references quarantoned.person(id)
);

comment on table quarantoned.event is 'A event in the app.';
comment on column quarantoned.event.id is 'The primary unique identifier for the event.';
comment on column quarantoned.event.attended is 'The group''s name.';
comment on column quarantoned.event.schedule_id is 'The groups''s description.';
comment on column quarantoned.event.name is 'The group''s name.';
comment on column quarantoned.event.email is 'The group''s email.';
comment on column quarantoned.event.token is 'The group''s token.';
comment on column quarantoned.event.address is 'The group''s address.';
comment on column quarantoned.event.start_time is 'The group''s start time.';
comment on column quarantoned.event.duration is 'How long the event is supposed to run, in minutes .';
comment on column quarantoned.event.end_time is 'The group''s end time.';
comment on column quarantoned.event.description is 'The group''s description.';
comment on column quarantoned.event.created_at is 'The time this event was created.';

create table if not exists quarantoned.person_event (
    id               uuid primary key default uuid_generate_v1mc(),
    join_time        timestamp not null,
    person_id        uuid not null,
    event_id         uuid not null,
    created_at       timestamp default now(),
    foreign key (event_id) references quarantoned.event(id),
    foreign key (person_id) references quarantoned.person(id)
);

comment on table quarantoned.person_event is 'A person to event attendance relation';
comment on column quarantoned.person_event.id is 'The primary id for the attendance relation.';
comment on column quarantoned.person_event.person_id is 'The persons''s primary id.';
comment on column quarantoned.person_event.event_id is 'The event''s primary id';
comment on column quarantoned.person_event.created_at is 'The time this attendance relation was created.';

create table if not exists quarantoned.person_group (
    id               uuid primary key default uuid_generate_v1mc(),
    joined           boolean not null,
    person_id        uuid not null,
    group_id         uuid not null,
    created_at       timestamp default now(),
    foreign key (group_id) references quarantoned.group(id),
    foreign key (person_id) references quarantoned.person(id)
);

comment on table quarantoned.person_group is 'A person to group membership relation';
comment on column quarantoned.person_group.id is 'The primary id for the group membership relation.';
comment on column quarantoned.person_group.joined is 'Whether the membership relation is being created or removed.';
comment on column quarantoned.person_group.person_id is 'The persons''s primary id.';
comment on column quarantoned.person_group.group_id is 'The group''s primary id';
comment on column quarantoned.person_group.created_at is 'The time this membership relation was created.';
