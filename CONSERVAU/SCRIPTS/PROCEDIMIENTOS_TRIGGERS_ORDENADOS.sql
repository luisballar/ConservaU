
-------------------------------- PROCEDIMIENTOS NO BASICOS --------------------------------



-- ACTUALIZA EL ESTADO DE TODOS LOS ACTIVOS
CREATE OR ALTER     PROCEDURE [NO_BASICOS].[SP_ACTUALIZAR_ESTADO_ACTIVOS]
    @PARAM_ESTADO_FILTRAR CHAR(1),
    @PARAM_NUEVO_ESTADO CHAR(1)
AS
BEGIN

DECLARE 
@VAR_INVENTARIO_ID INT,
@VAR_ACTIVO_ID INT

	BEGIN TRY
		BEGIN TRAN

		-- DECLARACIÓN DE LA VARIABLE TIPO TABLA
		DECLARE @ITEMS_ACTUALIZAR TABLE (
			INVENTARIO_ID INT,
			ACTIVO_ID INT
		);

		-- Insertar datos en la variable tipo tabla
		INSERT INTO @ITEMS_ACTUALIZAR 
		(INVENTARIO_ID, ACTIVO_ID)
		SELECT 
			INVENTARIO_ID, 
			ACTIVO_ID
		FROM PROYECTO.TB_INVENTARIO_ACTIVO
		WHERE ESTADO = @PARAM_ESTADO_FILTRAR;

		-- VARIABLES PARA CONTROLAR EL CICLO
		DECLARE 
		@VAR_CONTADOR INT = 1,
		@VAR_TOTAL_ITEMS INT;

		-- OBTENER EL NÚMERO TOTAL DE REGISTROS A ACTUALIZAR
		SELECT 
			@VAR_TOTAL_ITEMS = COUNT(*)
		FROM @ITEMS_ACTUALIZAR;

		-- CICLO WHILE PARA ITERAR SOBRE LA VARIABLE TIPO TABLA
		WHILE @VAR_CONTADOR <= @VAR_TOTAL_ITEMS
			BEGIN
			

				-- Obtener los IDs de los elementos a actualizar
				SELECT 
					@VAR_INVENTARIO_ID = INVENTARIO_ID,
					@VAR_ACTIVO_ID = ACTIVO_ID
				FROM 
					(SELECT 
					ROW_NUMBER() OVER (ORDER BY INVENTARIO_ID) AS ROW_NUM, INVENTARIO_ID, ACTIVO_ID
					FROM @ITEMS_ACTUALIZAR) AS T
				WHERE ROW_NUM = @VAR_CONTADOR;

				-- ACTUALIZAR EL ESTADO DEL ACTIVO EN INVENTARIO_ACTIVO
				UPDATE PROYECTO.TB_INVENTARIO_ACTIVO
				SET ESTADO = @PARAM_NUEVO_ESTADO
				WHERE INVENTARIO_ID = @VAR_INVENTARIO_ID AND ACTIVO_ID = @VAR_ACTIVO_ID;

				-- ACTUALIZAR LA FECHA DE ÚLTIMA ACTUALIZACIÓN EN INVENTARIO
				UPDATE PROYECTO.TB_INVENTARIO
				SET ULTIMA_ACTUALIZACION = GETDATE()
				WHERE INVENTARIO_ID = @VAR_INVENTARIO_ID;

				-- Incrementar el contador
				SET @VAR_CONTADOR = @VAR_CONTADOR + 1;
			END

		COMMIT
	END TRY

	BEGIN CATCH
		SELECT 
			ERROR_PROCEDURE() AS [PROCEDURE],
			ERROR_MESSAGE() AS ERROR
	END CATCH
END

GO






