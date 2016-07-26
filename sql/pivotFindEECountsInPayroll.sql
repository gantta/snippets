

select * from (
	select 
	datediff(m, DATEADD(dd,-(DAY(PayPeriodEndDate)-1),PayPeriodEndDate), getdate()) [Months Back]
	,count(distinct SSN) [EE Count]
	from
	eThorityUser.WFH_Pay_Period_Sum
	where datediff(m, PayPeriodEndDate, getdate()) < 13
	group by 
	DATEADD(dd,-(DAY(PayPeriodEndDate)-1),PayPeriodEndDate)
) as data
pivot (sum([EE Count]) for [Months Back] in ([0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) as ecnt
