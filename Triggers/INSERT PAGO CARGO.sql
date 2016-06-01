CREATE OR REPLACE TRIGGER INSERT_AND_UPDATE 
AFTER INSERT ON PAGO 
FOR EACH ROW
DECLARE
--VARIABLES DE FECHA
DIA INT; MES INT; AÑO INT;
FECHA_LIMITE DATE;

--VARIABLES DE CALCULO
TIPO_CAMBIO NUMERIC(11, 2) := (:NEW.TIPO_DE_CAMBIO);
MONEDA INT := (:NEW.MONEDA);
PAGO NUMERIC(11, 2) := (:NEW.MONTO);
DOLLAR NUMERIC(11, 2);
RESULTADO NUMERIC(11,2);
CONT INT := 0;

--CURSOR
CURSOR CURCargoEstudianteQuetzales IS
SELECT CARGO, CARNE, MONTO, SALDO, FECHA_VENCIMIENTO, DESCRIPCION, MONEDA 
FROM CARGO 
WHERE CARNE = (:NEW.CARNE)
ORDER BY MONEDA ASC, CARNE, FECHA_VENCIMIENTO ASC;

CURSOR CURCargoEstudianteDolares IS
SELECT CARGO, CARNE, MONTO, SALDO, FECHA_VENCIMIENTO, DESCRIPCION, MONEDA 
FROM CARGO 
WHERE CARNE = (:NEW.CARNE)
ORDER BY MONEDA DESC, FECHA_VENCIMIENTO ASC;
-- FIN DECLARE

BEGIN

AÑO := (EXTRACT(YEAR FROM (:NEW.FECHA_APLICACION)));
MES := (EXTRACT(MONTH FROM (:NEW.FECHA_APLICACION)));
DIA:= (EXTRACT(DAY FROM (:NEW.FECHA_APLICACION)));

DIA := DIA - 1; 
MES := MES + 1;
FECHA_LIMITE := TO_DATE(AÑO || '/' || MES || '/' || DIA, 'YYYY/MM/DD');

