﻿<#-----------------------------------------------------------------------------
  ScheduleIPAddressMailer.ps1

  Author: Robert C. Cain | @ArcaneCode | info@arcanetc.com
          http://arcanecode.me

  This script will create Windows Scheduled Tasks to execute the PowerShell
  script IPAddressMailer.ps1. 
  
  Note that the IPAddressMailer.ps1 script must reside in a folder outside 
  the standard user folders such as Documents or their OneDrive folder. 
  We suggest you create a folder named C:\IPAddressMailer to hold all 
  scripts for IPAddressMailer.
  
  See the notes within this script for items you as a user of this script
  will want to update. 

  If you want to remove all tasks created with this script, a companion
  script UnscheduleIPAddressMailer.ps1 is provided. 

  While designed to schedule the IPAddressMailer.ps1 script, this script
  could be easily adapted to setup scheduled tasks to run any PowerShell 
  script. 

  This script was designed to be run by the average person who may not be
  a PowerShell expert. As such I included many Write-Host statements, 
  to give the user feedback that things were working. 

  If you are a system admin who will regularly run this in unattended mode,
  just remove the Write-Host cmdlet calls. 
   
  This code is Copyright (c) 2018 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
 
  This code may be used in your projects. 

  This code may NOT be reproduced in whole or in part, in print, video, or
  on the internet, without the express written consent of the author.

-----------------------------------------------------------------------------#>


<#-----------------------------------------------------------------------------
  This first section contains the items that you, the user will need to 
  update in order to use the script. 
-----------------------------------------------------------------------------#>

# Enter the times of day you want the script to email you. Use the format 
# of hour:minute followed by the am/pm. 
#
# Example: 6:15am 10:20am 1:33pm etc.
#
# To add more times, just put a comma after the last time, hit enter, then 
# add the new time. Or you can remove times by just deleting them. 

$timesToRun = @('12:00am',
                '01:00am',
                '02:00am',
                '03:00am',
                '04:00am',
                '05:00am',
                '06:00am',
                '07:00am',
                '08:00am',
                '09:00am',
                '10:00am',
                '11:00am',
                '12:00pm',
                '01:00pm',
                '02:00pm',
                '03:00pm',
                '04:00pm',
                '05:00pm',
                '06:00pm',
                '07:00pm',
                '08:00pm',
                '09:00pm',
                '10:00pm',
                '11:00pm'
               )


# By default the script assumes you are putting the IPAddressMailer.ps1 file
# in it's own folder. If you change it, be sure to update the path below. 
#
# Note you need to put it in a folder outside a user area. In other words don't
# use the documents folder, or OneDrive, use something on the C drive.

$path = 'C:\IPAddressMailer'
$script = "$path\IPAddressMailer.ps1"

<#-----------------------------------------------------------------------------
  This next section you as a user shouldn't have to touch. It will create
  tasks in the Windows Task Scheduler, all tasks will begin with the 
  title SendExternalIP_at_ with the time to run ending the task name.   
-----------------------------------------------------------------------------#>

# This creates a task action object, it will hold the program to be executed,
# plus any parameters for you want the scheduler to run. Here we need to run
# the PowerShell executable, then pass in the path and name of our script.
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
  -Argument "-NoProfile -WindowStyle Hidden -File `"$script`""

# If you want to confirm the action, just uncomment the next two lines
# Write-Host "Action to execute: $($action.Execute)"
# Write-Host "Arguments: $($action.Arguments)"

# For each time in the array, create a Windows Scheduled Task
foreach ($timeToRun in $timesToRun)
{
  # We'll include the time as part of the task name, unfortunately
  # colons are not allowed in the names so we have to replace with 
  # something else. I just used an underscore.
  $taskName = "SendExternalIP_at_$($timeToRun -replace ':', '_')"

  # A trigger just indicates the frequency (Daily, weekly, etc) and the
  # time of day to run. We're using the times from the array above.
  $trigger = New-ScheduledTaskTrigger -Daily -at $timeToRun

  # Let's create a nice description so anyone looking at this knows
  # just what's going on and where to get more info
  $description = @"
At $timeToRun daily E-Mail the External IP Address using the PowerShell script $script
 These tasks generated by the IPAddressMailer scripts written by Robert C. Cain, @ArcaneCode.
 Scripts Copyright 2018, all rights reserverd.
 No warranty or guarentee is implied or expressly granted.
 For more info see http://arcanecode.me, or go to his github site at http://arcanecode.gallery
 Look in the PowerShell folder for the IPAddress folder.
 For more info email Robert at info@arcanetc.com
"@

  # Next we need to create specific settings for this task. In this case we
  # want the task to run without any visible UI, run on batteries, and wake the PC
  # if needed to run.
  $settings = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries -WakeToRun
  
  # We then need to tell it who to run as. Using a SYSTEM account will
  # allow it to run even if the user is not logged in. It is for this
  # reason you will have to run this script in admin mode.
  $prin = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" `
                                     -LogonType ServiceAccount `
                                     -RunLevel Highest

  # Now we know what to run (the $action), what to name it ($taskName),
  # when to run it ($trigger), and what it does ($description).
  # We've also generated settings ($settings) and indicated who the
  # script should run as ($prin). At the end we add the -Force switch 
  # so it will recreate the task in case it already exists. 
  # Finally we pipe to Out-Null so it suppresses the
  # message created from the Register-ScheduledTask cmdlet.
  #
  # We're finally ready to schedule the task!
  Write-Host "Creating task $taskName" -ForegroundColor Yellow
  Register-ScheduledTask -Action $action `
                         -Trigger $trigger `
                         -TaskName $taskName `
                         -Description $description `
                         -Settings $settings `
                         -Principal $prin `
                         -Force | Out-Null

}

# As a final step, display a list of all the scheduled tasks we just created, 
# as a way to confirm all went well.
Write-Host 'Here are the list of created tasks.' -ForegroundColor Green
Get-ScheduledTask -TaskPath '\' -TaskName 'SendExternalIP_at*'


