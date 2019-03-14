using System;
using System.Threading.Tasks;
using Npgsql;
using VaultSharp;
using VaultSharp.V1;
using VaultSharp.V1.AuthMethods.Token;

namespace DirectAccess
{
	public class Configuration
	{
		private readonly Lazy<IVaultClientV1> _vault;

		public Configuration()
		{
			_vault = new Lazy<IVaultClientV1>(CreateVaultClient);
		}

		public async Task<NpgsqlConnection> Connect()
		{
			var vault = _vault.Value;

			var response = await vault.Secrets.Database.GetCredentialsAsync("reader");
			var credentials = response.Data;

			var builder = new NpgsqlConnectionStringBuilder
			{
				Host = "localhost",
				Port = 5432,
				Username = credentials.Username,
				Password = credentials.Password,
				Database = "postgres"
			};

			var connection = new NpgsqlConnection(builder.ToString());
			await connection.OpenAsync();

			return connection;
		}

		private IVaultClientV1 CreateVaultClient()
		{
			var uri = new Uri("http://localhost:8200");
			var auth = new TokenAuthMethodInfo("vault");

			var settings = new VaultClientSettings(
				uri.ToString(),
				auth
			);

			return new VaultClient(settings).V1;
		}
	}
}
