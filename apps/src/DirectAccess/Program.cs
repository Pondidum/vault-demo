using System;
using System.Threading.Tasks;
using Dapper;

namespace DirectAccess
{
	class Program
	{
		static async Task Main(string[] args)
		{
			var config = new Configuration();

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
