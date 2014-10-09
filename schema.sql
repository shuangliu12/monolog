CREATE TABLE users(
  id serial PRIMARY KEY,
  uid varchar(255) NOT NULL,
  provider varchar(255) NOT NULL,
  username varchar(255) NOT NULL,
  name varchar(255) NOT NULL,
  email varchar(255) NOT NULL,
  avatar_url varchar(255)
);

CREATE TABLE status(
  id serial PRIMARY KEY,
  content varchar(1000) NOT NULL,
  mood integer NOT NULL,
  time timestamp
);
