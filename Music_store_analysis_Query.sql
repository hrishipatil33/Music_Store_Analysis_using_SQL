-- 1. Who is the senior most employee based on job title?
-- Ans-

select * from employee 
order by levels desc 
limit 1


-- Q2 Which countries have the most Invoices?
-- Ans
select billing_country,count(*)as c 
from invoice 
group by billing_country 
order by c desc


-- Q3 What are top 3 values of total invoice?
-- Ans

select total from invoice
 order by total desc
  limit 1


-- Q4 Which city has the best customers? We would like to throw a promotional Music
-- Festival in the city we made the most money. Write a query that returns one city that
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice
-- totals
-- Ans
select billing_city,sum(total)as totalsum 
from invoice
group by billing_city 
order by totalsum desc


-- Q5 Who is the best customer? The customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money
-- Ans

select c.customer_id,c.first_name,c.last_name,sum(t.total) as total 
from customer c
join invoice t on c.customer_id=t.customer_id 
group by c.customer_id 
order by  total desc
limit 1

                       --Question Set 2 – Moderate--
-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music
-- listeners. Return your list ordered alphabetically by email starting with A
--Ans
select e.email,e.first_name,e.last_name from customer e join invoice i
on e.customer_id=i.customer_id
join invoice_line l on i.invoice_id=l.invoice_id
where track_id in(
select track_id from track t
join genre g on t.genre_id=g.genre_id 
where g.name like 'Rock')
order by email;


-- Q2. Let's invite the artists who have written the most rock music in our dataset. Write a
-- query that returns the Artist name and total track count of the top 10 rock bands\
-- Ans
select a.artist_id,a.name ,count(al.title) as cnt from artist a 
join album al on a.artist_id=al.artist_id
join track t on al.album_id=t.album_id
join genre g on t.genre_id=g.genre_id 
where g.name like 'Rock'
group by a.artist_id order by cnt desc limit 10


-- Q3. Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the
-- longest songs listed first
-- Ans
select name , milliseconds from track 
where milliseconds>(
select avg(milliseconds) as milisec 
from track)
order by milliseconds desc;

                         --Question Set 3 – Advance
-- 1. Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent
-- Ans
with best_sales_artist as(
select a.artist_id as artist_id, a.name as name ,
sum(il.unit_price*il.quantity) as total_sum
from invoice_line il
join track t on t.track_id=il.track_id
join album al on al.album_id=t.album_id
join artist a on a.artist_id=al.artist_id
group by a.artist_id order by total_sum desc limit 1)

select c.customer_id, c.first_name, c.last_name,bsa.name,
sum(il.unit_price*il.quantity) as total_sum from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on il.track_id=t.track_id
join album al on al.album_id=t.album_id
join best_sales_artist bsa on  al.artist_id=bsa.artist_id
group by c.customer_id,c.first_name, c.last_name,bsa.name
order by total_sum desc

-- 2. We want to find out the most popular music Genre for each country. We determine the
-- most popular genre as the genre with the highest amount of purchases. Write a query
-- that returns each country along with the top Genre. For countries where the maximum
-- number of purchases is shared return all Genres
-- Ans
with popular_genre as(

select count(il.quantity)as purchase,c.country,g.name,g.genre_id,
ROW_NUMBER() OVER(partition by c.country order by count(il.quantity) desc)as row_no
from invoice_line il
join invoice i on il.invoice_id=i.invoice_id
join customer c on i.customer_id=c.customer_id
join track t on t.track_id=il.track_id
join genre g on g.genre_id=t.genre_id
group by 2,3,4
	order by 2 asc,1 desc
)
select * from popular_genre where row_no<=1

-- Q3. Write a query that determines the customer that has spent the most on music for each
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all
-- customers who spent this amount
-- Ans
with recursive customer_w_country as(
select c.customer_id,c.first_name,c.last_name,i.billing_country,sum(total)as total_Spend
from invoice i
join customer c on c.customer_id=i.customer_id
group by 1,2,3,4
order by 1,5 desc),

country_max_spend as(
select billing_country,max(total_Spend) as max_spend
from customer_w_country
group by billing_country)

select cw.billing_country,cw.total_Spend,cw.first_name,cw.last_name,cw.customer_id
from customer_w_country cw
join country_max_spend ms 
on cw.billing_country=ms.billing_country
where cw.total_spend=ms.max_spend
order by 1
                             or


with customer_w_country as(
select c.customer_id, c.first_name,c.last_name,i.billing_country ,sum(total)as total_spend,
row_number() over(partition by i.billing_country order by sum(total)desc)as row_no
from invoice i 
join customer c on c.customer_id=i.customer_id
group by 1,2,3,4
order by 4 asc,5 desc)

select * from customer_w_country where row_no<=1