-- =============================================
-- Author:		Luis Ballar
-- Create date: 26/06/2024
-- Description:	Calcular dias libres segun dias trabajados
-- =============================================
CREATE OR ALTER   PROCEDURE [NO_BASICOS].[SP_CALCULAR_DIAS_LIBRES]
@PARAM_DIAS_TRABAJADOS INT
AS
BEGIN

	BEGIN TRY
		BEGIN TRAN

			-- CALCULA LOS DIAS LIBRES SEGUN DIAS TRABAJADOS, LOS DIAS MAXIMOS LIBRES SON 8
			SELECT
				PER.CEDULA,
				PER.NOMBRE,
				FUNC.FUNCIONARIO_ID,
				FUNCAR.CARGO_ID,
				ROL.ROL_ID AS ROL,
				ROL.DIAS_TRABAJO,
				CASE 
					WHEN ROL.DIAS_TRABAJO % 2 = 0 THEN 
						CASE 
							WHEN ROL.DIAS_TRABAJO > 16 THEN 8 -- ESTRICTAMENTE 8 DIAS LIBRES
							ELSE ROL.DIAS_TRABAJO / 2 
						END
					ELSE  
						CASE 
							WHEN ROL.DIAS_TRABAJO - 1 > 16 THEN 8 -- ESTRICTAMENTE 8 DIAS LIBRES
							ELSE (ROL.DIAS_TRABAJO - 1) / 2
						END
				END AS DIAS_LIBRE
				INTO #TEMP_1
			FROM PROYECTO.TB_ROL ROL
				JOIN PROYECTO.TB_FUNCIONARIO FUNC
				ON ROL.FUNCIONARIO_ID = FUNC.FUNCIONARIO_ID
					JOIN PROYECTO.TB_PERSONA PER
					ON FUNC.PERSONA_CEDULA = PER.CEDULA
						LEFT JOIN PROYECTO.TB_FUNCIONARIO_CARGO FUNCAR
						ON FUNCAR.FUNCIONARIO_ID = FUNC.FUNCIONARIO_ID
			WHERE ROL.DIAS_TRABAJO = @PARAM_DIAS_TRABAJADOS

			-- MUESTRA LOS FUNCIONARIOS CON SUS DIAS LIBRES
			SELECT
			*
			FROM #TEMP_1

			DROP TABLE #TEMP_1

		COMMIT TRAN	
	END TRY

	BEGIN CATCH
		SELECT 
			ERROR_PROCEDURE() AS [PROCEDURE],
			ERROR_MESSAGE() AS ERROR
	END CATCH
END
GO






-- =============================================
-- Author:		Luis Ballar
-- Create date: 20/06/2024
-- Description:	Verificar si los email tiene el @
-- =============================================
CREATE OR ALTER     PROCEDURE [NO_BASICOS].[SP_VALIDATE_MAIL]
	@PARAM_CORREO VARCHAR(80),
	@PARAM_RESULTADO INT OUTPUT
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN

			-- SI EN EN TEXTO EXISTE @ ENTRA EL IF, SINO DESPLIEGA ERROR
			IF CHARINDEX('@', @PARAM_CORREO) > 0
				BEGIN
					SET @PARAM_RESULTADO = 1
				END
			ELSE 
				BEGIN
					THROW 51000, 'El correo debe contener "@"',1
				END
		COMMIT
	END TRY


	BEGIN CATCH
	 DECLARE @errMsg NVARCHAR(MAX);
	 SET @errMsg = ERROR_MESSAGE();
	 THROW 51000, @errMsg, 1;	
	END CATCH
END
GO







-- =============================================
-- Author:		Lus Ballar y Jahaziel 
-- Create date: 30/06/2024
-- Description:	Ver actividades asociadas a un desafío
-- =============================================
CREATE OR ALTER   PROCEDURE [NO_BASICOS].[SP_VER_ACTIVIDADES_DESAFIO]
	@PARAM_DESAFIO_ID INT
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
			
			IF EXISTS(SELECT TOP 1 1 FROM PROYECTO.TB_DESAFIO WHERE DESAFIO_ID = @PARAM_DESAFIO_ID)
				BEGIN
					SELECT
						DEF.DESAFIO_ID,
						DEF.DESAFIO,
						DEF.OBJETIVO,
						DEF.META,
						ACT.ACTIVIDAD_ID,
						ACT.ACTIVIDAD
					FROM PROYECTO.TB_DESAFIO DEF
						JOIN PROYECTO.TB_ACTIVIDADES_DESAFIO ACT
						ON DEF.DESAFIO_ID = ACT.DESAFIO_ID
					WHERE DEF.DESAFIO_ID = @PARAM_DESAFIO_ID
				END
			ELSE
			BEGIN
				SELECT 'No existe ese registro en la base de datos'
			END

		COMMIT
	END TRY

	BEGIN CATCH
		SELECT 
			ERROR_PROCEDURE() AS [PROCEDURE],
			ERROR_MESSAGE() AS ERROR
	END CATCH
	
END
GO









-------------------------------- PROCEDIMIENTOS BASICOS --------------------------------




