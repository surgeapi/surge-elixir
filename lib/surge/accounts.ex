defmodule Surge.Accounts do
  @moduledoc """
  Functions for managing Surge accounts.
  """

  alias Surge.Accounts.Account
  alias Surge.Accounts.AccountStatus
  alias Surge.Client

  @doc """
  Creates a new Account within the calling Platform.

  ## Examples

      iex> Surge.Accounts.create(%{name: "Test Account"})
      {:ok, %Surge.Accounts.Account{}}

      iex> client = Surge.Client.new("your_api_key")
      iex> Surge.Accounts.create(client, %{name: "Test Account"})
      {:ok, %Surge.Accounts.Account{}}

  """
  @spec create(map()) :: {:ok, Account.t()} | {:error, Surge.Error.t()}
  @spec create(Client.t(), map()) :: {:ok, Account.t()} | {:error, Surge.Error.t()}
  def create(client \\ Client.default_client(), params)

  def create(%Client{} = client, params) do
    case Client.request(client, :post, "/accounts", json: params) do
      {:ok, data} -> {:ok, Account.from_json(data)}
      error -> error
    end
  end

  @doc """
  Checks an account's status and capabilities.

  ## Examples

      iex> Surge.Accounts.get_status("acct_123", [:local_messaging])
      {:ok, %Surge.Accounts.AccountStatus{capabilities: %{local_messaging: %{status: :ready}}}}

      iex> client = Surge.Client.new("your_api_key")
      iex> Surge.Accounts.get_status(client, "acct_123", [:local_messaging])
      {:ok, %Surge.Accounts.AccountStatus{capabilities: %{local_messaging: %{status: :ready}}}}

  """
  @spec get_status(String.t(), list(AccountStatus.capability())) ::
          {:ok, AccountStatus.t()} | {:error, Surge.Error.t()}
  @spec get_status(Client.t(), String.t(), list(AccountStatus.capability())) ::
          {:ok, AccountStatus.t()} | {:error, Surge.Error.t()}
  def get_status(client \\ Client.default_client(), account_id, capabilities)

  def get_status(%Client{} = client, account_id, capabilities) do
    params = Enum.join(capabilities, ",")
    opts = [params: params, path_params: [account_id: account_id]]

    case Client.request(client, :get, "/accounts/:account_id/status", opts) do
      {:ok, data} -> {:ok, AccountStatus.from_json(data)}
      error -> error
    end
  end

  @doc """
  Updates an Account

  ## Examples

      iex> Surge.Accounts.update("acct_123", %{name: "Updated Account"})
      {:ok, %Surge.Accounts.Account{name: "Updated Account"}}

      iex> client = Surge.Client.new("your_api_key")
      iex> Surge.Accounts.update(client, "acct_123", %{name: "Updated"})
      {:ok, %Surge.Accounts.Account{}}

  """
  @spec update(String.t(), map()) :: {:ok, Account.t()} | {:error, Surge.Error.t()}
  @spec update(Client.t(), String.t(), map()) :: {:ok, Account.t()} | {:error, Surge.Error.t()}
  def update(client \\ Client.default_client(), account_id, params)

  def update(%Client{} = client, account_id, params) do
    opts = [json: params, path_params: [account_id: account_id]]

    case Client.request(client, :patch, "/accounts/:account_id", opts) do
      {:ok, data} -> {:ok, Account.from_json(data)}
      error -> error
    end
  end
end
