using System.Collections.Generic;

public record ConfigurationRecord : IConfiguration
{
    public string SubscriptionId { get; init; }
    public string ResourceGroupPrefix { get; init; }
    public string DeploymentName { get; init; }
    public Dictionary<string, string> EnvironmentNamesDict { get; init; }
    public Dictionary<string, string> RegionNamesDict { get; init; }
    public string TemplateFilename { get; init; }
    public string PublicKeyPath { get; init; }

    public DeploymentParameters DeploymentParameters { get; init; }
}