-- =============================================
-- Author:		LUIS BALLAR
-- Create date: 16/06/2024
-- Description:	SP LOGIC DELETE DE TB_ACTIVO 
-- =============================================
CREATE OR ALTER PROCEDURE [PROYECTO].[SP_DELETE_ACTIVO]
	@PARAM_ACTIVO_ID INT
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
		IF EXISTS(SELECT TOP 1 1 FROM PROYECTO.TB_INVENTARIO_ACTIVO WHERE ACTIVO_ID = @PARAM_ACTIVO_ID) 
			BEGIN																			
				DELETE FROM PROYECTO.TB_INVENTARIO_ACTIVO
				WHERE ACTIVO_ID = @PARAM_ACTIVO_ID

				UPDATE PROYECTO.TB_ACTIVO
					SET 
						DESHECHADO = 1, 
						FECHA_DESHECHO = GETDATE()
				WHERE ACTIVO_ID = @PARAM_ACTIVO_ID

			END

		ELSE IF EXISTS(SELECT TOP 1 1 FROM PROYECTO.TB_ACTIVO WHERE ACTIVO_ID = @PARAM_ACTIVO_ID)
			BEGIN

				UPDATE PROYECTO.TB_ACTIVO
					SET 
						DESHECHADO = 1, 
						FECHA_DESHECHO = GETDATE()
				WHERE ACTIVO_ID = @PARAM_ACTIVO_ID

			END

		ELSE 
			SELECT 'Este registro no existe en la base de datos'

		COMMIT
	END TRY

	BEGIN CATCH
		SELECT 
			ERROR_PROCEDURE() AS [PROCEDURE],
			ERROR_MESSAGE() AS ERROR
	END CATCH

END
GO




---DELETE BITACORA
CREATE OR ALTER PROCEDURE [PROYECTO].[SP_DELETE_BITACORA]   
    @PARAM_BITACORA_ID INT
AS
BEGIN

    BEGIN TRY
        IF EXISTS (
                SELECT TOP 1 1
                FROM PROYECTO.TB_BITACORA
                WHERE BITACORA_ID = @PARAM_BITACORA_ID
            )
			BEGIN
				DELETE FROM PROYECTO.TB_BITACORA
				WHERE BITACORA_ID = @PARAM_BITACORA_ID;
			END
        ELSE
			BEGIN
				SELECT 'La bitacora no existe en la base de datos';
			END
    END TRY

    BEGIN CATCH
        SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
   END CATCH

END;
GO






---DELETE CLASIFICACION_VOLUNTARIO

CREATE OR ALTER PROCEDURE [PROYECTO].[SP_DELETE_CLASIFICACION_VOLUNTARIO]  
    @PARAM_CLASIFICACION_ID INTEGER
AS
BEGIN
    BEGIN TRY
        IF EXISTS (
                SELECT TOP 1 1
                FROM PROYECTO.TB_CLASIFICACION_VOLUNTARIO
                WHERE CLASIFICACION_ID = @PARAM_CLASIFICACION_ID
            )
			BEGIN
				DELETE FROM PROYECTO.TB_CLASIFICACION_VOLUNTARIO
				WHERE CLASIFICACION_ID = @PARAM_CLASIFICACION_ID;
			END
        ELSE
			BEGIN
				SELECT 'La clasificacion del voluntario no existe en la base de datos para eliminar';
			END
    END TRY
    BEGIN CATCH
        SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
    END CATCH
END;
GO



---DELETE TIPO_VOLUNTARIO

CREATE   PROCEDURE [PROYECTO].[SP_DELETE_TIPO_VOLUNTARIO]  
    @PARAM_TIPO_VOLUNTARIOID INTEGER
AS
BEGIN
    BEGIN TRY
		BEGIN TRAN
			IF EXISTS (
				SELECT TOP 1 1
				FROM PROYECTO.TB_TIPO_VOLUNTARIO
				WHERE TIPO_VOLUNTARIO_ID = @PARAM_TIPO_VOLUNTARIOID
				)
			BEGIN
            DELETE FROM PROYECTO.TB_TIPO_VOLUNTARIO
            WHERE TIPO_VOLUNTARIO_ID = @PARAM_TIPO_VOLUNTARIOID;
        END
        ELSE
			BEGIN
				SELECT 'El tipo de voluntario no existe en la base de datos para eliminar';
		END
		COMMIT
    END TRY
    BEGIN CATCH
        SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
    END CATCH
END;
GO




-- =============================================
-- Author:		LUIS BALLAR
-- Create date: 15/06/2024
-- Description:	SP INSERT DE TB_ACTIVO
-- =============================================
-- =============================================
CREATE   PROCEDURE [PROYECTO].[SP_INSERT_ACTIVO] 
	@PARAM_ACTIVO_ID INT,
	@PARAM_NOMBRE VARCHAR(50),
	@PARAM_MARCA VARCHAR(30),
	@PARAM_MODELO VARCHAR(30),
	@PARAM_SERIE VARCHAR(30),
	@PARAM_DESHECHADO BIT,
	@PARAM_FECHA_DESHECHO DATE,
	@PARAM_REPONSABLE_ID INT
