defmodule Surge.Client do
  @moduledoc """
  HTTP client for interacting with the Surge API.
  """

  defstruct [:api_key, :base_url, :req_options]

  @type t :: %__MODULE__{
          api_key: String.t(),
          base_url: String.t(),
          req_options: keyword()
        }

  @default_base_url "https://api.surge.app"

  @doc """
  Creates a new client with the given API key.

  ## Examples

      iex> client = Surge.Client.new("sk_test_...")
      %Surge.Client{api_key: "sk_test_...", base_url: "https://api.surge.app"}

      iex> client = Surge.Client.new("sk_test_...", base_url: "https://custom.surge.app")
      %Surge.Client{api_key: "sk_test_...", base_url: "https://custom.surge.app"}
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

      config :surge,
        api_key: System.get_env("SURGE_API_KEY"),
        base_url: System.get_env("SURGE_API_URL", "https://api.surge.app")

  ## Examples

      iex> client = Surge.Client.default_client()
      %Surge.Client{api_key: "sk_...", base_url: "https://api.surge.app"}
  """
  @spec default_client() :: t()
  def default_client do
    api_key =
      Application.get_env(:surge, :api_key) ||
        raise "Surge API key not configured. Set :surge, :api_key in your config."

    base_url = Application.get_env(:surge, :base_url, @default_base_url)

    new(api_key, base_url: base_url)
  end

  @doc """
  Makes an HTTP request using the client configuration.

  ## Examples

      iex> Surge.Client.request(client, :get, "/accounts/123/status")
      {:ok, %{"status" => "active", ...}}

      iex> Surge.Client.request(client, :post, "/accounts", json: %{name: "Test"})
      {:ok, %{"id" => "acct_123", ...}}
  """
  @spec request(t(), atom(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Surge.Error.t()}
  def request(client, method, path, opts \\ []) do
    url = client.base_url <> path

    req_opts =
      Keyword.merge(client.req_options, opts)
      |> Keyword.put(:method, method)
      |> Keyword.put(:url, url)
      |> Keyword.put(:auth, {:bearer, client.api_key})
      |> Keyword.put_new(:headers, [])
      |> Keyword.update!(:headers, &[{"accept", "application/json"} | &1])

    case Req.request(req_opts) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        {:error, Surge.Error.from_response(status, body)}

      {:error, reason} ->
        {:error, Surge.Error.from_connection_error(reason)}
    end
  end
end
