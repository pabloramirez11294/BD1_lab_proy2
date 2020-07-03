use proy2;

DROP TABLE IF EXISTS votacion;
DROP TABLE IF EXISTS votante;
DROP TABLE IF EXISTS partido;
DROP TABLE IF EXISTS puesto;
DROP TABLE IF EXISTS eleccion;
DROP TABLE IF EXISTS zona;
CREATE TABLE zona(
    id_zona INTEGER PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    padre INTEGER ,
    tipo ENUM('p', 'r', 'd', 'm') NOT NULL,
    FOREIGN KEY(padre) REFERENCES zona(id_zona)
);

CREATE TABLE eleccion(
    id_eleccion INTEGER PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    pais INTEGER NOT NULL,
    FOREIGN KEY(pais) REFERENCES zona(id_zona)
);

CREATE TABLE puesto(
    id_puesto INTEGER PRIMARY KEY AUTO_INCREMENT,
    id_eleccion INTEGER NOT NULL,
    id_zona  INTEGER NOT NULL,
    tipo ENUM('p', 'r', 'd', 'm') NOT NULL,
    FOREIGN KEY(id_eleccion) REFERENCES eleccion(id_eleccion),
    FOREIGN KEY(id_zona) REFERENCES zona(id_zona)
);

CREATE TABLE partido(
    id_partido INTEGER PRIMARY KEY AUTO_INCREMENT,
    alias VARCHAR(20) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    id_puesto INTEGER NOT NULL,
    FOREIGN KEY(id_puesto) REFERENCES puesto(id_puesto) 
);

CREATE TABLE votante(
    id_votante INTEGER PRIMARY KEY AUTO_INCREMENT,
    sexo  ENUM('hombres', 'mujeres') NOT NULL,
    raza VARCHAR(50) NOT NULL
);

CREATE TABLE votacion(
    id_partido INTEGER,
    id_votante INTEGER,
    analfabetos INTEGER NOT NULL,
    alfabetos INTEGER NOT NULL,
    primaria INTEGER NOT NULL,
    nivel_medio INTEGER NOT NULL,
    universitarios INTEGER NOT NULL,
    PRIMARY KEY(id_partido,id_votante),
    FOREIGN KEY(id_partido) REFERENCES partido(id_partido),
    FOREIGN KEY(id_votante) REFERENCES votante(id_votante), 
    CHECK (analfabetos>=0),
    CHECK (alfabetos>=0),
    CHECK (primaria>=0),
    CHECK (nivel_medio>=0),
    CHECK (universitarios>=0)
);


INSERT INTO zona(nombre,padre,tipo)
    SELECT distinct pais,null,'p'
    FROM temporal;

INSERT INTO zona(nombre,padre,tipo)
    SELECT distinct region,id_zona,'r'
    FROM temporal
    JOIN zona as z on z.nombre=pais;

INSERT INTO zona(nombre,padre,tipo)
    SELECT depto,z2.id_zona,'d'
    FROM temporal
    join zona as z on z.nombre=pais and z.tipo='p'
    join zona as z2 on  z2.nombre=region  and z.id_zona=z2.padre and  z2.tipo='r'
    group by depto;


INSERT INTO zona(nombre,padre,tipo)
    SELECT municipio,z3.id_zona,'m'
    FROM temporal
    join zona as z on z.nombre=pais and z.tipo='p'
    join zona as z2 on  z2.nombre=region and z.id_zona=z2.padre  and  z2.tipo='r'
    join zona as z3 on z3.nombre=depto and z2.id_zona=z3.padre and z3.tipo='d'
    group by municipio,z2.id_zona;


INSERT INTO eleccion(nombre,pais)
    SELECT distinct nombre_eleccion,z.id_zona
    FROM temporal as t
    join zona as z on t.pais=z.nombre and z.tipo='p';

