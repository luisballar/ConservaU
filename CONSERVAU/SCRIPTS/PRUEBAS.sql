USE [IF5100_2024_CONSERVAU]
GO

------------------------------------------------------------------------------------------------

SELECT
*
FROM PROYECTO.TB_INVENTARIO_ACTIVO


DECLARE @RC int
DECLARE @PARAM_ESTADO_FILTRAR char(1)
DECLARE @PARAM_NUEVO_ESTADO char(1)

SET @PARAM_ESTADO_FILTRAR = 'E'
SET @PARAM_NUEVO_ESTADO = 'B'



EXECUTE @RC = [NO_BASICOS].[SP_ACTUALIZAR_ESTADO_ACTIVOS] 
   @PARAM_ESTADO_FILTRAR
  ,@PARAM_NUEVO_ESTADO
GO


SELECT
*
FROM PROYECTO.TB_INVENTARIO_ACTIVO

------------------------------------------------------------------------------------------------


DECLARE @RC int
DECLARE @PARAM_DIAS_TRABAJADOS int

SET @PARAM_DIAS_TRABAJADOS = 5

EXECUTE @RC = [NO_BASICOS].[SP_CALCULAR_DIAS_LIBRES] 
   @PARAM_DIAS_TRABAJADOS
GO


------------------------------------------------------------------------------------------------

SELECT
*
FROM PROYECTO.TB_DESAFIO


DECLARE @RC int
DECLARE @PARAM_DESAFIO_ID int

SET @PARAM_DESAFIO_ID = 2

EXECUTE @RC = [NO_BASICOS].[SP_VER_ACTIVIDADES_DESAFIO] 
   @PARAM_DESAFIO_ID
GO

------------------------------------------------------------------------------------------------

SELECT
*
FROM PROYECTO.TB_FUNCIONARIO_CARGO

DECLARE @RC int

EXECUTE @RC = [NO_BASICOS].[UPDATE_SALARIO_EXPERIENCIA] 
GO

SELECT
*
FROM PROYECTO.TB_FUNCIONARIO_CARGO


------------------------------------------------------------------------------------------------

SELECT
*
FROM PROYECTO.TB_ACTIVO

DECLARE @RC int
DECLARE @PARAM_ACTIVO_ID int

SET @PARAM_ACTIVO_ID = 136

EXECUTE @RC = [PROYECTO].[SP_DELETE_ACTIVO] 
   @PARAM_ACTIVO_ID
GO

SELECT
*
FROM PROYECTO.TB_ACTIVO

------------------------------------------------------------------------------------------------
SELECT
*
FROM PROYECTO.TB_BITACORA

DECLARE @RC int
DECLARE @PARAM_BITACORA_ID int

SET @PARAM_BITACORA_ID = 8

EXECUTE @RC = [PROYECTO].[SP_DELETE_BITACORA] 
   @PARAM_BITACORA_ID
GO

SELECT
*
FROM PROYECTO.TB_BITACORA


------------------------------------------------------------------------------------------------

SELECT
*
FROM PROYECTO.TB_CLASIFICACION_VOLUNTARIO

DECLARE @RC int
DECLARE @PARAM_CLASIFICACION_ID int

SET @PARAM_CLASIFICACION_ID = 2

EXECUTE @RC = [PROYECTO].[SP_DELETE_CLASIFICACION_VOLUNTARIO] 
   @PARAM_CLASIFICACION_ID
GO

SELECT
*
FROM PROYECTO.TB_CLASIFICACION_VOLUNTARIO

------------------------------------------------------------------------------------------------

SELECT
*
FROM PROYECTO.TB_TIPO_VOLUNTARIO

DECLARE @RC int
DECLARE @PARAM_TIPO_VOLUNTARIOID int

SET @PARAM_TIPO_VOLUNTARIOID = 1

EXECUTE @RC = [PROYECTO].[SP_DELETE_TIPO_VOLUNTARIO] 
   @PARAM_TIPO_VOLUNTARIOID
GO

SELECT
*
FROM PROYECTO.TB_TIPO_VOLUNTARIO

------------------------------------------------------------------------------------------------


SELECT
*
FROM PROYECTO.TB_ACTIVO


