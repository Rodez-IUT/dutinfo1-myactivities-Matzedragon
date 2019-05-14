CREATE OR REPLACE FUNCTION register_user_on_activity(idUser bigint, idActivity bigint) RETURNS registration AS $$
	DECLARE
		r registration%rowtype;
	BEGIN
		SELECT * INTO r FROM registration 
		WHERE user_id = idUser
		AND activity_id = idActivity;
		 
		IF FOUND THEN
			RAISE EXCEPTION 'registration_already_exists';     
		END IF;
		INSERT INTO registration (id, registration_date, user_id, activity_id)
			                      values (nextval('id_generator'), now(), idUser, idActivity);
		SELECT * INTO r FROM registration
		WHERE user_id = idUser
		AND activity_id = idActivity;
		RETURN r;
	END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS log_insert_registration on registration;
CREATE OR REPLACE FUNCTION log_insert_registration() RETURNS TRIGGER AS $$
	BEGIN
		INSERT INTO action_log (id,action_name, entity_name, entity_id, author, action_date)
		    values (nextval('id_generator'),'insert','registration', NEW.id, user,now()); 
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_insert_registration
    AFTER INSERT ON registration
    FOR EACH ROW EXECUTE PROCEDURE log_insert_registration();

CREATE OR REPLACE FUNCTION unregister_user_on_activity(idUser bigint, idActivity bigint) RETURNS void AS $$
	DECLARE
		rr registration%rowtype;
	BEGIN
		SELECT * INTO rr FROM registration
		WHERE user_id = idUser
		AND activity_id = idActivity;
		
		IF NOT FOUND THEN
			RAISE EXCEPTION 'registration_not_found';
		END IF;
		
		DELETE FROM registration
		WHERE user_id = idUser
		AND activity_id = idActivity;
	END;
$$ LANGUAGE plpgsql;
    
DROP TRIGGER IF EXISTS log_delete_registration on registration;
CREATE OR REPLACE FUNCTION log_delete_registration() RETURNS TRIGGER AS $$
	BEGIN
		INSERT INTO action_log (id,action_name, entity_name, entity_id, author, action_date)
		    values (nextval('id_generator'),'delete','registration', OLD.id, user,now()); 
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_delete_registration
    AFTER DELETE ON registration
    FOR EACH ROW EXECUTE PROCEDURE log_delete_registration();
