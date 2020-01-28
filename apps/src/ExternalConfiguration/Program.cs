using System;
using System.Threading;
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
                    "select rolname as Name, rolvaliduntil as ValidUntil from pg_roles where rolname not like 'pg_%'"
                );

                foreach (var userInfo in users)
                    Console.WriteLine(userInfo);
            }

            var cts = new CancellationTokenSource();

            AppDomain.CurrentDomain.ProcessExit += (s, e) => cts.Cancel();
            await Task.Delay(-1, cts.Token);
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
