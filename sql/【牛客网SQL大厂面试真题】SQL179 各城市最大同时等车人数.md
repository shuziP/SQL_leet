# 各城市最大同时等车人数__牛客网
[各城市最大同时等车人数__牛客网](https://www.nowcoder.com/questionTerminal/f301eccab83c42ab8dab80f28a1eef98)
题目理解：**问题：请统计各个城市在2021年10月期间，单日中最大的同时等车人数。**

**将计算任务理解为按时间顺序的累加任务，开始等车是+1，结束等车是-1**

**注**:   等车指从开始打车起，直到取消打车、取消等待或上车前的这段时间里用户的状态。
如果同一时刻有人停止等车，有人开始等车，等车人数记作先增加后减少。
结果按各城市最大等车人数升序排序，相同时按城市升序排序。

开始打车起，直到取消打车（订单号为空）：event_time  ~ end_time
开始打车起，直到取消等待（订单号不为空，start_time为空）：event_time ~ finish_time
开始打车起，直到上车（订单号不为空，start_time不为空为空）：event_time ~ start_time
## step1
```sql
select
  t_record.id,
  t_record.city,
  t_record.event_time,
  t_record.end_time,
  t_record.order_id,
  t_order.start_time,
  t_order.start_time
from
  tb_get_car_record as t_record
  left join tb_get_car_order as t_order on t_record.order_id = t_order.order_id and date_format(t_record.event_time, '%Y-%m') = '2021-10'

```
## step2:按时间顺序构造人数增减表
```sql
  select
    t_record.city,
    date_format(t_record.event_time, '%Y-%m-%d') as event_time,
    event_time as time_stamp,
    1 as waiter_count
  from
    tb_get_car_record as t_record
    left join tb_get_car_order as t_order on t_record.order_id = t_order.order_id
    and date_format(t_record.event_time, '%Y-%m') = '2021-10'
  union all
  select
    t_record.city,
    date_format(t_record.event_time, '%Y-%m-%d') as event_time,
    case
      when t_record.order_id is null then end_time
      when t_record.order_id is not null
      and t_order.start_time is null then finish_time
      when t_record.order_id is not null
      and t_order.start_time is not null then start_time
    end as time_stamp,
    -1 as waiter_count
  from
    tb_get_car_record as t_record
    left join tb_get_car_order as t_order on t_record.order_id = t_order.order_id
    and date_format(t_record.event_time, '%Y-%m') = '2021-10'
  order by
    time_stamp asc,
    waiter_count desc
)
```
## step3:基于开始打车时间和结束打车时间的人数增减表，使用开窗函数sum() over () 完成统计。
```sql
with v1 as (
  select
    t_record.city,
    date_format(t_record.event_time, '%Y-%m-%d') as event_time,
    event_time as time_stamp,
    1 as waiter_count
  from
    tb_get_car_record as t_record
    left join tb_get_car_order as t_order on t_record.order_id = t_order.order_id
    and date_format(t_record.event_time, '%Y-%m') = '2021-10'
  union all
  select
    t_record.city,
    date_format(t_record.event_time, '%Y-%m-%d') as event_time,
    case
      when t_record.order_id is null then end_time
      when t_record.order_id is not null
      and t_order.start_time is null then finish_time
      when t_record.order_id is not null
      and t_order.start_time is not null then start_time
    end as time_stamp,
    -1 as waiter_count
  from
    tb_get_car_record as t_record
    left join tb_get_car_order as t_order on t_record.order_id = t_order.order_id
    and date_format(t_record.event_time, '%Y-%m') = '2021-10'
  order by
    time_stamp asc,
    waiter_count desc
)
select
  city,
  max(wait_uv) as max_wait_uv
from
  (
    select
      event_time,
      city,
      sum(waiter_count) over(
        partition by city
        order by
          time_stamp asc, waiter_count desc
      ) as wait_uv
    from
      v1
  ) as t1
group by
  city
order by
  city desc/*  */
```

![image.png](https://cdn.nlark.com/yuque/0/2023/png/21613696/1673362516652-2006d383-b835-448e-8682-27d62bc4fbe4.png#averageHue=%23efefef&clientId=u9259616e-67f0-4&from=paste&id=uc062a151&originHeight=2259&originWidth=385&originalType=url&ratio=1&rotation=0&showTitle=false&size=237577&status=done&style=none&taskId=uefaa7833-7deb-4a7b-aa1d-5b7080c39c0&title=)
