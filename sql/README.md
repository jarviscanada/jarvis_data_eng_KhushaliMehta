# Introduction

This project was built as a learning activity to gain fundamental knowledge of RDBMS and SQL by solving SQL queries. The main focus of the project was on data modelling and data definition language (DDL) to describe data and its relationship in database. After developing required schema, data maniplation queries has been executed to perform CREATE, READ, UPDATE, DELETE (CRUD) operations. Potential users of the project are data engineers, business systems analyst and data analysts. To perform SQL queries, an open source, free to use online SQL interpreter -  https://sqliteonline.com/ was utilized. No set up is required to use this interpreter, after creating necessary tables, one can perform the queries easily.

## SQL Queries
### Table Setup (DDL)
```sql

-- create members table
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

-- create bookings table
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

-- create facilities table
create table cd.facilities (
    facid integer not null,
    name varchar(100) not null,
    membercost numeric not null,
    guestcost numeric not null, 
    initialoutlay numeric NOT NULL, 
    monthlymaintenance numeric NOT NULL,
    Primary key (facid)
);

```
### Modifying Data
#### Question 1: Show all members
```sql
SELECT * FROM cd.members
```

#### Question 2: The club is adding a new facility - a spa. We need to add it into the facilities table. Use the following values:

#### facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

```sql
insert into cd.facilities values(9, 'Spa', 20, 30, 100000, 800)
```

#### Question 3: Let's try adding the spa to the facilities table again. This time, though, we want to automatically generate the value for the next facid, rather than specifying it as a constant. Use the following values for everything else:

#### Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.

```sql
insert into cd.facilities values ((select max(facid) from cd.facilities)+1, 'Spa', 20, 30, 100000, 800)
```
#### Question 4: We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000: you need to alter the data to fix the error.


```sql
Update cd.facilities set initialoutlay = 10000 where facid = 1;
```

#### Question 5: We want to alter the price of the second tennis court so that it costs 10% more than the first one. Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.


```sql
update cd.facilities 
set membercost = (select membercost * 1.1 from cd.facilities where facid = 0 ), 
  guestcost = (select guestcost * 1.1 from cd.facilities where facid = 0) 
where facid = 1
```

#### Question 6: As part of a clearout of our database, we want to delete all bookings from the cd.bookings table. How can we accomplish this?

```sql
delete from cd.bookings;
```

#### Question 7: We want to remove member 37, who has never made a booking, from our database. How can we achieve that?

```sql
delete from cd.members where memid = 37;
```

### Basics
#### Question 8: How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.

```sql
select facid, name, membercost, monthlymaintenance from cd.facilities where membercost > 0 and 
membercost < monthlymaintenance/50;
```

#### Question 9: How can you produce a list of all facilities with the word 'Tennis' in their name?

```sql
select * from cd.facilities where name like '%Tennis%';
```

#### Question 10: How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.

```sql
select * from cd.facilities where facid in (1,5);
```

#### Question 11: How can you produce a list of members who joined after the start of September 2012? Return the memid, surname, firstname, and joindate of the members in question.

```sql
select memid, surname, firstname, joindate from cd.members where joindate >= '2012-09-01 00:00:00';
```

#### Question 12: You, for some reason, want a combined list of all surnames and all facility names. Produce that list!

```sql
select surname from cd.members UNION select name from cd.facilities;
```
### Joins
#### Question 13: How can you produce a list of the start times for bookings by members named 'David Farrell'?

```sql
select starttime from cd.bookings join cd.members on cd.bookings.memid = cd.members.memid 
where cd.members.firstname = 'David' and cd.members.surname= 'Farrell'; 
```

#### Question 14: How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.

```sql
select starttime , name from cd.bookings join cd.facilities  on cd.bookings.facid = cd.facilities.facid
where name like '%Tennis Court%' and starttime >= '2012-09-21' and starttime < '2012-09-22' order by starttime;
```

#### Question 15: How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).

```sql
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
```

#### Question 16: How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).

```sql
select 
  distinct mem.firstname, 
  mem.surname 
from 
  cd.members as m 
  join cd.members mem on mem.memid = m.recommendedby 
order by 
  mem.surname, 
  mem.firstname;
```

#### Question 17: How can you output a list of all members, including the individual who recommended them (if any), without using any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.

```sql
select distinct mems.firstname || ' ' ||  mems.surname as member,
	(select recs.firstname || ' ' || recs.surname as recommender 
		from cd.members recs 
		where recs.memid = mems.recommendedby
	)
	from 
		cd.members mems
order by member; 
```
### Aggregation
#### Question 18: Produce a count of the number of recommendations each member has made. Order by member ID.

```sql
select recommendedby, count(*) from cd.members where recommendedby is not null
	group by recommendedby
order by recommendedby;
```

#### Question 19: Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.

```sql
select facid, sum(slots) as "Total slots" from cd.bookings group by facid order by facid
```

#### Question 20: Produce a list of the total number of slots booked per facility in the month of September 2012. Produce an output table consisting of facility id and slots, sorted by the number of slots.

```sql
select facid, sum(slots) as "Total slots" from cd.bookings  
where starttime >= '2012-09-01' and starttime < '2012-10-01' 
group by facid order by sum(slots) 
```

#### Question 21: Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.

```sql
select facid, extract(month from starttime) as month, sum(slots) as "Total Slots" from cd.bookings
where extract(year from starttime) = 2012
group by facid, month
order by facid, month;
```

#### Question 22: Find the total number of members (including guests) who have made at least one booking.

```sql
select count(distinct memid) as "count" from cd.bookings;
```

#### Question 23: Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.

```sql
select m.surname, m.firstname, m.memid, min(b.starttime) as starttime from cd.members as m join 
cd.bookings as b
on m.memid = b.memid where b.starttime >= '2012-09-01' 
group by m.surname, m.firstname, m.memid
order by m.memid
```

#### Question 24: Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members.

```sql
select (select count(*) from cd.members) as "count", firstname, surname from cd.members 
order by joindate 
```

#### Question 25: Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining. Remember that member IDs are not guaranteed to be sequential.

```sql
select row_number() over(), firstname, surname from cd.members 
order by joindate
```

#### Question 26: Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing results get output.

```sql
select facid, total from (
	select facid, total, rank() over (order by total desc) rank from (
		select facid, sum(slots) total
			from cd.bookings
			group by facid
		) as sumslots
	) as ranked
where rank = 1
```

### String
#### Question 27: Output the names of all members, formatted as 'Surname, Firstname'

```sql
select surname || ', ' || firstname as name from cd.members;
```

#### Question 28: You've noticed that the club's member table has telephone numbers with very inconsistent formatting. You'd like to find all the telephone numbers that contain parentheses, returning the member ID and telephone number sorted by member ID.

```sql
select memid, telephone from cd.members where telephone ~ '[()]';
```

#### Question 29: You'd like to produce a count of how many members you have whose surname starts with each letter of the alphabet. Sort by the letter, and don't worry about printing out a letter if the count is 0.

```sql
select substr (mems.surname,1,1) as letter, count(*) as count 
from cd.members mems
group by letter
order by letter 
```