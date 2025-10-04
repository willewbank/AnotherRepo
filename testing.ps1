$alerts = Import-Csv -Path ./sample.csv

$subs = @()

foreach ($alert in $alerts){
    if($subs -notcontains $alert.SubscriptionId){
        $subs += $alert.SubscriptionId
    }
}
$formSubs = @()

foreach ($sub in $subs){
    $formSub = @{
        SubscriptionId = $sub
        ResourceGroups = @()
    }
    foreach ($alert in $alerts){
        if($sub -eq $alert.SubscriptionId){       
            if($formSub.ResourceGroups -notcontains $alert.ResourceGroup){
                $formSub.ResourceGroups += $alert.ResourceGroup
            }
        }
    }
    $formRgs = @()
    foreach( $rg in $formSub.ResourceGroups){
        $formRg = @{
            ResourceGroup = $rg
            Resources = @()
        }
        foreach ($alert in $alerts){
            if($sub -eq $alert.SubscriptionId){      
                if ($rg -eq $alert.ResourceGroup){
                    if($formRg.Resources -notcontains $alert.Name){
                        $formRg.Resources += $alert.Name
                    }
                }
            }
        }
        $formResources = @()
        foreach ($resource in $formRg.Resources){
            $formResource = @{
                Resource = $resource
                Tags = @{
                    SupportTeam = 'Cloud Operations'
                }
            }
            $formResources += $formResource
        }
        $formRg.Resources = $formResources
        $formRgs += $formRg
    }
    $formSub.ResourceGroups = $formRgs
    $formSubs += $formSub
}

$formSubs | ConvertTo-Json -Depth 100 | Set-Content -Path ./out.json