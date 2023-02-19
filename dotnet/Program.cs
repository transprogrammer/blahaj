using Azure.Core;
using Azure.Identity;
using FluentAzure = Microsoft.Azure.Management.Fluent.Azure;
using Microsoft.Azure.Management.ResourceManager.Fluent.Models;
using Microsoft.Azure.Management.ResourceManager.Fluent;
using Microsoft.Azure.Management.ResourceManager.Fluent.Core;
using Microsoft.Azure.Management.ResourceManager.Fluent.Deployment.Definition;
using System;
using System.IO;
using System.Linq;
using Newtonsoft.Json;
using Microsoft.Azure.Management.Fluent;

namespace Deploy
{
    class Program
    {
        const string ConfigPath = "./configuration.json";
        static Configuration configuration;

        static void Main(string[] args)
        {
            configuration = new Configuration(ConfigPath);

            AzureCliCredential credentials = new AzureCliCredential();

            IAzure azureFluency = GetFluency();

            string templateContent = GetTemplateContent(configuration.TemplateFilename);

            string publicKeyData = GetPublicKeyData(configuration.PublicKeyPath);

            string deploymentParameters = new DeploymentParameters(configuration, publicKeyData).ToString();

            string bicepParameter

            var parameterObject = new
            {
                public_key = new { value = publicKeyData },
                primary_region = new { value = configuration.Regions[RegionTypes.Primary] } //PrimaryRegion.Name },
                failover_region = new { value = configuration.Regions[RegionTypes.Failover] } //FailoverRegion.Name }
            };
            var parameterData = JsonConvert.SerializeObject(parameterObject);

            Console.WriteLine("parameterData: " + parameterData);

            var blankDeployment = azureFluency.Deployments.Define(configuration.DeploymentName);

            IWithTemplate templateReadyDeployment;

            if (azureFluency.ResourceGroups.Contain(configuration.ResourceGroupPrefix))
            {
                var existingResourceGroup = azureFluency.ResourceGroups.GetByName(configuration.ResourceGroupPrefix);

                if (existingResourceGroup.Region != configuration.Regions[RegionTypes.Primary])
                {
                    var errorMessage = String.Format(
                        "${Existing resource group {0} has region {1}, expecting {2}",
                        existingResourceGroup.Name,
                        existingResourceGroup.Region.Name,
                        PrimaryRegion.Name
                    );

                    throw new ArgumentException(errorMessage);
                }

                templateReadyDeployment = blankDeployment.WithExistingResourceGroup(configuration.ResourceGroupPrefix);
            }
            else
            {
                templateReadyDeployment = blankDeployment.WithNewResourceGroup(configuration.ResourceGroupPrefix, PrimaryRegion);
            }

            var deployment = templateReadyDeployment
                .WithTemplate(templateData)
                .WithParameters(parameterData)
                .WithMode(DeploymentMode.Incremental)
                .BeginCreate();

            Console.WriteLine("Current deployment status : " + deployment.ProvisioningState);

            var interimStates = new[] { ProvisioningState.Running, ProvisioningState.Accepted };

            while (interimStates.Contains(deployment.ProvisioningState))
            {
                SdkContext.DelayProvider.Delay(10000);
                deployment = azureFluency.Deployments.GetByResourceGroup(configuration.ResourceGroupPrefix, configuration.DeploymentName);
                Console.WriteLine("Current deployment status : " + deployment.ProvisioningState);
            }
        }
        static IAzure GetFluency()
        {
            var defaultCredential = new DefaultAzureCredential();
            var defaultToken = defaultCredential.GetToken(new TokenRequestContext(new[] { "https://management.azureFluency.com/.default" })).Token;
            var defaultTokenCredentials = new Microsoft.Rest.TokenCredentials(defaultToken);
            var azureCredentials = new Microsoft.Azure.Management.ResourceManager.Fluent.Authentication.AzureCredentials(defaultTokenCredentials, defaultTokenCredentials, null, AzureEnvironment.AzureGlobalCloud);
            var azure = FluentAzure.Configure().Authenticate(azureCredentials).WithSubscription("subscriptionId");
            return azure;
        }

        static string GetTemplateContent(string templateFilename)
        {
            var templatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, templateFilename);
            var templateData = File.ReadAllText(templatePath);
            return templateData;
        }
    }
}
