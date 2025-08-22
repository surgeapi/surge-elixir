defmodule Surge.Users do
  @moduledoc """
  Functions for managing Surge users.
  """

  alias Surge.Client
  alias Surge.Users.User

  @doc """
  Creates a new user.

  ## Examples

      Surge.Users.create("acc_123", %{
        email: "user@example.com",
        name: "John Doe",
        role: "admin"
      })
      #=> {:ok, %Surge.Users.User{}}

      client = Surge.Client.new("your_api_key")
      Surge.Users.create(client, "acc_123", %{email: "test@example.com"})
      #=> {:ok, %Surge.Users.User{}}

  """
  @spec create(String.t(), map()) :: {:ok, User.t()} | {:error, Surge.Error.t()}
  @spec create(Client.t(), String.t(), map()) :: {:ok, User.t()} | {:error, Surge.Error.t()}
  def create(client \\ Client.default_client(), account_id, params)

  def create(%Client{} = client, account_id, params) do
    opts = [json: params, path_params: [account_id: account_id]]

    case Client.request(client, :post, "/accounts/:account_id/users", opts) do
      {:ok, data} -> {:ok, User.from_json(data)}
      error -> error
    end
  end

  @doc """
  Creates a signed user token for authentication.

  ## Examples

      Surge.Users.create_token("usr_123", %{duration_seconds: 3600})
      #=> {:ok, "eyJ..."}

      client = Surge.Client.new("your_api_key")
      Surge.Users.create_token(client, "usr_123", %{})
      #=> {:ok, "eyJ..."}

  """
  @spec create_token(String.t(), map()) :: {:ok, map()} | {:error, Surge.Error.t()}
  @spec create_token(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, Surge.Error.t()}
  def create_token(client \\ Client.default_client(), user_id, params)

  def create_token(%Client{} = client, user_id, params) do
    opts = [json: params, path_params: [user_id: user_id]]

    case Client.request(client, :post, "/users/:user_id/tokens", opts) do
      {:ok, response_body} -> {:ok, response_body["token"]}
      error -> error
    end
  end

  @doc """
  Gets a user by ID.

  ## Examples

      Surge.Users.get("usr_123")
      #=> {:ok, %Surge.Users.User{id: "usr_123", ...}}

      client = Surge.Client.new("your_api_key")
      Surge.Users.get(client, "usr_123")
      #=> {:ok, %Surge.Users.User{}}

  """
  @spec get(String.t()) :: {:ok, User.t()} | {:error, Surge.Error.t()}
  @spec get(Client.t(), String.t()) :: {:ok, User.t()} | {:error, Surge.Error.t()}
  def get(client \\ Client.default_client(), user_id)

  def get(%Client{} = client, user_id) do
    case Client.request(client, :get, "/users/:user_id", path_params: [user_id: user_id]) do
      {:ok, data} -> {:ok, User.from_json(data)}
      error -> error
    end
  end

  @doc """
  Updates a user.

  ## Examples

      Surge.Users.update("usr_123", %{first_name: "Jane"})
      #=> {:ok, %Surge.Users.User{id: "usr_123", first_name: "Jane"}}

      client = Surge.Client.new("your_api_key")
      Surge.Users.update(client, "usr_123", %{first_name: "Sally"})
      #=> {:ok, %Surge.Users.User{id: "usr_123", first_name: "Sally"}}

  """
  @spec update(String.t(), map()) :: {:ok, User.t()} | {:error, Surge.Error.t()}
  @spec update(Client.t(), String.t(), map()) :: {:ok, User.t()} | {:error, Surge.Error.t()}
  def update(client \\ Client.default_client(), user_id, params)

  def update(%Client{} = client, user_id, params) do
    opts = [json: params, path_params: [user_id: user_id]]

    case Client.request(client, :patch, "/users/:user_id", opts) do
      {:ok, data} -> {:ok, User.from_json(data)}
      error -> error
    end
  end
end
