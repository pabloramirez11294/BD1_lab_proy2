/* 1. Desplegar para cada elección el país y el partido político que obtuvo mayor porcentaje de votos en su país. Debe desplegar el nombre de la
 elección, el año de la elección, el país, el nombre del partido político y el porcentaje que obtuvo de votos en su país. 
*/

create or replace view c1 as select *
from (SELECT e.nombre,e.pais,z.nombre as nombrePais,e.year,par.alias,sum(analfabetos+alfabetos) as total
FROM eleccion as e
JOIN puesto as p on e.id_eleccion=p.id_eleccion
JOIN votacion as v on p.id_puesto=v.id_puesto
JOIN partido as par on v.id_partido=par.id_partido
join zona as z on e.pais=z.id_zona
GROUP BY e.nombre,e.pais,e.year,par.alias) as x;

SELECT e.nombre,(select nombrePais from c1 where pais=e.pais order by total desc limit 1) as pais,e.year,
                (select alias from c1 where pais=e.pais order by total desc limit 1) as partido,
                (select total from c1 where pais=e.pais order by total desc limit 1)/(select sum(total )from c1 where pais=e.pais )*100 as total
FROM eleccion as e
JOIN puesto as p on e.id_eleccion=p.id_eleccion
JOIN votacion as v on p.id_puesto=v.id_puesto
JOIN partido as par on v.id_partido=par.id_partido
GROUP BY e.nombre,e.pais,e.year;


/* 2.Desplegar total de votos y porcentaje de votos de mujeres por departamento y país. El ciento por ciento es el total de votos 
de mujeres por país. (Tip: Todos los porcentajes por departamento de un país deben sumar el 100%)
*/

create or replace view c2 as SELECT pa.nombre as pais,de.nombre as depto,sum(v.analfabetos+v.alfabetos )as total
	FROM votacion as v
	JOIN puesto as p on v.id_puesto=p.id_puesto
	JOIN zona as mu on mu.id_zona=p.id_zona and mu.tipo='m'
	JOIN zona as de on de.id_zona=mu.padre 
	JOIN zona as re on re.id_zona=de.padre
	JOIN zona as pa on pa.id_zona=re.padre
	JOIN votante as vo on vo.id_votante=v.id_votante and vo.sexo='mujeres'
	group by pa.id_zona,de.id_zona
	order by total;

SELECT pa.nombre as pais,de.nombre as depto,(select sum(c2.total) from c2 where pais=pa.nombre)as totalPais,sum(v.analfabetos+v.alfabetos )as totalDepto,
									sum(v.analfabetos+v.alfabetos )/(select sum(c2.total) from c2 where pais=pa.nombre)*100 as porcentajeDepto
FROM votacion as v
JOIN puesto as p on v.id_puesto=p.id_puesto
JOIN zona as mu on mu.id_zona=p.id_zona and mu.tipo='m'
JOIN zona as de on de.id_zona=mu.padre 
JOIN zona as re on re.id_zona=de.padre
JOIN zona as pa on pa.id_zona=re.padre
JOIN votante as vo on vo.id_votante=v.id_votante and vo.sexo='mujeres'
group by pa.id_zona,de.id_zona
order by pa.nombre;

/*3.Desplegar el nombre del país, nombre del partido político y número de alcaldías de los partidos políticos que ganaron más alcaldías por país.
*/



/*4.Desplegar todas las regiones por país en las que predomina la raza indígena. Es decir, hay más votos que las otras razas.*/
create or replace view c4 as SELECT pa.nombre as pais,re.nombre as region,vo.raza,sum(v.analfabetos+v.alfabetos) as total
	FROM votacion as v
	JOIN puesto as p on v.id_puesto=p.id_puesto
	JOIN zona as mu on mu.id_zona=p.id_zona and mu.tipo='m'
	JOIN zona as de on de.id_zona=mu.padre 
	JOIN zona as re on re.id_zona=de.padre
	JOIN zona as pa on pa.id_zona=re.padre
	JOIN votante as vo on vo.id_votante=v.id_votante 
	group by pa.nombre,re.nombre,vo.raza
	order by pa.nombre,re.nombre,vo.raza;

select pais,region,total from c4 as p1 
where raza='INDIGENAS' and total=(select max(total) from c4 where pais=p1.pais and region=p1.region)
order by pais;