DECLARE @RC int
DECLARE @PARAM_ACTIVO_ID int 
DECLARE @PARAM_NOMBRE varchar(50) = 'Nombre del Activo'
DECLARE @PARAM_MARCA varchar(30) = 'Marca'
DECLARE @PARAM_MODELO varchar(30) = 'Modelo'
DECLARE @PARAM_SERIE varchar(30) = 'Serie123'
DECLARE @PARAM_DESHECHADO bit = 0
DECLARE @PARAM_FECHA_DESHECHO date = NULL
DECLARE @PARAM_REPONSABLE_ID int = NULL

EXECUTE @RC = [PROYECTO].[SP_INSERT_ACTIVO] 
   @PARAM_ACTIVO_ID
  ,@PARAM_NOMBRE
  ,@PARAM_MARCA
  ,@PARAM_MODELO
  ,@PARAM_SERIE
  ,@PARAM_DESHECHADO
  ,@PARAM_FECHA_DESHECHO
  ,@PARAM_REPONSABLE_ID
GO



SELECT
*
FROM PROYECTO.TB_ACTIVO


------------------------------------------------------------------------------------------------

SELECT
*
FROM PROYECTO.TB_BITACORA

DECLARE @RC int;
DECLARE @PARAM_FECHA date = GETDATE()
DECLARE @PARAM_ACTIVIDAD varchar(100) = 'Actividad realizada'; -- Ejemplo de actividad
DECLARE @PARAM_ALIAS varchar(5) = 'Alias'; -- Ejemplo de alias
DECLARE @PARAM_DESCRIPCION varchar(250) = 'Descripción detallada de la actividad'; -- Ejemplo de descripción
DECLARE @PARAM_HORA_INICIO time(7) = CONVERT(time, GETDATE())
DECLARE @PARAM_HORA_FINAL time(7) = CONVERT(time, GETDATE())
DECLARE @PARAM_FUNCIONARIO_ID int = NULL; -- Ejemplo de ID de funcionario

EXECUTE @RC = [PROYECTO].[SP_INSERT_BITACORA] 
   @PARAM_FECHA,
   @PARAM_ACTIVIDAD,
   @PARAM_ALIAS,
   @PARAM_DESCRIPCION,
   @PARAM_HORA_INICIO,
   @PARAM_HORA_FINAL,
   @PARAM_FUNCIONARIO_ID;

SELECT
*
FROM PROYECTO.TB_BITACORA


------------------------------------------------------------------------------------------------

SELECT
*
FROM PROYECTO.TB_CLASIFICACION_VOLUNTARIO

DECLARE @RC int;
DECLARE @PARAM_CLASIFICACION_ID int = 3; 
DECLARE @PARAM_DESCRIPCION varchar(1) = 'D'; 

EXECUTE @RC = [PROYECTO].[SP_INSERT_CLASIFICACION_VOLUNTARIO] 
   @PARAM_CLASIFICACION_ID,
   @PARAM_DESCRIPCION;

SELECT
*
FROM PROYECTO.TB_CLASIFICACION_VOLUNTARIO


------------------------------------------------------------------------------------------------
SELECT
*
FROM PROYECTO.TB_TIPO_VOLUNTARIO


DECLARE @RC int;
DECLARE @PARAM_TIPO_VOLUNTARIOID int = 3; 
DECLARE @PARAM_DESCRIPCION varchar(1) = 'O'; 

EXECUTE @RC = [PROYECTO].[SP_INSERT_TIPO_VOLUNTARIO] 
   @PARAM_TIPO_VOLUNTARIOID,
   @PARAM_DESCRIPCION;


SELECT
*
FROM PROYECTO.TB_TIPO_VOLUNTARIO


------------------------------------------------------------------------------------------------

EXEC [PROYECTO].[SP_SELECT_ACTIVO]
EXEC [PROYECTO].[SP_SELECT_BITACORA]
EXEC [PROYECTO].[SP_SELECT_CLASIFICACION_VOLUNTARIO]
EXEC [PROYECTO].[SP_SELECT_TIPO_VOLUNTARIO]

------------------------------------------------------------------------------------------------


SELECT
*
FROM PROYECTO.TB_ACTIVO

