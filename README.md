# Datadog

This package helps you maintain Datadog tags using PowerShell.

## Getting Started

### Authentication

Use the **Set-DatadogAuthentication** function with appropriate parameters. *All operations require an API Key*. Some also require an *Application Key*. Therefore, the *-ApiKey* Parameter is required, but the -ApplicationKey Parameter is optional.

Example
>$request_headers = (Set-DatadogAuthentication -ApiKey "&lt;your api key&gt;")

or
>$request_headers = Set-DatadogAuthentication -ApiKey "&lt;your api key&gt;" -ApplicationKey "&lt;your application key&gt;"

Both methods call the authentication validation endpoint and verify that it received a json result with a key named "valid" with the value of "True". If it fails or credentials are not valid, it returns **false**.

## Getting Hosts

### Get-DatadogHostList

Use this function do get a list of all of the hosts. Can optionally define sort order and direction. Can also specify to return metadata.

The below command demonstrates usage with default values for all parameters.

>&#36;host_list = (Get-DatadogHostList -Headers **$Headers** -IncludeMetadata $false -Count 1000 -Start 0 -SortField "name" -SortDirection "asc")

## Getting Tags

### Getting Tags By Host

## Tagging Hosts

### Adding Tags By Host

### Updating all tags

### Tagging Hosts By Tag

TODO: Create examples
