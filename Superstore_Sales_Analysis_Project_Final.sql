/***************************************
****************************************
SUPERSTORE SALES ANALYSIS

Objective: Determine if the business is doing better or worse YoY, 
and create other business questions to explore.

By: Yuri Oh

Data provided by WeCloudData

****************************************
****************************************
A. Creating the database and the product, orders, customer, and returns tables
B. Exploring the timeframe and dates of the data
C. Exploring top profit, expenses, sales, orders and avearages per year
D. Exploring Customer Info 
E. Exploring the top sales, products, and customer info per year
F. Conclusion
G. Miscellaneous Queries
###########################################################################

/***************************************
# A. First, I created the superstore database in which to store the tables
****************************************/

show databases;

drop database if exists superstore;

create database superstore;

use superstore;

/********************************
 # Then, I created the 4 necessary tables to store the data stored in the csv files.
 - created the product, orders, customer, and returns tables
********************************/

show tables;    # Made sure there were no tables created yet in the database

# A.1 Created the framework and data types for the PRODUCT table:

drop table if exists superstore.product;
create table superstore.product (
    ProductID            int,
    ProductName	         varchar(200),
    ProductCategory	     varchar(20),
    ProductSubCategory	 varchar(50),
    ProductContainer	 varchar(20),
    ProductBaseMargin	 decimal(4,2),
    PRIMARY KEY	(ProductID)
);

# Checked the table and data types I created
describe superstore.product; 

# Cleared any data in this table to avoid repeated insertion of same data
truncate superstore.product; 

# Next, I populated the product table by loading the data from the product.csv file
load data local infile 'C:/Users/Yuri/Google Drive/WCD-Toolbox-B5-SQL/data/superstore/product_new.csv'
into table superstore.product character set latin1
fields terminated by '\t'
lines terminated by '\n'
;

# Checked first several rows of newly created table to ensure data loaded properly
select * from superstore.product order by productID asc limit 50;  

# Checked that count of data matched that of csv file; counted 1,234 rows of data
select count(*) from superstore.product; 


# A.2 Created the framework and data types for the ORDERS table:

drop table if exists superstore.orders;
create table superstore.orders (
	OrderID Int,
    ProductID int,
    CustomerID int,
    OrderDate Date,
    OrderPriority VARCHAR(20),
    OrderQuantity int,
    Sales decimal (15,5),
    Discount decimal (3,2),
    ShipMode VARCHAR (20),
    Profit decimal (15,2),
    UnitPrice decimal (15,2),
    ShippingCost decimal (15,2)
);

describe superstore.orders;
truncate superstore.orders;

# Loaded orders.csv into superstore.orders table

load data local infile 'C:/Users/Yuri/Google Drive/WCD-Toolbox-B5-SQL/data/superstore/orders_new.csv'
into table superstore.orders character set latin1
fields terminated by '\t'
lines terminated by '\n'
;

select * from superstore.orders order by orderdate asc; 
select count(*) from superstore.orders; 
# 8060 rows of data counted

# A.3 Created and loaded the CUSTOMER table:

drop table if exists superstore.customer;
create table superstore.customer (
  CustomerID int,
  CustomerName varchar(50),
  Province varchar (50),
  Region varchar (50),
  CustomerSegment Varchar(20),
  Primary Key (CustomerID)
);

truncate superstore.customer;

# Loaded customer.csv into superstore.customer table

load data local infile 'C:/Users/Yuri/Google Drive/WCD-Toolbox-B5-SQL/data/superstore/customer_new.csv'
into table superstore.customer character set latin1
fields terminated by '\t'
lines terminated by '\n'
;
       
select * from superstore.customer limit 10;
select count(*) from superstore.customer;

# 1832 rows of data counted

# A.4 Created and loaded the RETURNS table:

drop table if exists superstore.returns;
create table superstore.returns (
		OrderID Int,
        status varchar (45)
);

truncate superstore.returns;

# Loaded returns.csv into superstore.returns table

