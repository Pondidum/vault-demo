using System;
using System.Threading.Tasks;
using Dapper;
using Npgsql;
using VaultSharp;
using VaultSharp.V1;
using VaultSharp.V1.AuthMethods.AppRole;
using VaultSharp.V1.AuthMethods.Token;
using VaultSharp.V1.SecretsEngines;

namespace DirectAccess
{
	class Program
	{
		static async Task Main(string[] args)
		{
			var uri = new Uri("http://localhost:8200");
			var auth = new TokenAuthMethodInfo("vault");

			var vault = new VaultClient(new VaultClientSettings(
				uri.ToString(),
				auth
			)).V1;

			var response = await vault.Secrets.Database.GetCredentialsAsync("reader");

			using (var connection = await Connect(response.Data))
			{
				Console.WriteLine("Connected!");

				var users = await connection.QueryAsync<UserInfo>("select rolname as Name, rolvaliduntil as ValidUntil from pg_roles");

				foreach (var userInfo in users)
					Console.WriteLine(userInfo);
			}
		}

		private static async Task<NpgsqlConnection> Connect(UsernamePasswordCredentials credentials)
		{
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
	}
}
