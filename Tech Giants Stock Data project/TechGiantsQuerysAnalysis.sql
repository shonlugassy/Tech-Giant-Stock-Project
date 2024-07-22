--1. Stock compare between the giant techs from 2013 to 2018 
select FORMAT(g.[date], 'MM-yyyy')as [google date],FORMAT(m.[date], 'MM-yyyy') as [microsoft date],FORMAT(p.[date], 'MM-yyyy') as [apple date],FORMAT(a.[date], 'MM-yyyy')as [amazon date],
case 
	when g.[close] > m.[close] and g.[close] > p.[close] and g.[close] > a.[close] then concat(g.[close], ' - Google') 
	when m.[close] > g.[close] and m.[close] > p.[close] and m.[close] >a.[close] then concat(m.[close], ' - Microssoft')
	when p.[close] > g.[close] and p.[close] > m.[close] and p.[close] > a.[close] then concat(p.[close], ' - Apple')
	when a.[close] > g.[close] and a.[close] > m.[close] and a.[close]> p.[close] then concat(a.[close], ' - Amazon')
	when g.[close] is null and m.[close] > p.[close] and m.[close] >a.[close] then concat(m.[close], ' - Microssoft')
	when g.[close] is null and p.[close] > a.[close] and p.[close] > m.[close] then concat(p.[close], ' - Apple')
	when g.[close] is null and a.[close] > m.[close] and a.[close]> p.[close] then concat(a.[close], ' - Amazon')
	else 'Not valid'
end as [highest trade close]
from GOOG_data$ g right join MSFT_data$ m 
on g.[date] = m.[date] 
inner join AAPL_data$ p on p.[date] = m.[date]
inner join AMZN_data a on a.[date] = m.[date]


--2. Most highest Giant Tech stock
select g.[close] as [google date],m.[close] as [microsoft date],p.[close] as [apple date],a.[close] as [amazon date],
case 
	when g.[close] > m.[close] and g.[close] > p.[close] and g.[close] > a.[close] then concat(g.[close], ' - Google') 
	when m.[close] > g.[close] and m.[close] > p.[close] and m.[close] >a.[close] then concat(m.[close], ' - Microssoft')
	when p.[close] > g.[close] and p.[close] > m.[close] and p.[close] > a.[close] then concat(p.[close], ' - Apple')
	when a.[close] > g.[close] and a.[close] > m.[close] and a.[close]> p.[close] then concat(a.[close], ' - Amazon')
	when g.[close] is null and m.[close] > p.[close] and m.[close] >a.[close] then concat(m.[close], ' - Microssoft')
	when g.[close] is null and p.[close] > a.[close] and p.[close] > m.[close] then concat(p.[close], ' - Apple')
	when g.[close] is null and a.[close] > m.[close] and a.[close]> p.[close] then concat(a.[close], ' - Amazon')
	else 'Not valid'
end as [highest trade close]
from GOOG_data$ g right join MSFT_data$ m 
on g.[date] = m.[date] 
inner join AAPL_data$ p on p.[date] = m.[date]
inner join AMZN_data a on a.[date] = m.[date]
--)


--3. Google stock status- UP or Down and how much
select [open] ,[close],
case 
	when [close] > [open]  then concat('increased by -  ',[close] - [open])
	when [close] < [open]  then concat('decreased by -  ',[open]- [close])
	else 'stock stays equal'
end as [stock status]
from GOOG_data$ 


--4. Stock most highest increasing and most highest decreasing
with s as (
select [open] ,[close],
case 
	when [close] > [open]  then concat('increase by -  ',[close] - [open])
	when [close] < [open]  then concat('decreased by -  ',[open]- [close])
	else 'stock stays equal'
end as [stock status]
from GOOG_data$ 
)
select max([stock status])as [highest increasing stock],(select max([stock status]) as[lowest decreasing] from s where [stock status] like '%decreased%') from s where [stock status]  like '%increase%'


--5. Stock most lowest increasing and most lowest decreasing 
with s as (
select [open] ,[close],
case 
	when [close] > [open]  then concat('increase by -  ',[close] - [open])
	when [close] < [open]  then concat('decreased by -  ',[open]- [close])
	else 'stock stays equal'
end as [stock status]
from GOOG_data$ 
)
select min([stock status])as [highest stock],(select min([stock status]) as[highest stock] from s where [stock status] like '%decreased%') from s where [stock status]  like '%increase%'


