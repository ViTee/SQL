--xoa cot
--alter table data
--drop column f1,.., f27

--doi ten cot
--sp_rename 'data.order number', 'order_number', 'column'

--doi kieu du lieu cot
--update data
--set time = convert(datetime, time)

--tinh med va mean tu kho cu chi soc den nguoi nhan dau tien
with sub as (select *, row_number () over (partition by order_number order by order_number, event) as stt
from data
where event like '%Cu Chi SOC' or event like 'Giao hàng không thành công%' or event like 'Giao hàng thành công%'),
leadtime as (select a.order_number, DATEDIFF(mi, a.time, b.time) as leadtime
from sub a join sub b
on a.order_number = b.order_number
and a.stt = 1
and b.stt = 2)
select 'mean' as metric, avg(leadtime) as value
from leadtime
union
select 'med' as metric, PERCENTILE_CONT(0.5) WITHIN GROUP ( ORDER BY leadtime )  OVER (PARTITION BY 0) as value
from leadtime

--loc tu cu chi soc den dia chi nguoi nhan ma k qua hub '50-HCM Quan 10/Phuong 15 LM Hub'
select distinct order_number 
from data 
where order_number not in(select distinct order_number 
                   from data 
				   where event like '%50-HCM Quan 10/Phuong 15 LM%')