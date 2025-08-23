defmodule Surge.Contacts.Contact do
  @moduledoc """
  A contact who has consented to receive messages.
  """

  @type t :: %__MODULE__{
          id: String.t(),
          email: String.t() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          metadata: map() | nil,
          phone_number: String.t() | nil
        }

  defstruct [
    :id,
    :email,
    :first_name,
    :last_name,
    :metadata,
    :phone_number
  ]

  @doc """
  Converts JSON response to Contact struct.

  ## Examples

      iex> data = %{"id" => "con_123", "phone_number" => "+15551234567"}
      iex> Surge.Contacts.Contact.from_json(data)
      %Surge.Contacts.Contact{id: "con_123", phone_number: "+15551234567"}

  """
  @spec from_json(map() | nil) :: t() | nil
  def from_json(nil), do: nil

  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      email: data["email"],
      first_name: data["first_name"],
      last_name: data["last_name"],
      metadata: data["metadata"],
      phone_number: data["phone_number"]
    }
  end
end
