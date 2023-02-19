public interface IParameters<T>
{
    public T VirtualMachineSize { get; init; }
    public T StorageAccountType { get; init; }
    public T VirtualNetworkAddressPrefix { get; init; }
    public T SubnetAddressPrefix { get; init; }
    public T UbuntuServerOffer { get; init; }
    public T UbuntuServerSku { get; init; }
    public T UbuntuServerVersion { get; init; }
}