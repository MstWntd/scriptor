SELECT   SPID       = er.session_id
    ,STATUS         = ses.STATUS
    ,[Login]        = ses.login_name
    ,Host           = ses.host_name
    ,BlkBy          = er.blocking_session_id
    ,DBName         = DB_Name(er.database_id)
    ,CommandType    = er.command
    ,ObjectName     = OBJECT_NAME(st.objectid)
    ,CPUTime        = er.cpu_time
	,StartTime      = SWITCHOFFSET(CONVERT(datetimeoffset, er.start_time), REPLACE(CAST(DATENAME(tzoffset, SYSDATETIMEOFFSET()) AS VARCHAR),'-','+'))
--    ,StartTime      = er.start_time
    ,TimeElapsed    = CAST(GETDATE() - er.start_time AS TIME)
    ,SQLStatement   = st.text
FROM    sys.dm_exec_requests er
    OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
    LEFT JOIN sys.dm_exec_sessions ses
    ON ses.session_id = er.session_id
LEFT JOIN sys.dm_exec_connections con
    ON con.session_id = ses.session_id
WHERE   st.text IS NOT NULL AND st.text NOT LIKE '%er.session_id%'


SELECT 
	t.text AS 'SQL'
	, SWITCHOFFSET(CONVERT(datetimeoffset, s.last_execution_time), REPLACE(CAST(DATENAME(tzoffset, SYSDATETIMEOFFSET()) AS VARCHAR),'-','+')) AS 'Last Exection Time'
	, (CAST(s.last_elapsed_time AS MONEY) / (1000*1000)) / CAST(60.0 AS MONEY) AS 'Duration (Secs)'
	, s.last_elapsed_time AS 'Duration (micros)'
FROM sys.dm_exec_cached_plans AS p
INNER JOIN sys.dm_exec_query_stats AS s
	ON p.plan_handle = s.plan_handle
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS t
WHERE t.text NOT LIKE '%er.session_id%' AND t.text NOT LIKE '%dba_%'
ORDER BY  s.last_execution_time DESC;

------------
SELECT SYSDATETIMEOFFSET() AS 'Sys DateTime', GETUTCDATE() AS 'UTC DateTime';

SELECT sqlserver_start_time, SYSDATETIMEOFFSET()
FROM sys.dm_os_sys_info;

SELECT @@VERSION AS 'Version';

-----FIND COLUMN-----
sp_MSforeachdb 'select 
    ''?'' AS DatabaseName, o.name AS TableName,c.name AS ColumnName
    from sys.columns            c
        inner join ?.sys.objects  o on c.object_id=o.object_id
    --WHERE ''?'' NOT IN (''master'',''msdb'',''tempdb'',''model'')
    order by o.name,c.column_id'
---OR---
SELECT
    s.name as ColumnName
        ,sh.name+'.'+o.name AS ObjectName
        ,o.type_desc AS ObjectType
        ,CASE
             WHEN t.name IN ('char','varchar') THEN t.name+'('+CASE WHEN s.max_length<0 then 'MAX' ELSE CONVERT(varchar(10),s.max_length) END+')'
             WHEN t.name IN ('nvarchar','nchar') THEN t.name+'('+CASE WHEN s.max_length<0 then 'MAX' ELSE CONVERT(varchar(10),s.max_length/2) END+')'
            WHEN t.name IN ('numeric') THEN t.name+'('+CONVERT(varchar(10),s.precision)+','+CONVERT(varchar(10),s.scale)+')'
             ELSE t.name
         END AS DataType

        ,CASE
             WHEN s.is_nullable=1 THEN 'NULL'
            ELSE 'NOT NULL'
        END AS Nullable
        ,CASE
             WHEN ic.column_id IS NULL THEN ''
             ELSE ' identity('+ISNULL(CONVERT(varchar(10),ic.seed_value),'')+','+ISNULL(CONVERT(varchar(10),ic.increment_value),'')+')='+ISNULL(CONVERT(varchar(10),ic.last_value),'null')
         END
        +CASE
             WHEN sc.column_id IS NULL THEN ''
             ELSE ' computed('+ISNULL(sc.definition,'')+')'
         END
        +CASE
             WHEN cc.object_id IS NULL THEN ''
             ELSE ' check('+ISNULL(cc.definition,'')+')'
         END
            AS MiscInfo
    FROM sys.columns                           s
        INNER JOIN sys.types                   t ON s.system_type_id=t.user_type_id and t.is_user_defined=0
        INNER JOIN sys.objects                 o ON s.object_id=o.object_id
        INNER JOIN sys.schemas                sh on o.schema_id=sh.schema_id
        LEFT OUTER JOIN sys.identity_columns  ic ON s.object_id=ic.object_id AND s.column_id=ic.column_id
        LEFT OUTER JOIN sys.computed_columns  sc ON s.object_id=sc.object_id AND s.column_id=sc.column_id
        LEFT OUTER JOIN sys.check_constraints cc ON s.object_id=cc.parent_object_id AND s.column_id=cc.parent_column_id
    ORDER BY sh.name+'.'+o.name,s.column_id
