<powershell>
Install-WindowsFeature -name Web-Server -IncludeManagementTools


New-Item -Path C:\inetpub\wwwroot\index.html -ItemType File -Force
Add-Content -Path C:\inetpub\wwwroot\index.html "<font face="Verdana" size="5" color="green">"
Add-Content -Path C:\inetpub\wwwroot\index.html "<center><h1>The Green Environment !</h1></center>"
Add-Content -Path C:\inetpub\wwwroot\index.html "</font>"

</powershell>
