#kill FOFs
$pids = gwmi win32_process -filter "name='FOFSERV.exe' AND commandline like '%/Subsets/%_BATCH_%/%'" | select-object -expandproperty processid
foreach($xpid in $pids){echo stop-process-id $xpid -force}

#dump mem and cpu for all procs every 5s
mkdir c:\temp 2>&1 |
out-null; $top = 10;$intv = 5;
while(1){
	$processMemoryUsage = gwmi Win32_PerfFormattedData_PerfProc_Process |
		where-object {$_.name -notin @('_Total','Idle','vmmemMDAG','Memory Compression')} |
			sort-object workingsetprivate, PercentProcessorTime -desc |
				select-object  @{Expression={date}}, name, @{N='mem';E={[math]::round($_.workingsetprivate / 1mb)}}, @{N='cpu';E={$_.PercentProcessorTime}} -first $top;
	
	foreach($proc in $processMemoryUsage){echo "$($proc.date), $($proc.name), $($proc.mem), $($proc.cpu)" >> "C:\temp\$($env:COMPUTERNAME).stats.csv" };
	sleep $intv;
}

#find FOF procs and show stats
$tenv='SVB-PROD';
while(1){
	date
	gwmi Win32_Process |
		Where-Object {$_.name -eq 'FOFSERV.EXE' -and $_.commandline -like "*\Subsets\$($tenv)*"} |
			Select-Object `
			@{E={date}},
			Name,
			ProcessId,
			@{N='StartTime';E={$_.ConvertToDateTime($_.CreationDate)}},
			@{N='WS';E={ [math]::round($_.ws/1mb)}},
			@{N='CPU';E={(gwmi Win32_PerfFormattedData_PerfProc_Process -filter "idprocess=$($_.ProcessId)" | Select-Object -expandproperty PercentProcessorTime)}},
			@{N='list';E={([regex]::match($_. commandline, '\\Subsets\\([\-A-Z_]+)').groups[1])}} | ft;
	sleep 10
}

#find SOS procs and show stats
while(1){
	date;
	gwmi Win32_Process |
		Where-Object {$_.name -LIKE 'SOS*' }|
			Select-Object `
			@{E={date}},
			Name,
			ProcessId,
			@{N='StartTime';E={$_.ConvertToDateTime($_.CreationDate)}},
			@{N='WS';E={ [math]::round($_.ws/1mb)}},
			@{N='CPU';E={(gwmi Win32_PerfFormattedData_PerfProc_Process -filter "idprocess=$($_.ProcessId)" | Select-Object -expandproperty PercentProcessorTime)}}|
				ft;
	sleep 10
}
