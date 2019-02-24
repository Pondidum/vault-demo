using System;
using System.Linq;
using System.Threading.Tasks;
using Consul;
using Npgsql;
using VaultSharp;
using VaultSharp.V1;
using VaultSharp.V1.AuthMethods.AppRole;

namespace DemoService
{
	public class Configuration : IDisposable
	{
		private readonly ConsulClient _consul;
		private readonly Lazy<Task<IVaultClientV1>> _vault;

		public Configuration()
		{
			_consul = new ConsulClient();
			_vault = new Lazy<Task<IVaultClientV1>>(async () =>
			{
				var uri = await GetService("vault");
				var auth = new AppRoleAuthMethodInfo(VaultRoleID, VaultSecretID);

				var settings = new VaultClientSettings(
					uri.ToString(),
					auth
				);

				return new VaultClient(settings).V1;
			});
		}

		public string DatabaseName { get; set; }
		public string VaultRoleID { get; set; }
		public string VaultSecretID { get; set; }

		public async Task<NpgsqlConnection> Connect()
		{
			var vault = await _vault.Value;
			var address = await GetService("postgres");

			var response = await vault.Secrets.Database.GetCredentialsAsync("writer");
			var credentials = response.Data;

			var builder = new NpgsqlConnectionStringBuilder
			{
				Host = address.Host,
				Port = address.Port,
				Username = credentials.Username,
				Password = credentials.Password,
				Database = DatabaseName
			};

			var connection = new NpgsqlConnection(builder.ToString());
			await connection.OpenAsync();

			return connection;
		}

		private async Task<Uri> GetService(string serviceName)
		{
			var service = await _consul.Catalog.Service(serviceName);

			// do some randomisation here!
			var instance = service.Response.First();

			var builder = new UriBuilder
			{
				Scheme = Uri.UriSchemeHttp,
				Host = instance.ServiceAddress ?? instance.Address,
				Port = instance.ServicePort
			};

			return builder.Uri;
		}

		public void Dispose()
		{
			_consul.Dispose();

			if (_vault.IsValueCreated)
				_vault.Value.Dispose();
		}
	}
}
