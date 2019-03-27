DROP TRIGGER IF EXISTS action_log_delete ON activity ;

CREATE OR REPLACE FUNCTION action_log_delete() RETURNS TRIGGER AS $action_log$
BEGIN 
    INSERT INTO action_log SELECT nextval('id_generator'), 'delete', TG_TABLE_NAME, old.id, user, now();
    RETURN OLD;
    RETURN NULL; -- le résultat est ignoré car il s'agit d'un trigger AFTER

END;
$action_log$ language plpgsql;

CREATE TRIGGER action_log_delete
    AFTER DELETE ON activity
    FOR EACH ROW EXECUTE PROCEDURE action_log_delete();