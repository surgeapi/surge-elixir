defmodule Surge.Messages.Message do
  @moduledoc """
  A communication sent to a Contact.
  """

  alias Surge.Messages.Attachment
  alias Surge.Messages.Conversation

  @type t :: %__MODULE__{
          id: String.t(),
          attachments: list(Attachment.t()),
          body: String.t() | nil,
          conversation: Conversation.t(),
          metadata: map() | nil
        }

  defstruct [
    :id,
    :attachments,
    :body,
    :conversation,
    :metadata
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
      conversation: Conversation.from_json(data["conversation"]),
      metadata: data["metadata"]
    }
  end

  # Private

  @spec parse_attachments(list(map()) | nil) :: list(Attachment.t())
  defp parse_attachments(nil), do: []

  defp parse_attachments(attachments) when is_list(attachments) do
    Enum.map(attachments, &Attachment.from_json/1)
  end
end
