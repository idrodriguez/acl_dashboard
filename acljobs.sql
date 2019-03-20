SELECT TOP 25
sysjobhistory.run_status,
LEFT(CAST(sysjobhistory.run_date AS VARCHAR),4)+ '-'
+SUBSTRING(CAST(sysjobhistory.run_date AS VARCHAR),5,2)+'-'
+SUBSTRING(CAST(sysjobhistory.run_date AS VARCHAR),7,2) last_run_date, 
CASE 
    WHEN LEN(CAST(sysjobhistory.run_time AS VARCHAR)) = 6  
    THEN SUBSTRING(CAST(sysjobhistory.run_time AS VARCHAR),1,2) 
        +':' + SUBSTRING(CAST(sysjobhistory.run_time AS VARCHAR),3,2)
        +':' + SUBSTRING(CAST(sysjobhistory.run_time AS VARCHAR),5,2)
    WHEN LEN(CAST(sysjobhistory.run_time AS VARCHAR)) = 5
    THEN '0' + SUBSTRING(CAST(sysjobhistory.run_time AS VARCHAR),1,1) 
        +':'+SUBSTRING(CAST(sysjobhistory.run_time AS VARCHAR),2,2)
        +':'+SUBSTRING(CAST(sysjobhistory.run_time AS VARCHAR),4,2)
    WHEN LEN(CAST(sysjobhistory.run_time AS VARCHAR)) = 4
    THEN '00:' 
        + SUBSTRING(CAST(sysjobhistory.run_time AS VARCHAR),1,2)
        +':' + SUBSTRING(CAST(sysjobhistory.run_time AS VARCHAR),3,2)
    WHEN LEN(CAST(sysjobhistory.run_time AS VARCHAR)) = 3
    THEN '00:' 
        +'0' + SUBSTRING(CAST(sysjobhistory.run_time AS VARCHAR),1,1)
        +':' + SUBSTRING(CAST(sysjobhistory.run_time AS VARCHAR),2,2)
    WHEN LEN(CAST(sysjobhistory.run_time AS VARCHAR)) = 2  THEN '00:00:' + CAST(sysjobhistory.run_time AS VARCHAR)
    WHEN LEN(CAST(sysjobhistory.run_time AS VARCHAR)) = 1  THEN '00:00:' + '0'+ CAST(sysjobhistory.run_time AS VARCHAR)
END last_run_time, 
sysjobhistory.run_duration/100%100 run_duration_minutes
FROM msdb.dbo.sysjobhistory sysjobhistory
JOIN msdb.dbo.sysjobs sysjobs ON sysjobs.job_id = sysjobhistory.job_id
WHERE sysjobhistory.step_name = 'YourStepName' AND sysjobs.name = 'YourJobName'
ORDER BY last_run_date DESC, last_run_time DESC