defmodule Instream.InfluxDBv1.Connection.DatabaseTest do
  use ExUnit.Case, async: true

  @moduletag :"influxdb_exclude_2.0"
  @moduletag :"influxdb_exclude_2.1"
  @moduletag :"influxdb_exclude_2.2"

  import Mox

  alias Instream.TestHelpers.HTTPClientMock
  alias Instream.TestHelpers.TestSeries

  setup :verify_on_exit!

  defmodule MockConnection do
    use Instream.Connection,
      config: [
        database: "default_database",
        http_client: HTTPClientMock,
        loggers: [],
        version: :v1
      ]
  end

  test "query database priority" do
    url_default = "http://localhost:8086/query?db=default_database&q=--ignored--"
    url_override = "http://localhost:8086/query?db=override_database&q=--ignored--"

    HTTPClientMock
    |> expect(:request, fn :get, ^url_default, _, _, _ -> {:ok, 200, [], ""} end)
    |> expect(:request, fn :get, ^url_override, _, _, _ -> {:ok, 200, [], ""} end)

    MockConnection.query("--ignored--")
    MockConnection.query("--ignored--", database: "override_database")
  end

  test "write database priority" do
    url_default = "http://localhost:8086/write?db=default_database"
    url_override = "http://localhost:8086/write?db=override_database"

    HTTPClientMock
    |> expect(:request, fn :post, ^url_default, _, _, _ -> {:ok, 200, [], ""} end)
    |> expect(:request, fn :post, ^url_override, _, _, _ -> {:ok, 200, [], ""} end)

    MockConnection.write(%TestSeries{})
    MockConnection.write(%TestSeries{}, database: "override_database")
  end
end
