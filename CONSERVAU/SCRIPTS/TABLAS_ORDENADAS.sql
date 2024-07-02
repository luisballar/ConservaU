USE IF5100_2024_CONSERVAU
GO

-- CREAR TABLA ACTIVIDADES_DESAFIO
CREATE TABLE PROYECTO.TB_ACTIVIDADES_DESAFIO(
   ACTIVIDAD_ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
   ACTIVIDAD VARCHAR(100) NOT NULL,
   DESCRIPCION VARCHAR(255),
   DESAFIO_ID INT NULL,
   FOREIGN KEY(DESAFIO_ID) REFERENCES PROYECTO.TB_DESAFIO(DESAFIO_ID)
);

-- CREAR TABLA ACTIVO
CREATE TABLE PROYECTO.TB_ACTIVO(
   ACTIVO_ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
   NOMBRE VARCHAR(50),
   MARCA VARCHAR(30),
   MODELO VARCHAR(30),
   SERIE VARCHAR(30),
   DESHECHADO BIT DEFAULT 0 NOT NULL,
   FECHA_DESHECHO DATE,
   RESPONSABLE_ID INT,
   FOREIGN KEY(RESPONSABLE_ID) REFERENCES PROYECTO.TB_FUNCIONARIO(FUNCIONARIO_ID)
);

-- CREAR TABLA BITACORA
CREATE TABLE PROYECTO.TB_BITACORA(
   BITACORA_ID INT PRIMARY KEY IDENTITY(1,1),
   FECHA DATE NOT NULL,
   ACTIVIDAD VARCHAR(100) NOT NULL,
   ALIAS VARCHAR(5),
   DESCRIPCION VARCHAR(255),
   HORA_INICIO TIME NOT NULL,
   HORA_FINAL TIME,
   FUNCIONARIO_ID INT,
   FOREIGN KEY(FUNCIONARIO_ID) REFERENCES PROYECTO.TB_FUNCIONARIO(FUNCIONARIO_ID)
);

-- CREAR TABLA CARGO
CREATE TABLE PROYECTO.TB_CARGO(
   CARGO_ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
   NOMBRE VARCHAR(50) NULL,
   FUNCION VARCHAR(100) NULL,
   DESCRIPCION VARCHAR(255) NULL,
   SALARIO_BASE DECIMAL(10,2) NOT NULL
);

-- CREAR TABLA CLASIFICACION_VOLUNTARIO
CREATE TABLE PROYECTO.TB_CLASIFICACION_VOLUNTARIO(
   CLASIFICACION_ID INT UNIQUE NOT NULL,
   PRIMARY KEY(CLASIFICACION_ID),
   DESCRIPCION VARCHAR(1) NOT NULL,
	CONSTRAINT CHK_DESC CHECK (DESCRIPCION = 'A' OR DESCRIPCION = 'C' OR DESCRIPCION = 'D') -- DISTINTAS CLASIFICACIONES
);

-- CREAR TABLA DESAFIO
CREATE TABLE PROYECTO.TB_DESAFIO(
   DESAFIO_ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
   DESAFIO VARCHAR(200) NOT NULL,
   OBJETIVO VARCHAR(200) NOT NULL,
   META VARCHAR(200) NOT NULL,
   INDICADOR_CUMPLIMIENTO VARCHAR(200),
   FUNCIONARIO_ID INT,
   FOREIGN KEY(FUNCIONARIO_ID) REFERENCES PROYECTO.TB_FUNCIONARIO(FUNCIONARIO_ID)
);

-- CREAR TABLA FUNCIONARIO
CREATE TABLE PROYECTO.TB_FUNCIONARIO(
   FUNCIONARIO_ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
   DEPARTAMENTO VARCHAR(25) NOT NULL,
   FECHA_CONTRATACION DATE NOT NULL,
   CODIGO_PARQUE INT NOT NULL,
   PERSONA_CEDULA INT NOT NULL,
   FOREIGN KEY(PERSONA_CEDULA) REFERENCES PROYECTO.TB_PERSONA(CEDULA)
);

