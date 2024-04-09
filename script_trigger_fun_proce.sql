-- TRIGGERS, FUNCIONES Y PROCEDIMIENTOS ALMACENADOS

USE db_gol_sv;

-- TRIGGER
-- El trigger calcula el promedio de las notas de las subcaracterísticas para el jugador que ha sido modificado.
DELIMITER //
CREATE TRIGGER update_promedio_subcaracteristicas
AFTER UPDATE ON caracteristicas_analisis
FOR EACH ROW
BEGIN
  UPDATE vista_promedio_subcaracteristicas_por_jugador
  SET promedio_subcaracteristicas = AVG(nota_caracteristica_analisis)
  WHERE id_jugador = NEW.id_jugador;
END;
//
DELIMITER ;

-- FUNCION


-- PROCEDIMIENTO ALMACENADO