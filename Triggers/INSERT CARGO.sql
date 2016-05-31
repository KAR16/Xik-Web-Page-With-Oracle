--TRIGGER 1 -- INSERT CARGO

CREATE OR REPLACE TRIGGER INSERTCARGO 
AFTER INSERT ON PLAN_PAGO
FOR EACH ROW
DECLARE 
IDPlanPago INT := (:NEW.Plan_Pago); Monto INT := 0; NoCuotas INT := 0; Cuota INT := 0; Fecha DATE; 
Fecha_Final DATE; Cont INT := 1;
Mes INT := 0; Anio INT := 0;
Fecha_Transaccion DATE;
Fecha_Vencimiento DATE;

--FINAL DECLARE
BEGIN
--AQUI OBTENEMOS EL MONTO A PAGAR
Monto := (:NEW.Monto);

--AQUI OBTENEMOS EL No. DE CUOTAS A PAGAR
NoCuotas := (:NEW.Cuotas);

--AQUI OBTENEMOS EL MONTO A PAGAR POR CUOTA
Cuota := (Monto / NoCuotas);

--HACEMOS LA OPERACION PARA LA FECHA
Anio := (EXTRACT(YEAR FROM (:NEW.FECHA_APLICACION)));

--Fecha_Final := TO_DATE(Fecha, 'YYYY/MON/DD');
Mes := (EXTRACT(MONTH FROM (:NEW.FECHA_APLICACION)));

  IF (Mes) <= 9 THEN
  Fecha := TO_DATE(Anio|| '/0' || (Mes + 1) || '/05', 'YYYY/MM/DD');
  ELSE
  Fecha := TO_DATE(Anio|| '/' || (Mes + 1) || '/05', 'YYYY/MM/DD');
  END IF;

--AHORA INSERTAMOS EN CARGOS LAS CUOTAS
INSERT INTO Cargo
VALUES(SECIdUserCargo.NEXTVAL, (:NEW.Carne), (:NEW.Fecha_Aplicacion), Cuota, Cuota, Fecha, ('Cuota ' || Cont), (:NEW.Moneda));

--ACA INICIAMOS EL WHILE PARA TERMINAR DE INSERTAR LAS CUTOAS RESTANTES
WHILE (Cont < NoCuotas) LOOP
--AQUI MODIFICAMOS LAS FECHAS DE TRANSACCION Y VENCIMIENTO PARA LAS CUOTAS
Mes:= Mes + 1;

IF Mes > 12 THEN
    Mes := 1;
    Anio:= Anio + 1;
    IF (Mes + Cont) <= 9 THEN
    Fecha_Transaccion := TO_DATE(Anio || '/0' || (Mes)|| '/06', 'YYYY/MM/DD' );
    ELSE
    Fecha_Transaccion := TO_DATE(Anio || '/' || (Mes )|| '/06', 'YYYY/MM/DD' );
    END IF;
ELSE
    IF (Mes) <= 9 THEN
    Fecha_Transaccion := TO_DATE(Anio || '/0' || (Mes)|| '/06', 'YYYY/MM/DD' );
    ELSE
    Fecha_Transaccion := TO_DATE(Anio || '/' || (Mes)|| '/06', 'YYYY/MM/DD' );
    END IF;
END IF;


IF (EXTRACT(MONTH FROM Fecha_Transaccion)) >= 12 THEN
    Mes := 0;
    Anio:= Anio + 1 ;
    IF (Mes + Cont + 1)<=9 THEN
    Fecha_Vencimiento := TO_DATE(Anio || '/0' || (Mes + 1) || '/05', 'YYYY/MM/DD');
    ELSE
    Fecha_Vencimiento := TO_DATE(Anio || '/' || (Mes + 1) || '/05', 'YYYY/MM/DD');
    END IF;
ELSE
    IF (Mes + Cont + 1)<=9 THEN
    Fecha_Vencimiento := TO_DATE(Anio || '/0' || (Mes + 1) || '/05', 'YYYY/MM/DD');
    ELSE
    Fecha_Vencimiento := TO_DATE(Anio || '/' || (Mes + 1) || '/05', 'YYYY/MM/DD');
    END IF;
END IF;

Cont := Cont + 1; --AQUI INCREMENTAMOS EL VALOR DEL LOOP DE 1-1
INSERT INTO Cargo 
VALUES(SECIdUserCargo.NEXTVAL, (:NEW.Carne), Fecha_Transaccion, Cuota, Cuota, Fecha_Vencimiento, ('Cuota ' || Cont),(:NEW.Moneda));
END LOOP;
  NULL;
END;