/***************************************
****************************************
SUPERSTORE SALES ANALYSIS

Objective: Determine if the business is doing better or worse YoY.

By: Yuri Oh

Data provided by WeCloudData

****************************************
****************************************

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
# C. I then explored the top sales, profit, orders and expenses data per year
 ***************************************/

# C.1 What are the cumulative sales, quantity of items ordered, total number of orders, 
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

# C.2 What is the total profit per year?
select year(OrderDate) as OrderYear,
       sum(profit) as TotalProfit
from superstore.orders
group by year(OrderDate) order by orderyear desc;
/*
2012	334558.27
2011	370214.31
2010	364371.07
2009	416346.00  */

-- 2009 had the highest Total Profit while 2012 had the least.


# C.3 What is the YoY Profit Growth rate?
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


# C.4	What is the total shipping cost per year?

select year(orderdate) as orderyear, 
	sum(shippingcost) as totalshipping 
from superstore.orders
group by year(orderdate) order by orderyear desc;

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
more efficient logistics routes etc) and/or the discounts used also increased (reducing profit margins).
*/


/***************************************
# D. I then explored the top sales, products, 
and customer info per year
 ***************************************/

# D.1 How much sales was generated by the top five orders placed in 2009?
select * from superstore.orders
	where year(orderdate)=2009
	order by sales desc limit 5;

-- The top five orders were made in January, March, and December and yielded sales of 
-- $89,061.05, $45,923.76, $28,359.40, $28,180.08, and $27,820.34. 

	# D.1.1 What were the top products ordered in the above top sales orders for 2009?
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

	# D.1.2 Who were the top customers that placed these orders?
select * from superstore.customer
	where customerid=39007820
	or customerid=104752832
	or customerid=19646967
	or customerid=67636836
	or customerid=92656557;

-- The customers were from Saskachewan, New Brunswick, Nova Scotia and Quebec
-- under the Corporate, Consumer, and Home Office customer segments.


# D.2 How much sales was generated by the top five orders placed in 2010?
select * from superstore.orders
	where year(orderdate)=2010
	order by sales desc limit 5;

-- The top five orders were made in January, June, and October and yielded sales of 
-- $29,884.60, $28,761.52, $28,389.14, $27,875.54, and $25,313.34. 

	# D.2.1 What were the products ordered in the above top sales orders for 2010?
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

	# D.2.2 Who were the top customers that placed these orders?
select * from superstore.customer
	where customerid=60814472
	or customerid=19360668
	or customerid=58178202
	or customerid=79088641
	or customerid=107565533;

-- The customers were from Manitoba, Alberta, British Columbia, and New Brunswick
-- under the Home Office, Consumer, and Corporate customer segments.

# D.3 How much sales was generated by the top five orders placed in 2011?
select * from superstore.orders
	where year(orderdate)=2011
	order by sales desc limit 5;
    
-- The top five orders were made in January, March, July, and November and yielded sales of 
-- $29,345.27, $29,186.49, $28,664.52, $27,720.98, and $27,663.92. 

	# D.3.1 What were the products ordered in the above top sales orders for 2011?
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

	
    # D.3.2 Who were the top customers that placed these orders?
select * from superstore.customer
	where customerid=91042485
	or customerid=10406639
	or customerid=35250192
	or customerid=38079848
	or customerid=71445870;
    
-- The customers were from Saskachewan, Manitoba, Alberta, and British Columbia
-- under the Corporate, Small Business, and Consumer customer segments.

# D.4 How much sales was generated by the top five orders placed in 2012?
select * from superstore.orders
	where year(orderdate)=2012
	order by sales desc limit 5;
    
-- The top five orders were made in January, May, and December and yielded sales of 
-- $41,343.21, $33,367.85, $24,701.12, $24,559.91, and $24,391.16. 

	# D.4.1 What were the products ordered in the above top sales orders for 2012?
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

	# D.4.2 Who were the top customers that placed these orders?
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


# D.5 On which day of week was the biggest sales order made? What was the product? 

select dayofweek(orderdate) as OrderDay, 
	OrderDate, ProductID
	from superstore.orders
	where sales in (select max(sales) from superstore.orders);

select * from superstore.product where productid=147664;

