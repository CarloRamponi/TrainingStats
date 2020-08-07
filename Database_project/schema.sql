-- -----------------------------------------------------
-- Table "Player"
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS "Player" (
  "id" INTEGER PRIMARY KEY,
  "name" VARCHAR(128) NULL,
  "short_name" VARCHAR(4) NOT NULL,
  "photo" VARCHAR(128) NULL);


-- -----------------------------------------------------
-- Table "Team"
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS "Team" (
  "id" INTEGER PRIMARY KEY,
  "name" VARCHAR(128) NOT NULL);


-- -----------------------------------------------------
-- Table "PlayerTeam"
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS "PlayerTeam" (
  "player" INTEGER NOT NULL,
  "team" INTEGER NOT NULL,
  PRIMARY KEY ("player", "team"),
  CONSTRAINT "fk_PlayerTeam_1"
    FOREIGN KEY ("player")
    REFERENCES "Player" ("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT "fk_PlayerTeam_2"
    FOREIGN KEY ("team")
    REFERENCES "Team" ("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
