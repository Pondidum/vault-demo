using Microsoft.Extensions.Configuration;

namespace DemoService
{
    class Program
    {
        static void Main(string[] args)
        {
            var config = new Configuration();
            new ConfigurationBuilder()
                .AddEnvironmentVariables()
                .Build()
                .Bind(config);
        }
    }

    public class Configuration
    {
        public string VaultRoleID { get; set; }
        public string VaultSecretID { get; set; }
    }
}
