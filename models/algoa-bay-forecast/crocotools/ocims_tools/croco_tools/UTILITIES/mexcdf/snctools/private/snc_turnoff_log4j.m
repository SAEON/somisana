function snc_turnoff_log4j()
% These next few steps are needed to stop annoying warning messages
% from log4j.

if exist('org.apache.log4j.BasicConfigurator','class')
    org.apache.log4j.BasicConfigurator.configure();
    level = org.apache.log4j.Level.OFF;
    logger = org.apache.log4j.Logger.getRootLogger();
    logger.setLevel(level);
end
