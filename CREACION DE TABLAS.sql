--TEST SQL XIK 2
--KEVIN HERRERA - DEVELOPER

CREATE TABLE Moneda(
	Moneda 			INT PRIMARY KEY, --PK
	Nombre 			VARCHAR(20) NOT NULL 
);

CREATE TABLE Plan_Pago
 (
	Plan_Pago 		        INT PRIMARY KEY, --PK
	Carne 			        VARCHAR(12) NOT NULL,
	Fecha_Aplicacion	    DATE NOT NULL,
	Monto			        NUMERIC(11, 2) NOT NULL,
	Cuotas			        INT NOT NULL,
	Moneda					INT NOT NULL,  --FK
	CONSTRAINT FK_PPM FOREIGN KEY (Moneda) REFERENCES Moneda(Moneda)  
);


CREATE TABLE Cargo(
	Cargo			        INT PRIMARY KEY, --PK
	Carne			        VARCHAR(12) NOT NULL,
	Fecha_Transaccion 		DATE NOT NULL,
  	Monto               	NUMERIC(11, 2) NOT NULL,
	Saldo			        NUMERIC(11, 2) NOT NULL,
	Fecha_Vencimiento	  	DATE NOT NULL,
	Descripcion		      	VARCHAR(100) NOT NULL,
	Moneda					INT NOT NULL,  --FK
	CONSTRAINT FK_CM FOREIGN KEY (Moneda) REFERENCES Moneda(Moneda)
);


CREATE TABLE Pago(
	Pago				  INT PRIMARY KEY, --PK
	Carne				  VARCHAR(12) NOT NULL,
	Fecha_Aplicacion	  DATE NOT NULL,
	Monto			      NUMERIC(11, 2) NOT NULL,
	Descripcion			  VARCHAR(100),
	Moneda				  INT NOT NULL,  --FK
	Tipo_De_Cambio 		  NUMERIC(11,2) NOT NULL,
	CONSTRAINT FK_PM FOREIGN KEY (Moneda) REFERENCES Moneda(Moneda)
);


CREATE TABLE Pago_Cargo(
	Pago_Cargo				  INT PRIMARY KEY,		--PK
	Pago			          INT,					--FK
	Cargo			          INT NOT NULL,			--FK
	Monto			          NUMERIC(11, 2) NOT NULL,
	CONSTRAINT fk_PCP FOREIGN KEY (Pago) REFERENCES Pago(Pago),
	CONSTRAINT fk_PCC FOREIGN KEY (Cargo) REFERENCES Cargo(Cargo)
);