load data local infile 'C:/Users/Yuri/Google Drive/WCD-Toolbox-B5-SQL/data/superstore/returns_new.csv'
into table superstore.returns character set latin1
fields terminated by '\t'
lines terminated by '\n'
;      

select * from superstore.returns limit 10;
select count(*) from superstore.returns;
# 572 rows of data counted

/***************************************
# B. I then explored the timeframe and dates of the data
 ***************************************/

# B.1 How many years of transactions are there? 
-- The orders table is the only one with dates.  
select distinct YEAR(OrderDate)
from superstore.orders;
-- There are 4 years of transaction records (2009, 2010, 2011, 2012).


# B.2 What are the dates of the first and last orders placed? 
select orderdate from superstore.orders 
order by orderdate asc limit 5;
-- 2009-01-01 is the first date of transactions

select orderdate from superstore.orders 
order by orderdate desc limit 5;
-- 2012-12-30 is the last date of transactions

-- Thus, the range of orders is from January 1, 2009 to December 30, 2012.

# B.3 Are there consistent orders throughout the year for each year?
select year(OrderDate) as OrderYear,
	   month(OrderDate) as OrderMonth,
       day(OrderDate) as OrderDay
from superstore.orders
group by year(OrderDate), month(OrderDate), day(OrderDate)
order by year(OrderDate), month(OrderDate), day(OrderDate);

-- Results returning twelve distinct months per year and 28 to 31 days per month each year
-- demonstrate that there are no substantial gaps in data in terms of logging order information.

/***************************************
# C. I then explored the top profit, expenses, sales, orders and avearages per year
 ***************************************/

# C.1 What is the total profit per year?
select year(OrderDate) as OrderYear,
       sum(profit) as TotalProfit
from superstore.orders
group by year(OrderDate) order by orderyear desc;
/*
2012	334558.27
2011	370214.31
2010	364371.07
2009	416346.00  */

-- 2009 had the highest Total Profit while 2012 had the smallest.


# C.2 What is the YoY Profit Growth rate?
# 2009 to 2010
select (((select sum(profit) from superstore.orders where year(orderdate)=2010)-(select sum(profit) from superstore.orders where year(orderdate)=2009))
/(select sum(profit) from superstore.orders where year(orderdate)=2009)) as ProfitGrowthRate from superstore.orders;
# 2010 to 2011
select (((select sum(profit) from superstore.orders where year(orderdate)=2011)-(select sum(profit) from superstore.orders where year(orderdate)=2010))
/(select sum(profit) from superstore.orders where year(orderdate)=2010)) as ProfitGrowthRate from superstore.orders;
# 2011 to 2012
select (((select sum(profit) from superstore.orders where year(orderdate)=2012)-(select sum(profit) from superstore.orders where year(orderdate)=2011))
/(select sum(profit) from superstore.orders where year(orderdate)=2011)) as ProfitGrowthRate from superstore.orders;

/* Manually calculated to check results, which did match the above:
2009-2010: (364371.07-416346.00) / 416346.00 = -0.125 = -12.5% 
2010-2011: (370214.31-364371.07) / 364371.07 = 0.016 = 1.6% 
2011-2012: (334558.27-370214.31) / 370214.31 = -0.096 = -9.6% 
*/
-- In terms of YOY profit growth rate, there has been a negative growth rate for most years, 
-- meaning that although the business has been earning a positive profit for all four years, 
-- the profit amount is shrinking. This alone doesn’t conclusively indicate whether the business is 
-- doing well or not, as factors such as expansion of the business or economic recession can affect the profits.


# C.4.1	With shipping cost being the only expense data available, what is the total shipping cost per year?

select year(orderdate) as orderyear, 
	sum(shippingcost) as totalshipping 
from superstore.orders
group by year(orderdate) order by orderyear desc;

# C.4.2 What is the change in shipping cost YoY?
select (((select sum(shippingcost) from superstore.orders where year(orderdate)=2010)-(select sum(shippingcost) from superstore.orders where year(orderdate)=2009))
/(select sum(shippingcost) from superstore.orders where year(orderdate)=2009)) as ChangeInShippingCost from superstore.orders;

