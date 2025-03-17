/*In this project, you’ll be tasked to analyze real-world NFT data. 
That data set is a sales data set of one of the most famous NFT projects, Cryptopunks. Meaning each row of the data set represents a sale of an NFT. The data includes sales from January 1st, 2018 to December 31st, 2021. The table has several columns including the buyer address, the ETH price, the price in U.S. dollars, the seller’s address, the date, the time, the NFT ID, the transaction hash, and the NFT name.
You might not understand all the jargon around the NFT space, but you should be able to infer enough to answer the following prompts.*/
 
Use heroes;
#Exploration
/*Select count(1) from pricedata; #19920
show columns in pricedata;
Select * from pricedata limit 10;
Select min(event_date), max(event_date) from pricedata;
Select count(distinct token_id) from pricedata;
Select count(distinct name) from pricedata;
Select count(distinct transaction_hash) from pricedata;*/
 
#1. How many sales occurred during this time period?
Select count(1) from pricedata;

/*2. Return the top 5 most expensive transactions (by USD price) for this data set. Return the name, ETH price, and USD price, 
as well as the date.*/
Select name, eth_price, usd_price, event_date from pricedata 
order by usd_price desc limit 5;

/*3. Return a table with a row for each transaction with an event column, a USD price column, and a moving average of 
USD price that averages the last 50 transactions.*/
Select name, usd_price, avg(usd_price) over (order by event_date rows between 50 preceding and current row)
from pricedata;

#4. Return all the NFT names and their average sale price in USD. Sort descending. Name the average column as average_price.
Select name, avg(usd_price) as average_price from pricedata
group by name order by average_price desc;

/*5. Return each day of the week and the number of sales that occurred on that day of the week, as well as the
 average price in ETH. Order by the count of transactions in ascending order.*/
 Select dayofweek(event_date), count(1), avg(eth_price) from pricedata
 group by dayofweek(event_date) order by 2;

/*6. Construct a column that describes each sale and is called summary. The sentence should include who sold the NFT name, 
who bought the NFT, who sold the NFT, the date, and what price it was sold for in USD rounded to the nearest thousandth.
 Here’s an example summary:
 “CryptoPunk #1139 was sold for $194000 to 0x91338ccfb8c0adb7756034a82008531d7713009d from 0x1593110441ab4c5f2c133f21b0743b2b43e297cb on 2022-01-14”
*/
Select concat(name,' was sold for $', usd_price,' to ', buyer_address, ' from ', seller_address, ' on ', event_date) from pricedata;

#7. Create a view called “1919_purchases” and contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.
Create view 1919_purchases as
Select * from pricedata where buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

#8. Create a histogram of ETH price ranges. Round to the nearest hundred value.
Select round(eth_price,-2) as bucket, count(1) as count, rpad('', count(1), '*') from pricedata
group by bucket order by bucket;

/*9. Return a unioned query that contains the highest price each NFT was bought for and a new column called status 
saying “highest” with a query that has the lowest price each NFT was bought for and the status column saying “lowest”. 
The table should have a name column, a price column called price, and a status column. Order the result set by the name of the NFT, 
and the status, in ascending order. */
Select name, max(usd_price) as price, 'highest' as status from pricedata group by name
Union
Select name, min(usd_price) as price, 'lowest' as status from pricedata group by name
order by name, status;

#10. What NFT sold the most each month / year combination? Also, what was the name and the price in USD? Order in chronological format.
Select name, year(event_date), month(event_date), sum(usd_price) from pricedata
group by name, year(event_date), month(event_date) order by 2,3,1;

#11. Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year).
Select round(sum(usd_price),-2) from pricedata
group by year(event_date), month(event_date);

#12. Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.
Select count(1) from pricedata
where seller_address='0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685' or buyer_address='0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

/*13. Create an “estimated average value calculator” that has a representative price of the collection every day based off of these criteria:
 - Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
 - Take the daily average of remaining transactions
 a) First create a query that will be used as a subquery. Select the event date, the USD price, and the average USD price 
 for each day using a window function. Save it as a temporary table.
 b) Use the table you created in Part A to filter out rows where the USD prices is below 10% of the daily average and 
 return a new estimated value which is just the daily average of the filtered data.
 */

 Create temporary table `estimated average value calculator`
 Select event_date, usd_price, avg(usd_price) over (partition by event_date) as daily_average from pricedata;
 
 Select event_date,usd_price, avg(usd_price) over (partition by event_date) as daily_average  from `estimated average value calculator`
 where usd_price > (10/100)*daily_average;
 
 
 