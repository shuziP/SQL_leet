

**问题**：计算每个用户2021年7月以来每月获得的金币数（该活动到10月底结束，11月1日开始的签到不再获得金币）。结果按月份、ID升序排序。
**注**：如果签到记录的in_time-进入时间和out_time-离开时间跨天了，也只记作in_time对应的日期签到了。

[连续签到领金币__牛客网](https://www.nowcoder.com/questionTerminal/aef5adcef574468c82659e8911bb297f)
代码有问题，待解决
```sql

with t1 as (
	select
		uid,
		date_format(in_time, '%Y%m') as month,
		date_format(in_time, '%Y-%m-%d') as in_time
	from
		tb_user_log
	where
		artical_id = 0
		and sign_in = 1
		and date_format(in_time, '%Y-%m-%d') >= '2021-07-01'
		and date_format(in_time, '%Y-%m-%d') < '2021-11-01'
	group by
		uid,
		date_format(in_time, '%Y%m'),
		date_format(in_time, '%Y-%m-%d')
)

select 
*
# 	uid,
#     month,
# sum(coin) as coin
from 
(SELECT
	uid,
    month,
rn2,
(	FLOOR(max(rn3) / 7) * (7 + 2 + 6) + (
		case
			when mod(max(rn3), 7) >= 3 then mod(max(rn3), 7) + 2
			else mod(max(rn3), 7)
		end
	)) as coin
FROM
	(
		select
			uid,
            month,
			in_time,
			(rn - day_diff) as rn2,
			# rn2 相同，则为连续日期
			row_number() over(
				partition by uid,
(rn - day_diff)
				order by
					in_time asc
			) as rn3
		from
			(
				select
					t1.uid,
                    t1.month,
					t1.in_time,
					t_min.in_time_min,
					cast(datediff(t1.in_time, t_min.in_time_min) as signed) as day_diff,
					cast(row_number() over(
						partition by t1.uid
						order by
							t1.in_time asc
					)  as signed) as rn
				from
					t1
					left join (
						select
							uid,
							min(in_time) as in_time_min
						from
							t1
						group by
							uid
					) as t_min on t1.uid = t_min.uid
			) as t2
	) as t3
group by
	uid,
    rn2,
     month) as t4
    # group by
	# uid,
    # month
    order by month asc ,uid asc 
```

评论区高赞题解
[连续签到领金币_牛客题霸_牛客网](https://www.nowcoder.com/practice/aef5adcef574468c82659e8911bb297f)
```sql
WITH t1 AS(
    -- t1表筛选出活动期间内的数据，并且为了防止一天有多次签到活动，distinct 去重
    SELECT
        DISTINCT uid,
        DATE(in_time) dt,
        DENSE_RANK() over(
            PARTITION BY uid
            ORDER BY
                DATE(in_time)
        ) rn -- 编号
    FROM
        tb_user_log
    WHERE
        DATE(in_time) BETWEEN '2021-07-07' AND '2021-10-31'
        AND artical_id = 0
        AND sign_in = 1
),
t2 AS (
    SELECT
        *,
        DATE_SUB(dt, INTERVAL rn day) dt_tmp,
        case
            DENSE_RANK() over(
                PARTITION BY DATE_SUB(dt, INTERVAL rn day),
                uid
                ORDER BY
                    dt
            ) % 7 -- 再次编号
            WHEN 3 THEN 3
            WHEN 0 THEN 7
            ELSE 1
        END as day_coin -- 用户当天签到时应该获得的金币数
    FROM
        t1
)
SELECT
    uid,
    DATE_FORMAT(dt, '%Y%m') ` month `,
    sum(day_coin) coin -- 总金币数
FROM
    t2
GROUP BY
    uid,
    DATE_FORMAT(dt, '%Y%m')
ORDER BY
    DATE_FORMAT(dt, '%Y%m'),
    uid;

```

![image.png](https://cdn.nlark.com/yuque/0/2023/png/21613696/1675584443440-ec96f0f6-9678-47a4-8dd8-cf5708d9f72e.png#averageHue=%23f1f1f1&clientId=udba798e7-05cf-4&from=paste&id=ucb9fc43c&originHeight=1651&originWidth=385&originalType=url&ratio=1&rotation=0&showTitle=false&size=171805&status=done&style=none&taskId=ue36a3241-b14a-4826-a0ab-f922a8ebaab&title=)