-- The largest sale was made on Saturday, March 21, 2009 for the Polycom ViewStationª ISDN Videoconferencing Unit.



/***********************************
      Date and Time Functions 
 ***********************************/

# Which orders made in 2012 have the highest order quantity?

select count(distinct orderID),OrderQuantity,orderdate 
from superstore.orders where year(OrderDate)='2012' and OrderQuantity=50;

/***********************************
      Aggregation Functions 
 ***********************************/


-- Example #2 MIN/MAX
# Smallest and largest order quantity and sales by year and month

select year(OrderDate) as OrderYear,
	   month(OrderDate) as OrderMonth,
       min(OrderQuantity) as MinOrderQuantity,
       max(OrderQuantity) as MaxOrderQuantity,
       min(Sales) as MinSales,
       max(Sales) as maxSales
from superstore.orders
group by year(OrderDate), month(OrderDate)
order by year(OrderDate), month(OrderDate);

select year(OrderDate) as OrderYear,
	   month(OrderDate) as OrderMonth,
       min(OrderQuantity) as MinOrderQuantity,
       max(OrderQuantity) as MaxOrderQuantity,
       min(Sales) as MinSales,
       max(Sales) as maxSales
from superstore.orders
group by year(OrderDate) #--in deleting "month(orderdate)" from being included in grouping, only 4 year rows show up.
order by year(OrderDate), month(OrderDate);

-- Example #3: AVG()
# Which Shipping Mode has the highest average order shipping cost? 

select ShipMode, avg(ShippingCost)
from superstore.orders
group by ShipMode;

/*	Delivery Truck	43.838932
	Express Air		8.044281
	Regular Air		7.683405	*/

# What is the biggest customer segment? 

select CustomerSegment, 
       count(distinct CustomerID) 
from superstore.customer
group by CustomerSegment
order by count(distinct CustomerID) desc;

-- The Corporate segment was the largest with 662 unique customers, 
-- followed by the Home office segment with 420 customers,
-- then the Consumer segment with 376 customers,
-- and lastly the Small Business segment with 374 customers.


# Which Product Sub Category has the highest average base margin?

select ProductCategory,
	ProductSubCategory, 
	avg(ProductBaseMargin) as AvgMargin
from superstore.product 
group by ProductSubCategory
order by avg(ProductBaseMargin) desc limit 5;
/*
Furniture
Office Supplies
Furniture
Office Supplies
Technology

Tables							0.665000
"Scissors, Rulers and Trimmers"	0.650455
Bookcases						0.643667
Storage & Organization			0.635747
Computer Peripherals			0.586552*/

# Which province has most number of Corporate customers? 
	
select province, count(customersegment) as countCS
from superstore.customer where lower(customersegment)='corporate'
group by province
order by countCS desc limit 5;

-- Ontario has the most Corporate customers with 120, followed by BC with 80 and Quebec with 71.


# Which customers placed most orders in a given month between 2011 and 2012?
	
select customerID,
month(orderdate),
count(distinct OrderID) as num_orders
from superstore.orders
group by CustomerID, month(orderdate)
order by count(distinct orderid) desc;

select CustomerID,month(OrderDate) as monthorder,count(OrderID) order_count 
from superstore.orders 
where year(OrderDate)>='2011' and year(OrderDate)<='2012' 
group by CustomerID,monthorder
order by monthorder;

select customerid, year(orderdate), month(orderdate), count(distinct orderid)
from orders 
where year(orderdate) between 2011 and 2012
group by year(OrderDate), month(OrderDate)
order by year(OrderDate), month(OrderDate);


# Which customer segment did the top 10 customers with the most total orders belong to?

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

select b.CustomerSegment,
     count(b.CustomerSegment) as CountCS,  
     count(distinct a.OrderID) as TotalOrders   
from superstore.orders a
	inner join superstore.customer b
	on a.CustomerID = b.CustomerID
group by CustomerSegment

/*
CustSegment	   CountCS  TotalOrders
Consumer		1584	1050
Corporate		2947	1959
Home Office		1952	1306
Small Business	1577	1046*/


select count(distinct a.OrderID), sum(a.Sales) 
from superstore.orders a 
	 inner join
	 superstore.returns b 
	on a.OrderID = b.OrderID
    
