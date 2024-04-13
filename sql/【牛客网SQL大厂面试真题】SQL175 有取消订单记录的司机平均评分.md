[有取消订单记录的司机平均评分_牛客题霸_牛客网](https://www.nowcoder.com/practice/f022c9ec81044d4bb7e0711ab794531a?tpId=268&tqId=2294893&ru=/exam/oj&qru=/ta/sql-factory-interview/question-ranking&sourceUrl=%2Fexam%2Foj%3Fpage%3D1%26tab%3DSQL%25E7%25AF%2587%26topicId%3D268)


```plsql
with v1 as (
	select
		driver_id,
		order_id,
		grade
	from
		tb_get_car_order
),
v2 as (
	select
		driver_id
	from
		tb_get_car_order
	where
		unix_timestamp(order_time) between unix_timestamp('2021-10-01')
		and unix_timestamp('2021-10-31')
		and start_time is null
)
select
	v2.driver_id as driver_id,
	round(avg(v1.grade), 1) as avg_grade
from
	v2
	left join v1 on v2.driver_id = v1.driver_id
group by
	v2.driver_id
union
all
select
	"总体" as driver_id,
	round(avg(v1.grade), 1) as avg_grade
from
	v2
	left join v1 on v2.driver_id = v1.driver_id
order by
	driver_id asc
```
## Original Problem Description(原题目描述)

![image.png](https://cdn.nlark.com/yuque/0/2022/png/21613696/1672321691145-e8338738-eb46-42ec-9fe7-2f5ed85cba93.png#averageHue=%23efefef&clientId=u35163513-a8c5-4&from=paste&id=u0c21ab61&originHeight=2389&originWidth=385&originalType=url&ratio=1&rotation=0&showTitle=false&size=243749&status=done&style=none&taskId=u7e340631-7625-46c2-847b-f2972042970&title=)
