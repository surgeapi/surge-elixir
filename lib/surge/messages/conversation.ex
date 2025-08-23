defmodule Surge.Messages.Conversation do
  @moduledoc """
  Represents a conversation between a Surge phone number and a contact.
  """

  alias Surge.Contacts.Contact
  alias Surge.PhoneNumbers.PhoneNumber

  @type t :: %__MODULE__{
          id: String.t() | nil,
          contact: Contact.t() | nil,
          phone_number: PhoneNumber.t() | nil
        }

  defstruct [
    :id,
    :contact,
    :phone_number
  ]

  @doc """
  Converts JSON response to Conversation struct.

  ## Examples

      iex> data = %{
      ...>   "id" => "cnv_01jav8xy7fe4nsay3c9deqxge9",
      ...>   "phone_number" => %{
      ...>     "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
      ...>     "number" => "+18015556789",
      ...>     "type" => "local"
      ...>   },
      ...>   "contact" => %{
      ...>     "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
      ...>     "first_name" => "Dominic",
      ...>     "last_name" => "Toretto",
      ...>     "phone_number" => "+18015551234"
      ...>   }
      ...> }
      iex> Surge.Messages.Conversation.from_json(data)
      %Surge.Messages.Conversation{
        id: "cnv_01jav8xy7fe4nsay3c9deqxge9",
        phone_number: %Surge.PhoneNumbers.PhoneNumber{
          id: "pn_01jsjwe4d9fx3tpymgtg958d9w",
          number: "+18015556789",
          type: :local
        },
        contact: %Surge.Contacts.Contact{
          id: "ctc_01ja88cboqffhswjx8zbak3ykk",
          first_name: "Dominic",
          last_name: "Toretto",
          phone_number: "+18015551234"
        }
      }

  """
  @spec from_json(map() | nil) :: t() | nil
  def from_json(nil), do: nil

  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      contact: Contact.from_json(data["contact"]),
      phone_number: PhoneNumber.from_json(data["phone_number"])
    }
  end
end