select (((select sum(shippingcost) from superstore.orders where year(orderdate)=2011)-(select sum(shippingcost) from superstore.orders where year(orderdate)=2010))
/(select sum(shippingcost) from superstore.orders where year(orderdate)=2010)) as ChangeInShippingCost from superstore.orders;

select (((select sum(shippingcost) from superstore.orders where year(orderdate)=2012)-(select sum(shippingcost) from superstore.orders where year(orderdate)=2011))
/(select sum(shippingcost) from superstore.orders where year(orderdate)=2011)) as ChangeInShippingCost from superstore.orders;

/*
% change in shipping cost YOY 
2009-2010 = -5.6%
2010-2011 = -9.9% 
2011-2012 = 10.6% 

During consistent periods of negative growth rate YOY for profit, shipping costs (the only expense indicated) 
actually decreased from 2009-2011. Assuming there was no business expansion or big investments made, 
that means revenue in total had to have decreased. This can indicate that for 2009, 2010, and 2011 the 
number of items ordered and/or mass of items ordered decreased (leading to both decreased shipping costs and profits), 
the profit margins of the ordered products were smaller, the cost of shipping itself decreased (fuel costs, 
more efficient logistics routes etc) and/or the discounts used also increased (reducing the profit margins).
*/

# C.5 What are the cumulative sales, quantity of items ordered, total number of orders, 
# average sales per order, average discount rate, and average unit price of items sold per year?

select year(OrderDate) as OrderYear, 
	sum(Sales) as TotalSales, 
    sum(orderquantity) as TotalQuantity, 
	count(orderid) as TotalOrders,
    sum(Sales)/count(orderid) as AvgSalesPerOrder,
    Avg(discount) as AvgDiscount, 
    Avg(UnitPrice) as AvgPrice
from superstore.orders
group by OrderYear 
order by OrderYear desc;

/* 
OrderYear 	TotalSales	  TotalQuantity  TotalOrders 	AvgSalesPerOrder AvgDiscount	AvgPrice
2012		3356203.19100	 52320			2020		1661.486728217	  0.049807		90.311124
2011		3107206.25950	 49363			1911		1625.958272893	  0.050801		76.116431
2010		3177019.94800	 52252			2056		1545.243165369 	  0.049339		71.315851
2009		3930381.23000	 52325			2073		1895.987086348	  0.048833		106.146059
*/

-- The maximum of total sales occurred in 2009, followed by 2012, 2010, then 2011. 
-- The maximum count of orders occured in 2009, followed by 2010, 2012, then 2011.
-- The maximum average sales per order occured in 2009, followed by 2012, 2011, then 2010.
-- Generally, 2009 performed best in terms of sales and orders, which both overall declined in subsequent years.
-- Overall analysis:
/*The total sales, total quantity of items ordered, and total number of orders placed YoY between 2009 and 2010 
consistently decreased as did the profits. Moreover, the average price of items purchased decreased during that 
period from 106.14 to around 73.5, while the average discount provided to customers increased each year (both resulting in lower revenue). 
-Although shipping costs may have decreased from 2009-2010, it's possible that having fewer orders and perhaps shipping 
lighter items may have contributed to that decrease. 
-Although total sales, total quantity of items ordered and total orders increased from 2011 to 2012, the shipping costs also
increased while profit decreased, so that increase is marginal. The increase in average price to 90.31 also doesn’t meet the 
initial higher average price of 106.14.*/


# C.6 How many orders got returned each year and what is the yearly revenue loss due to the product returns?
select year(OrderDate) as Year,
	count(distinct OrderID) as TotalOrdersReturned, 
	sum(Sales) as SalesLost 
from superstore.orders
where OrderID in (select distinct OrderID 
                              from superstore.returns)
