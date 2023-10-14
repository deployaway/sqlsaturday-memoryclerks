USE master;
GO

-- memory clerks
SELECT
    [type],
    [name],
    pages_kb,
    virtual_memory_reserved_kb,
    virtual_memory_committed_kb,
    pages_kb * 1024 / page_size_in_bytes AS [page_count]
FROM
    sys.dm_os_memory_clerks
ORDER BY
    [type],
    [name]

-- memory brokers
SELECT * FROM sys.dm_os_ring_buffers WHERE ring_buffer_type = 'RING_BUFFER_MEMORY_BROKER';

-- lets see the beefiest clerks
SELECT
    [type],
    [name],
    pages_kb,
    virtual_memory_reserved_kb,
    virtual_memory_reserved_kb,
    pages_kb * 1024 / page_size_in_bytes AS [page_count]
FROM
    sys.dm_os_memory_clerks
ORDER BY
    pages_kb DESC

-- Examples:
-- MEMORYCLERK_SOSNODE - sql server's main "memory grab" from the OS
-- MEMORYCLERK_SQLBUFFERPOOL - buffer pool. in-memory pages with the data
-- MEMORYCLERK_SQLCLR - memory clerk for CLR runtime


SELECT
    [type],
    SUM(pages_kb) AS pages_kb,
    SUM(virtual_memory_reserved_kb) AS virtual_memory_reserved_kb,
    SUM(virtual_memory_committed_kb) as virtual_memory_committed_kb,
    SUM(pages_kb * 1024 / page_size_in_bytes) AS [page_count]
FROM
    sys.dm_os_memory_clerks WITH (NOLOCK)
GROUP BY 
    [type]
ORDER BY
    pages_kb DESC

-- unique clerks: 80+ of them!
SELECT
    DISTINCT(SUBSTRING([name],0,12))
AS
    clerk_name_prefix
FROM
    sys.dm_os_memory_clerks

SELECT DISTINCT
    parent_memory_broker_type,
    type,
    name
from
    sys.dm_os_memory_clerks

SELECT
    [type],
    [name],
    pages_kb,
    virtual_memory_reserved_kb,
    virtual_memory_committed_kb,
    pages_kb * 1024 / page_size_in_bytes AS [page_count]
FROM
    sys.dm_os_memory_clerks
ORDER BY
    pages_kb DESC







-- looking at memory
DBCC MEMORYSTATUS

SELECT
    cntr_value, *
FROM
    sys.dm_os_performance_counters
WHERE
    [counter_name] IN ('Stolen Server Memory (KB)')
        

