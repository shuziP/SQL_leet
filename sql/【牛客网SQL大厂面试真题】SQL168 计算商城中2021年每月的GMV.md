[计算商城中2021年每月的GMV__牛客网](https://www.nowcoder.com/questionTerminal/5005cbf5308249eda1fbf666311753bf)

问题：请计算商城中2021年每月的GMV，输出GMV大于10w的每月GMV，值保留到整数。

注：GMV为已付款订单和未付款订单两者之和。结果按GMV升序排序。

```plsql
select
  month,
  GMV
from
  (
    select
      event_time as month,
      sum(total_amount) as GMV
    from
      (
        select
          date_format(event_time, '%Y-%m') as event_time,
          total_amount,
          status
        from
          tb_order_overall
        where
          date_format(event_time, '%Y') = '2021'
      ) as t1
    where
      status in (1, 0)
    group by
      event_time
  ) as t2
where
  GMV > 100000
order by
  GMV asc
```

![image.png](https://cdn.nlark.com/yuque/0/2023/png/21613696/1673389085051-5bd9daa2-9433-48d3-9159-82b655c40fea.png#averageHue=%23f1f1f1&clientId=uc3a3d884-875c-4&from=paste&id=u6e17a415&originHeight=1442&originWidth=385&originalType=url&ratio=1&rotation=0&showTitle=false&size=150501&status=done&style=none&taskId=u06115cf3-1f66-45b6-921f-d1650f012eb&title=)