

CREATE TABLE users
(
  id serial NOT NULL,
  first_name character varying(50),
  last_name character varying(50),
  age integer,
  email character varying(255),
  UNIQUE(email),
  CONSTRAINT users_pkey PRIMARY KEY (id)
);

\copy users(first_name,last_name,age,email) FROM '/mnt/init/users.csv' with (format csv,header true, delimiter ',');

