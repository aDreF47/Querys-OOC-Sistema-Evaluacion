-- 1. Eliminar los Triggers
DROP TRIGGER trg_check_max_estudiantes;

-- 2. Eliminar las Vistas
DROP VIEW v_cursos_matriculados;

-- 3. Eliminar restricciones de claves foráneas antes de eliminar las tablas
ALTER TABLE matricula DROP CONSTRAINT fk_pago;
ALTER TABLE horario DROP CONSTRAINT fk_curso;
ALTER TABLE horario DROP CONSTRAINT fk_profesor;

-- 4. Eliminar las Tablas (en el orden adecuado para evitar errores)
DROP TABLE matricula CASCADE CONSTRAINTS;
DROP TABLE pago CASCADE CONSTRAINTS;
DROP TABLE estudiante CASCADE CONSTRAINTS;
DROP TABLE horario CASCADE CONSTRAINTS;
DROP TABLE curso CASCADE CONSTRAINTS;
DROP TABLE modulo CASCADE CONSTRAINTS;
Drop Table Profesor Cascade Constraints;
Drop Table Informe_curso Cascade Constraints;
Drop Table Opciones_Satisfaccion Cascade Constraints;
DROP TABLE metricas_desempeno CASCADE CONSTRAINTS;

-- Tabla Modulo
CREATE TABLE modulo (
    id_modulo NUMBER(3),  -- Definición de la columna
    nombre VARCHAR2(20) CHECK (nombre IN ('basico', 'intermedio', 'avanzado')), 
    numero_modulo NUMBER(2) CHECK (numero_modulo BETWEEN 1 AND 12),
    CONSTRAINT pk_modulo PRIMARY KEY (id_modulo)  -- Nombre de la PK
);

-- Tabla Curso
CREATE TABLE curso (
    id_curso NUMBER(3),  -- Definición de la columna
    nombre VARCHAR2(50) NOT NULL,
    id_modulo NUMBER(3) NOT NULL,
    vacantes NUMBER(5) CHECK (vacantes >= 0),
    estado NUMBER(1) CHECK (estado IN (0, 1)),  -- 1 = activo, 0 = inactivo
    CONSTRAINT pk_curso PRIMARY KEY (id_curso),  -- Nombre de la PK
    CONSTRAINT fk_curso_modulo FOREIGN KEY (id_modulo) REFERENCES modulo(id_modulo)  -- Nombre de la FK
);

-- Tabla Profesor
CREATE TABLE profesor (
    id_profesor NUMBER(3),  -- Definición de la columna
    nombre VARCHAR2(50) NOT NULL,
    especializacion Varchar2(50) Not Null,
    --desempeno NUMBER(3, 1),  -- Calificación de desempeño (1 a 10) con 1 decimal
    CONSTRAINT pk_profesor PRIMARY KEY (id_profesor)  -- Nombre de la PK
);

drop table profesor;
-- Tabla Horario
CREATE TABLE horario (
    id_horario NUMBER(3),  -- Definición de la columna
    id_curso NUMBER(3) NOT NULL,
    id_profesor NUMBER(3) NOT NULL,
    hora_inicio DATE NOT NULL,
    hora_fin DATE NOT NULL,
    dia_semana VARCHAR2(10) CHECK (dia_semana IN ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')),
    CONSTRAINT pk_horario PRIMARY KEY (id_horario),  -- Nombre de la PK
    CONSTRAINT fk_horario_curso FOREIGN KEY (id_curso) REFERENCES curso(id_curso),  -- Nombre de la FK
    CONSTRAINT fk_horario_profesor FOREIGN KEY (id_profesor) REFERENCES profesor(id_profesor)  -- Nombre de la FK
);

-- Tabla Estudiante
CREATE TABLE estudiante (
    id_estudiante NUMBER(3),  -- Definición de la columna
    codigo VARCHAR2(20) NOT NULL,
    nombre VARCHAR2(50) NOT NULL,
    email VARCHAR2(50) NOT NULL,
    contrasena VARCHAR2(20) NOT NULL,
    saldo NUMBER(10, 2) DEFAULT 0,  -- Saldo con valor predeterminado de 0
    fecha_registro DATE DEFAULT SYSDATE,
    estado NUMBER(1) CHECK (estado IN (0, 1)),  -- 1 = activo, 0 = inactivo
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante)  -- Nombre de la PK
);


