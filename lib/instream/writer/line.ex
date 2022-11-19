defmodule Instream.Writer.Line do
  @moduledoc """
  Point writer for the line protocol.

  ## Write Options

  - `precision`: write points with a precision other than `:nanosecond`

  ### InfluxDB v2.x Options

  - `bucket`: write data to a specific bucket
  - `org`: write data to a specific organization

  ### InfluxDB v1.x Options

  - `database`: write data to a specific database
  - `retention_policy`: write data with a specific retention policy
  """

  alias Instream.Encoder.Line, as: Encoder
  alias Instream.Query.Headers
  alias Instream.Query.URL

  @behaviour Instream.Writer

  @impl Instream.Writer
  def write([_ | _] = points, opts, conn) do
    config = conn.config()
    headers = Headers.assemble(config, opts) ++ [{"Content-Type", "text/plain"}]
    body = Encoder.encode(points)
    url = URL.write(config[:version], config, opts)

    http_opts =
      Keyword.merge(
        Keyword.get(config, :http_opts, []),
        Keyword.get(opts, :http_opts, [])
      )

    config[:http_client].request(:post, url, headers, body, http_opts)
  end

  def write(_, _, _), do: {:ok, 200, [], ""}
end