# How many orders were placed with multiple products? 

select OrderID, orderquantity, count(distinct productID) as TotalProd
from superstore.orders group by orderid
having TotalProd>=2; = WRONG

LEOS ANSWER

create table superstore.order_multi_prod as
select OrderID, count(ProductID) as cnt
from superstore.orders
group by OrderID
having count(ProductID)>1
order by count(ProductID) desc;

select count(*) from superstore.order_multi_prod;       #answer is 2020
drop table superstore.order_multi_prod;

SHARANS ANSWER

select count(1) count_of_orders from (
select count(orderid) from superstore.orders 
group by orderid 
having count(productid)>1) as order_count;


# What is the average total OrderQuantity of customers who made more than 3 orders in 2009

select CustomerID, 
       count(distinct OrderID) as cnt_Order
from superstore.orders
where year(OrderDate) = 2009
group by CustomerID
having cnt_Order >= 3;

--leos answer

create table superstore.customer_multi_order as
select customerID, count(distinct OrderID) as num_orders,
sum(orderquantity) as tot_order_quantity from superstore.orders
where year(Orderdate)=2009
group by CustomerID
having count(distinct OrderID)>3
order by num_orders desc;

select * from superstore.customer_multi_order limit 5;


select year(OrderDate) as OrderYear,
       sum(profit) as profitTotal
from superstore.orders
group by year(OrderDate) order by orderyear desc;


select year(orderdate) as orderyear, sum(shippingcost) as totalshipping from superstore.orders
group by year(orderdate) order by orderyear desc;

################################################################################

###### COPIED FROM 'superstore 4 complex sales'

/********************************************************************************
	  Lab #4 Complex Sales Questions with JOINs and Subqueries

*********************************************************************************/

/*****************************************
				CASE WHEN 
*****************************************/

-- Example
# Total number of distinct orders year over year 
# Expecting one column for each year

select sum(case when year(OrderDate)=2009 then 1 else 0 end) as orders_2009,
		  sum(case when year(OrderDate)=2010 then 1 else 0 end) as orders_2010,
          sum(case when year(OrderDate)=2011 then 1 else 0 end) as orders_2011,
          sum(case when year(OrderDate)=2012 then 1 else 0 end) as orders_2012
from (select distinct OrderID, OrderDate from superstore.orders) t
;

# [discussion] we can of course solve the question using group by
select year(OrderDate), count(distinct OrderID) as orders
from superstore.orders
group by year(OrderDate)
order by year(OrderDate);





-- Lab : CASE WHEN #2
# Create a pivot table that calculates number of orders in each order priority (rows) by different ship mode (columns)



/*********************************
            Subqueries
*********************************/

-- Example: Subquery with IN clause

# How many orders got returned and what is the total sales revenue loss due to product return?

select sum(sales) from superstore.orders; # 13570810.62850

select count(distinct OrderID) as TotalOrdersReturned, sum(Sales) 
from superstore.orders
where OrderID in (select distinct OrderID 
                              from superstore.returns);
                              
# 558 orders returned with a net sales revenue loss of 1485707.73150.

select count(distinct OrderId) from superstore.returns;
select * from superstore.returns;
select count(distinct OrderId) from superstore.orders;

-- Lab #1: Subquery with IN claues
# Generate a sales report that has total sales by year and month for products in the ProductCategory "Office Supplies"
# Hint: create a new table



-- Example: Subquery - SELECT FROM a temp table 
-- with inner query
# What is the highest single day sales number? 

select max(TotSalesByDay)
from (select OrderDate, sum(sales) as TotSalesByDay
         from superstore.orders
         group by OrderDate
         order by sum(sales) asc) tmp
;

# [discussion] What if we want to know the date that generated the highest single sales? 

-- # Lab 2: Subquery - SELECT FROM a temp table with inner query
# How many orders were placed with more than 3 products purchased? 

 
 
/*****************************************
			     SQL JOINS 
*****************************************/

-- ** INNER JOIN ** --

-- Example
# How many orders got returned and what is the total sales revenue loss due to product return?
# HINT: some returned orders cannot be found in orders table