-- Tabla Pago
CREATE TABLE pago (
    id_pago NUMBER(3),  -- Definición de la columna
    id_estudiante NUMBER(3) NOT NULL,
    monto NUMBER(10, 2) NOT NULL CHECK (monto > 0),  -- Verifica que el monto sea positivo
    fecha_pago DATE DEFAULT SYSDATE,
    estado NUMBER(1) CHECK (estado IN (0, 1)),  -- 1 = pagado, 0 = pendiente
    CONSTRAINT pk_pago PRIMARY KEY (id_pago),  -- Nombre de la PK
    CONSTRAINT fk_pago_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)  -- Nombre de la FK
);

-- Tabla Matricula
CREATE TABLE matricula (
    id_matricula NUMBER(3),  -- Definición de la columna
    id_curso NUMBER(3) NOT NULL,
    id_pago NUMBER(3) NOT NULL,
    fecha_inscripcion DATE DEFAULT SYSDATE,
    estado NUMBER(1) CHECK (estado IN (0, 1)),  -- 1 = matriculado, 0 = no matriculado
    CONSTRAINT pk_matricula PRIMARY KEY (id_matricula),  -- Nombre de la PK
    CONSTRAINT fk_matricula_curso FOREIGN KEY (id_curso) REFERENCES curso(id_curso),  -- Nombre de la FK
    CONSTRAINT fk_matricula_pago FOREIGN KEY (id_pago) REFERENCES pago(id_pago)  -- Nombre de la FK
);

-- Tabla EstructuraExamen
CREATE TABLE estructura_examen (
    Id_Estructura Number(3),
    Tipo_Examen Varchar(20),
    Cantidad_Preguntas Number(3), -- CANTIDAD DE ESTE EXAMEN
    Puntaje Number(5, 2),
    Duracion Number(3), -- Duración en minutos
    Constraint Pk_Estructura Primary Key (Id_Estructura),
    CONSTRAINT CK_EXAMEN_TIPO CHECK (tipo_Examen IN ('prueba', 'examen final', 'entrada'))
);

-- Tabla Examen
CREATE TABLE Examen (
    Id_Examen Number(3),
    Id_Estructura Number(3),
    Fecha_Examen Date DEFAULT Sysdate,
    CONSTRAINT FK_EXAMEN_ESTRUCTURA FOREIGN KEY (Id_Estructura) REFERENCES estructura_examen(Id_Estructura),
    CONSTRAINT PK_EXAMEN PRIMARY KEY (Id_Examen)
);

-- Tabla Notas
Create Table Notas (
    Id_Nota Number(3),
    Id_Examen Number(3),
    id_estudiante number(3),
    Nota_Sacada Number(5, 2),
    Fecha_Completado Date Default Sysdate,
    CONSTRAINT PK_NOTAS PRIMARY KEY (ID_NOTA), 
    Constraint Fk_Notas_Examen Foreign Key (Id_Examen) References Examen(Id_Examen),
    CONSTRAINT FK_NOTAS_ESTUDIANTE FOREIGN KEY (id_estudiante) REFERENCES estudiante(Id_ESTUDIANTE),
    CONSTRAINT CK_NOTAS_PUNTAJE CHECK (nota_sacada BETWEEN 0 AND 20)
);

-- Tabla Retroalimentacion
Create Table Retroalimentacion (
    Id_Retroalimentacion Number(3),
    Id_Nota Number(3),
    Respuesta_Estudiante VARCHAR2(4000),
    correcta NUMBER(1),
    fundamento VARCHAR2(4000),
    Sugerencia Varchar2(4000),
    Constraint Pk_Retroalimentacion Primary Key (Id_Retroalimentacion),
    Constraint Fk_Retroalimentacion_Resultado Foreign Key (Id_Nota) References Notas(Id_Nota),
    CONSTRAINT CK_RETROALI_CORRECTA CHECK (correcta IN (0, 1))
);

-- Tabla Nivel
Create Table Nivel (
    id_Nivel NUMBER(3),
    Nombre Varchar2(20),
    CONSTRAINT PK_NIVEL PRIMARY KEY (ID_NIVEL),
    CONSTRAINT CK_NIVEL_NOMBRE CHECK (nombre IN ('facil', 'medio', 'dificil'))
);

