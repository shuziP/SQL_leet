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