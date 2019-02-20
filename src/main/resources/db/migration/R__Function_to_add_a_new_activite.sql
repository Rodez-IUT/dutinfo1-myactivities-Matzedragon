CREATE OR REPLACE FUNCTION add_activity_with_title(title VARCHAR(200)) RETURNS bigint AS $$
	INSERT INTO activity (id, title)
	VALUES (nextval('id_generator'), add_activity_with_title.title)
	RETURNING id;
$$ LANGUAGE SQL;
