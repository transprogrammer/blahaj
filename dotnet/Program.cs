using Azure.Core;
using Azure.Identity;
using FluentAzure = Microsoft.Azure.Management.Fluent.Azure;
using Microsoft.Azure.Management.ResourceManager.Fluent.Models;
using Microsoft.Azure.Management.ResourceManager.Fluent;
using System;
using System.IO;
using System.Linq;
using Newtonsoft.Json;

namespace Deploy
{
    class Program
    {
        const string ResourceGroupName = "blahaj";

        const string DeploymentName = "blahaj-deployment";
        const string Location = "eastus2";
	    const string SubscriptionId = "8713d401-d857-426a-95ff-9ff08e7930da";

        const string TemplateFilename = "main.json";
        
        const string PublicKeyPath = "../ssh/id_rsa.pub";

        static void Main(string[] args)
        {
	        var credentials = new AzureCliCredential();

            var defaultCredential = new DefaultAzureCredential();
            var defaultToken = defaultCredential.GetToken(new TokenRequestContext(new[] { "https://management.azure.com/.default" })).Token;
            var defaultTokenCredentials = new Microsoft.Rest.TokenCredentials(defaultToken);
            var azureCredentials = new Microsoft.Azure.Management.ResourceManager.Fluent.Authentication.AzureCredentials(defaultTokenCredentials, defaultTokenCredentials, null, AzureEnvironment.AzureGlobalCloud);
            var azure = FluentAzure.Configure().Authenticate(azureCredentials).WithSubscription(SubscriptionId);

            var templatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, TemplateFilename);
            var templateData = File.ReadAllText(templatePath);

            var publicKeyData = File.ReadAllText(PublicKeyPath);

            var parameterObject = new { public_key = new { value = publicKeyData}};
            var parameterData = JsonConvert.SerializeObject(parameterObject);

            Console.WriteLine("parameterData: " + parameterData);

            azure.Deployments.Define(DeploymentName)
                .WithExistingResourceGroup(ResourceGroupName)
                .WithTemplate(templateData)
                .WithParameters(parameterData)
                .WithMode(DeploymentMode.Incremental)
                .BeginCreate();
        
            var deployment = azure.Deployments.GetByResourceGroup(ResourceGroupName, DeploymentName);
            
            Console.WriteLine("Current deployment status : " + deployment.ProvisioningState);

            var interimStates = new []{ProvisioningState.Running, ProvisioningState.Accepted};

            while(interimStates.Contains(deployment.ProvisioningState))
            {
                SdkContext.DelayProvider.Delay(10000);
                deployment = azure.Deployments.GetByResourceGroup(ResourceGroupName, DeploymentName);
                Console.WriteLine("Current deployment status : " + deployment.ProvisioningState);
            }
        }
    }
}
