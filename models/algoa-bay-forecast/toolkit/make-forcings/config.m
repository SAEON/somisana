d = dotenv('/tmp/somisana/current/.env');

RUN_DATE = datetime(d.env.RUN_DATE, 'InputFormat','yyyy-MM-dd');
RUN_DATE_1 = RUN_DATE - 1;

date_now_year=year(RUN_DATE);
date_now_month=month(RUN_DATE);
date_now_day=day(RUN_DATE);
date_yesterday_year=year(RUN_DATE_1);
date_yesterday_month=month(RUN_DATE_1);
date_yesterday_day=day(RUN_DATE_1);

delta_days_gfs=d.env.DELTA_DAYS_GFS;

hdays=5;
fdays=5;
