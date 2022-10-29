/****** Script for SelectTopNRows command from SSMS  ******/

--DATA CLEANING

--I will inspect the data to familiarize myself with it and get a better feel for what exactly needs to be cleaned
--Total Records = 541909
SELECT [InvoiceNo]
      ,[StockCode]
      ,[Description]
      ,[Quantity]
      ,[InvoiceDate]
      ,[UnitPrice]
      ,[CustomerID]
      ,[Country]
  FROM [PortfolioProject].[dbo].[online_retail]
  /*
  From inspecting the data:
	-There are CustomerID's whose values are null, these rows need to be deleted.
	-The are Quantities and Unit Prices that are not greater than zero, these are need to be removed as they
	 represent items returned (most likely).
	-There are other random null values in other columns so those have to be deleted as well.
    
  */

--Deleting Null Values
delete from [PortfolioProject].[dbo].[online_retail]
where InvoiceNo is null

delete from [PortfolioProject].[dbo].[online_retail]
where StockCode is null

delete from [PortfolioProject].[dbo].[online_retail]
where [Description] is null

delete from [PortfolioProject].[dbo].[online_retail]
where Quantity is null

delete from [PortfolioProject].[dbo].[online_retail]
where InvoiceDate is null

delete from [PortfolioProject].[dbo].[online_retail]
where UnitPrice is null

delete from [PortfolioProject].[dbo].[online_retail]
where Country is null

--New Data
SELECT [InvoiceNo]
      ,[StockCode]
      ,[Description]
      ,[Quantity]
      ,[InvoiceDate]
      ,[UnitPrice]
      ,[CustomerID]
      ,[Country]
  FROM [PortfolioProject].[dbo].[online_retail]

--Converting Null values in CustomerID to zero
update [PortfolioProject].[dbo].[online_retail]
set CustomerID = 0
where CustomerID is null

select *
from [PortfolioProject].[dbo].[online_retail]

--creating a CTE without the zero CustomerID values
;with OnlineRetail as
(
	select [InvoiceNo]
      ,[StockCode]
      ,[Description]
      ,[Quantity]
      ,[InvoiceDate]
      ,[UnitPrice]
      ,[CustomerID]
      ,[Country]
	from [PortfolioProject].[dbo].[online_retail]
	where CustomerID != 0
)
, quantity_unit_price as
(
	select *
	from OnlineRetail
	where Quantity > 0 and UnitPrice > 0 --Quantites and unit prices greater than zero, the actual data we care about
)
, dup_check as
(
--Duplicate check
	select *, ROW_NUMBER() over (partition by InvoiceNo, StockCode, Quantity order by InvoiceDate)dup_flag
	from quantity_unit_price
)

--392669 clean data
select *
into #onlineretail_main
from dup_check 
where dup_flag = 1

--Clean Data!
select *
from #onlineretail_main

--COHORT ANALYSIS

--Unique Identifier (CustomerID)
--Initial Start Date(First Invoice Date)
--Revenue Data

--1st Create Cochort Group
select 
	CustomerID,
	min(InvoiceDate) first_purchase_date,
	DATEFROMPARTS(year(min(InvoiceDate)), month(min(InvoiceDate)), 1) Cohort_Date
into #cohort
from #onlineretail_main
group by CustomerID

select *
from #cohort

--Create Cohort Index (number that represents the number of months since customers first engagement)
/*
	-Index = 1 --> Customer made their second purchase in the same month they made their first.
	-Index = 2 --> Customer made a purchase in the month after their first purchase.
	-...
*/

select
	mmm.*,
	cohort_index = year_diff * 12 + month_diff + 1
into #cohort_retention
from
	(	
	select
		mm.*,
		year_diff = invoice_year - cohort_year,
		month_diff = invoice_month - cohort_month
	from (
		select
			m.*,
			c.Cohort_Date,
			year(m.InvoiceDate) invoice_year,
			month(m.InvoiceDate) invoice_month,
			year(c.Cohort_Date) cohort_year,
			month(c.Cohort_Date) cohort_month
		from #onlineretail_main m
		left join #cohort c
			on m.CustomerID = c.CustomerID
		)mm
	)mmm



select *
from #cohort_retention

--Find distinct customers, so we can better see their buying patterns.

select distinct
	CustomerID,
	Cohort_Date,
	cohort_index
from #cohort_retention
order by 1, 3

--Pivot Data to see the cohort table

select *
into #cohort_pivot
from (
	select distinct
		CustomerID,
		Cohort_Date,
		cohort_index
	from #cohort_retention

)tbl
pivot (
	count(CustomerID)
	for Cohort_index In 
					(
					[1],
					[2],
					[3],
					[4],
					[5],
					[6],
					[7],
					[8],
					[9],
					[10],
					[11],
					[12],
					[13])
) as pivot_table 


--Convert to percentages


select Cohort_Date,
		(1.0 * [1]/[1] * 100) as [1]
		, 1.0 * [2]/[1] * 100 as [2],
		1.0 * [3]/[1] * 100 as [3],
		1.0 * [4]/[1] * 100 as [4],
		1.0 * [5]/[1] * 100 as [5],
		1.0 * [6]/[1]* 100 as [6],
		1.0 * [7]/[1] * 100 as [7],
		1.0 * [8]/[1] * 100 as [8],
		1.0 * [9]/[1] * 100 as [9],
		1.0 * [10]/[1] * 100 as [10],
		1.0 * [11]/[1] * 100 as [11],
		1.0 * [12]/[1] * 100 as [12],
		1.0 * [13]/[1] * 100 as [13]

from #cohort_pivot
order by Cohort_Date
