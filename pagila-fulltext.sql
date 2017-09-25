/*
 * Adds fulltext seaching support.  Requires that Tsearch2 libraries
 * already be installed, and the Tsearch2 SQL script run in this database
 *
 * Example usage:
 *
 * SELECT * FROM film WHERE fulltext @@ to_tsquery('fate&india');
 */

BEGIN;

ALTER TABLE film ADD COLUMN fulltext tsvector;

UPDATE film SET fulltext=to_tsvector(title || ' ' || coalesce(description, ''));

ALTER TABLE film ALTER COLUMN fulltext SET NOT NULL;

CREATE INDEX film_fulltext_idx ON film USING gist(fulltext);

CREATE TRIGGER film_fulltext_trigger BEFORE INSERT OR UPDATE ON film FOR EACH ROW EXECUTE PROCEDURE tsearch2('fulltext', 'title', 'description');

COMMIT;

VACUUM FULL ANALYZE film;