DECLARE @RC int;
DECLARE @PARAM_ACTIVO_ID int = 116; 
DECLARE @PARAM_NOMBRE varchar(50) = 'Laptop HP Micaere'; 
DECLARE @PARAM_MARCA varchar(30) = NULL; 
DECLARE @PARAM_MODELO varchar(30) = NULL;
DECLARE @PARAM_SERIE varchar(30) = NULL; 
DECLARE @PARAM_DESHECHADO varchar(30) = NULL; 
DECLARE @PARAM_FECHA_DESHECHO date = NULL; 
DECLARE @PARAM_RESPONSABLE_ID int = NULL; 

EXECUTE @RC = [PROYECTO].[SP_UPDATE_ACTIVO] 
   @PARAM_ACTIVO_ID,
   @PARAM_NOMBRE,
   @PARAM_MARCA,
   @PARAM_MODELO,
   @PARAM_SERIE,
   @PARAM_DESHECHADO,
   @PARAM_FECHA_DESHECHO,
   @PARAM_RESPONSABLE_ID;

SELECT
*
FROM PROYECTO.TB_ACTIVO

------------------------------------------------------------------------------------------------
SELECT
*
FROM PROYECTO.TB_BITACORA


DECLARE @RC int;
DECLARE @PARAM_BITACORA_ID int = 11; 
DECLARE @PARAM_ACTIVIDAD varchar(255) = NULL; 
DECLARE @PARAM_FECHA date = NULL; 
DECLARE @PARAM_ALIAS varchar(255) = NULL; 
DECLARE @PARAM_DESCRIPCION varchar(255) = 'Estoy cansado jefe'; 
DECLARE @PARAM_HORA_INICIO time(7) = NULL;
DECLARE @PARAM_HORA_FINAL time(7) = NULL; 
DECLARE @PARAM_FUNCIONARIO_ID int = NULL; 

EXECUTE @RC = [PROYECTO].[SP_UPDATE_BITACORA] 
   @PARAM_BITACORA_ID,
   @PARAM_FECHA,
   @PARAM_ACTIVIDAD,
   @PARAM_ALIAS,
   @PARAM_DESCRIPCION,
   @PARAM_HORA_INICIO,
   @PARAM_HORA_FINAL,
   @PARAM_FUNCIONARIO_ID;

SELECT
*
FROM PROYECTO.TB_BITACORA

------------------------------------------------------------------------------------------------


SELECT
*
FROM PROYECTO.TB_CLASIFICACION_VOLUNTARIO


DECLARE @RC int;
DECLARE @PARAM_CLASIFICACION_ID int = 2; -- ID de la clasificación voluntario que deseas actualizar
DECLARE @PARAM_DESCRIPCION varchar(1) = 'C'; -- Nueva descripción para la clasificación

EXECUTE @RC = [PROYECTO].[SP_UPDATE_CLASIFICACION_VOLUNTARIO] 
   @PARAM_CLASIFICACION_ID,
   @PARAM_DESCRIPCION;


SELECT
*
FROM PROYECTO.TB_CLASIFICACION_VOLUNTARIO


------------------------------------------------------------------------------------------------

SELECT
*
FROM PROYECTO.TB_TIPO_VOLUNTARIO

DECLARE @RC int;
DECLARE @PARAM_TIPO_VOLUNTARIOID int = 1; -- ID del tipo de voluntario que deseas actualizar
DECLARE @PARAM_DESCRIPCION varchar(1) = 'P'; -- Nueva descripción para el tipo de voluntario

EXECUTE @RC = [PROYECTO].[SP_UPDATE_TIPO_VOLUNTARIO] 
   @PARAM_TIPO_VOLUNTARIOID,
   @PARAM_DESCRIPCION;


SELECT
*
FROM PROYECTO.TB_TIPO_VOLUNTARIO



------------------------------------------------------------------------------------------------


   
SELECT
*
FROM PROYECTO.TB_VOLUNTARIO


DECLARE @RC int;
DECLARE @PARAM_FECHA_INICIO date = '2024-01-01'; -- Fecha de inicio del reporte (ejemplo)
DECLARE @PARAM_FECHA_FINAL date = '2024-07-02'; -- Fecha final del reporte (ejemplo)
DECLARE @PARAM_SALIDA int; -- Parámetro de salida

EXECUTE @RC = [REPORTE].[SP_GENERAR_REPORTE_VOLUNTARIOS] 
   @PARAM_FECHA_INICIO,
   @PARAM_FECHA_FINAL,
   @PARAM_SALIDA OUTPUT;
