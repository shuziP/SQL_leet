
## Address(题目地址)
**SQL177 国庆期间近7日日均取消订单量**[每个城市中评分最高的司机信息__牛客网](https://www.nowcoder.com/questionTerminal/dcc4adafd0fe41b5b2fc03ad6a4ac686)

## Solution Approach(解法)
```sql
with v1 as (
  select
    driver_id,
    count(order_time) as order_time_count #接单日期数
  from
    (
      select
        driver_id,
        date_format(order_time, '%Y-%m-%d') as order_time
      from
        tb_get_car_order
      group by
        driver_id,
        date_format(order_time, '%Y-%m-%d')
    ) as v2_t1
    group by driver_id
), v2 as (
  select
    t_record.city,
    t_order.driver_id,
    sum(t_order.grade) as sum_grade, #总分
	count(t_order.grade) as count_grade, #评价次数
    count(t_record.order_id) as order_count, #接单量
    sum(t_order.mileage) as sum_mileage #总行驶里程数
  from
    tb_get_car_order as t_order
    left join tb_get_car_record as t_record on t_order.order_id = t_record.order_id
  
  group by
    t_record.city,
    t_order.driver_id
)
select 
    city,
    driver_id,
	avg_grade,
	avg_order_num,
	avg_mileage 
	from 
(select 
    city,
    driver_id,
	avg_grade,
	avg_order_num,
	avg_mileage,
	rank() over(partition by city order by avg_grade desc) as rn
	from 
(select
    v2.city,
    v2.driver_id,
	round((v2.sum_grade / v2.count_grade), 1) as avg_grade,
	round((v2.order_count / v1.order_time_count), 1) as avg_order_num,
	round((v2.sum_mileage / v1.order_time_count),3) as avg_mileage
from
  v2 left join v1
  on v2.driver_id = v1.driver_id) as t1) as t2
  where rn = 1
order by avg_order_num asc
```

## Original Problem Description(原题目描述)
![image.png](https://cdn.nlark.com/yuque/0/2022/png/21613696/1672322089400-d514b2b9-c789-4729-a0ea-c3653593e3cc.png#averageHue=%23efefef&clientId=u6bc84075-76be-4&from=paste&id=u4ee57d1c&originHeight=2430&originWidth=385&originalType=url&ratio=1&rotation=0&showTitle=false&size=256148&status=done&style=none&taskId=uf9fe6528-afad-4d21-93e8-db1ecbb09b1&title=)
