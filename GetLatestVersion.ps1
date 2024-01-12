# Gets download url of latest release with an asset
Function Get-LatestVersionNumber {
    # Define parameters
    param(
        $Repository
    )
    
    # Define local variables
    $releases = "https://api.github.com/repos/$Repository/releases"
    
    # Get latest version
    Write-Host "Determining latest release of $Repository ..."
    
    # Get the tags
    $tags = (Invoke-WebRequest $releases -UseBasicParsing | ConvertFrom-Json)
    
    # Find the latest version with a downloadable asset
    foreach ($tag in $tags) {
        if ($tag.assets.Count -gt 0) {
            return $tag.tag_name
        }
    }

    # Return the version
    return $null
}

# Get latest version of Liquibase
$latestLiquibaseVersion = Get-LatestVersionNumber -Repository "liquibase/liquibase"

# Compare to the worktools tag
$workerToolsTags = Invoke-RestMethod "https://registry.hub.docker.com/v1/repositories/octopuslabs/liquibase-workertools/tags"
$matchingTag = $workerToolsTags | Where-Object { $_.name -eq $latestLiquibaseVersion }

if ($null -ne $matchingTag)
{
    Write-Host "Docker container already has latest version of flyway"
}
else
{
    Write-Host "We need to upgrade the flyway container to $latestLiquibaseVersion"
}