-------------------- DESNORMALIZACION --------------------

CREATE TABLE PROYECTO.TB_FUNCIONARIO(
   FUNCIONARIO_ID INTEGER PRIMARY KEY IDENTITY(1,1) NOT NULL,
   NOMBRE_PERSONA VARCHAR(50) NOT NULL,
   DEPARTAMENTO VARCHAR(25) NOT NULL,
   FECHA_CONTRATACION DATE NOT NULL, 
   CODIGO_PARQUE INTEGER NOT NULL,
   MAIL VARCHAR(80),
   PERSONA_CEDULA INTEGER NOT NULL,
	FOREIGN KEY(PERSONA_CEDULA) REFERENCES PROYECTO.TB_PERSONA(CEDULA)
);






-- CREAR TABLA FUNCIONARIO_CARGO
CREATE TABLE PROYECTO.TB_FUNCIONARIO_CARGO(
   FUNCIONARIO_ID INT NOT NULL,
   FOREIGN KEY(FUNCIONARIO_ID) REFERENCES PROYECTO.TB_FUNCIONARIO(FUNCIONARIO_ID),
   CARGO_ID INT NOT NULL,
   FOREIGN KEY(CARGO_ID) REFERENCES PROYECTO.TB_CARGO(CARGO_ID),
   FECHA_INICIO DATE NOT NULL,
   FECHA_FIN DATE NULL,
   SALARIO DECIMAL(10,2) NOT NULL,
   PRIMARY KEY (FUNCIONARIO_ID, CARGO_ID)
);

-- CREAR TABLA INVENTARIO
CREATE TABLE PROYECTO.TB_INVENTARIO(
   INVENTARIO_ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
   NOMBRE VARCHAR(60) NOT NULL,
   FECHA_CREACION DATE NOT NULL,
   ULTIMA_ACTUALIZACION DATE
);

-- CREAR TABLA INVENTARIO_ACTIVO
CREATE TABLE PROYECTO.TB_INVENTARIO_ACTIVO(
   INVENTARIO_ID INT NOT NULL,
   FOREIGN KEY(INVENTARIO_ID) REFERENCES PROYECTO.TB_INVENTARIO(INVENTARIO_ID),
   ACTIVO_ID INT NOT NULL,
   FOREIGN KEY(ACTIVO_ID) REFERENCES PROYECTO.TB_ACTIVO(ACTIVO_ID),
   ESTADO CHAR(1) NOT NULL,
   UBICACION VARCHAR(70) NOT NULL,
   OBSERVACIONES VARCHAR(255),
   PRIMARY KEY(INVENTARIO_ID, ACTIVO_ID),
   CONSTRAINT CHK_ESTADO CHECK (ESTADO = 'B' OR ESTADO = 'M' OR ESTADO = 'E')
);

-- CREAR TABLA PERSONA
CREATE TABLE PROYECTO.TB_PERSONA(
   CEDULA INT UNIQUE NOT NULL,
   PRIMARY KEY(CEDULA),
   NOMBRE VARCHAR(50) NOT NULL,
   NACIMIENTO DATE NOT NULL,
   GENERO CHAR(1),
   TELEFONO VARCHAR(10),
   DIRECCION VARCHAR(200),
   MAIL VARCHAR(80),
   CONSTRAINT CHK_GENERO CHECK (GENERO = 'F' OR GENERO = 'M'),
   CONSTRAINT CHK_TELEFONO CHECK (TELEFONO NOT LIKE '%[^0-9-]%')
);

-------------------- DESNORMALIZACION --------------------

-- CREAR TABLA PERSONA
CREATE TABLE PROYECTO.TB_PERSONA(
   CEDULA INT UNIQUE NOT NULL,
   PRIMARY KEY(CEDULA),
   NOMBRE VARCHAR(50) NOT NULL,
   NACIMIENTO DATE NOT NULL,
   GENERO CHAR(1),
   TELEFONOS VARCHAR(100),
   DIRECCION VARCHAR(200),
   MAIL VARCHAR(80),
	CONSTRAINT CHK_GENERO CHECK (GENERO = 'F' OR GENERO = 'M'),
	CONSTRAINT CHK_TELEFONO CHECK (TELEFONO NOT LIKE '%[^0-9-]%')
);