AS
BEGIN
	BEGIN TRY
		IF NOT EXISTS(SELECT TOP 1 1 FROM PROYECTO.TB_ACTIVO WHERE ACTIVO_ID = @PARAM_ACTIVO_ID AND NOMBRE = @PARAM_NOMBRE AND MARCA = @PARAM_MARCA AND MODELO = @PARAM_MODELO AND SERIE = @PARAM_SERIE AND DESHECHADO = @PARAM_DESHECHADO AND FECHA_DESHECHO = @PARAM_FECHA_DESHECHO AND RESPONSABLE_ID = @PARAM_REPONSABLE_ID)
		BEGIN
			INSERT INTO PROYECTO.TB_ACTIVO
			(
				[NOMBRE], 
				[MARCA], 
				[MODELO], 
				[SERIE], 
				[DESHECHADO], 
				[FECHA_DESHECHO], 
				[RESPONSABLE_ID]
			)
			VALUES
			(
				@PARAM_NOMBRE,
				@PARAM_MARCA,
				@PARAM_MODELO,
				@PARAM_SERIE,
				@PARAM_DESHECHADO,
				@PARAM_FECHA_DESHECHO,
				@PARAM_REPONSABLE_ID
			)
		END


	END TRY

	BEGIN CATCH
		SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
	END CATCH
END
GO






---INSERT BITACORA
CREATE OR ALTER     PROCEDURE [PROYECTO].[SP_INSERT_BITACORA]
    @PARAM_FECHA DATE,
    @PARAM_ACTIVIDAD VARCHAR(100),
    @PARAM_ALIAS VARCHAR(5),
    @PARAM_DESCRIPCION VARCHAR(250),
    @PARAM_HORA_INICIO TIME,
    @PARAM_HORA_FINAL TIME,
    @PARAM_FUNCIONARIO_ID INTEGER
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT TOP 1 1 FROM PROYECTO.TB_BITACORA WHERE FECHA = @PARAM_FECHA AND ACTIVIDAD = @PARAM_ACTIVIDAD AND 
        ALIAS = @PARAM_ALIAS AND FUNCIONARIO_ID = @PARAM_FUNCIONARIO_ID)
			BEGIN
				INSERT INTO PROYECTO.TB_BITACORA
				(
					FECHA,
					ACTIVIDAD,
					ALIAS,
					DESCRIPCION,
					HORA_INICIO,
					HORA_FINAL,
					FUNCIONARIO_ID
				)
				VALUES
				(
					@PARAM_FECHA,
					@PARAM_ACTIVIDAD,
					@PARAM_ALIAS,
					@PARAM_DESCRIPCION,
					@PARAM_HORA_INICIO,
					@PARAM_HORA_FINAL,
					@PARAM_FUNCIONARIO_ID
				);
			END
    END TRY
    BEGIN CATCH
        SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
    END CATCH
END;
GO


---INSERT ClASIFICACION_VOLUNTARIO

CREATE OR ALTER   PROCEDURE [PROYECTO].[SP_INSERT_CLASIFICACION_VOLUNTARIO]
    @PARAM_CLASIFICACION_ID INTEGER,
    @PARAM_DESCRIPCION VARCHAR(1) NULL
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT TOP 1 1 FROM PROYECTO.TB_CLASIFICACION_VOLUNTARIO WHERE CLASIFICACION_ID = @PARAM_CLASIFICACION_ID AND @PARAM_DESCRIPCION = DESCRIPCION)
			BEGIN
				INSERT INTO PROYECTO.TB_CLASIFICACION_VOLUNTARIO
				(
				   CLASIFICACION_ID,
				   DESCRIPCION
				)
				VALUES
				(
				   @PARAM_CLASIFICACION_ID ,
				   @PARAM_DESCRIPCION
				)
			END
    END TRY
    BEGIN CATCH
        SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
    END CATCH
END;
GO











---------INSERT TIPO VOLUNTARIO--------------
CREATE OR ALTER PROCEDURE [PROYECTO].[SP_INSERT_TIPO_VOLUNTARIO]
    @PARAM_TIPO_VOLUNTARIOID INTEGER,
    @PARAM_DESCRIPCION VARCHAR(1)
AS
BEGIN
    BEGIN TRY
		BEGIN TRAN
			IF NOT EXISTS (SELECT TOP 1 1 FROM PROYECTO.TB_TIPO_VOLUNTARIO WHERE TIPO_VOLUNTARIO_ID = @Param_TIPO_VOLUNTARIOID AND DESCRIPCION = @Param_DESCRIPCION)
				BEGIN
					INSERT INTO PROYECTO.TB_TIPO_VOLUNTARIO
					(
						TIPO_VOLUNTARIO_ID,
						DESCRIPCION
					)
					VALUES
					(
						@PARAM_TIPO_VOLUNTARIOID,
						@PARAM_DESCRIPCION
					);
				END
			COMMIT
		END TRY
	BEGIN CATCH
        SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
    END CATCH
END;
GO