group by Year;
/*
Year  TotalOrdersReturned	SalesLost
2009	147					477143.48950
2010	141					361132.18400
2011	135					245510.31300
2012	135					401921.74500
-- The number of Orders returned and Sales Revenue lost decreased each year,
-- except for an increase in sales lost in 2012. However, I did not have enough
-- info on whethere these figures were already included Profit/Sales in the Orders table.


/***************************************
# D. I then further explored the customer data
 ***************************************/

# D.1 What is the biggest customer segment? 

select CustomerSegment, 
       count(distinct CustomerID) 
from superstore.customer
group by CustomerSegment
order by count(distinct CustomerID) desc;

-- The Corporate segment was the largest with 662 unique customers, 
-- followed by the Home office segment with 420 customers,
-- then the Consumer segment with 376 customers,
-- and lastly the Small Business segment with 374 customers.

# D.2 Which customer segment did the top 10 customers with the most total orders belong to?

select a.CustomerID, 
      count(distinct a.OrderID) as TotalOrders,
      b.CustomerSegment
from superstore.orders a
	inner join superstore.customer b
	on a.CustomerID = b.CustomerID
group by CustomerID
order by TotalOrders Desc
limit 10;

/* 
CustomerID TotalOrders CustomerSegment
32605811	16			Home Office
79423257	16			Home Office
98758480	15			Consumer
58189342	14			Corporate
90514203	13			Home Office
36255546	13			Home Office
107565533	12			Corporate
56764115	12			Small Business
79337791	12			Home Office
29705839	12			Consumer
*/

-- There were 5 of 10 top customers in the Home Office segment, followed by
-- two Consumer and two Corporate, then one Small Business.


# D.3.1 How many total orders and sales were generated by each customer segment?
select b.CustomerSegment,
	count(distinct a.OrderID) as TotalOrders,
    sum(a.sales) as TotalSales
from superstore.orders a
	inner join superstore.customer b
	on a.CustomerID = b.CustomerID
group by CustomerSegment
order by TotalSales desc;

/*
CustomerSegment   TotalOrders   TotalSales
Corporate		 	  1959		5069948.53950
Home Office			  1306		3191802.13450
Consumer			  1050 		2841460.52500
Small Business	 	  1046		2467599.42950  */

-- The Corporate Segment generated the most total sales and total number of orders,
-- followed by Home Office, Consumer, and Small Business in last place.

# D.3.2 How many total orders and sales were generated by each customer segment per year? 
select year(a.orderdate) as Year,
	b.CustomerSegment,
	count(distinct a.OrderID) as TotalOrders,
    sum(a.sales) as TotalSales
from superstore.orders a
	inner join superstore.customer b
	on a.CustomerID = b.CustomerID
group by CustomerSegment, year
order by year asc, totalsales desc;
/*
Year   CustomerSeg	 TotalOrders  TotalSales

2009	Corporate		507		1426222.56950
2009	Consumer		278		947432.09800
2009	Home Office		324		909454.37450
2009	Small Business	255		647272.18800

2010	Corporate		483		1124388.62700
2010	Home Office		323		876163.33500
2010	Consumer		275		618435.04050
2010	Small Business	274		558032.94550

2011	Corporate		457		1109191.77650
2011	Home Office		319		707903.38500
2011	Consumer		254		663425.19850
2011	Small Business	248		626685.89950

2012	Corporate		512		1410145.56650
2012	Home Office		340		698281.04000
2012	Small Business	269		635608.39650
2012	Consumer		243		612168.18800
*/
/*
-Corporate Sales and Total Orders decreased each year, except for an increase in both in 2012.
-Consumer Sales and Total Orders decreased each year, except for an increase in Sales generated in 2011, 
 likely due to sales of more expensive products.
-Home Office Sales and Total Orders decreased each year, except of an increase in Total Orders in 2012,
 likely due to sales of less expensive products.
-Small Business Total Orders increased each year, except for a decrease in 2011; 
-Small Business Sales decreased then increased, overall showing a less consistent pattern.

-- Overall, the trends demonstrated in each customer segment per year mirror the overall trends seen 
   in profit and sales YoY.
*/
# D.4 Which province has the most number of Corporate customers? 
	
