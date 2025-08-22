defmodule Surge.Accounts.Account do
  @moduledoc """
  Response containing account information
  """

  alias Surge.Accounts.Organization

  @type t :: %__MODULE__{
          id: String.t(),
          brand_name: String.t() | nil,
          name: String.t(),
          organization: Organization.t() | nil,
          time_zone: String.t() | nil
        }

  defstruct [
    :brand_name,
    :id,
    :name,
    :organization,
    :time_zone
  ]

  @doc """
  Converts JSON response to Account struct.

  ## Examples

      iex> data = %{"id" => "acct_123", "name" => "Test Account"}
      iex> Surge.Accounts.Account.from_json(data)
      %Surge.Accounts.Account{id: "acct_123", name: "Test Account"}
  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      brand_name: data["brand_name"],
      id: data["id"],
      name: data["name"],
      organization: Organization.from_json(data["organization"]),
      time_zone: data["time_zone"]
    }
  end
end
