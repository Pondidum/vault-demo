using System;
using System.Threading.Tasks;
using Dapper;
using Microsoft.Extensions.Configuration;

namespace AppRoleAccess
{
	class Program
	{
		static async Task Main(string[] args)
		{
			var config = new Configuration();
			new ConfigurationBuilder()
				.AddEnvironmentVariables()
				.AddJsonFile("appsettings.json")
				.Build()
				.Bind(config);

			using (var connection = await config.Connect())
			{
				Console.WriteLine("Connected!");

				var users = await connection.QueryAsync<UserInfo>(
					"select rolname as Name, rolvaliduntil as ValidUntil from pg_roles"
				);

				foreach (var userInfo in users)
					Console.WriteLine(userInfo);
			}
		}
	}
}
