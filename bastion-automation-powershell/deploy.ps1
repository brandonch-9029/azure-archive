$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$body = "{`"Action`":`"Deploy`"}"

$RequestURL = "https://prod-12.southeastasia.logic.azure.com:443/workflows/3f0971a606444e6685385ac31dc40dbf/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=F9m_vSubElKAaJ1_AKh0DvpthEdetAQu4kq1DdjcmSw"

$response = Invoke-RestMethod $RequestURL -Method 'POST' -Headers $headers -Body $body
