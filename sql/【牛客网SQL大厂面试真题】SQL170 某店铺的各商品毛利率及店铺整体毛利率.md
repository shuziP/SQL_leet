[某店铺的各商品毛利率及店铺整体毛利率__牛客网](https://www.nowcoder.com/questionTerminal/65de67f666414c0e8f9a34c08d4a8ba6)

问题：请计算2021年10月以来店铺901中商品毛利率大于24.9%的商品信息及店铺整体毛利率。

注：商品毛利率=(1-进价/平均单件售价)*100%；
店铺毛利率=(1-总进价成本/总销售收入)*100%。
结果先输出店铺毛利率，再按商品ID升序输出各商品毛利率，均保留1位小数。

```sql
with v1 as (
  select
  order_detail.order_id,
  order_detail.product_id,
  order_detail.price,
  order_detail.cnt,
  order_overall.total_amount,
  order_overall.total_cnt,
  product_info.in_price
  from
  tb_order_detail as order_detail
  left join tb_order_overall as order_overall on order_detail.order_id = order_overall.order_id
  left join tb_product_info as product_info on order_detail.product_id = product_info.product_id
  where
  date_format(event_time, '%Y-%m') >= '2021-10'
  and shop_id = '901'
)
select
product_id,
concat(
    (round((1 - (sum(in_price) / sum(out_price))) * 100, 1)),
    '%'
  )
from
(
    select
    product_id,
    in_price * cnt as in_price,
    price * cnt as out_price,
    cnt
    from
    v1
  ) as t1
group by
product_id
```
step2
```sql
with v1 as (
  select
    order_detail.order_id,
    order_detail.product_id,
    order_detail.price,
    order_detail.cnt,
    order_overall.total_amount,
    order_overall.total_cnt,
    product_info.in_price
  from
    tb_order_detail as order_detail
    left join tb_order_overall as order_overall on order_detail.order_id = order_overall.order_id
    left join tb_product_info as product_info on order_detail.product_id = product_info.product_id
  where
    date_format(event_time, '%Y-%m') >= '2021-10'
    and shop_id = '901'
  order by
    product_id
)
select
  '店铺汇总' as product_id,
  concat(
    (round((1 - (sum(in_price) / sum(out_price))) * 100, 1)),
    '%'
  ) as profit_rate
from
  (
    select
      product_id,
      in_price * cnt as in_price,
      price * cnt as out_price,
      cnt
    from
      v1
  ) as t1
union all
select
  product_id,
  concat(
    (round((1 - (sum(in_price) / sum(out_price))) * 100, 1)),
    '%'
  ) as profit_rate
from
  (
    select
      product_id,
      in_price * cnt as in_price,
      price * cnt as out_price,
      cnt
    from
      v1
  ) as t1
group by
  product_id
```
完整代码
```sql
with v1 as (
  select
    order_detail.order_id,
    order_detail.product_id,
    order_detail.price,
    order_detail.cnt,
    order_overall.total_amount,
    order_overall.total_cnt,
    product_info.in_price
  from
    tb_order_detail as order_detail
    left join tb_order_overall as order_overall on order_detail.order_id = order_overall.order_id
    left join tb_product_info as product_info on order_detail.product_id = product_info.product_id
  where
    date_format(event_time, '%Y-%m') >= '2021-10'
    and shop_id = '901'
    and status = 1
  order by
    product_id
)
select
  '店铺汇总' as product_id,
  concat(
    (round((1 - (sum(in_price) / sum(out_price))) * 100, 1)),
    '%'
  ) as profit_rate
from
  (
    select
      product_id,
      in_price * cnt as in_price,
      price * cnt as out_price,
      cnt
    from
      v1
  ) as t1
union all
select
  product_id,
  concat(profit_rate, '%') as profit_rate
from
  (
    select
      product_id,
      (round((1 - (sum(in_price) / sum(out_price))) * 100, 1)) as profit_rate
    from
      (
        select
          product_id,
          in_price * cnt as in_price,
          price * cnt as out_price,
          cnt
        from
          v1
      ) as t1
    group by
      product_id
  ) as t1_tem
where
  profit_rate > 24.9
```

![image.png](https://cdn.nlark.com/yuque/0/2023/png/21613696/1674653630284-d1a0ee6b-4dcc-4972-b91b-0e4a29eb2f11.png#averageHue=%23f0f0f0&clientId=ue9e8b794-e2d2-4&from=paste&height=930&id=ubfe25b94&originHeight=1860&originWidth=385&originalType=binary&ratio=1&rotation=0&showTitle=false&size=198630&status=done&style=none&taskId=ud1ae20c8-26cf-48ff-ad54-5e0e7ad6974&title=&width=192.5)