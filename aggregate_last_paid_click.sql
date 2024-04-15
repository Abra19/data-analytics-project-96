 with leads_visitors as (
    select
        s.visitor_id,
        s.source as utm_source,
        s.medium as utm_medium,
        s.campaign as utm_campaign,
        l.lead_id,
        l.amount,
        l.created_at,
        l.status_id,
        date(s.visit_date) as visit_date,
        row_number() over (
            partition by s.visitor_id
            order by s.visit_date desc
        ) as rn
    from sessions as s
    left join leads as l
        on
            s.visitor_id = l.visitor_id
            and s.visit_date <= l.created_at
    where
        s.medium in ('cpc', 'cpm', 'cpa', 'youtube', 'cpp', 'tg', 'social')
),

leads_last_visits as (
    select * from leads_visitors
    where rn = 1
),

partners as (
    select
        date(campaign_date) as ads_date,
        utm_source,
        utm_medium,
        utm_campaign,
        sum(daily_spent) as total_cost
    from vk_ads
    group by
        ads_date,
        utm_source,
        utm_medium,
        utm_campaign
    union all
    select
        date(campaign_date) as ads_date,
        utm_source,
        utm_medium,
        utm_campaign,
        sum(daily_spent) as total_cost
    from ya_ads
    group by
        ads_date,
        utm_source,
        utm_medium,
        utm_campaign
)

select
    l.visit_date,
    count(*) as visitors_count,
    l.utm_source,
    l.utm_medium,
    l.utm_campaign,
    p.total_cost,
    count(*) filter (where l.lead_id is not null) as leads_count,
    count(*) filter (where l.status_id = 142) as purchases_count,
    sum(l.amount) filter (where l.status_id = 142) as revenue
from leads_last_visits as l
left join partners as p
    on
        l.visit_date = p.ads_date
        and l.utm_source = p.utm_source
        and l.utm_medium = p.utm_medium
        and l.utm_campaign = p.utm_campaign
group by
    l.utm_source,
    l.utm_medium,
    l.utm_campaign,
    p.total_cost,
    l.visit_date
order by
    revenue desc nulls last,
    l.visit_date asc,
    l.utm_campaign desc,
    visitors_count asc,
    l.utm_source asc,
    l.utm_medium asc
limit 15;