/*
5.Desplegar el nombre del país, el departamento, el municipio, el partido político y la cantidad de votos universitarios de todos aquellos 
partidos políticos que obtuvieron una cantidad de votos de universitarios mayor que el 25% de votos de primaria y menor que el 30% de votos
 de nivel medio (correspondiente a ese municipio y al partido político).  Ordene sus resultados de mayor a menor.
*/

create or replace view c5 as
 select pa.nombre as pais,de.nombre as depto,mu.nombre as municipio,par.alias as partido,sum(v.universitarios) as totalU,sum(v.primaria) as totalP
																						,sum(v.nivel_medio) as totalNM
from votacion as v
JOIN puesto as p on v.id_puesto=p.id_puesto
JOIN zona as mu on mu.id_zona=p.id_zona and mu.tipo='m'
JOIN zona as de on de.id_zona=mu.padre 
JOIN zona as re on re.id_zona=de.padre
JOIN zona as pa on pa.id_zona=re.padre 
join partido as par on par.id_partido=v.id_partido
group by pa.nombre,de.nombre,mu.nombre,par.alias;

select * from c5 
where totalU>0.25*totalP and totalU <0.3*totalNM
order by totalU desc;


/*
6.Desplegar el porcentaje de mujeres universitarias y hombres universitarios que votaron por departamento, donde las mujeres universitarias 
que votaron fueron más que los hombres universitarios que votaron.
*/

create or replace view c6 as
select pa.nombre as pais,de.nombre as depto,vo.sexo,sum(v.universitarios) as universitarios
from votacion as v
JOIN puesto as p on v.id_puesto=p.id_puesto
JOIN zona as mu on mu.id_zona=p.id_zona and mu.tipo='m'
JOIN zona as de on de.id_zona=mu.padre 
JOIN zona as re on re.id_zona=de.padre
JOIN zona as pa on pa.id_zona=re.padre 
JOIN votante as vo on vo.id_votante=v.id_votante 
group by pa.nombre,de.nombre,vo.sexo
order by pa.nombre,de.nombre;

select m.pais,m.depto,(m.universitarios/(m.universitarios+h.universitarios))*100 as mujeres,(h.universitarios/(m.universitarios+h.universitarios))*100  as hombres
from c6 as m
join c6 as h on m.pais=h.pais and m.depto=h.depto
where m.universitarios>h.universitarios; 


/*7. Desplegar el nombre del país, la región y el promedio de votos por departamento. Por ejemplo: si la región tiene tres departamentos,
 se debe sumar todos los votos de la región y dividirlo dentro de tres (número de departamentos de la región).
*/

create or replace view c7 as
select pa.nombre as pais,re.nombre as region,de.nombre as depto,sum(v.analfabetos+v.alfabetos )as total
from votacion as v
JOIN puesto as p on v.id_puesto=p.id_puesto
JOIN zona as mu on mu.id_zona=p.id_zona and mu.tipo='m'
JOIN zona as de on de.id_zona=mu.padre 
JOIN zona as re on re.id_zona=de.padre
JOIN zona as pa on pa.id_zona=re.padre
group by pa.nombre,re.nombre,de.nombre;

select pais,region,sum(total)/(select count(*) from c7 where ban.pais=pais and ban.region=region ) as promedio from c7 as ban group by pais,region ;


/*8. Desplegar el nombre del municipio y el nombre de los dos partidos políticos con más votos en el municipio, ordenados por país.
*/

create or replace view c8 as
 select pa.nombre as pais,de.nombre as depto,mu.nombre as municipio,par.alias as partido,sum(v.analfabetos+v.alfabetos) as total
from votacion as v
JOIN puesto as p on v.id_puesto=p.id_puesto
JOIN zona as mu on mu.id_zona=p.id_zona and mu.tipo='m'
JOIN zona as de on de.id_zona=mu.padre 
JOIN zona as re on re.id_zona=de.padre
JOIN zona as pa on pa.id_zona=re.padre 
join partido as par on par.id_partido=v.id_partido
group by pa.nombre,de.nombre,mu.nombre,par.alias;

select distinct pais,municipio,(select partido from c8 where pais=ban.pais and municipio=ban.municipio order by  total desc limit 1)as part1
					,(select partido from c8 where pais=ban.pais and municipio=ban.municipio order by  total desc limit 1,1)as part2
