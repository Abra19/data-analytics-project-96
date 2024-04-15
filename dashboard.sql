-- visits by date
select
    date(visit_date) as visit_day,
    count(distinct visitor_id) as visitors
from sessions
group by visit_day
order by visit_day;

-- leads by date
select
    date(created_at) as lead_day,
    count(distinct lead_id) as leads
from leads
group by lead_day
order by lead_day;

-- sales by date
select
    date(created_at) as sales_date,
    count(case when status_id = 142 then 1 end) as sales_count
from leads
group by sales_date
order by sales_date;


-- count all visitors, leads, sales
select
    'visitors' as title,
    count(distinct visitor_id) as count
from sessions
union
select
    'leads' as title,
    count(distinct lead_id) as count
from leads
union
select
    'sales' as title,
    count(case when status_id = 142 then 1 end) as count
from leads
order by count desc;


-- campaigns daily costs
with all_sources as (
    select
        campaign_date,
        utm_source,
        utm_medium,
        daily_spent
    from ya_ads
    union all
    select
        campaign_date,
        utm_source,
        utm_medium,
        daily_spent
    from vk_ads
)

select
    date(campaign_date) as campaign_date,
    utm_source,
    sum(daily_spent) as daily_cost
from all_sources
where utm_medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
group by utm_source, campaign_date
order by campaign_date, utm_source;