--6. Ranking total number stock from the highest to lowest 
with stock as (
select concat(SUM([close]), ' - Google') as [s] from GOOG_data$ g  
union all
select concat(SUM([close]), ' - Microssoft') as [s] from MSFT_data$
union all
select concat(SUM([close]), ' - Apple') as [s] from AAPL_data$ 
union all
select  concat(SUM([close]), ' - Amazon') as [s] from AMZN_data 
)
select [s],RANK() over(order by s desc) from stock


--7. Stock on weekdays and weekends
with weekd as (
select 'Google' as [company],COUNT(case when DATEPART(weekday,[open]) not in(7,1) then 1 else null end) as [weekday stock amount] ,COUNT(case when DATEPART(weekday,[open]) in(7,1) then 1 else null end) as [weekdend stock amount]from GOOG_data$ 
union all
select 'Amazon' as [company],COUNT(case when DATEPART(weekday,[open]) not in(7,1) then 1 else null end) as [weekday stock amount] ,COUNT(case when DATEPART(weekday,[open]) in(7,1) then 1 else null end) as [weekdend stock amount]from AMZN_data
union all
select 'Apple' as [company],COUNT(case when DATEPART(weekday,[open]) not in(7,1) then 1 else null end) as [weekday stock amount] ,COUNT(case when DATEPART(weekday,[open]) in(7,1) then 1 else null end) as [weekdend stock amount]from AAPL_data$
union all
select 'Microssoft' as [company],COUNT(case when DATEPART(weekday,[open]) not in(7,1) then 1 else null end) as [weekday stock amount] ,COUNT(case when DATEPART(weekday,[open]) in(7,1) then 1 else null end) as [weekdend stock amount]from MSFT_data$
)
select company,[weekday stock amount], [weekdend stock amount] from weekd 


--8. The total number of stock get closed per year
select year([date]),sum([close]) from GOOG_data$ group by year([date]) order by sum([close]) desc


--9. Second highest close stock in Google
with sec as (
select year([date]) as[year],sum([close]) as [total sum],ROW_NUMBER() over(order by sum([close]) desc ) as [rn] from GOOG_data$ group by year([date])
)
select [year],[total sum], [rn] from sec where [rn] = 2


--10. Stock that closed with the same value
select [close],COUNT(*) from GOOG_data$ group by [close] having COUNT([close]) >1


--11. Second highest close stock in the Giant Tech companys 
with s as (
select 'Google' as[company name],[close], ROW_NUMBER() over (order by [close] desc) as[r] from GOOG_data$ 
union all 
select 'Amazon' as[company name],[close], ROW_NUMBER() over (order by [close] desc) as[r] from AMZN_data 
union all
select 'Apple' as[company name],[close], ROW_NUMBER() over (order by [close] desc) as[r] from AAPL_data$
union all
select 'Microssoft' as[company name],[close], ROW_NUMBER() over (order by [close] desc) as[r] from MSFT_data$ 
) 
select [company name],[close],[r] from s where [r] = 2 order by [close] desc


--12. Total number of the second highest close stock per year of each Giant Tech companys
with w as (
select year([date])as [yd],sum([close])as [sClose], ROW_NUMBER() over (order by sum([close]) desc) as [r] from GOOG_data$  group by year([date])
union all
select year([date])as [yd],sum([close])as [sClose], ROW_NUMBER() over (order by sum([close]) desc) as [r] from AMZN_data  group by year([date])
union all
select year([date])as [yd],sum([close])as [sClose], ROW_NUMBER() over (order by sum([close]) desc) as [r] from AAPL_data$  group by year([date])
union all
select year([date])as [yd],sum([close])as [sClose], ROW_NUMBER() over (order by sum([close]) desc) as [r] from MSFT_data$ group by year([date])
)
select [yd],[sClose],[r] from w where [r] =2 


--13. The average of the open stock amount per each month and year
with g as (
select FORMAT([date], 'MM-yyyy')as [md],COUNT([open])as [cd] from GOOG_data$ group by FORMAT([date], 'MM-yyyy') 
)
select [md],[cd],AVG([cd]) over(), from g


--14. Amount of stock that are get closed of each company
select 'google' as [company name],COUNT([close]) from GOOG_data$ 
union all
select 'Amazon' as [company name],COUNT([close]) from AMZN_data 
union all
select 'Apple' as [company name],COUNT([close]) from AAPL_data$ 
union all
select 'Microssoft' as [company name],COUNT([close]) from MSFT_data$ 
order by COUNT([close]) desc




