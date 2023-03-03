using Microsoft.Azure.Management.ResourceManager.Fluent.Core;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;
using System;

public class Configuration : IConfiguration
{
    public string SubscriptionId { get; init; }
    public string ResourceGroupPrefix { get; init; }
    public string DeploymentName { get; init; }
    public Dictionary<string, string> EnvironmentNamesDict { get; init; }
    public Dictionary<string, string> RegionNamesDict { get; init; }
    public string TemplateFilename { get; init; }
    public string PublicKeyPath { get; init; }

    public Dictionary<Environments, string> Environments { get; init; }
    public Dictionary<RegionTypes, Region> Regions { get; init; }

    public BicepParameters BicepParameters { get; init; }

    public Configuration(string configPath)
    {
        string json = File.ReadAllText(configPath);
        ConfigurationRecord configRecord = JsonConvert.DeserializeObject<ConfigurationRecord>(json);

        this.SubscriptionId = configRecord.SubscriptionId;
        this.ResourceGroupPrefix = configRecord.ResourceGroupPrefix;
        this.DeploymentName = configRecord.DeploymentName;
        this.EnvironmentNamesDict = configRecord.EnvironmentNamesDict;
        this.RegionNamesDict = configRecord.RegionNamesDict;
        this.TemplateFilename = configRecord.TemplateFilename;
        this.PublicKeyPath = configRecord.PublicKeyPath;

        this.Environments = new Dictionary<Environments, string>();
        this.Regions = new Dictionary<RegionTypes, Region>();

        foreach (KeyValuePair<string, string> entry in this.EnvironmentNamesDict)
        {
            Enum.TryParse(entry.Key, out Environments environment);

            this.Environments.Add(environment, entry.Value);
        }

        foreach (KeyValuePair<string, string> entry in this.RegionNamesDict)
        {
            Enum.TryParse(entry.Key, out RegionTypes regionType);
            Region regionValue = Region.Create(entry.Value);

            this.Regions.Add(regionType, regionValue);
        }

        this.BicepParameters = new BicepParameters(
            configRecord.DeploymentParameters,
            this.PublicKeyPath,
            this.Regions[RegionTypes.Primary],
            this.Regions[RegionTypes.Failover]
        );
    }
}
