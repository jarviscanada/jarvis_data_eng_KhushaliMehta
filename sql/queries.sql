-- Table setup

CREATE TABLE cd.members (
  memid integer not null, 
  surname varchar(200) not null, 
  firstname varchar(200) not null, 
  address varchar(300) not null, 
  zipcode integer not null, 
  recommendedby integer, 
  joindate timestamp not null, 
  Primary key (memid), 
  foreign key (recommendedby) references cd.members(memid) on delete 
  set 
    null
);

create table cd.bookings (
  bookid integer not null, 
  facid integer not null, 
  memid integer not null, 
  starttime timestamp not null, 
  slots integer not null, 
  Primary key (bookid), 
  Foreign key (facid) references cd.facilities(facid), 
  Foreign key (memid) references cd.members(memid)
);

create table cd.facilities (
    facid integer not null,
    name varchar(100) not null,
    membercost numeric not null,
    guestcost numeric not null, 
    initialoutlay numeric NOT NULL, 
    monthlymaintenance numeric NOT NULL,
    Primary key (facid)
);

-- modifying data
insert into cd.facilities values(9, 'Spa', 20, 30, 100000, 800);

insert into cd.facilities values ((select max(facid) from cd.facilities)+1, 'Spa', 20, 30, 100000, 800);

Update cd.facilities set initialoutlay = 10000 where facid = 1;

update cd.facilities 
set membercost = (select membercost * 1.1 from cd.facilities where facid = 0 ), 
  guestcost = (select guestcost * 1.1 from cd.facilities where facid = 0) 
where facid = 1

delete from cd.bookings;

delete from cd.members where memid = 37;

-- basics
select facid, name, membercost, monthlymaintenance from cd.facilities where membercost > 0 and 
membercost < monthlymaintenance/50;

select * from cd.facilities where name like '%Tennis%';

select * from cd.facilities where facid in (1,5);

select memid, surname, firstname, joindate from cd.members where joindate >= '2012-09-01 00:00:00';

select surname from cd.members UNION select name from cd.facilities;

-- joins
select starttime from cd.bookings join cd.members on cd.bookings.memid = cd.members.memid 
where cd.members.firstname = 'David' and cd.members.surname= 'Farrell'; 

select starttime , name from cd.bookings join cd.facilities  on cd.bookings.facid = cd.facilities.facid
where name like '%Tennis Court%' and starttime >= '2012-09-21' and starttime < '2012-09-22' order by starttime;

select 
  m.firstname as memfname, 
  m.surname as memsname, 
  mem.firstname as recfname, 
  mem.surname as recsname 
from 
  cd.members as m 
  left outer join cd.members as mem on mem.memid = m.recommendedby 
order by 
  memsname, 
  memfname

select 
  distinct mem.firstname, 
  mem.surname 
from 
  cd.members as m 
  join cd.members mem on mem.memid = m.recommendedby 
order by 
  mem.surname, 
  mem.firstname;

select distinct mems.firstname || ' ' ||  mems.surname as member,
	(select recs.firstname || ' ' || recs.surname as recommender 
		from cd.members recs 
		where recs.memid = mems.recommendedby
	)
	from 
		cd.members mems
order by member; 

-- aggregation 
select recommendedby, count(*) from cd.members where recommendedby is not null
	group by recommendedby
order by recommendedby;

select facid, sum(slots) as "Total slots" from cd.bookings group by facid order by facid;

select facid, sum(slots) as "Total slots" from cd.bookings  
where starttime >= '2012-09-01' and starttime < '2012-10-01' 
group by facid order by sum(slots) 

select facid, extract(month from starttime) as month, sum(slots) as "Total Slots" from cd.bookings
where extract(year from starttime) = 2012
group by facid, month
order by facid, month;

select count(distinct memid) as "count" from cd.bookings;


select m.surname, m.firstname, m.memid, min(b.starttime) as starttime from cd.members as m join 
cd.bookings as b
on m.memid = b.memid where b.starttime >= '2012-09-01' 
group by m.surname, m.firstname, m.memid
order by m.memid

select (select count(*) from cd.members) as "count", firstname, surname from cd.members 
order by joindate 

select row_number() over(), firstname, surname from cd.members 
order by joindate

select facid, total from (
	select facid, total, rank() over (order by total desc) rank from (
		select facid, sum(slots) total
			from cd.bookings
			group by facid
		) as sumslots
	) as ranked
where rank = 1

-- string
select surname || ', ' || firstname as name from cd.members;

select memid, telephone from cd.members where telephone ~ '[()]';

select substr (mems.surname,1,1) as letter, count(*) as count 
from cd.members mems
group by letter
order by letter 