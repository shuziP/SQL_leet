## Address(题目地址)
**SQL177 国庆期间近7日日均取消订单量**
[国庆期间近7日日均取消订单量_牛客题霸_牛客网](https://www.nowcoder.com/practice/2b330aa6cc994ec2a988704a078a0703)

## Solution Approach(解法)
```sql
select
  finish_time,
  finish_num_7d,
  cancel_num_7d
from
  (
    select
      finish_time,
      round(
        (
          sum(finish_num) over(
            order by
              finish_time asc rows between 6 preceding
              and current row
          ) / 7
        ),
        2
      ) as finish_num_7d,
      round(
        (
          sum(cancel_num) over(
            order by
              finish_time asc rows between 6 preceding
              and current row
          ) / 7
        ),
        2
      ) as cancel_num_7d
    from
      (
        select
          finish_time,
          count(start_time) as finish_num,
          sum(
            case
              when start_time is null then 1
              else 0
            end
          ) as cancel_num
        from
          (
            select
              order_id,
              date_format(finish_time, '%Y-%m-%d') as finish_time,
              date_format(start_time, '%Y-%m-%d') as start_time
            from
              tb_get_car_order
          ) as v1
        group by
          finish_time
        order by
          finish_time asc
      ) as t2
  ) as t3
where
  finish_time between '2021-10-01' and '2021-10-03'
```

本题核心考察开窗函数sum的使用

第一步，先计算计算每日的完成量和取消量，并讲时间格式转换成年月日（'%Y-%m-%d'）
```sql
select
  finish_time,
  count(start_time) as finish_num,
  sum(
    case
      when start_time is null then 1
      else 0
    end
  ) as cancel_num
from
  (
    select
      order_id,
      date_format(finish_time, '%Y-%m-%d') as finish_time,
      date_format(start_time, '%Y-%m-%d') as start_time
    from
      tb_get_car_order
  ) as t1
```
把上面的代码段括号括起来，as t2, 然后使用开窗函数 sum() over() 统计当前日期以及往前7天的总量，并7算日均值，最后使用round 函数保留两位小数
```sql
 select
      finish_time,
      round(
        (
          sum(finish_num) over(
            order by
              finish_time asc rows between 6 preceding
              and current row
          ) / 7
        ),
        2
      ) as finish_num_7d,
      round(
        (
          sum(cancel_num) over(
            order by
              finish_time asc rows between 6 preceding
              and current row
          ) / 7
        ),
        2
      ) as cancel_num_7d
    from
      (
        select
          finish_time,
          count(start_time) as finish_num,
          sum(
            case
              when start_time is null then 1
              else 0
            end
          ) as cancel_num
        from
          (
            select
              order_id,
              date_format(finish_time, '%Y-%m-%d') as finish_time,
              date_format(start_time, '%Y-%m-%d') as start_time
            from
              tb_get_car_order
          ) as t1
        group by
          finish_time
        order by
          finish_time asc
      ) as t2
```
为了加深理解，这里这里补充实现近期日的多种写法
上文种的开窗函数，去掉除以7求平均，去掉保留两位小数后，长这样：
```sql
select 
finish_time,
sum(finish_num) over(order by finish_time asc rows between 6 preceding and current row)
sum(cancel_num) over(order by finish_time asc rows between 6 preceding and current row)

from xx
```
rows between ... and ...:Mysql 种的between and 是>= and <= 的意思，两端都是闭区间
6 preceding ： 之前的第6行
current row:关键字，指代统计的当前行
综上，这个语句的意思是
rows between 6 preceding and current row：>=之前的第6行，<=当前行
进行求和，

关于开窗函数<窗口函数> over (partition by <用于分组的列名>                order by <用于排序的列名>)

partition by :分组关键词可以省略，省略后对整个查询的表进行后续的操作


除了用rows between xx and xxx 之外，还可以直接用 6 preceding
```sql
select 
finish_time,
sum(finish_num) over(order by finish_time asc rows 6 preceding)
sum(cancel_num) over(order by finish_time asc rows 6 preceding)


from xx
```

分步骤拆解

```sql
select
      finish_time,
      round(
        (
          sum(finish_num) over(
            order by
              finish_time asc rows between 6 preceding
              and current row
          ) / 7
        ),
        2
      ) as finish_num_7d,
      round(
        (
          sum(cancel_num) over(
            order by
              finish_time asc rows between 6 preceding
              and current row
          ) / 7
        ),
        2
      ) as cancel_num_7d
    from
      (
        select
          finish_time,
          count(start_time) as finish_num,
          sum(
            case
              when start_time is null then 1
              else 0
            end
          ) as cancel_num
        from
          (
            select
              order_id,
              date_format(finish_time, '%Y-%m-%d') as finish_time,
              date_format(start_time, '%Y-%m-%d') as start_time
            from
              tb_get_car_order
          ) as v1
        group by
          finish_time
        order by
          finish_time asc
```


附带看一下牛客网题解区，不用开窗函数的写法，使用了日期差，在where处进行过滤where timestampdiff(day, date(order_time), dt) between 0 and 6
```sql
select
  dt,
  round(finish_num / 7, 2) finish_num_7d,
  round(cancel_num / 7, 2) cancel_num_7d
from
  (
    select
      distinct date(order_time) dt,
      (
        select
          sum(if(start_time is null, 0, 1))
        from
          tb_get_car_order
        where
          timestampdiff(day, date(order_time), dt) between 0 and 6
      ) finish_num,
      (
        select
          sum(if(start_time is null, 1, 0))
        from
          tb_get_car_order
        where
          timestampdiff(day, date(order_time), dt) between 0 and 6
      ) cancel_num
    from
      tb_get_car_order t1
    where
      date(order_time) between '2021-10-01' and '2021-10-03'
  ) t2
```
## Original Problem Description(原题目描述)

![897II3@(F_)F_S96DNBS(RC.png](https://cdn.nlark.com/yuque/0/2023/png/21613696/1673131768737-f375a6a9-b507-40dc-8cb3-464f459c596f.png#clientId=u3a3d37b8-de1a-4&from=paste&height=2582&id=ubfb0a841&originHeight=3228&originWidth=385&originalType=binary&ratio=1&rotation=0&showTitle=false&size=363249&status=done&style=none&taskId=ud9953227-b023-4c85-b2f6-f6883cb0e59&title=&width=308)