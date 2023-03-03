public record DeploymentParameters : IParameters<string>
{
    public string VirtualMachineSize { get; init; }
    public string StorageAccountType { get; init; }
    public string VirtualNetworkAddressPrefix { get; init; }
    public string SubnetAddressPrefix { get; init; }
    public string UbuntuServerOffer { get; init; }
    public string UbuntuServerSku { get; init; }
    public string UbuntuServerVersion { get; init; }
}