select province, 
	count(customersegment) as countCS
from superstore.customer 
	where lower(customersegment)like '%corporate%'
group by province
order by countCS desc limit 5;

-- Ontario has the most Corporate customers with 120, followed by BC with 80 and Quebec with 71.

/***************************************
# E. I then explored the top sales, products, 
and customer info per year
 ***************************************/

# E.1 How much sales was generated by the top five orders placed in 2009?
select * from superstore.orders
	where year(orderdate)=2009
	order by sales desc limit 5;

-- The top five orders were made in January, March, and December and yielded sales of 
-- $89,061.05, $45,923.76, $28,359.40, $28,180.08, and $27,820.34. 

	# E.1.1 What were the top products ordered in the above top sales orders for 2009?
select * from superstore.product 
	where productid=147664 
	or productid=147664
	or productid=260366 
	or productid=751161 
	or productid=1005949;

-- The products were: two Polycom ViewStationª ISDN Videoconferencing Units,
-- a Polycom ViaVideoª Desktop Video Communications Unit,
-- a "Riverside Palais Royal Lawyers Bookcase, Royale Cherry Finish",
-- and a Hewlett Packard LaserJet 3310 Copier
-- in the Technology and Furniture product categories.

	# E.1.2 Who were the top customers that placed these orders?
select * from superstore.customer
	where customerid=39007820
	or customerid=104752832
	or customerid=19646967
	or customerid=67636836
	or customerid=92656557;

-- The customers were from Saskachewan, New Brunswick, Nova Scotia and Quebec
-- under the Corporate, Consumer, and Home Office customer segments.


# E.2 How much sales was generated by the top five orders placed in 2010?
select * from superstore.orders
	where year(orderdate)=2010
	order by sales desc limit 5;

-- The top five orders were made in January, June, and October and yielded sales of 
-- $29,884.60, $28,761.52, $28,389.14, $27,875.54, and $25,313.34. 

	# E.2.1 What were the products ordered in the above top sales orders for 2010?
select * from superstore.product 
	where productid=125839 
	or productid=360858 
	or productid=751161 
	or productid=125839
	or productid=772761;
    
-- The products were: two Canon Image Class D660 Copiers,
-- a Canon imageCLASS 2200 Advanced Copier,
-- a "Riverside Palais Royal Lawyers Bookcase, Royale Cherry Finish",
-- and an Okidata ML591 Wide Format Dot Matrix Printer
-- in the Technology and Furniture product categories.

	# E.2.2 Who were the top customers that placed these orders?
select * from superstore.customer
	where customerid=60814472
	or customerid=19360668
	or customerid=58178202
	or customerid=79088641
	or customerid=107565533;

-- The customers were from Manitoba, Alberta, British Columbia, and New Brunswick
-- under the Home Office, Consumer, and Corporate customer segments.

# E.3 How much sales was generated by the top five orders placed in 2011?
select * from superstore.orders
	where year(orderdate)=2011
	order by sales desc limit 5;
    
-- The top five orders were made in January, March, July, and November and yielded sales of 
-- $29,345.27, $29,186.49, $28,664.52, $27,720.98, and $27,663.92. 

	# E.3.1 What were the products ordered in the above top sales orders for 2011?
select * from superstore.product 
	where productid=751161 
	or productid=49746 
	or productid=1005949 
	or productid=1005949
	or productid=360858;
    
-- The products were: a "Hewlett-Packard Business Color Inkjet 3000 [N, DTN] Series Printers",
-- a Canon imageCLASS 2200 Advanced Copier,
-- a "Riverside Palais Royal Lawyers Bookcase, Royale Cherry Finish",
-- and a Hewlett Packard LaserJet 3310 Copier
-- in the Technology and Furniture product categories.

	
    # E.3.2 Who were the top customers that placed these orders?
