# Getting user inputs
$fname = Read-Host -Prompt "Enter your First name "
$lname = Read-Host -Prompt "Enter your Last name "
$email = Read-Host -Prompt "Enter your Email ID "
$UPN = "$fname.$lname" + "@test.local"
$Samid = "$fname.$lname"
$pass = Read-Host "Enter a Password" -AsSecureString

# verify user 

if (( get-aduser -filter {SamAccountName -eq $samid})  -ne $null){

Write-Host " user $samid is already exist , Please re run and try with different Name" -ForegroundColor Red

exit

}

#create user and add groups 

else{

New-ADUser -Name "$fname $lname" -SamAccountName $Samid -Description "test" -AccountPassword $pass -Enabled:$true  -UserPrincipalName $UPN -GivenName $fname -Surname $lname -EmailAddress $email

Write-Host "user $Samid created sucessfully" -ForegroundColor Green


Write-Host "Choose the Group, Multiple can be selected" -BackgroundColor DarkGreen

$adgrps= @(Get-ADGroup -Filter * | select Name | Out-GridView -Title 'Choose the Group, Multiple can be selected ' -PassThru)


Write-Host "Thanks for the selection" -BackgroundColor DarkGreen

foreach ( $adgrp in $adgrps){

Add-ADGroupMember $adgrp.'Name' -Members $Samid
Write-Host "Group "$adgrp.'Name'" added" 

}


Write-Host "Ad user creation completed , Thank You ! " -ForegroundColor DarkGreen


}

#send email to admin


$mem = Get-ADPrincipalGroupMembership $Samid | select name

$EmailBody="

Greetings,

 <p> AD account '$samid' has been created on <b>   test.local domain </b>


<p> Name : '$fname $lname' <br /> </p>

<p> Email ID : '$email' <br /> </p>



Sincerely,  
<br />
Dev AD Team <br />
  </p> "

Send-MailMessage -From noreply@test.local -To adminid@fisdev.local -SmtpServer mail.test.local -port 25 -Body $EmailBody -BodyAsHtml -Subject ADuser_creation
