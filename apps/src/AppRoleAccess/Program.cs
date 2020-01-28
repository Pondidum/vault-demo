using System;
using System.Threading.Tasks;
using Npgsql;
using VaultSharp;
using VaultSharp.V1;
using VaultSharp.V1.AuthMethods.AppRole;

using Dapper;
using VaultSharp.V1.SecretsEngines;
using Newtonsoft.Json;
using System.IO;

namespace AppRoleAccess
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var vault = CreateVaultClient();
            var response = await vault.Secrets.Database.GetCredentialsAsync("reader");

            using (var connection = await Connect(response.Data))
            {
                Console.WriteLine("Connected!");

                var users = await connection.QueryAsync<UserInfo>(
                    "select rolname as Name, rolvaliduntil as ValidUntil from pg_roles where rolname not like 'pg_%'"
                );

                foreach (var userInfo in users)
                    Console.WriteLine(userInfo);
            }
        }

        static async Task<NpgsqlConnection> Connect(UsernamePasswordCredentials credentials)
        {
            var builder = new NpgsqlConnectionStringBuilder
            {
                Host = Environment.GetEnvironmentVariable("MACHINE_IP"),
                Port = 5432,
                Username = credentials.Username,
                Password = credentials.Password,
                Database = "postgres"
            };

            var connection = new NpgsqlConnection(builder.ToString());
            await connection.OpenAsync();

            return connection;
        }

        static IVaultClientV1 CreateVaultClient()
        {
            var appConfig = JsonConvert.DeserializeObject<AppConfig>(File.ReadAllText("appsettings.json"));

            var uri = new Uri(Environment.GetEnvironmentVariable("VAULT_ADDR"));
            var auth = new AppRoleAuthMethodInfo(
                Environment.GetEnvironmentVariable("VAULT_ROLE_ID"),
                appConfig.VaultSecretID);

            var settings = new VaultClientSettings(
                uri.ToString(),
                auth
            );

            return new VaultClient(settings).V1;
        }

        private class AppConfig
        {
            public string VaultSecretID { get; set; }
        }
    }
}