-----SELECT ACTIVO
CREATE OR ALTER PROCEDURE [PROYECTO].[SP_SELECT_ACTIVO] 
	
AS
BEGIN
	BEGIN TRY
		SELECT
			[ACTIVO_ID], 
			[NOMBRE], 
			[MARCA], 
			[MODELO], 
			[SERIE], 
			[DESHECHADO], 
			[FECHA_DESHECHO], 
			[RESPONSABLE_ID]
		FROM PROYECTO.TB_ACTIVO
	END TRY

	BEGIN CATCH
		SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR
	END CATCH
END
GO


--------SELECT BITACORA

CREATE OR ALTER   PROCEDURE [PROYECTO].[SP_SELECT_BITACORA]
AS
BEGIN
    BEGIN TRY
        SELECT 
			BITACORA_ID,
            FECHA,
            ACTIVIDAD,
            ALIAS,
            DESCRIPCION,
            HORA_INICIO,
            HORA_FINAL,
            FUNCIONARIO_ID
        FROM PROYECTO.TB_BITACORA;
    END TRY
    BEGIN CATCH
        SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
    END CATCH
END;
GO

----------SELECT CLASIFICACION VOLUNTARIO--------------
CREATE OR ALTER   PROCEDURE [PROYECTO].[SP_SELECT_CLASIFICACION_VOLUNTARIO]
AS
BEGIN
    BEGIN TRY
        SELECT 
			CLASIFICACION_ID,
			DESCRIPCION
        FROM PROYECTO.TB_CLASIFICACION_VOLUNTARIO;
    END TRY
    BEGIN CATCH
        SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
    END CATCH
END;
GO

---SELECT TIPO_VOLUNTARIO
CREATE OR ALTER PROCEDURE [PROYECTO].[SP_SELECT_TIPO_VOLUNTARIO]
AS
BEGIN
    BEGIN TRY
		BEGIN TRAN
			SELECT 
				TIPO_VOLUNTARIO_ID,
				DESCRIPCION
			FROM PROYECTO.TB_TIPO_VOLUNTARIO;
		COMMIT
    END TRY
    BEGIN CATCH
        SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
    END CATCH
END;
GO

----UPDATE ACTIVO
CREATE OR ALTER PROCEDURE [PROYECTO].[SP_UPDATE_ACTIVO]
	@PARAM_ACTIVO_ID INT,
	@PARAM_NOMBRE VARCHAR(50) = NULL,
	@PARAM_MARCA VARCHAR(30) = NULL,
	@PARAM_MODELO VARCHAR(30) = NULL,
	@PARAM_SERIE VARCHAR(30) = NULL,
	@PARAM_DESHECHADO VARCHAR(30) = NULL,
	@PARAM_FECHA_DESHECHO DATE,
	@PARAM_RESPONSABLE_ID INT = NULL
AS
BEGIN
	BEGIN TRY
		IF EXISTS(SELECT TOP 1 1 FROM PROYECTO.TB_ACTIVO WHERE ACTIVO_ID = @PARAM_ACTIVO_ID)
		BEGIN
			UPDATE PROYECTO.TB_ACTIVO
			SET
				NOMBRE = ISNULL(@PARAM_NOMBRE,NOMBRE), 
				MARCA = ISNULL(@PARAM_MARCA, MARCA), 
				MODELO = ISNULL(@PARAM_MODELO, MODELO), 
				SERIE = ISNULL(@PARAM_SERIE, SERIE), 
				DESHECHADO = ISNULL(@PARAM_DESHECHADO, DESHECHADO), 
				FECHA_DESHECHO = ISNULL(@PARAM_FECHA_DESHECHO, FECHA_DESHECHO), 
				RESPONSABLE_ID = ISNULL(@PARAM_RESPONSABLE_ID, RESPONSABLE_ID)
			WHERE ACTIVO_ID = @PARAM_ACTIVO_ID
		END
		ELSE
			SELECT 'Este registro no existe en la base de datos'

	END TRY

	BEGIN CATCH 
		SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
	END CATCH

END
GO


---UPDATE BITACORA
CREATE OR ALTER PROCEDURE [PROYECTO].[SP_UPDATE_BITACORA] 
	@PARAM_BITACORA_ID INT,
    @PARAM_FECHA DATE = NULL,
    @PARAM_ACTIVIDAD VARCHAR(255) = NULL,
    @PARAM_ALIAS VARCHAR(255) = NULL,
    @PARAM_DESCRIPCION VARCHAR(255) = NULL,
    @PARAM_HORA_INICIO TIME = NULL,
    @PARAM_HORA_FINAL TIME = NULL,
    @PARAM_FUNCIONARIO_ID INTEGER
