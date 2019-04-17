CREATE OR REPLACE FUNCTION register_user_on_activity(in_user_id bigint, in_activity_id bigint) RETURNS registration AS $$
    DECLARE
        res_registration registration%rowtype;

    BEGIN
        SELECT * INTO res_registration FROM registration WHERE user_id = in_user_id AND activity_id = in_activity_id;
        IF FOUND THEN
            RAISE EXCEPTION 'registration_already_exists';
        END IF;

        INSERT INTO registration (id, user_id, activity_id)
        VALUES(nextval('id_generator'), in_user_id, in_activity_id);

        SELECT * INTO res_registration FROM registration WHERE user_id = in_user_id AND activity_id = in_activity_id;
        RETURN res_registration;
    END
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION unregister_user_on_activity(in_user_id bigint, in_activity_id bigint) RETURNS void AS $$
    DECLARE
        res_registration registration%rowtype;

    BEGIN
        SELECT * INTO res_registration FROM registration WHERE user_id = in_user_id AND activity_id = in_activity_id;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'registration_not_found';
        END IF;

        DELETE FROM registration WHERE user_id = in_user_id AND activity_id = in_activity_id;

    END
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS action_log ON registration;

CREATE OR REPLACE FUNCTION action_log() RETURNS TRIGGER AS $action_log$
BEGIN 
	IF (TG_OP = 'INSERT') THEN
   	 	INSERT INTO action_log VALUES(nextval('id_generator'), 'insert', 'registration', NEW.id, user, now());
    ELSE
    	INSERT INTO action_log SELECT nextval('id_generator'), 'delete', TG_TABLE_NAME, OLD.id, user, now();
    END IF;
    RETURN NULL; -- le résultat est ignoré car il s'agit d'un trigger AFTER

END;
$action_log$ language plpgsql;


CREATE TRIGGER action_log
    AFTER DELETE OR INSERT ON registration
    FOR EACH ROW EXECUTE PROCEDURE action_log();