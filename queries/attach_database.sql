CREATE DATABASE StackOverflow
    ON (FILENAME = '/sqlserverdata/StackOverflow_1.mdf'),
    (FILENAME = '/sqlserverdata/StackOverflow_2.ndf'),
    (FILENAME = '/sqlserverdata/StackOverflow_3.ndf'),
    (FILENAME = '/sqlserverdata/StackOverflow_4.ndf'),
    (FILENAME = '/sqlserverdata/StackOverflow_log.ldf')
FOR ATTACH;