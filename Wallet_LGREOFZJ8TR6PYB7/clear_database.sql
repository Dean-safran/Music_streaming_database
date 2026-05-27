
BEGIN
  FOR t IN (SELECT table_name FROM user_tables) LOOP
    EXECUTE IMMEDIATE 'DELETE FROM "' || t.table_name || '"';
  END LOOP;
END;
/

COMMIT;