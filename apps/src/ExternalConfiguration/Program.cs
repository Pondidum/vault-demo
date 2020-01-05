using System;
using System.Threading.Tasks;
using Dapper;
using Microsoft.Extensions.Configuration;
using Npgsql;

namespace ExternalConfiguration
{
	class Program
	{
		static async Task Main(string[] args)
		{
			var connect = CreateConnector();

			using (var connection = await connect())
			{
				Console.WriteLine("Connected!");

				var users = await connection.QueryAsync<UserInfo>(
					"select rolname as Name, rolvaliduntil as ValidUntil from pg_roles"
				);

				foreach (var userInfo in users)
					Console.WriteLine(userInfo);
			}
		}

		private static Func<Task<NpgsqlConnection>> CreateConnector()
		{
			var builder = new NpgsqlConnectionStringBuilder();
			new ConfigurationBuilder()
				.AddEnvironmentVariables("DB_")
				.Build()
				.Bind(builder);

			var connection = new NpgsqlConnection(builder.ToString());

			return async () =>
			{
				await connection.OpenAsync();
				return connection;
			};
		}
	}
}
