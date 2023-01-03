
# 题目

[https://www.nowcoder.com/questionTerminal/96263162f69a48df9d84a93c71045753](https://www.nowcoder.com/questionTerminal/96263162f69a48df9d84a93c71045753)
![image.png](https://cdn.nlark.com/yuque/0/2022/png/21613696/1662291360223-9630f14b-7e68-43eb-a237-ab37179994e0.png#clientId=ueaffa2e0-0a3c-4&crop=0&crop=0&crop=1&crop=1&errorMessage=unknown%20error&from=paste&id=u9569b0ad&margin=%5Bobject%20Object%5D&name=image.png&originHeight=1594&originWidth=385&originalType=url&ratio=1&rotation=0&showTitle=false&size=163652&status=error&style=none&taskId=u16f1c5a2-20da-43eb-9f59-c17d59b2db3&title=)
```sql

select
    video_id,
    round(sum(v1) / sum(v2), 3)
from
    (
        select
            t1.id,
            t1.video_id,
            sum(
                case
                    when t2.duration <= t1.dif_second then 1
                    else 0
                end
            ) as v1,
            count(t1.id) as v2
        from
            (
                select
                    id,
                    uid,
                    video_id,
                    start_time,
                    end_time,
                    (
                        UNIX_TIMESTAMP(end_time) - UNIX_TIMESTAMP(start_time)
                    ) as dif_second
                from
                    tb_user_video_log
            ) as t1
            left join tb_video_info as t2 on t1.video_id = t2.video_id
        where
            year(t1.start_time) = 2021
            and year(t1.end_time) = 2021
        group by
            t1.id,
            t1.video_id
    ) as t3
group by
    video_id
order by
    round(sum(v1) / sum(v2), 3) desc
```

写习惯了hive，mysql中不能把字符串格式的时间相减，需调用函数获取年份year函数，和时间相减函数 UNIX_TIMESTAMP(end_time) - UNIX_TIMESTAMP(start_time)

# 解题思路
1、先计算tb_user_video_log表中每次观看操作的观看时长、并与视频表连接或得id、观看时长、观看的视频的时长三个字段，并筛选2021年的视频（第一个测试用例不涉及其他年份，第一次提交查了好久没查出来）
2、聚合计算完播率的分子v1和分母v2，活得中间表t3
3、聚合计算每个视频的完播率v1/v2，并保留三位小数。
