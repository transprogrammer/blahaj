using System.IO;
using Microsoft.Azure.Management.ResourceManager.Fluent.Core;
using Newtonsoft.Json;

public class BicepValue
{
    [JsonProperty("value")]
    public string Value { get; set; }

    public BicepValue(string value)
    {
        this.Value = value;
    }
}

public class BicepParameters : IParameters<BicepValue>
{
    [JsonProperty("virtualMachineSize")]
    public BicepValue VirtualMachineSize { get; init; }

    [JsonProperty("storageAccountType")]
    public BicepValue StorageAccountType { get; init; }

    [JsonProperty("virtualNetworkAddressPrefix")]
    public BicepValue VirtualNetworkAddressPrefix { get; init; }

    [JsonProperty("SubnetAddressPrefix")]
    public BicepValue SubnetAddressPrefix { get; init; }

    [JsonProperty("UbuntuServerOffer")]
    public BicepValue UbuntuServerOffer { get; init; }

    [JsonProperty("UbuntuServerSku")]
    public BicepValue UbuntuServerSku { get; init; }

    [JsonProperty("UbuntuServerVersion")]
    public BicepValue UbuntuServerVersion { get; init; }


    [JsonProperty("primaryRegion")]
    public BicepValue PrimaryRegion { get; set; }

    [JsonProperty("failoverRegion")]
    public BicepValue FailoverRegion { get; set; }

    [JsonProperty("publicKey")]
    public BicepValue PublicKey { get; set; }

    public BicepParameters(
        DeploymentParameters deploymentParameters,
        string publicKeyPath,
        Region primaryRegion,
        Region failoverRegion
    )
    {
        this.VirtualMachineSize = new BicepValue(deploymentParameters.VirtualMachineSize);
        this.StorageAccountType = new BicepValue(deploymentParameters.StorageAccountType);
        this.VirtualNetworkAddressPrefix = new BicepValue(deploymentParameters.VirtualNetworkAddressPrefix);
        this.SubnetAddressPrefix = new BicepValue(deploymentParameters.SubnetAddressPrefix);
        this.UbuntuServerOffer = new BicepValue(deploymentParameters.UbuntuServerOffer);
        this.UbuntuServerSku = new BicepValue(deploymentParameters.UbuntuServerSku);
        this.UbuntuServerVersion = new BicepValue(deploymentParameters.UbuntuServerVersion);

        this.PrimaryRegion = new BicepValue(primaryRegion.ToString());
        this.FailoverRegion = new BicepValue(failoverRegion.ToString());

        string publicKeyContent = File.ReadAllText(publicKeyPath);
        this.PublicKey = new BicepValue(publicKeyContent);
    }

    public override string ToString()
    {
        return JsonConvert.SerializeObject(this);
    }
}