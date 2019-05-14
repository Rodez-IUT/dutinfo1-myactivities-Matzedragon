CREATE OR REPLACE FUNCTION add_activity(in_title VARCHAR(200),in_description VARCHAR(200), in_owner_id bigint DEFAULT = get_default_owner().id ) RETURNS activity AS $$
-- faire le default 
DECLARE 
	ligne activity%rowtype;
BEGIN
	INSERT INTO activity VALUES(nextval('id_generator'),in_title, in_description, now(), now(),in_owner_id);
	SELECT * INTO ligne FROM activity WHERE title = in_title;
	RETURN ligne;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION find_all_activities(activities_cursor refcursor) RETURNS refcursor AS $$
BEGIN
	OPEN activities_cursor FOR SELECT activity.title, user.username FROM activity JOIN "user" ON activity.owner_id = user.id;
	RETURN activities_cursor;
END
$$ LANGUAGE plpgsql;
	