IF (MONEDA = 1) THEN
        FOR Iteracion IN CURCargoEstudianteQuetzales
        LOOP
            DBMS_OUTPUT.put_line('ENTRE EN QUETZALES');
            IF (PAGO > 0 ) THEN
                IF (Iteracion.FECHA_VENCIMIENTO <= FECHA_LIMITE AND Iteracion.MONEDA = 1) THEN
                    DBMS_OUTPUT.put_line('ENTRE A PAGO > 0 Y TOCA PAGAR Q');
                    DBMS_OUTPUT.put_line('Soy Menor que tu fecha y entre en Quetzales');
                    IF (PAGO <= Iteracion.SALDO) THEN
                        RESULTADO := Iteracion.SALDO - PAGO;
                        --UPDATE ENTIDAD CARGO
                        UPDATE CARGO
                        SET SALDO = RESULTADO
                        WHERE CARGO = Iteracion.CARGO AND FECHA_VENCIMIENTO = Iteracion.FECHA_VENCIMIENTO;
                        DBMS_OUTPUT.put_line('UPDATE DE CARGO HECHO Q. / pago es menor 1');

                        --INSERT ENTIDAD PAGO_CARGO
                        INSERT INTO PAGO_CARGO
                        VALUES(SECIdPagoCargo.NEXTVAL, :NEW.PAGO, Iteracion.CARGO, PAGO);
                        DBMS_OUTPUT.put_line('INSERT EN PAGO_CARGO HECHO Q. pago es menor 1');
                    --SE RESTA EL PAGO
                    DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                    PAGO := PAGO - Iteracion.SALDO;
                    DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                    ELSE
                        --UPDATE ENTIDAD CARGO
                        UPDATE CARGO
                        SET SALDO = 0
                        WHERE CARGO = Iteracion.CARGO AND FECHA_VENCIMIENTO = Iteracion.FECHA_VENCIMIENTO;
                        DBMS_OUTPUT.put_line('UPDATE DE CARGO HECHO Q. / pago es mayor 2');

                        --INSERT ENTIDAD PAGO_CARGO
                        INSERT INTO PAGO_CARGO
                        VALUES(SECIdPagoCargo.NEXTVAL, :NEW.PAGO, Iteracion.CARGO, Iteracion.SALDO);
                        DBMS_OUTPUT.put_line('INSERT EN PAGO_CARGO HECHO Q. / pago es mayor 2');
                        --SE RESTA EL PAGO
                    DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                    PAGO := PAGO - Iteracion.SALDO;
                    DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                    END IF;
                END IF;

                
                IF (Iteracion.FECHA_VENCIMIENTO <= FECHA_LIMITE AND Iteracion.MONEDA = 2) THEN
                    IF (CONT = 0) THEN
                        DBMS_OUTPUT.put_line('LOS Q. ' || PAGO);
                        PAGO := PAGO / TIPO_CAMBIO;
                        CONT := CONT +1;
                        DBMS_OUTPUT.put_line('AHORA SON $. ' || PAGO);
                    END IF;
                    DBMS_OUTPUT.put_line('ENTRE A PAGO > 0 Y AHORA TOCA PAGAR $');
                    DBMS_OUTPUT.put_line('Soy Menor que tu fecha y entre en Dolares');
                    IF (PAGO <= Iteracion.SALDO) THEN
                        RESULTADO := Iteracion.SALDO - PAGO;
                        --UPDATE ENTIDAD CARGO
                        UPDATE CARGO
                        SET SALDO = RESULTADO
                        WHERE CARGO = Iteracion.CARGO AND FECHA_VENCIMIENTO = Iteracion.FECHA_VENCIMIENTO;
                        DBMS_OUTPUT.put_line('UPDATE DE CARGO HECHO $. / pago es menor 3');

                        --INSERT ENTIDAD PAGO_CARGO
                        INSERT INTO PAGO_CARGO
                        VALUES(SECIdPagoCargo.NEXTVAL, :NEW.PAGO, Iteracion.CARGO, PAGO);
                        DBMS_OUTPUT.put_line('INSERT EN PAGO_CARGO HECHO $. / pago es menor 3');
                    --SE RESTA EL PAGO
                    DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                    PAGO := PAGO - Iteracion.SALDO;
                    DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                    ELSE
                        --UPDATE ENTIDAD CARGO
                        UPDATE CARGO
                        SET SALDO = 0
                        WHERE CARGO = Iteracion.CARGO AND FECHA_VENCIMIENTO = Iteracion.FECHA_VENCIMIENTO;
                        DBMS_OUTPUT.put_line('UPDATE DE CARGO HECHO $. / pago es mayor 4');
                        
                        --INSERT ENTIDAD PAGO_CARGO
                        INSERT INTO PAGO_CARGO
                        VALUES(SECIdPagoCargo.NEXTVAL, :NEW.PAGO, Iteracion.CARGO, Iteracion.SALDO);
                        DBMS_OUTPUT.put_line('INSERT EN PAGO_CARGO HECHO $. / pago es mayor 4');

                    --SE RESTA EL PAGO
                    DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                    PAGO := PAGO - Iteracion.SALDO;
                    DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                    END IF;
                END IF;
            ELSE
                CONT := 0;
                DBMS_OUTPUT.put_line('Llegue al final Quetzales');
                EXIT WHEN PAGO <= 0 OR (Iteracion.FECHA_VENCIMIENTO > FECHA_LIMITE);
            END IF;
        END LOOP;
    END IF;