select * from superstore.customer
	where customerid=91042485
	or customerid=10406639
	or customerid=35250192
	or customerid=38079848
	or customerid=71445870;
    
-- The customers were from Saskachewan, Manitoba, Alberta, and British Columbia
-- under the Corporate, Small Business, and Consumer customer segments.

# E.4 How much sales was generated by the top five orders placed in 2012?
select * from superstore.orders
	where year(orderdate)=2012
	order by sales desc limit 5;
    
-- The top five orders were made in January, May, and December and yielded sales of 
-- $41,343.21, $33,367.85, $24,701.12, $24,559.91, and $24,391.16. 

	# E.4.1 What were the products ordered in the above top sales orders for 2012?
select * from superstore.product 
	where productid=147664 
	or productid=360858 
	or productid=528974 
	or productid=515534
	or productid=751161;

-- The products were: a Polycom ViewStationª ISDN Videoconferencing Unit,
-- a Canon imageCLASS 2200 Advanced Copier,
-- a Panasonic KX-P3626 Dot Matrix Printer,
-- a Global Troyª Executive Leather Low-Back Tilter
-- and a "Riverside Palais Royal Lawyers Bookcase, Royale Cherry Finish"
-- in the Technology and Furniture product categories.

	# E.4.2 Who were the top customers that placed these orders?
select * from superstore.customer
	where customerid=67304326
	or customerid=23905406
	or customerid=28488718
	or customerid=30238656
	or customerid=67879495;
    
-- The customers were from Quebec and Saskachewan
-- under the Corporate, Small Business, and Home Office customer segments.

### Overall, the top order placed in 2009 of $89,061.05 was substantially higher than the top orders
### from the subsequent years, which were below $30,000 in 2010 and 2011 and $41,343.21 in 2012.

### One of the top 5 orders of each year was consistently placed in January and November/Decemnber,
### but there didn't seem to be any seasonality in terms of orders.

### Products like videoconferencing units, copiers, and bookshelves from the Technology and Furniture 
### product categories were consistently the top products ordered each year.


# E.5 On which day of week was the biggest sales order made? What was the product? 

select dayofweek(orderdate) as OrderDay, 
	OrderDate, ProductID
	from superstore.orders
	where sales in (select max(sales) from superstore.orders);

select * from superstore.product where productid=147664;

-- The largest sale was made on Saturday, March 21, 2009 for the Polycom ViewStationª ISDN Videoconferencing Unit.



/***************************************
# F. Conclusion about YoY Performance
 ***************************************/
 /*
-- I concluded that Superstore's YoY performance from 2009 to 2012 generally worsened given that:
-- In terms of YOY profit, there was a negative growth rate for most years.
-- The total sales, total quantity of items ordered, and total number of orders placed YoY also geerally decreased. 
-- Moreover, the average price of items purchased decreased while the average discount provided to customers 
   increased each year, both resulting in lower revenue YoY. 
-- Although total sales, total quantity of items ordered and total orders increased from 2011 to 2012, the shipping costs also
   increased while profit decreased, so that increase is marginal. The increase in average price of ordered items to 90.31 also 
   didn’t meet the initial higher average price of 106.14 in 2009.
-- There were no outstanding changes in the number of customers purchasing and customers compositions per year.
*/


/***********************************
# G. Miscellaneous Queries
 ***********************************/

# G.1 Add a Return column to the orders table to indicate if the order has been returned

drop table if exists superstore.orders_1;
create table superstore.orders_1 as
select a.*, 
          case when b.Status is not null then 'Returned' 
                  else 'Not Returned' 
		  end as ReturnStatus
from superstore.orders a
	left join superstore.returns b
	on a.OrderID = b.OrderID
;

select OrderID, ProductID, CustomerID, OrderDate, ReturnStatus
from superstore.orders_1 
order by OrderDate 
limit 50;

select count(*) from superstore.orders_1; # 8060
select count(*) from superstore.orders; # 8060

