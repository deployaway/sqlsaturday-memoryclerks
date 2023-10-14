USE StackOverflow;
GO

-- something simple, to warm up the buffer pool
SELECT TOP 100 * FROM dbo.Posts

-- something to scan much more data
SELECT TOP 1000 Id FROM dbo.Comments WHERE YEAR(CreationDate) = 2010 AND [Text] LIKE '%awesome%';

-- something that takes a long time on the current setup
-- takes 70-90 seconds
SELECT
    TOP 10 c.UserId
FROM
    dbo.Comments AS c
WHERE
    YEAR(c.CreationDate) IN (2016)
GROUP BY
    c.UserId
HAVING COUNT(c.PostId) > 3

-- something with a bit harder execution plan
SELECT TOP 100
    c.UserId
FROM
    dbo.Comments AS c
WHERE
    YEAR(c.CreationDate) IN (2016,2017,2018)
GROUP BY
    c.UserId
HAVING
    COUNT(DISTINCT DATEFROMPARTS(YEAR(c.CreationDate),MONTH(c.CreationDate),DAY(c.CreationDate))) > 3
