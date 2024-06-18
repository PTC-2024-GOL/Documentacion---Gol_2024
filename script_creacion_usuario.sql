-- Iniciamos con nuestro usuario root
mysql -u root

-- Creamos el usuario y le otorgamos una contraseña
CREATE USER 'db_sv_gol_desarrollador'@'localhost' IDENTIFIED BY '123456';
 
-- Usamos nuestra base de datos
USE db_gol_sv;
 
-- Asignamos permisos para ver, actualizar, eliminar y crear
GRANT SELECT, INSERT, UPDATE, DELETE ON db_gol_sv.* TO 'db_gol_sv_desarrollador'@'localhost'	;
  
-- Asignamos permisos para ejecutar y crear funciones, triggers, vistas y procedimientos
GRANT EXECUTE, CREATE ROUTINE, CREATE VIEW, TRIGGER ON db_gol_sv.* TO 'db_gol_sv_desarrollador'@'localhost';
  
-- Mostramos los permisos que tiene asignado el desarrollador
SHOW GRANTS FOR 'db_gol_sv_desarrollador'@'localhost';