-- Tabla BancoPregunta
Create Table Banco_Pregunta (
    Id_Bancopregunta Number(3) ,
    id_Nivel NUMBER(3),
    contenido VARCHAR2(4000),  -- Pregunta del examen
    Claves Varchar2(4000),  -- Claves de la pregunta (si es necesario para elegir múltiples opciones)
    Respuesta_Correcta Varchar2(4000),
    Constraint Pk_Banco_Pregunta Primary Key (Id_Bancopregunta),
    CONSTRAINT FK_BANCO_PREGUNTA_NIVEL FOREIGN KEY (id_Nivel) REFERENCES Nivel(id_Nivel)
);

-- Tabla ExamenBancoPregunta
Create Table ExamenBancopregunta (
    Id_Examen Number(3),
    Id_Bancopregunta Number(3),
    Constraint Fk_Examenbancopregunta_Examen Foreign Key (Id_Examen) References Examen(Id_Examen),
    Constraint Fk_ExamenBancoPregunta_Banco Foreign Key (Id_Bancopregunta) References Banco_pregunta(Id_Bancopregunta),
    CONSTRAINT PK_EXAMENBANCOPREGUNTA PRIMARY KEY (id_Examen, id_BancoPregunta)
);


--dejado para el  final
-- Tabla InformeCurso
CREATE TABLE informe_curso (
    id_informe NUMBER(3),  -- Definición de la columna
    id_curso NUMBER(3) NOT NULL,
    fecha_generacion_informe DATE DEFAULT SYSDATE,
    puntaje_promedio_en_curso NUMBER(5, 2) CHECK (puntaje_promedio_en_curso BETWEEN 0 AND 10),
    total_estudiantes NUMBER(5) CHECK (total_estudiantes >= 0),
    porcentaje_aprobados NUMBER(5, 2) CHECK (porcentaje_aprobados BETWEEN 0 AND 100),
    CONSTRAINT pk_informe_curso PRIMARY KEY (id_informe),  -- Nombre de la PK
    Constraint Fk_Informe_Curso Foreign Key (Id_Curso) References Curso(Id_Curso)  -- Nombre de la FK
);


--Trigger para controlar el número máximo de estudiantes en un curso
CREATE OR REPLACE TRIGGER trg_check_max_estudiantes
BEFORE INSERT OR UPDATE ON matricula
FOR EACH ROW
DECLARE
    v_count NUMBER;
    v_vacantes NUMBER;
BEGIN
    -- Contar el número de estudiantes matriculados en el curso
    SELECT COUNT(*) INTO v_count
    FROM matricula
    WHERE id_curso = :new.id_curso;

    -- Obtener el número de vacantes del curso
    SELECT vacantes INTO v_vacantes
    FROM curso
    WHERE id_curso = :new.id_curso;

    -- Verificar si se excede el máximo de estudiantes
    IF v_count >= v_vacantes THEN
        RAISE_APPLICATION_ERROR(-20001, 'Número máximo de estudiantes alcanzado para este curso');
    END IF;
END;

-- Vista para mostrar los cursos matriculados con el número de estudiantes
CREATE OR REPLACE VIEW v_cursos_matriculados AS
SELECT 
    c.id_curso, 
    c.nombre, 
    c.estado, 
    COUNT(p.id_estudiante) AS num_estudiantes
FROM curso c
  LEFT JOIN matricula m ON c.id_curso = m.id_curso
  LEFT JOIN pago p ON m.id_pago = p.id_pago  -- Unimos Matricula con Pago
GROUP BY c.id_curso, c.nombre, c.estado;


Create View Vistanotas As
Select E.Id_Estudiante,
       Ex.Id_Curso,
       n.nota_Sacada AS nota
From Examen Ex
JOIN Nota n ON ex.Id_Estudiante = n.Id_Estudiante
JOIN estudiante e ON ex.Id_Estudiante = e.Id_Estudiante
Where E.Estado = 1;  -- Solo estudiantes activos


CREATE OR REPLACE PROCEDURE calcular_nota_final (
    p_idEstudiante IN NUMBER
) IS
    v_nota_final NUMBER(5, 2);