AS
BEGIN
    BEGIN TRY
        IF EXISTS (
                SELECT TOP 1 1
                FROM PROYECTO.TB_BITACORA
                WHERE BITACORA_ID = @PARAM_BITACORA_ID
            )
        BEGIN
            UPDATE PROYECTO.TB_BITACORA
            SET
                FECHA = ISNULL(@PARAM_FECHA, FECHA),
                ACTIVIDAD = ISNULL(@PARAM_ACTIVIDAD, ACTIVIDAD),
                ALIAS = ISNULL(@PARAM_ALIAS, ALIAS),
                DESCRIPCION = ISNULL(@PARAM_DESCRIPCION, DESCRIPCION),
                HORA_INICIO = ISNULL(@PARAM_HORA_INICIO, HORA_INICIO),
                HORA_FINAL = ISNULL(@PARAM_HORA_FINAL, HORA_FINAL)
            WHERE BITACORA_ID = @PARAM_BITACORA_ID;
        END
        ELSE
        BEGIN
            SELECT 'La bitacora no existe en la base de datos' AS ERROR;
        END
    END TRY
    BEGIN CATCH
        SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
    END CATCH
END;
GO

---UPDATE CLASIFICACION_VOLUNTARIO
CREATE OR ALTER PROCEDURE [PROYECTO].[SP_UPDATE_CLASIFICACION_VOLUNTARIO]
    @PARAM_CLASIFICACION_ID INTEGER,
    @PARAM_DESCRIPCION VARCHAR(1)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (
                SELECT TOP 1 1
                FROM PROYECTO.TB_CLASIFICACION_VOLUNTARIO
                WHERE CLASIFICACION_ID = @PARAM_CLASIFICACION_ID
            )
			BEGIN
				UPDATE PROYECTO.TB_CLASIFICACION_VOLUNTARIO
				SET
					CLASIFICACION_ID = ISNULL(@PARAM_CLASIFICACION_ID, CLASIFICACION_ID),
					DESCRIPCION = ISNULL(@PARAM_DESCRIPCION, DESCRIPCION)
				WHERE CLASIFICACION_ID = @PARAM_CLASIFICACION_ID;
			END
        ELSE
			BEGIN
				SELECT 'La clasificacion de voluntario no existe en la base de datos para actualizar'
			END
    END TRY
    BEGIN CATCH
        SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
    END CATCH
END;
GO

---UPDATE TIPO_VOLUNTARIO
CREATE OR ALTER   PROCEDURE [PROYECTO].[SP_UPDATE_TIPO_VOLUNTARIO]
    @PARAM_TIPO_VOLUNTARIOID INTEGER,
    @PARAM_DESCRIPCION VARCHAR(1)
AS
BEGIN
    BEGIN TRY
		BEGIN TRAN
			IF EXISTS (
                SELECT TOP 1 1
                FROM PROYECTO.TB_TIPO_VOLUNTARIO
                WHERE TIPO_VOLUNTARIO_ID = @PARAM_TIPO_VOLUNTARIOID
            )
			BEGIN
				UPDATE PROYECTO.TB_TIPO_VOLUNTARIO
					SET
						TIPO_VOLUNTARIO_ID = ISNULL(@PARAM_TIPO_VOLUNTARIOID, TIPO_VOLUNTARIO_ID),
						DESCRIPCION = ISNULL(@PARAM_DESCRIPCION, DESCRIPCION)
					WHERE TIPO_VOLUNTARIO_ID = @PARAM_TIPO_VOLUNTARIOID;
				END
			ELSE
				BEGIN
					SELECT 'El tipo de voluntario no existe en la base de datos' AS ERROR;
				END
			COMMIT
		END TRY
    BEGIN CATCH
        SELECT ERROR_PROCEDURE() AS [PROCEDURE], ERROR_MESSAGE() AS ERROR;
    END CATCH
END;
GO


------------------ GENERA EL REPORTE DE LOS VOLUNTARIOS DEL AREA DE CONSERVACION ------------------
CREATE OR ALTER PROCEDURE [REPORTE].[SP_GENERAR_REPORTE_VOLUNTARIOS]

@PARAM_FECHA_INICIO DATE,
@PARAM_FECHA_FINAL DATE,
@PARAM_SALIDA INT OUTPUT