from c8 as ban
order by pais;

/*9. Desplegar el total de votos de cada nivel de escolaridad (primario, medio, universitario) por país, sin importar raza o sexo.
*/
select pa.nombre as pais,sum(primaria),sum(nivel_medio),sum(universitarios)
from votacion as v
JOIN puesto as p on v.id_puesto=p.id_puesto
JOIN zona as mu on mu.id_zona=p.id_zona and mu.tipo='m'
JOIN zona as de on de.id_zona=mu.padre 
JOIN zona as re on re.id_zona=de.padre
JOIN zona as pa on pa.id_zona=re.padre 
join partido as par on par.id_partido=v.id_partido
group by pais;

/*
10. Desplegar el nombre del país y el porcentaje de votos por raza.
*/
create or replace view c10 as
select pa.nombre as pais,vot.raza,sum(v.analfabetos+v.alfabetos) as total
from votacion as v
JOIN puesto as p on v.id_puesto=p.id_puesto
JOIN zona as mu on mu.id_zona=p.id_zona and mu.tipo='m'
JOIN zona as de on de.id_zona=mu.padre 
JOIN zona as re on re.id_zona=de.padre
JOIN zona as pa on pa.id_zona=re.padre 
join votante as vot on vot.id_votante=v.id_votante
group by pais,vot.raza;

select pais,raza,total/(select sum(total) from c10 where pais=ban.pais group by pais)*100 as porcentaje
from c10 as ban
group by pais,raza
order by pais;

/*
11. Desplegar el nombre del país en el cual las elecciones han sido más peleadas. Para determinar esto se debe
 calcular la diferencia de porcentajes de votos entre el partido que obtuvo más votos y el partido que obtuvo menos votos.
*/
create or replace view c11 as
select pa.nombre as pais,par.alias as partido,sum(v.analfabetos+v.alfabetos) as total
from votacion as v
JOIN puesto as p on v.id_puesto=p.id_puesto
JOIN zona as mu on mu.id_zona=p.id_zona and mu.tipo='m'
JOIN zona as de on de.id_zona=mu.padre 
JOIN zona as re on re.id_zona=de.padre
JOIN zona as pa on pa.id_zona=re.padre 
join partido as par on par.id_partido=v.id_partido
group by pais,partido;

select pais,(max(total)-min(total))/(select sum(total) from c11 where pais=ban.pais)*100 as diferencia
from c11 as ban
group by pais 
limit 1;


/*12.Desplegar el total de votos y el porcentaje de votos emitidos por mujeres indígenas alfabetas.*/

/*13.Desplegar el nombre del país, el porcentaje de votos de ese país en el que han votado mayor porcentaje de analfabetas.
 (tip: solo desplegar un nombre de país, el de mayor porcentaje).*/

  create or replace view c13 as
select pa.nombre as pais,sum(v.analfabetos) as analfabetas,sum(v.analfabetos+v.alfabetos) as total
from votacion as v
JOIN puesto as p on v.id_puesto=p.id_puesto
JOIN zona as mu on mu.id_zona=p.id_zona and mu.tipo='m'
JOIN zona as de on de.id_zona=mu.padre 
JOIN zona as re on re.id_zona=de.padre
JOIN zona as pa on pa.id_zona=re.padre 
group by pais;
 
select pais,(analfabetas/total)*100 as porcentaje
from c13
order by porcentaje desc
limit 1;


/*14.Desplegar la lista de departamentos de Guatemala y número de votos obtenidos, para los departamentos que obtuvieron más 
votos que el departamento de Guatemala.*/

create or replace view c14 as
select pa.nombre as pais,de.nombre as depto,sum(v.analfabetos+v.alfabetos) as total
from votacion as v
JOIN puesto as p on v.id_puesto=p.id_puesto
JOIN zona as mu on mu.id_zona=p.id_zona and mu.tipo='m'
JOIN zona as de on de.id_zona=mu.padre 
JOIN zona as re on re.id_zona=de.padre
JOIN zona as pa on pa.id_zona=re.padre  and pa.nombre='GUATEMALA'
group by pais,depto;

select * 
from c14 as c1
where total > (select total from c14 where depto='GUATEMALA');