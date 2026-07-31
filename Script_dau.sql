with daily_active_users as (
	select 
		date_trunc('day', u.entry_at) as date_from_calendar,
		count(distinct u.user_id) as daily_active_users_cnt
	from userentry u 
	where u.entry_at between '2022-01-01'::timestamp and
		'2022-01-01'::timestamp + interval '150 days'
	group by date_from_calendar
),
time_period as (
	select date_from_calendar
	from generate_series('2022-01-01'::timestamp, 
		'2022-01-01'::timestamp + interval '150 days', '1 day') as date_from_calendar
),
dau_all_period as (
	select 
		tp.date_from_calendar,
		coalesce(dau.daily_active_users_cnt, 0) as daily_active_users_cnt
	from daily_active_users dau
	right join time_period tp on dau.date_from_calendar = tp.date_from_calendar 
)
select 
	dau_ap.*,
	max(dau_ap.daily_active_users_cnt) over(order by dau_ap.date_from_calendar) as max_dau_cnt,
	dau_ap.daily_active_users_cnt - max(dau_ap.daily_active_users_cnt) 
		over(order by dau_ap.date_from_calendar) as diff_dau
from dau_all_period dau_ap
order by date_from_calendar

