using System;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.Dynamic;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;

namespace ConsysWinUI.Services;

public interface IDatabaseService
{
    Task<DataTable> ExecuteQueryAsync(string sql, Dictionary<string, object>? parameters = null);
    Task<int> ExecuteNonQueryAsync(string sql, Dictionary<string, object>? parameters = null);
    Task<T?> ExecuteScalarAsync<T>(string sql, Dictionary<string, object>? parameters = null);
    Task ExecuteAsync(string sql, Dictionary<string, object>? parameters = null);
    Task<IEnumerable<dynamic>> QueryAsync(string sql, Dictionary<string, object>? parameters = null);
}

public class DatabaseService : IDatabaseService
{
    private readonly string _connectionString;

    public DatabaseService(IConfiguration configuration)
    {
        var backendPath = configuration["Database:BackendPath"]
            ?? throw new InvalidOperationException("Database:BackendPath not configured");

        _connectionString = $"Provider=Microsoft.ACE.OLEDB.12.0;Data Source={backendPath};";
    }

    public async Task<DataTable> ExecuteQueryAsync(string sql, Dictionary<string, object>? parameters = null)
    {
        return await Task.Run(() =>
        {
            using var connection = new OleDbConnection(_connectionString);
            using var command = new OleDbCommand(sql, connection);

            if (parameters != null)
            {
                foreach (var param in parameters)
                {
                    command.Parameters.AddWithValue($"@{param.Key}", param.Value ?? DBNull.Value);
                }
            }

            var dataTable = new DataTable();
            connection.Open();

            using var adapter = new OleDbDataAdapter(command);
            adapter.Fill(dataTable);

            return dataTable;
        });
    }

    public async Task<int> ExecuteNonQueryAsync(string sql, Dictionary<string, object>? parameters = null)
    {
        return await Task.Run(() =>
        {
            using var connection = new OleDbConnection(_connectionString);
            using var command = new OleDbCommand(sql, connection);

            if (parameters != null)
            {
                foreach (var param in parameters)
                {
                    command.Parameters.AddWithValue($"@{param.Key}", param.Value ?? DBNull.Value);
                }
            }

            connection.Open();
            return command.ExecuteNonQuery();
        });
    }

    public async Task<T?> ExecuteScalarAsync<T>(string sql, Dictionary<string, object>? parameters = null)
    {
        return await Task.Run(() =>
        {
            using var connection = new OleDbConnection(_connectionString);
            using var command = new OleDbCommand(sql, connection);

            if (parameters != null)
            {
                foreach (var param in parameters)
                {
                    command.Parameters.AddWithValue($"@{param.Key}", param.Value ?? DBNull.Value);
                }
            }

            connection.Open();
            var result = command.ExecuteScalar();

            if (result == null || result == DBNull.Value)
                return default;

            return (T)Convert.ChangeType(result, typeof(T));
        });
    }

    public async Task ExecuteAsync(string sql, Dictionary<string, object>? parameters = null)
    {
        await ExecuteNonQueryAsync(sql, parameters);
    }

    public async Task<IEnumerable<dynamic>> QueryAsync(string sql, Dictionary<string, object>? parameters = null)
    {
        var dataTable = await ExecuteQueryAsync(sql, parameters);
        var results = new List<dynamic>();

        foreach (DataRow row in dataTable.Rows)
        {
            var expando = new ExpandoObject() as IDictionary<string, object>;

            foreach (DataColumn column in dataTable.Columns)
            {
                var value = row[column];
                expando[column.ColumnName] = value == DBNull.Value ? null : value;
            }

            results.Add(expando);
        }

        return results;
    }
}
