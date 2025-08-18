defmodule Surge.Contacts do
  @moduledoc """
  Functions for managing Surge contacts.
  """

  alias Surge.Client
  alias Surge.Contacts.Contact

  @doc """
  Creates a new Contact object.

  ## Examples

      iex> Surge.Contacts.create("acct_123", %{
      ...>   phone_number: "+18015551234",
      ...>   email: "dom@toretto.family",
      ...>   first_name: "Dominic",
      ...>   last_name: "Toretto",
      ...>   metadata: %{
      ...>     "car" => "1970 Dodge Charger R/T"
      ...>   }
      ...> })
      {:ok, %Surge.Contacts.Contact{}}

      iex> client = Surge.Client.new("your_api_key")
      iex> Surge.Contacts.create(client, "acct_123", %{phone_number: "+15551234567"})
      {:ok, %Surge.Contacts.Contact{}}

  """
  @spec create(String.t(), map()) :: {:ok, Contact.t()} | {:error, Surge.Error.t()}
  @spec create(Client.t(), String.t(), map()) :: {:ok, Contact.t()} | {:error, Surge.Error.t()}
  def create(client \\ Client.default_client(), account_id, params)

  def create(%Client{} = client, account_id, params) do
    case Client.request(client, :post, "/accounts/#{account_id}/contacts", json: params) do
      {:ok, data} -> {:ok, Contact.from_json(data)}
      error -> error
    end
  end

  @doc """
  Retrieves a Contact object.

  ## Examples

      iex> Surge.Contacts.get("ctc_123")
      {:ok, %Surge.Contacts.Contact{id: "ctc_123"}}

      iex> client = Surge.Client.new("your_api_key")
      iex> Surge.Contacts.get(client, "ctc_123")
      {:ok, %Surge.Contacts.Contact{id: "ctc_123"}}

  """
  @spec get(String.t()) :: {:ok, Contact.t()} | {:error, Surge.Error.t()}
  @spec get(Client.t(), String.t()) :: {:ok, Contact.t()} | {:error, Surge.Error.t()}
  def get(client \\ Client.default_client(), contact_id)

  def get(%Client{} = client, contact_id) do
    case Client.request(client, :get, "/contacts/#{contact_id}") do
      {:ok, data} -> {:ok, Contact.from_json(data)}
      error -> error
    end
  end

  @doc """
  Updates the specified contact by setting the values of the parameters passed.
  Any parameters not provided will be left unchanged.

  ## Examples

      iex> Surge.Contacts.update("ctc_123", %{first_name: "Jane"})
      {:ok, %Surge.Contacts.Contact{id: "ctc_123", first_name: "Jane"}}

      iex> client = Surge.Client.new("your_api_key")
      iex> Surge.Contacts.update(client, "ctc_123", %{email: "jane@example.com"})
      {:ok, %Surge.Contacts.Contact{id: "ctc_123", email: "jane@example.com"}}

  """
  @spec update(String.t(), map()) :: {:ok, Contact.t()} | {:error, Surge.Error.t()}
  @spec update(Client.t(), String.t(), map()) :: {:ok, Contact.t()} | {:error, Surge.Error.t()}
  def update(client \\ Client.default_client(), contact_id, params)

  def update(%Client{} = client, contact_id, params) do
    case Client.request(client, :patch, "/contacts/#{contact_id}", json: params) do
      {:ok, data} -> {:ok, Contact.from_json(data)}
      error -> error
    end
  end
end
