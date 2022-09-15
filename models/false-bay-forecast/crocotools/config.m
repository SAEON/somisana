d = dotenv('/tmp/somisana/current/.env');

RESTART_FILE_1_PATH = d.env.RESTART_FILE_1_PATH

RUN_DATE = datetime(d.env.RUN_DATE, 'InputFormat','yyyy-MM-dd');
date_now_year=year(RUN_DATE);
date_now_month=month(RUN_DATE);
date_now_day=day(RUN_DATE);

RESTART_DATE = datetime(d.env.RESTART_FILE_DATE, 'InputFormat','yyyy-MM-dd');
date_yesterday_year=year(RESTART_DATE);
date_yesterday_month=month(RESTART_DATE);
date_yesterday_day=day(RESTART_DATE);

delta_days_gfs=d.env.DELTA_DAYS_GFS;

hdays=5;
fdays=5;