select count(distinct a.OrderID), sum(a.Sales) 
from superstore.orders a 
	 inner join
	 superstore.returns b 
	on a.OrderID = b.OrderID
; #558

select count(distinct OrderID)
from superstore.returns; #572

# [discussion] 
# there are 572 returned orders, however inner join only returns 558 orders


-- # Lab: Inner Join #1
# Create a temporary table that has order detail as well as product details such as product category and sub-category
# Requirements:
#       - OrderID
#       - ProductID
#       - OrderDate
#       - Sales
#       - ShipMode
#       - ProductCategory
#       - ProductSubCategory

# After the table is created, calculate average sales by product categories in 2010



-- # Lab: Inner Join #2 
# Answer the previous question using subquery instead of creating a temp table




-- # Lab: Inner Join #3
# Find products that were purchased by customers in both 'Ontario' and 'West' region
# Required fields:
#     - ProductID
#     - ProductName




-- ** LEFT JOIN ** --

-- Example
# Add a Return column to the orders table to indicate if the
# order has been returned
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
select count(*) from superstore.orders; #8060

-- # Lab: Left Outer Join #1
# For all the superstore products, what is the total sales and number of orders without a discount? 
# Required fields in report:
#      - ProductID
#      - ProductName
#      - ProductCategory
#      - Total Sales
#      - # of distinct orders
#      - # of unique customers that bought the product


-- # Lab: Left Outer Join #2
# Of all products sold in 2012, which products had total sales greater than $1000 
# in both 'Ontario' and 'West' regions?        

# Expected output:
#     - ProductID
#     - SalesOntario
#     - SalesWest
# Condition: SalesOntario > 1000 and SalesWest > 1000




-- # Lab: Left Outer Join #3 (JOIN a temp table created with inner query)
# Calculate RFM (Recency, Frequency, Monetary) attributes for each user
# Build a customer attributes table that contains the following columns
	-- CustomerID
    -- CustomerName
    -- CustomerSegment
    -- FirstOrderDate
    -- LastOrderDate
    -- CustomerTenure (defined as the number of days between first purchase date and 2013-01-01)
    -- Recency (defined as time since last purchase as of 2013-01-01)
    -- Frequency (defined as purchase frequency in the last 2 years between 2011-01-01 and 2013-01-01)
    -- Monetary (defined as total spending in the last 2 years as of 2013-01-01)



-- ** SELF JOIN ** --

-- Example: Self Join
# Find customers who has made orders from two consecutive days

select distinct a.OrderID, 
                       a.CustomerID, 
                       a.OrderDate, 
                       b.OrderDate as OrderDate2
from superstore.orders a
	inner join superstore.orders b
    on a.CustomerID = b.CustomerID and
         a.OrderDate = b.OrderDate - 1
;

select * 
from superstore.orders 
where CustomerID = 26995184
order by OrderDate;


-- Lab: Self Join #1
# Find customers who purchased the same product more than once
# within a week and enjoyed a better discount on the second purchase


-- Lab: Self Join #2
# Calculating YoY revenue growth trend using self join





-- ** CROSS JOIN ** --

-- Example: cross join
# For product 778385, we would like to plot the total sales and number of orders by year and month (time series)
# Requirements:
# For months that didn't generate sales for product 778385, we still want to show count and sales as 0 so that we
# can plot the numbers on a time line


select count(distinct OrderDate)
from superstore.orders
where year(OrderDate) = 2010; #350 days

# Frist try
select year(OrderDate) as OrderYear, month(OrderDate) as OrderMonth, count(distinct OrderID), sum(Sales)
from superstore.orders
where ProductID = 778385
group by year(OrderDate), month(OrderDate)
order by year(OrderDate), month(OrderDate);

# Cross join
select yr.OrderYear, mn.OrderMonth
from (select distinct year(OrderDate) as OrderYear 
			from superstore.orders) yr
	cross join
		(select distinct month(OrderDate) as OrderMonth 
			from superstore.orders) mn
order by OrderYear, OrderMonth;


# Second try

