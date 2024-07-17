use andy;

show tables;
-- Q1. Who is the senior most employee based on job title ?

select * from employee
order by levels desc
limit 1;


-- Q2. Which country have the most invoices ?

select billing_country,count(*) as c
from invoice
group by billing_country
order by c desc;

-- Q3. What are top 3 values of total invoice

select total from invoice
order by total desc
limit 3;


-- Q4. Which city has most customer ? We would like to throw a promotional Song festival in the city we made most money.
-- Write a query that return one city that has highest sum of invoice totals. Return both the city name & sum of all invoice totals.

select sum(total) as invoice_total,billing_city
 from invoice
 group by billing_city
 order by invoice_total desc;
 
-- Q5. Who is the best customer ? The customer who has spent the most money will be declared best customer.
-- Write the query htat returns the person who has spent most money.

select ANY_VALUE(c.customer_id) as id, c.first_name, c.last_name,sum(i.total) as total
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.first_name, c.last_name
order by total desc
limit 1;


-- Moderate level

-- Q1. Write a query to return the email, first name, last name & genre of all rock music listeners.
-- Return your list ordered alphabetically by email starting with A

select c.first_name, c.last_name, c.email,g.name as Genre
from customer c 
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
where g.name = 'Rock'
order by c.email;


-- Q2. Lets invite the artist who has written the most rock music in our dataset. Write a query to return 
-- the artist name and total track count of top 10 rock bands.

select any_value(artist.name),count(album.artist_id) as no_of_song
from album 
join track on album.﻿album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by no_of_song desc
limit 10;


-- Q3. Return all the track names that have song length longer than the average song length.
-- Return the name and milliseconds for each track. Order by song length with highest song listed first.

select milliseconds,name from track 
where milliseconds >(
select avg(milliseconds) from track)
order by milliseconds desc;



-- Advance Query

-- Q1. Find how much amount spent by each customer on artists? 
-- Write a query to return customer name and total spent

with best_selling_artist as(
select any_value(a.artist_id) as artist_id, any_value(a.name) as artist_name,
sum(il.unit_price*il.quantity) as total_sales
from invoice_line il
join track t on t.track_id= il.track_id
join album ab on ab.﻿album_id = t.album_id
join artist a on a.artist_id = ab.artist_id
group by a.artist_id
order by total_sales desc
limit 1
)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album ab on ab.﻿album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = ab.artist_id
group by c.customer_id,c.first_name,c.last_name,bsa.artist_name
order by amount_spent desc;

-- Q2. We want to find out the most popular music genre for each country.
-- we determone the most popular genre as the genre with the highest amount of purchases.
-- Write a query that returns each country along with the top genre.
-- For countries where the maximum number of purchases is shared return all genres.alter

with popular_genre as(
select count(il.quantity) as purchases, c.country, 
g.name, g.genre_id, 
row_number() over(partition by c.country order by count(il.quantity) desc) as rowno
from invoice_line il
join invoice i on i.invoice_id = il.invoice_id
join customer c on c.customer_id = i.customer_id
join track t on t.track_id= il.track_id
join genre g on g.genre_id = t.genre_id
group by c.country, g.name, g.genre_id
order by c.country asc, purchases desc
)
select * from popular_genre where rowno <= 1;

-- Q3. Write a query that determins the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, 
-- provide all customers who spent this amount.

with recursive
	customer_with_country as(
		select c.customer_id, first_name,last_name,billing_country,sum(total) as total_spending
		from invoice i 
		join customer c on c.customer_id = i.customer_id
		group by 1,2,3,4
		order by 2,3 desc),
    
	country_max_spending as(
		select billing_country,max(total_spending) max_spending
		from customer_with_country
		group by billing_country)
    
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;


















