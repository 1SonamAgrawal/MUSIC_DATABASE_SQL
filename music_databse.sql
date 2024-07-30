-- who is the senior most employee based on job title?
 select * from employee
 order by levels desc limit 1
 
-- which countries have the most invoices?
 
 -- select * from invoice
 select count(*), billing_country from invoice
 group by billing_country
 order by count(*) desc
 
-- what are top 3 values of total invoice ?
 
 select total from invoice
 order by total desc limit 3
 
-- which city has the best customers?
 -- we would like to throw a promotional music festival in the city
 -- we made the most money. write a query that returns one city that
 -- has the highest sum of invoice totals. return both the city name
 -- $ sum of all invoice totals.
 
 -- select * from invoice
 select sum(total) as invoice_total, billing_city from invoice
 group by billing_city
 order by invoice_total desc limit 1
 
 -- 5. who is the best customer? the customer who has spent the most
 -- money will be declared the best customer. write a query that returns
 -- the person who has spent the most money.
 
 -- select * from customer
 
 select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
 from customer
 join invoice on customer.customer_id = invoice.customer_id
 group by customer.customer_id
 order by total desc limit 1
 
 -- write query to return the emails, first name, last name & genre of all 
-- rock music listeners. return your list orderes alphabetically by email
 -- starting with A
 
 -- select * from customer
 -- select * from genre
 
 select distinct email, first_name, last_name from customer
 join invoice on customer.customer_id = invoice. customer_id
 join invoice_line on invoice.invoice_id = invoice_line.invoice_id
 where track_id in (
	 select track_id from track
     join genre on track.genre_id = genre.genre_id
     where genre.name= 'Rock')
order by email asc;


-- let's invite the artists who have written the most rock music in our 
-- dataset. write a query that reutrns the artist name and total track count
-- of the top 10 rock bands.
-- select * from artist
-- select * from genre
-- select * from track

select  artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

-- return all the track names that have a song length longer 
-- than the average song length. return the name and millliseconds
-- for each track. order by the song length with the longest songs
-- listed first.
-- select * from track

select name, milliseconds from track 
where milliseconds > (
    select avg(milliseconds) as avg_length
    from track
    )
order by milliseconds desc;

-- find how much amount spent by each customer on artists? write a
-- query to return customer name, artist name and total spent
with best_selling_artist as (
	select artist.artist_id as id, artist.name as namee, sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by id
	order by total_sales desc
	limit 1
  )
select c.customer_id, c.first_name, c.last_name, bsa.namee, sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

-- we want to find out the most popular music genre for each country.
-- we determine the most popular genre as the genre with the highest 
-- amount of purchases. write a query that returns each country along
-- with the top genre. for countries where the maximum number of purchases
-- is shared return all genres.
with popular_genre as(
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
