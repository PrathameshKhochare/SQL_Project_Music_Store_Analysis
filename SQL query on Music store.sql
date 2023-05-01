select * from album;


Q.1 Who is the senior most employee based on Job title ?
Ans-
#### select * from employee;

select first_name,last_name,levels,title from employee
order by levels desc
limit 1;
-----------------------------------------------------------------
### Q.2 Which countries has the most Invoices?
select * from invoice;

select billing_country, count(*) from invoice
group by billing_country
order by count(*) desc
limit 3;
-----------------------------------------------------------------
Q.3 What are top 3 values of total invoice?
select * from invoice;

select total from invoice
order by total desc
limit 3;
-----------------------------------------------------------------
Q.4 Which city has best customers? we would like to throw a promotional Music Festival in the city 
we made the most money.Write a query that returns one city that has the highest sum of invoice totals.
Return both the city name and sum of invoice totals
Ans-
select * from invoice;

select billing_city,sum(total) as total_invoice
from invoice
group by billing_city
order by total_invoice desc
limit 1;
----------------------------------------------------------------
Q.5 Who is best customer? The customer who has spent the most money will be declared the best custmer.
Write a query that returns the person who has spent the most money
Ans -
select * from customer;

select c.first_name,c.last_name,(sum(total)) as max_amount_spent
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.first_name,c.last_name
order by sum(total) desc
limit 1;
----------------------------------------------------------------
Q.6 Write query to return email,first_name,last_name and Genre of rock music listeners.
Return your list ordered alphabetically by email starting with A
Ans-
select * from customer;
select * from genre;


select distinct c.email,c.first_name,c.last_name
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
where t.track_id in
	 (select track_id from track t
	 join genre g on g.genre_id = t.genre_id
	 where g.name = 'Rock')
order by email;	
-------------------------------------------
or 
-----------------

select distinct c.email,c.first_name,c.last_name
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
where il.track_id in
	 (select track_id from track t
	 join genre g on g.genre_id = t.genre_id
	 where g.name like 'Rock')
order by email;	 
-----------------------------------------------------------------------
Q.7 Lets invite the artits who have written the mock rock music in our dataset.
Write a query that returns the artists name and total track count of top 10 rock bands.
Ans-
select * from artist
select * from track


select a.artist_id,at.name,count(a.artist_id) as total_artists_count
from track t
join album a on t.album_id = a.album_id
join artist at on a.artist_id = at.artist_id
where t.genre_id in 
    (select genre_id from genre
     where name like 'Rock')
group by a.artist_id,at.name
order by total_artists_count desc
limit 10;
--------------------------------------------------------------------------
Q8. Return all the track names that have a song length longer than the average song length.
Return the name and millliseconds for each track.
order by the song length with the longest songs listed first
Ans-
select * from track
select * from playlist

select name,milliseconds
from track 
where milliseconds > (select avg(milliseconds) as avg_length from track)
order by milliseconds desc;

--------------------------------------------------------------------------
Q.9 Find how much amount spent by each customer on artists? write a query to return customer name,
artist name and total spent
Ans-
select * from customer


WITH best_selling_artist AS (
	select ar.artist_id , ar.name AS artist_name , sum(il.unit_price * il.quantity) as total_spent
	from invoice_line il join track t on t.track_id = il.track_id
	join album a on a.album_id = t.album_id
	join artist ar on ar.artist_id = a.artist_id
	group by 1
	order by 3 desc
	limit 1
)

select c.first_name, c.last_name,bst.artist_name,sum(il.unit_price * il.quantity) as total_spent
from 
customer c join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on t.track_id = il.track_id
join album a on a.album_id = t.album_id
join best_selling_artist bst on a.artist_id = bst.artist_id
group by 1,2,3
order by 4 desc;

--------------------
/# Q. 10 We want find out most popular music Genre for each country.
we determine the most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top genre.
For countries where maximum number of purcheses is shared return all genres. #//
Ans-

select * from genre


WITH best_selling_genre AS (
	select c.country,gr.genre_id,gr.name AS genre_name , count(il.quantity) as purchases,
	Row_Number() over (partition by c.country order by count(il.quantity) desc) as rowno
	from invoice_line il join track t on t.track_id = il.track_id
	join genre gr on gr.genre_id = t.genre_id
	join invoice i on i.invoice_id = il.invoice_id
	join customer c on c.customer_id = i.customer_id
	group by 1,2,3
	order by 1 asc,4 desc
)

select * from best_selling_genre where rowno <= 1;

--------------------------------------------------------------------------------
Q.11 Write the query that determines the customer that has spent the most on music for each country.
write a query that returns the country along with the top customrer and how much they spent.
for countries where top amount spent is shared,provide all the customres who spent this amount
Ans- 

with top_customer_per_country as (
    select c.first_name,c.last_name,c.country,sum(il.quantity * il.unit_price) as total_spent,
	row_number () over (partition by c.country order by sum(il.quantity * il.unit_price) desc) as rowno
	from customer c join invoice i on c.customer_id = i.customer_id
    join invoice_line il on i.invoice_id = il.invoice_id
	group by 3,1,2
	order by 3,4 desc
)
select * from top_customer_per_country where rowno <= 1;

----------------------
