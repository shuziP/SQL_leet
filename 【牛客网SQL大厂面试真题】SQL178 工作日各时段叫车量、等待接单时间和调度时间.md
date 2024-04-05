[工作日各时段叫车量、等待接单时间和调度时间__牛客网](https://www.nowcoder.com/questionTerminal/34f88f6d6dc549f6bc732eb2128aa338)

SQL中拆分日期和时间的方法
```plsql
SELECT
  id,
  DATE_FORMAT(event_time, '%Y-%m-%d') as event_time_date,
  DATE_FORMAT(event_time, '%H:%i:%s') as event_time_times
from
  tb_get_car_record
where
  DATE_FORMAT(event_time, '%H:%i:%s') >= '07:00:00'
  and DATE_FORMAT(event_time, '%H:%i:%s') < '09:00:00'
```
拆分日期和时间之后的表格
```plsql
SELECT 
id,
DATE_FORMAT(event_time , '%Y-%m-%d') as event_time_date,
DATE_FORMAT(event_time ,'%H:%i:%s') as event_time_times
from 
tb_get_car_record 
```
**event_time-开始打车时间**为时段划分依据，平均等待接单时间和平均调度时间均保留1位小数，平均调度时间仅计算完成了的订单，结果按叫车量升序排序。
从开始打车到司机接单为等待接单时间，从司机接单到上车为调度时间。
等待接单时间:  order_time - event_time 
调度时间: start_time - order_time
step1：先连接两张表
```plsql
SELECT
  t_record.id,
  DATE_FORMAT(t_record.event_time, '%Y-%m-%d') as event_time_date,
  DATE_FORMAT(t_record.event_time, '%H:%i:%s') as event_time_times,
  TIMESTAMPDIFF(SECOND, t_record.event_time, t_order.order_time) as wait_time,
  TIMESTAMPDIFF(SECOND, t_order.order_time, t_order.start_time) as dispatch_time,
  dayofweek(t_record.event_time) as dow,
  t_record.event_time,
  t_record.order_id,
  t_order.order_time,
  t_order.start_time
from
  tb_get_car_record as t_record
  left join tb_get_car_order as t_order on t_record.order_id = t_order.order_id
where dayofweek(t_record.event_time) not in (0, 6)
```
本体需要对分钟保留小数，故_TIMESTAMPDIFF（）_应使用秒数相减，再除以60获取保留小数位数的分钟计量单位。
step2：时间区间判断
```plsql
select
  case
    when event_time_times >= '07:00:00'
    and event_time_times < '09:00:00' then '早高峰'
    when event_time_times >= '09:00:00'
    and event_time_times < '17:00:00' then '工作时间'
    when event_time_times >= '17:00:00'
    and event_time_times < '20:00:00' then '晚高峰'
    when event_time_times >= '20:00:00' then '休息时间'
    when event_time_times >= '00:00:00'
    and event_time_times < '07:00:00' then '休息时间'
  end as period

from
  (
    SELECT
  t_record.id,
  DATE_FORMAT(t_record.event_time, '%Y-%m-%d') as event_time_date,
  DATE_FORMAT(t_record.event_time, '%H:%i:%s') as event_time_times,
  TIMESTAMPDIFF(SECOND ,t_record.event_time, t_order.order_time) as wait_time,
  TIMESTAMPDIFF(SECOND ,t_order.order_time, t_order.start_time) as dispatch_time,
  t_record.event_time,
  t_record.order_id,
  t_order.order_time,
  t_order.start_time
from
  tb_get_car_record as t_record
  left join tb_get_car_order as t_order on t_record.order_id = t_order.order_id

  ) as t1
```
step3：增加筛选条件，group by聚合，最后排序输出
```plsql
select
  case
    when event_time_times >= '07:00:00'
    and event_time_times < '09:00:00' then '早高峰'
    when event_time_times >= '09:00:00'
    and event_time_times < '17:00:00' then '工作时间'
    when event_time_times >= '17:00:00'
    and event_time_times < '20:00:00' then '晚高峰'
    when event_time_times >= '20:00:00' then '休息时间'
    when event_time_times >= '00:00:00'
    and event_time_times < '07:00:00' then '休息时间'
  end as period,
  count(order_id) as get_car_num,
  round(avg(wait_time) / 60, 1) as avg_wait_time,
  round(avg(dispatch_time) / 60, 1) as avg_dispatch_time
from
  (
    SELECT
      t_record.id,
      DATE_FORMAT(t_record.event_time, '%Y-%m-%d') as event_time_date,
      DATE_FORMAT(t_record.event_time, '%H:%i:%s') as event_time_times,
      TIMESTAMPDIFF(SECOND, t_record.event_time, t_order.order_time) as wait_time,
      TIMESTAMPDIFF(SECOND, t_order.order_time, t_order.start_time) as dispatch_time,
      dayofweek(t_record.event_time) as dow,
      t_record.event_time,
      t_record.order_id,
      t_order.order_time,
      t_order.start_time
    from
      tb_get_car_record as t_record
      left join tb_get_car_order as t_order on t_record.order_id = t_order.order_id
    where
      WEEKDAY(t_record.event_time) not in (5,6)
  ) as t1
group by
  case
    when event_time_times >= '07:00:00'
    and event_time_times < '09:00:00' then '早高峰'
    when event_time_times >= '09:00:00'
    and event_time_times < '17:00:00' then '工作时间'
    when event_time_times >= '17:00:00'
    and event_time_times < '20:00:00' then '晚高峰'
    when event_time_times >= '20:00:00' then '休息时间'
    when event_time_times >= '00:00:00'
    and event_time_times < '07:00:00' then '休息时间'
  end
order by get_car_num asc
```


附参考：
MySQL判断星期几的方法对比：
[使用mysql判断日期是星期几_大胖东的博客-CSDN博客](https://blog.csdn.net/qq_42583263/article/details/124887900)

![image.png](https://cdn.nlark.com/yuque/0/2023/png/21613696/1673356280950-036ed0be-5752-4fa1-95a1-d1d309966652.png#averageHue=%23efefef&clientId=u0ca86b8d-9e99-4&from=paste&id=u07e50f09&originHeight=2658&originWidth=385&originalType=url&ratio=1&rotation=0&showTitle=false&size=274705&status=done&style=none&taskId=ua6986218-238c-4b8a-8571-2fb051e91a4&title=)