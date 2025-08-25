defmodule Surge.Client do
  @moduledoc """
  HTTP client for interacting with the Surge API.
  """

  alias Surge.Error

  @default_base_url "https://api.surge.app"

  @type t :: %__MODULE__{
          api_key: String.t(),
          base_url: String.t(),
          req_options: keyword()
        }

  defstruct [:api_key, :base_url, :req_options]

  @doc """
  Creates a new client with the given API key.

  ## Examples

      client = Surge.Client.new("sk_test_...")
      #=> %Surge.Client{api_key: "sk_test_...", base_url: "https://api.surge.app"}

      client = Surge.Client.new("sk_test_...", base_url: "https://custom.surge.app")
      #=> %Surge.Client{api_key: "sk_test_...", base_url: "https://custom.surge.app"}

  """
  @spec new(String.t(), keyword()) :: t()
  def new(api_key, opts \\ []) do
    %__MODULE__{
      api_key: api_key,
      base_url: Keyword.get(opts, :base_url, @default_base_url),
      req_options: Keyword.get(opts, :req_options, [])
    }
  end

  @doc """
  Returns the default client using configuration from the application environment.

  ## Configuration

  Configure the client in your `config/config.exs`:

      config :surge_api,
        api_key: System.get_env("SURGE_API_KEY"),
        base_url: System.get_env("SURGE_API_URL", "https://api.surge.app")

  ## Examples

      client = Surge.Client.default_client()
      #=> %Surge.Client{api_key: "sk_...", base_url: "https://api.surge.app"}

  """
  @spec default_client() :: t()
  def default_client do
    api_key =
      Application.get_env(:surge_api, :api_key) ||
        raise "Surge API key not configured. Set :surge_api, :api_key in your config."

    base_url = Application.get_env(:surge_api, :base_url, @default_base_url)
    req_options = Application.get_env(:surge_api, :req_options, [])

    new(api_key, base_url: base_url, req_options: req_options)
  end

  @doc """
  Makes an HTTP request using the client configuration.

  ## Examples

      Surge.Client.request(client, :get, "/accounts/123/status")
      #=> {:ok, %{"status" => "active", ...}}

      Surge.Client.request(client, :post, "/accounts", json: %{name: "Test"})
      #=> {:ok, %{"id" => "acct_123", ...}}

  """
  @spec request(t(), atom(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def request(client, method, path, opts \\ []) do
    url = client.base_url <> path
    user_agent = "surge-elixir/#{Application.spec(:surge_api, :vsn)}"

    req_opts =
      Keyword.merge(client.req_options, opts)
      |> Keyword.put(:method, method)
      |> Keyword.put(:url, url)
      |> Keyword.put(:auth, {:bearer, client.api_key})
      |> Keyword.put_new(:headers, [])
      |> Keyword.update!(
        :headers,
        &[{"accept", "application/json"}, {"user-agent", user_agent} | &1]
      )

    case Req.request(req_opts) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        {:error, Error.from_response(status, body)}

      {:error, reason} ->
        {:error, Error.from_connection_error(reason)}
    end
  end
end
