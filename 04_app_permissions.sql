-- Права единого DB-аккаунта, под которым подключается учебное Bottle-приложение.
-- Сначала создайте роль afh_app и задайте ей пароль локально (не записывайте пароль в Git).
-- Выполнять от имени владельца базы после 01_schema.sql и 02_views_functions_triggers.sql.
-- Данный набор широк для учебного стенда; не используйте его как production-политику.
GRANT CONNECT ON DATABASE afh TO afh_app;
GRANT USAGE ON SCHEMA public TO afh_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO afh_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO afh_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO afh_app;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO afh_app;

-- Привилегии на объекты, создаваемые в этой схеме позднее владельцем, от имени которого
-- выполняется следующий ALTER DEFAULT PRIVILEGES.
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO afh_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO afh_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT EXECUTE ON FUNCTIONS TO afh_app;
