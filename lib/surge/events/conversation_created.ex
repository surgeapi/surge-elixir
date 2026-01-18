defmodule Surge.Events.ConversationCreated do
  @moduledoc """
  The `conversation.created` event is delivered whenever a new conversation is
  started with a contact. This could be when either the contact sends a message
  to your Surge number or when you create a conversation, whether by sending an
  initial message to the contact or by manually creating the conversation using
  the API.
  """

  alias Surge.Contacts.Contact
  alias Surge.PhoneNumbers.PhoneNumber

  @type t :: %__MODULE__{
          id: String.t() | nil,
          phone_number: PhoneNumber.t() | nil,
          contact: Contact.t() | nil
        }

  defstruct [
    :id,
    :phone_number,
    :contact
  ]

  @doc """
  Converts JSON webhook payload to ConversationCreated struct.

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
      iex> Surge.Events.ConversationCreated.from_json(data)
      %Surge.Events.ConversationCreated{
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
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      phone_number: parse_phone_number(data["phone_number"]),
      contact: parse_contact(data["contact"])
    }
  end

  # Private

  @spec parse_phone_number(map() | nil) :: PhoneNumber.t() | nil
  defp parse_phone_number(nil), do: nil
  defp parse_phone_number(data) when is_map(data), do: PhoneNumber.from_json(data)

  @spec parse_contact(map() | nil) :: Contact.t() | nil
  defp parse_contact(nil), do: nil
  defp parse_contact(data) when is_map(data), do: Contact.from_json(data)
end