AS
BEGIN
    
    CREATE TABLE #REPORTE_VOLUNTARIOS (
        VOLUNTARIO VARCHAR(50),
        TIPO VARCHAR(1),
		CLASIFICACION VARCHAR(1),
        FECHA_INICIO DATE,
        FECHA_FIN DATE
    )

    INSERT INTO #REPORTE_VOLUNTARIOS (
	VOLUNTARIO, 
	TIPO, 
	CLASIFICACION, 
	FECHA_INICIO, 
	FECHA_FIN
	)

    SELECT
		PER.NOMBRE,
		TIPO.DESCRIPCION,
		CLA.DESCRIPCION,
		VOL.FECHA_INICIO,
		VOL.FECHA_FINAL
	FROM PROYECTO.TB_VOLUNTARIO VOL
		JOIN PROYECTO.TB_PERSONA PER
		ON VOL.PERSONA_CEDULA = PER.CEDULA
			JOIN PROYECTO.TB_TIPO_VOLUNTARIO TIPO
			ON VOL.TIPO_ID = TIPO.TIPO_VOLUNTARIO_ID
				JOIN PROYECTO.TB_CLASIFICACION_VOLUNTARIO CLA
				ON VOL.CLASIFICACION_ID = CLA.CLASIFICACION_ID
	WHERE VOL.FECHA_INICIO BETWEEN @PARAM_FECHA_INICIO AND  @PARAM_FECHA_FINAL
	AND VOL.FECHA_FINAL BETWEEN @PARAM_FECHA_INICIO AND  @PARAM_FECHA_FINAL

		
    SELECT @PARAM_SALIDA = COUNT(*) FROM #REPORTE_VOLUNTARIOS
	
    SELECT * FROM #REPORTE_VOLUNTARIOS

    DROP TABLE #REPORTE_VOLUNTARIOS
END
GO



-------------------------------- TRIGGERS --------------------------------



-- Author:		Luis Ballar
-- Create date: 30/06/2024
-- Description:	Borrado logico  
-- =============================================
CREATE OR ALTER       TRIGGER [PROYECTO].[TRG_BORRAR_ACTIVO] 
ON [PROYECTO].[TB_ACTIVO] 
AFTER UPDATE
AS 
BEGIN
DECLARE
@VAR_ACTIVO_ID INT,
@VAR_HORA_ACTUAL DATETIME


	BEGIN TRY
		BEGIN TRAN
	
		IF UPDATE(DESHECHADO)
			BEGIN
				SELECT 
					@VAR_ACTIVO_ID = ACTIVO_ID
				FROM inserted

				IF EXISTS(SELECT TOP 1 1 FROM PROYECTO.TB_INVENTARIO_ACTIVO WHERE ACTIVO_ID = @VAR_ACTIVO_ID)
					BEGIN
						DELETE FROM PROYECTO.TB_INVENTARIO_ACTIVO
						WHERE ACTIVO_ID = @VAR_ACTIVO_ID
					END

					UPDATE PROYECTO.TB_ACTIVO
						SET RESPONSABLE_ID = NULL
					WHERE ACTIVO_ID = @VAR_ACTIVO_ID

					SET @VAR_HORA_ACTUAL = FORMAT(GETDATE(), 'HH:mm:ss')

					-- REGISTRA LA ACTIVIDAD EN BITACORA
					INSERT INTO PROYECTO.TB_BITACORA
					([FECHA], [ACTIVIDAD], [ALIAS], [DESCRIPCION], [HORA_INICIO], [HORA_FINAL], [FUNCIONARIO_ID])
					VALUES
					(GETDATE(), 'Activo ' + CAST(@VAR_ACTIVO_ID AS VARCHAR) + ' deshechado', 'DES', NULL, @VAR_HORA_ACTUAL, @VAR_HORA_ACTUAL, NULL)
	
				END

		COMMIT
	END TRY

	BEGIN CATCH
       SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine
    END CATCH
	

END
GO

ALTER TABLE [PROYECTO].[TB_ACTIVO] ENABLE TRIGGER [TRG_BORRAR_ACTIVO]
GO








-- SI SE BORRA UNA PERSONA VERIFICA ESI ESTÁ EN OTRAS TABLAS QUE TENGAN FK A CEDULA
CREATE OR ALTER   TRIGGER [PROYECTO].[TRG_BORRAR_PERSONA]
ON [PROYECTO].[TB_PERSONA]
INSTEAD OF DELETE

