-- "physical" memory (whatever docker exposes to ubuntu)
SELECT
    [total_physical_memory_kb]/1024/1024
AS
    total_memory_gb,
    available_physical_memory_kb/1024/1024
AS
    available_memory_gb
FROM
    sys.dm_os_sys_memory


-- set min to 6GB and max to 7GB (container overall has 8GB)
/*
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'min server memory', 5120;
GO
sp_configure 'max server memory', 6144;
GO
RECONFIGURE;
GO
*/

-- memory info
SELECT
    [name],
    [value],
    [value_in_use]
FROM
    sys.configurations
WHERE
    [name] = 'max server memory (MB)' OR [name] = 'min server memory (MB)';

