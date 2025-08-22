defmodule Surge.Messages.Message do
  @moduledoc """
  A communication sent to a Contact.
  """

  alias Surge.Contacts.Contact
  alias Surge.Messages.Attachment
  alias Surge.PhoneNumbers.PhoneNumber

  @type conversation :: %{
          id: String.t(),
          contact: Contact.t(),
          phone_number: PhoneNumber.t()
        }

  @type t :: %__MODULE__{
          id: String.t(),
          attachments: list(Attachment.t()),
          body: String.t() | nil,
          conversation: conversation()
        }

  defstruct [
    :id,
    :attachments,
    :body,
    :conversation
  ]

  @doc """
  Converts JSON response to Message struct.

  ## Examples

      iex> data = %{"id" => "msg_123", "body" => "Hello"}
      iex> Surge.Messages.Message.from_json(data)
      %Surge.Messages.Message{id: "msg_123", body: "Hello", attachments: []}
  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      attachments: parse_attachments(data["attachments"]),
      body: data["body"],
      conversation: parse_conversation(data["conversation"])
    }
  end

  # Private

  @spec parse_attachments(list(map()) | nil) :: list(Attachment.t())
  defp parse_attachments(nil), do: []

  defp parse_attachments(attachments) when is_list(attachments) do
    Enum.map(attachments, &Attachment.from_json/1)
  end

  @spec parse_conversation(map) :: conversation()
  defp parse_conversation(conversation) do
    %{
      id: conversation["id"],
      contact: Contact.from_json(conversation["contact"]),
      phone_number: PhoneNumber.from_json(conversation["phone_number"])
    }
  end
end