-- CREAR TABLA RECURSO
CREATE TABLE PROYECTO.TB_RECURSO(
   RECURSO_ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
   RECURSO VARCHAR(70),
   DESAFIO_ID INT NULL,
   FOREIGN KEY(DESAFIO_ID) REFERENCES PROYECTO.TB_DESAFIO(DESAFIO_ID)
);

-- CREAR TABLA ROL
CREATE TABLE PROYECTO.TB_ROL(
   ROL_ID INT PRIMARY KEY,
   DESCRIPCION VARCHAR(255) NOT NULL,
   DIAS_TRABAJO INT NOT NULL,
   FUNCIONARIO_ID INT,
   FOREIGN KEY(FUNCIONARIO_ID) REFERENCES PROYECTO.TB_FUNCIONARIO(FUNCIONARIO_ID)
);


-- CREAR TABLA TIPO_VOLUNTARIO
CREATE TABLE PROYECTO.TB_TIPO_VOLUNTARIO(
   TIPO_VOLUNTARIO_ID INT UNIQUE NOT NULL,
   PRIMARY KEY(TIPO_VOLUNTARIO_ID),
   DESCRIPCION VARCHAR(1) NULL,
   CONSTRAINT CHK_DESC_TYPE CHECK (DESCRIPCION = 'E' OR DESCRIPCION = 'P' OR DESCRIPCION = 'O') -- ESTUDIANTE, PROFESOR U OTRO
);


-- CREAR TABLA VOLUNTARIO
CREATE TABLE PROYECTO.TB_VOLUNTARIO(
   VOLUNTARIO_ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
   FECHA_INICIO DATE NOT NULL,
   FECHA_FINAL DATE NOT NULL,
   PERSONA_CEDULA INT NOT NULL,
   FOREIGN KEY(PERSONA_CEDULA) REFERENCES PROYECTO.TB_PERSONA(CEDULA),
   TIPO_ID INT NOT NULL,
   FOREIGN KEY(TIPO_ID) REFERENCES PROYECTO.TB_TIPO_VOLUNTARIO(TIPO_VOLUNTARIO_ID),
   CLASIFICACION_ID INT NOT NULL,
   FOREIGN KEY(CLASIFICACION_ID) REFERENCES PROYECTO.TB_CLASIFICACION_VOLUNTARIO(CLASIFICACION_ID)
);

-------------------- DESNORMALIZACION --------------------

-- CREATE TABLE PROYECTO.TB_VOLUNTARIO(
   VOLUNTARIO_ID INTEGER PRIMARY KEY IDENTITY(1,1) NOT NULL,
   NOMBRE VARCHAR(50) NOT NULL,
   FECHA_INICIO DATE NOT NULL,
   FECHA_FINAL DATE NOT NULL,
   PERSONA_CEDULA INTEGER NOT NULL, 
   FOREIGN KEY(PERSONA_CEDULA) REFERENCES PROYECTO.TB_PERSONA(PERSONA_CEDULA),
   TIPO_ID INTEGER NOT NULL,
   FOREIGN KEY(TIPO_ID) REFERENCES PROYECTO.TB_TIPO_VOLUNTARIO(TIPO_VOLUNTARIO_ID),
   CLASIFICACION_ID INTEGER NOT NULL,
   FOREIGN KEY(CLASIFICACION_ID) REFERENCES PROYECTO.TB_CLASIFICACION_VOLUNTARIO(CLASIFICACION_ID),
);





----------------------- INDEX -------------------------

-- INDICE NONCLUSTERED SOBRE LA TABLA PERSONA CON LA CLAVE NOMBRE
CREATE NONCLUSTERED INDEX IX_TB_PERSONA_NOMBRE
ON PROYECTO.TB_PERSONA(NOMBRE);