AS
BEGIN
DECLARE @VAR_CEDULA INT,
@VAR_PERSONA VARCHAR(50),
@VAR_FUNCIONARIO_ID INT


	BEGIN TRAN
	BEGIN TRY

		IF EXISTS(SELECT * FROM deleted)
			BEGIN
				SELECT
				@VAR_CEDULA = CEDULA,
				@VAR_PERSONA = NOMBRE
				FROM deleted

			
				--VERIFICA SI ESA PERSONA ES FUNCIONARIO
				IF EXISTS(SELECT TOP 1 1 FROM PROYECTO.TB_FUNCIONARIO WHERE PERSONA_CEDULA = @VAR_CEDULA)
				BEGIN
				

		

						--ENCONTRAR EL FUNCIONARIO_ID DE ESA PERSONA
						SELECT TOP 1 @VAR_FUNCIONARIO_ID = FUNCIONARIO_ID FROM PROYECTO.TB_FUNCIONARIO WHERE PERSONA_CEDULA = @VAR_CEDULA

						EXECUTE PROYECTO.SP_DELETE_FUNCIONARIO @VAR_FUNCIONARIO_ID -- DEBE BORRAR EN TABLAS INTERMEDIAS DE FUNCIONARIO	
				END
				--VERIFICA SI ESA PERSONA ES VOLUNTARIO
			ELSE IF EXISTS(SELECT TOP 1 1 FROM PROYECTO.TB_VOLUNTARIO WHERE PERSONA_CEDULA = @VAR_CEDULA)
				BEGIN
					DELETE FROM PROYECTO.TB_VOLUNTARIO
					WHERE PERSONA_CEDULA = @VAR_CEDULA
				END

			DELETE FROM PROYECTO.TB_PERSONA
			WHERE CEDULA = @VAR_CEDULA

		END
	COMMIT
	END TRY
	 

	BEGIN CATCH
       SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine
    END CATCH

END

GO






-- CUANDO SE INSERTA UN FUNCIONARIO SE DEBE INSERTAR EN FUNCIONARIO_CARGO CON SU CARGO

CREATE OR ALTER   TRIGGER [PROYECTO].[TRG_INSERTAR_FUNCIONARIO]
ON [PROYECTO].[TB_FUNCIONARIO]
AFTER INSERT 

AS
BEGIN
DECLARE 
--TABLA FUNCIONARIO
@VAR_FUNCIONARIO_ID INT,
@VAR_FECHA_CONTRATACION DATE,
 
 --TABLA CARGO
 @VAR_CARGO_ID INT,
 @VAR_SALARIO_BASE DECIMAL(10,2)


	BEGIN TRY
		BEGIN TRAN
		
			--CAPTURAR DATOS DEL FUNCIONARIO INSERTADO
			SELECT
				@VAR_FUNCIONARIO_ID = FUNCIONARIO_ID
			FROM inserted

			-- AGARRAR UN CARGO ALEATORIO
			SELECT TOP 1
				@VAR_CARGO_ID = CARGO_ID,
				@VAR_SALARIO_BASE = SALARIO_BASE
			FROM PROYECTO.TB_CARGO
			ORDER BY NEWID()



			INSERT INTO [PROYECTO].[TB_FUNCIONARIO_CARGO]
			([FUNCIONARIO_ID], [CARGO_ID], [FECHA_CONTRATACION], [FECHA_FIN], [SALARIO])
			VALUES
			(@VAR_FUNCIONARIO_ID, @VAR_CARGO_ID, GETDATE(), NULL, @VAR_SALARIO_BASE)

		COMMIT
	END TRY

	BEGIN CATCH
		   SELECT 
				ERROR_NUMBER() AS ErrorNumber,
				ERROR_MESSAGE() AS ErrorMessage,
				ERROR_SEVERITY() AS ErrorSeverity,
				ERROR_STATE() AS ErrorState,
				ERROR_LINE() AS ErrorLine
			ROLLBACK TRAN
	END CATCH

END
GO





-- Description:	Comprueba si desafio está en otras tablas y lo desliga para borrarlo
-- =============================================
CREATE OR ALTER     TRIGGER [PROYECTO].[TRG_DELETE_DESAFIO]
ON [PROYECTO].[TB_DESAFIO]
INSTEAD OF DELETE
AS
BEGIN
DECLARE 
@VAR_DESAFIO_ID INT
	BEGIN TRY
		BEGIN TRAN

			SELECT
				@VAR_DESAFIO_ID = DESAFIO_ID
			FROM deleted

			IF EXISTS(SELECT TOP 1 1 FROM PROYECTO.TB_ACTIVIDADES_DESAFIO WHERE DESAFIO_ID = @VAR_DESAFIO_ID)
				BEGIN
					UPDATE PROYECTO.TB_ACTIVIDADES_DESAFIO
						SET DESAFIO_ID = NULL
					WHERE DESAFIO_ID = @VAR_DESAFIO_ID
				END

			IF EXISTS(SELECT TOP 1 1 FROM PROYECTO.TB_RECURSO WHERE DESAFIO_ID = @VAR_DESAFIO_ID)
				BEGIN
					UPDATE PROYECTO.TB_RECURSO
						SET DESAFIO_ID = NULL
					WHERE DESAFIO_ID = @VAR_DESAFIO_ID
				END

			DELETE FROM PROYECTO.TB_DESAFIO
			WHERE DESAFIO_ID = @VAR_DESAFIO_ID

		COMMIT
	END TRY

	BEGIN CATCH
		SELECT 
			ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_LINE() AS ErrorLine
    END CATCH
END
GO





