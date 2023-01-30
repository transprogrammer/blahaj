using Azure.Core;
using Azure.Identity;
using Azure.ResourceManager.Fluent;
using Azure.ResourceManager.Fluent.Core;
using Azure.ResourceManager.Resources;
using Azure.ResourceManager.Resources.Models;
using Samples.Utilities;
using System;
using System.Threading.Tasks;

namespace Deploy
{
    class Program
    {
        const string Name = "beep-boops";
        const string Location = "eastus2";
	    const string SubscriptionId = "8713d401-d857-426a-95ff-9ff08e7930da";

        static void Main(string[] args)
        {
	    var credentials = new DefaultAzureCredential();

            var azure = Azure.Configure().Authenticate(credentials).Subscription(SubscriptionId);

            string bicepTemplate = System.IO.File.ReadAllText("main.bicep");

            var deployment = await azure.Deployments.Define("deploymentName")
                .WithTemplate(bicepTemplate)
                .WithParameters("{}")
                .CreateAsync();

            Console.WriteLine("Bicep template deployed successfully.");
        }
    }
}