BEGIN
    -- Calcular la nota promedio de los exámenes realizados
    SELECT AVG(re.puntajeSacado) INTO v_nota_final
    FROM Examen ex
    JOIN ResultadoExamen re ON ex.idExamen = re.idExamen
    WHERE ex.idEstudiante = p_idEstudiante AND re.puntajeSacado IS NOT NULL;

    -- Actualizar la tabla estudiante con la nota final calculada
    UPDATE estudiante
    SET nota = v_nota_final
    WHERE idEstudiante = p_idEstudiante;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Nota final para el estudiante ' || p_idEstudiante || ' calculada exitosamente.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('El estudiante no tiene exámenes registrados.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al calcular la nota final: ' || SQLERRM);
END;
/

desc matricula;
desc pago;
-------------------------------------------------------------------------------- 
-------------------------- INSERTAR DATOS -------------------------------------  
--------------------------------------------------------------------------------

-- Insertar datos en la tabla modulo (niveles de curso)
INSERT INTO modulo (id_modulo, nombre, numero_modulo)
VALUES (1, 'basico', 1);
INSERT INTO modulo (id_modulo, nombre, numero_modulo)
VALUES (2, 'intermedio', 2);
INSERT INTO modulo (id_modulo, nombre, numero_modulo)
VALUES (3, 'avanzado', 3);

-- Insertar datos en la tabla curso
INSERT INTO curso (id_curso, nombre, id_modulo, vacantes, estado) Values (1, 'Curso de Programación Básica', 1, 30, 1);
INSERT INTO curso (id_curso, nombre, id_modulo, vacantes, estado) VALUES (2, 'Curso de Programación Intermedia', 2, 25, 1);
INSERT INTO curso (id_curso, nombre, id_modulo, vacantes, estado) Values (3, 'Curso de Programación Avanzada', 3, 20, 1);
Insert Into Curso (Id_Curso, Nombre, Id_Modulo, Vacantes, Estado) Values (4, 'Curso INGLES', 3, 2, 1);

-- Insertar datos en la tabla profesor
INSERT INTO profesor (id_profesor, nombre, especializacion, desempeno)
VALUES (1, 'Juan Pérez', 'Programación en C++', 9.5);
INSERT INTO profesor (id_profesor, nombre, especializacion, desempeno)
VALUES (2, 'María López', 'Programación Web', 8.7);
INSERT INTO profesor (id_profesor, nombre, especializacion, desempeno)
VALUES (3, 'Carlos Martínez', 'Desarrollo de Software', 9.0);

-- Insertar datos en la tabla estudiante
INSERT INTO estudiante (id_estudiante, codigo, nombre, email, contrasena, saldo, fecha_registro, estado)
VALUES (1, 'E12345', 'Pedro Martínez', 'pedro@example.com', '1234', 0, SYSDATE, 1);
INSERT INTO estudiante (id_estudiante, codigo, nombre, email, contrasena, saldo, fecha_registro, estado)
VALUES (2, 'E67890', 'Laura Gómez', 'laura@example.com', 'abcd', 0, SYSDATE, 1);
INSERT INTO estudiante (id_estudiante, codigo, nombre, email, contrasena, saldo, fecha_registro, estado)
VALUES (3, 'E11223', 'José Rodríguez', 'jose@example.com', 'efgh', 0, SYSDATE, 1);
Insert Into Estudiante (Id_Estudiante, Codigo, Nombre, Email, Contrasena, Saldo, Fecha_Registro, Estado)
VALUES (4, 'E11223', 'FERNANDO', 'FERNANDO@example.com', '123', 0, SYSDATE, 1);
Insert Into Estudiante (Id_Estudiante, Codigo, Nombre, Email, Contrasena, Saldo, Fecha_Registro, Estado)
Values (5, 'E11223', 'LOPES', 'LOPES@example.com', 'e423', 0, Sysdate, 1);
Insert Into Estudiante (Id_Estudiante, Codigo, Nombre, Email, Contrasena, Saldo, Fecha_Registro, Estado)
VALUES (6, 'E11223', 'BETTY', 'BETTY@example.com', '222', 0, SYSDATE, 1);
-- Insertar datos en la tabla pago (suponiendo que los estudiantes pagaron)
INSERT INTO pago (id_pago, id_estudiante, monto, fecha_pago, estado)
VALUES (1, 1, 150.00, SYSDATE, 1);  -- Pago realizado por Pedro
INSERT INTO pago (id_pago, id_estudiante, monto, fecha_pago, estado)
VALUES (2, 2, 120.00, SYSDATE, 1);  -- Pago realizado por Laura
INSERT INTO pago (id_pago, id_estudiante, monto, fecha_pago, estado)
VALUES (3, 3, 130.00, SYSDATE, 1);  -- Pago realizado por José
Insert Into Pago (Id_Pago, Id_Estudiante, Monto, Fecha_Pago, Estado)
VALUES (4, 4, 150.00, SYSDATE, 1);  -- Pago realizado por FERNANDO
INSERT INTO pago (id_pago, id_estudiante, monto, fecha_pago, estado)
VALUES (5, 5, 120.00, SYSDATE, 1);  -- Pago realizado por LOPES
Insert Into Pago (Id_Pago, Id_Estudiante, Monto, Fecha_Pago, Estado)
VALUES (6, 6, 130.00, SYSDATE, 1);  -- Pago realizado por BETTY