# G.2 What are the smallest and largest order quantities and sales by year and month?

select year(OrderDate) as OrderYear,
	   month(OrderDate) as OrderMonth,
       min(OrderQuantity) as MinOrderQuantity,
       max(OrderQuantity) as MaxOrderQuantity,
       min(Sales) as MinSales,
       max(Sales) as maxSales
from superstore.orders
group by year(OrderDate), month(OrderDate)
order by year(OrderDate), month(OrderDate);

# G.3 Which Shipping Mode has the highest average order shipping cost? 

select ShipMode, avg(ShippingCost)
from superstore.orders
group by ShipMode;
/*	Delivery Truck	43.838932
	Express Air		8.044281
	Regular Air		7.683405	*/
    
-- Delivery Truck shipping had the highest average shipping cost

# G.4 Which Product SubCategory has the highest average base margin?

select ProductCategory,
	ProductSubCategory, 
	avg(ProductBaseMargin) as AvgMargin
from superstore.product 
group by ProductSubCategory
order by avg(ProductBaseMargin) desc limit 5;
/*
ProductCategory   ProductSubCategory			AvgMargin
Furniture			Tables						0.665000  -- Furniture has the highest average margin
Office Supplies "Scissors, Rulers and Trimmers"	0.650455
Furniture		   Bookcases					0.643667
Office Supplies    Storage & Organization		0.635747
Technology		   Computer Peripherals			0.586552
*/

# G.5 How many orders were placed each month between 2011 and 2012?

select	year(orderdate) as year, 
    month(orderdate) as month, 
    count(distinct orderid) as ordersplaced
from superstore.orders 
where year(orderdate) between 2011 and 2012
group by year(OrderDate), month(OrderDate)
order by year(OrderDate) desc, month(OrderDate);


# G.6 How many orders were placed with multiple products? 

select count(1) count_of_orders from (
select count(orderid) from superstore.orders 
group by orderid 
having count(productid)>1) as order_count;

-- 2020 orders had multiple producs placed

# G.7 Which customers made more than 3 orders in 2009?

select CustomerID, 
       count(distinct OrderID) as cnt_Order
from superstore.orders
where year(OrderDate) = 2009
group by CustomerID
having cnt_Order >= 3;


# G.8 How many orders were placed each year, with years listed as column headers?

select sum(case when year(OrderDate)=2009 then 1 else 0 end) as orders_2009,
		  sum(case when year(OrderDate)=2010 then 1 else 0 end) as orders_2010,
          sum(case when year(OrderDate)=2011 then 1 else 0 end) as orders_2011,
          sum(case when year(OrderDate)=2012 then 1 else 0 end) as orders_2012
from (select distinct OrderID, OrderDate from superstore.orders) t
;

# G.9 What is the highest single day sales figure? 

select max(TotSalesByDay)
from (select OrderDate, sum(sales) as TotSalesByDay
         from superstore.orders
         group by OrderDate
         order by sum(sales) asc) tmp
;

-- $114,488.88 was the max sales achieved in a day


# G.10 Which customers made orders within two consecutive days?

select distinct a.OrderID, 
                       a.CustomerID, 
                       a.OrderDate, 
                       b.OrderDate as OrderDate2
from superstore.orders a
	inner join superstore.orders b
    on a.CustomerID = b.CustomerID and
         a.OrderDate = b.OrderDate - 1
;

# G.11 Which customers purchased products on New Years Eve in either 2009 and 2010

select CustomerID
	from superstore.orders
    where OrderDate = '2009-12-31'
union
select CustomerID
	from superstore.orders
    where OrderDate = '2010-12-31';


# G.12 Find all orders that have "Air" shipmode (as opposed to truck or boat)

select OrderID, 
       ProductID,
       ShipMode
from superstore.orders
where substr(trim(ShipMode), -3)='Air';


# G.13 How many product in the product table is from the Belkin brand

select count(*) 
from superstore.product 
where lower(ProductName) like '%belkin%';  
-- 15 products


/**************END*****************/