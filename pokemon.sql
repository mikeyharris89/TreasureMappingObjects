CREATE TABLE pokemon (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  trainer_id INTEGER,

  FOREIGN KEY(trainer_id) REFERENCES trainer(id)
);

CREATE TABLE trainers (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  town_id INTEGER,

  FOREIGN KEY(town_id) REFERENCES town(id)
);

CREATE TABLE towns (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  towns (id, name)
VALUES
  (1, "Pallet Town"), (2, "Saffron City"), (3, "Cerulean City");

INSERT INTO
  trainers (id, fname, lname, town_id)
VALUES
  (1, "Ash", "Ketchum", 1),
  (2, "Gary", "Oak", 1),
  (3, "Mikey", "Harris", NULL),
  (4, "Misty", "Waterflower", 3);

INSERT INTO
  pokemon (id, name, owner_id)
VALUES
  (1, "Pikachu", 1),
  (2, "Mewtwo", 2),
  (3, "Articuno", 3),
  (4, "Jolteon", 3),
  (5, "Staryu", 4);