-- Insertar datos en la tabla horario (Asignación de horarios para los cursos)
INSERT INTO horario (id_horario, id_curso, id_profesor, hora_inicio, hora_fin, dia_semana)
VALUES (1, 1, 1, TO_DATE('2024-12-08 08:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-12-08 10:00', 'YYYY-MM-DD HH24:MI'), 'Lunes');
INSERT INTO horario (id_horario, id_curso, id_profesor, hora_inicio, hora_fin, dia_semana)
VALUES (2, 2, 2, TO_DATE('2024-12-08 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-12-08 12:00', 'YYYY-MM-DD HH24:MI'), 'Martes');
INSERT INTO horario (id_horario, id_curso, id_profesor, hora_inicio, hora_fin, dia_semana)
VALUES (3, 3, 3, TO_DATE('2024-12-08 14:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2024-12-08 16:00', 'YYYY-MM-DD HH24:MI'), 'Miercoles');

SELECT * FROM horario
-- Insertar datos en la tabla matricula (los estudiantes se matriculan después del pago)
INSERT INTO matricula (id_matricula, id_curso, id_pago, fecha_inscripcion, estado)
VALUES (1, 1, 1, SYSDATE, 1);  -- Pedro se matricula en el curso de Programación Básica
INSERT INTO matricula (id_matricula, id_curso, id_pago, fecha_inscripcion, estado)
VALUES (2, 2, 2, SYSDATE, 1);  -- Laura se matricula en el curso de Programación Intermedia
INSERT INTO matricula (id_matricula, id_curso, id_pago, fecha_inscripcion, estado)
Values (3, 3, 3, Sysdate, 1);  -- José se matricula en el curso de Programación Avanzada
Insert Into Matricula (Id_Matricula, Id_Curso, Id_Pago, Fecha_Inscripcion, Estado)
VALUES (4, 4, 1, SYSDATE, 1);  -- 
INSERT INTO matricula (id_matricula, id_curso, id_pago, fecha_inscripcion, estado)
Values (5, 4, 2, Sysdate, 1);  -- 
Insert Into Matricula (Id_Matricula, Id_Curso, Id_Pago, Fecha_Inscripcion, Estado)
VALUES (5, 4, 3, SYSDATE, 1);  -- 


SELECT * FROM matricula
-- Si ya está implementado el mecanismo para generar el informe del curso (informeCurso)
-- Esto se generaría automáticamente basado en el curso y los estudiantes matriculados.
-- Por ejemplo, vamos a insertar un informe manual para los cursos:

-- 1. Ver todos los módulos
SELECT * FROM modulo;

-- 2. Ver todos los cursos
SELECT * FROM curso;

-- 3. Ver todos los profesores
SELECT * FROM profesor;

-- 4. Ver todos los horarios
SELECT * FROM horario;

-- 5. Ver todos los estudiantes
SELECT * FROM estudiante;

-- 6. Ver todos los pagos
SELECT * FROM pago;

-- 7. Ver todas las matrículas
SELECT * FROM matricula;

-- 8. Ver todos los informes de cursos
SELECT * FROM informe_curso;

-- 9. Ver todas las opciones de satisfacción
SELECT * FROM opciones_satisfaccion;

-- 10. Ver todas las métricas de desempeño
SELECT * FROM metricas_desempeno;

-- 11. Ver la vista de cursos matriculados
SELECT * FROM v_cursos_matriculados;

/* POR EVALUAR*/
-- Tabla Nota