IF (MONEDA = 2) THEN
    FOR Iteracion IN CURCargoEstudianteDolares
    LOOP

        DBMS_OUTPUT.put_line(Iteracion.FECHA_VENCIMIENTO);
        DBMS_OUTPUT.put_line(FECHA_LIMITE);
        DBMS_OUTPUT.put_line('ENTRE EN DOLARES');
        IF (PAGO > 0 ) THEN
            IF (Iteracion.FECHA_VENCIMIENTO <= FECHA_LIMITE AND Iteracion.MONEDA = 2) THEN
                DBMS_OUTPUT.put_line('ENTRE A PAGO > 0 Y TOCA PAGAR $');
                DBMS_OUTPUT.put_line('Soy Menor que tu fecha y entre en Dolares');
                IF (PAGO <= Iteracion.SALDO) THEN
                    RESULTADO := Iteracion.SALDO - PAGO;
                    DBMS_OUTPUT.put_line('RESULTADO: ' || RESULTADO);
                    --UPDATE ENTIDAD CARGO
                    UPDATE CARGO
                    SET SALDO = RESULTADO
                    WHERE CARGO = Iteracion.CARGO AND FECHA_VENCIMIENTO = Iteracion.FECHA_VENCIMIENTO;
                    DBMS_OUTPUT.put_line('UPDATE DE CARGO HECHO $. / pago es menor 1');

                    --INSERT ENTIDAD PAGO_CARGO
                    INSERT INTO PAGO_CARGO
                    VALUES(SECIdPagoCargo.NEXTVAL, :NEW.PAGO, Iteracion.CARGO, PAGO);
                    DBMS_OUTPUT.put_line('INSERT EN PAGO_CARGO HECHO $. pago es menor 1');
                --SE RESTA EL PAGO
                DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                PAGO := PAGO - Iteracion.SALDO;
                DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                ELSE
                    --UPDATE ENTIDAD CARGO
                    UPDATE CARGO
                    SET SALDO = 0
                    WHERE CARGO = Iteracion.CARGO AND FECHA_VENCIMIENTO = Iteracion.FECHA_VENCIMIENTO;
                    DBMS_OUTPUT.put_line('UPDATE DE CARGO HECHO $. / pago es mayor 2');

                    --INSERT ENTIDAD PAGO_CARGO
                    INSERT INTO PAGO_CARGO
                    VALUES(SECIdPagoCargo.NEXTVAL, :NEW.PAGO, Iteracion.CARGO, Iteracion.SALDO);
                    DBMS_OUTPUT.put_line('INSERT EN PAGO_CARGO HECHO $. / pago es mayor 2');
                --SE RESTA EL PAGO
                DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                PAGO := PAGO - Iteracion.SALDO;
                DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                END IF;
            END IF;

            
            IF (Iteracion.FECHA_VENCIMIENTO <= FECHA_LIMITE AND Iteracion.MONEDA = 1) THEN
                IF (CONT = 0) THEN
                    DBMS_OUTPUT.put_line('LOS $. ' || PAGO);
                    PAGO := PAGO * TIPO_CAMBIO;
                    CONT := CONT +1;
                    DBMS_OUTPUT.put_line('AHORA SON Q. ' || PAGO);
                END IF;
                DBMS_OUTPUT.put_line('ENTRE A PAGO > 0 Y AHORA TOCA PAGAR Q');
                DBMS_OUTPUT.put_line('Soy Menor que tu fecha y entre en Quetzales');
                IF (PAGO <= Iteracion.SALDO) THEN
                    DBMS_OUTPUT.put_line('RESULTADO: ' || RESULTADO);
                    RESULTADO := Iteracion.SALDO - PAGO;
                    DBMS_OUTPUT.put_line('RESULTADO: ' || RESULTADO);
                    --UPDATE ENTIDAD CARGO
                    UPDATE CARGO
                    SET SALDO = RESULTADO
                    WHERE CARGO = Iteracion.CARGO AND FECHA_VENCIMIENTO = Iteracion.FECHA_VENCIMIENTO;
                    DBMS_OUTPUT.put_line('UPDATE DE CARGO HECHO Q. / pago es menor 3');

                    --INSERT ENTIDAD PAGO_CARGO
                    INSERT INTO PAGO_CARGO
                    VALUES(SECIdPagoCargo.NEXTVAL, :NEW.PAGO, Iteracion.CARGO, PAGO);
                    DBMS_OUTPUT.put_line('INSERT EN PAGO_CARGO HECHO Q. / pago es menor 3');
                --SE RESTA EL PAGO
                DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                PAGO := PAGO - Iteracion.SALDO;
                DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                ELSE
                    --UPDATE ENTIDAD CARGO
                    UPDATE CARGO
                    SET SALDO = 0
                    WHERE CARGO = Iteracion.CARGO AND FECHA_VENCIMIENTO = Iteracion.FECHA_VENCIMIENTO;
                    DBMS_OUTPUT.put_line('UPDATE DE CARGO HECHO Q. / pago es mayor 4');
                    
                    --INSERT ENTIDAD PAGO_CARGO
                    INSERT INTO PAGO_CARGO
                    VALUES(SECIdPagoCargo.NEXTVAL, :NEW.PAGO, Iteracion.CARGO, Iteracion.SALDO);
                    DBMS_OUTPUT.put_line('INSERT EN PAGO_CARGO HECHO Q. / pago es mayor 4');

                --SE RESTA EL PAGO
                DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                PAGO := PAGO - Iteracion.SALDO;
                DBMS_OUTPUT.put_line('PAGO: ' || PAGO);
                END IF;
            END IF;
        ELSE
            DBMS_OUTPUT.put_line('Llegue al final Dolares');
            CONT := 0;
            EXIT WHEN PAGO <= 0 OR (Iteracion.FECHA_VENCIMIENTO > FECHA_LIMITE);

        END IF;
    END LOOP;
END IF;
  NULL;
END;