select a.OrderYear, a.OrderMonth, b.CntTotal, b.TotalSales
from (select yr.OrderYear, mn.OrderMonth
			from (select distinct year(OrderDate) as OrderYear from superstore.orders) yr
				cross join
					(select distinct month(OrderDate) as OrderMonth from superstore.orders) mn
		) a
	left join (select year(OrderDate) as OrderYear, 
                            month(OrderDate) as OrderMonth, 
							count(distinct OrderID) as CntTotal, sum(Sales) as TotalSales
					from superstore.orders
					where ProductID = 778385
					group by year(OrderDate), month(OrderDate)
				) b
on a.OrderYear = b.OrderYear and
     a.OrderMonth = b.OrderMonth
order by a.OrderYear, a.OrderMonth;   # [comment] a lot of null values

# Third try
select a.OrderYear, 
          a.OrderMonth, 
          case when b.CntTotal is null then 0 else b.CntTotal end as CntTotal, 
          case when b.TotalSales is null then 0 else b.TotalSales end as TotalSales
from (select yr.OrderYear, mn.OrderMonth
			from (select distinct year(OrderDate) as OrderYear from superstore.orders) yr
				cross join
					(select distinct month(OrderDate) as OrderMonth from superstore.orders) mn
		) a
	left join (select year(OrderDate) as OrderYear, 
                            month(OrderDate) as OrderMonth, 
							count(distinct OrderID) as CntTotal, sum(Sales) as TotalSales
					from superstore.orders
					where ProductID = 778385
					group by year(OrderDate), month(OrderDate)
				) b
on a.OrderYear = b.OrderYear and
     a.OrderMonth = b.OrderMonth
order by a.OrderYear, a.OrderMonth; 


/************************************************
		      UNION | UNION ALL
*************************************************/


-- Example
# Find customers who purchased products on New Years Eve in either 2009 and 2010

select CustomerID
	from superstore.orders
    where OrderDate = '2009-12-31'
union
select CustomerID
	from superstore.orders
    where OrderDate = '2010-12-31';
 
  
select * from superstore.orders where CustomerID=33681614;






/***************************************
# I then cleaned up some string data from product table to make
 everything lowercase and removed unnecessary quotation marks
 ***************************************/

drop table if exists superstore.product_new;
create table superstore.product_new as
select ProductID, 
	   REPLACE(lower(ProductName), '"', '') as ProductName,
	   lower(ProductCategory),
       lower(ProductSubCategory),
       lower(ProductContainer),
       ProductBaseMargin
from superstore.product;
select * from superstore.product_new limit 150;


select * from orders limit 250;

select * from orders where OrderID = 8710;
select sum(Sales + Profit) as totalblah
from orders where OrderID = 8710 and OrderQuantity = 17;


# Find all orders that have "Air" shipmode (as opposed to truck or boat)

select OrderID, 
       ProductID,
       ShipMode
from superstore.orders
where substr(trim(ShipMode), -3)='Air';

select shipmode from superstore.orders;

-- *** String function LIKE() ***

-- Example #6
# How many product in the product table is from the Belkin brand

select count(*) 
from superstore.product 
where lower(ProductName) like 'belkin%';  

select * from superstore.product where lower(productname) like 'belkin%';

# [Discussions]
-- In the above example, the query returns 13 as the result.
-- Let's give it another try. This time we change the string pattern
select count(*) 
from superstore.product 
where lower(ProductName) like '%belkin%'; 

# [Discussions]
# After the changes, we get 15. 
# So what happened? Let's print all the results
select * 
from superstore.product
where lower(ProductName) like '%belkin%';



# [Discussions]
-- looks like we've done a great job... but really? let's run the following query
select *
from superstore.product_new
where locate('\'', lower(ProductName)) > 0;

# [Discussions]
-- looks like the replace function is
-- too aggresive, we removed the inch/foot
-- quotes from the productname. for example
-- ProductID 48396
select productid,productname from superstore.product where productid=48396;

# [Discussions]
-- ** A better approach
-- we can improve that by removing
-- trimming the leading and trialing
-- double quotes first and then replace
-- '""' with '"'
select ProductName, 
       locate('\'', lower(ProductName)),
       trim(both '"' from ProductName), 
       trim(both '"' from replace(lower(ProductName), '""', '"'))
from superstore.product
where locate('\'', lower(ProductName)) > 0;