

**问题**：统计每天的日活数及新用户占比
**注**：

- 新用户占比=当天的新用户数÷当天活跃用户数（日活数）。
- 如果**in_time-进入时间**和**out_time-离开时间**跨天了，在两天里都记为该用户活跃过。
- 新用户占比保留2位小数，结果按日期升序排序。

[每天的日活数及新用户占比__牛客网](https://www.nowcoder.com/questionTerminal/dbbc9b03794a48f6b34f1131b1a903eb)
```sql
# 此题的判题有bug，测试用例未考虑一个用户连续跨天的情况
select
    u_log.dt,
    u_log.uid_cnt as dau,
    case when t_new_user.new_user_cnt is null then 0.00
    else round(t_new_user.new_user_cnt/u_log.uid_cnt,2)
    end as uv_new_ratio
from
    (
        select dt,sum(uid_cnt) as uid_cnt from 
        (


        select
            date_format(out_time, '%Y-%m-%d') as dt,
            count(uid) as uid_cnt
        from
            tb_user_log
        group by
            date_format(out_time, '%Y-%m-%d')
        union all
        select
            date_format(in_time, '%Y-%m-%d') as dt,
            count(uid) as uid_cnt
        from
            tb_user_log
        where
            -- timestampdiff(day, in_time, out_time) > 0
            timestampdiff(day, date_format(in_time,'%Y-%m-%d'), date_format(out_time,'%Y-%m-%d'))
        group by
            date_format(in_time, '%Y-%m-%d')
        ) as tb_user_log_2
        group by dt
            
    ) as u_log
    left join (
        select
            first_in as dt,
            count(uid) as new_user_cnt
        from
            (
                select
                    uid,
                    date_format(min(in_time), '%Y-%m-%d') first_in
                from
                    tb_user_log
                group by
                    uid
            ) as user_frist_in
        group by
            first_in
    ) as t_new_user on u_log.dt = t_new_user.dt

```



![image.png](https://cdn.nlark.com/yuque/0/2023/png/21613696/1675584156520-fda76bf5-7eb2-4463-9765-ffa987fbca7d.png#averageHue=%23f3f3f3&clientId=ua70ca930-4212-4&from=paste&id=uf1c3adbe&originHeight=1480&originWidth=385&originalType=url&ratio=1&rotation=0&showTitle=false&size=137863&status=done&style=none&taskId=ud62d4b57-1951-4806-baab-e074fe77887&title=)