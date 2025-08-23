defmodule Surge.Events.MessageReceived do
  @moduledoc """
  The `message.received` event is delivered whenever someone sends a message to
  a Surge number you own.

  ## Common Use Cases

  * Trigger automated responses
  * Update conversation analytics
  * Send notifications to other systems
  * Log customer interactions
  """

  alias Surge.Messages.Attachment
  alias Surge.Messages.Conversation

  @type t :: %__MODULE__{
          id: String.t() | nil,
          body: String.t() | nil,
          attachments: list(Attachment.t()),
          received_at: DateTime.t() | nil,
          conversation: Conversation.t() | nil
        }

  defstruct [
    :id,
    :body,
    :attachments,
    :received_at,
    :conversation
  ]

  @doc """
  Converts JSON webhook payload to MessageReceived struct.

  ## Examples

      iex> data = %{
      ...>   "id" => "msg_01jav96823f9x9054d6gyzpp16",
      ...>   "body" => "I don't have friends, I got family.",
      ...>   "attachments" => [
      ...>     %{
      ...>       "id" => "att_01jav8z6x1j4m1b3w8v2jz7j3r",
      ...>       "type" => "image",
      ...>       "url" => "https://toretto.family/image.jpg"
      ...>     }
      ...>   ],
      ...>   "received_at" => "2024-10-22T23:32:49Z",
      ...>   "conversation" => %{
      ...>     "id" => "cnv_01jav8xy7fe4nsay3c9deqxge9",
      ...>     "phone_number" => %{
      ...>       "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
      ...>       "number" => "+18015556789",
      ...>       "type" => "local"
      ...>     },
      ...>     "contact" => %{
      ...>       "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
      ...>       "first_name" => "Dominic",
      ...>       "last_name" => "Toretto",
      ...>       "phone_number" => "+18015551234"
      ...>     }
      ...>   }
      ...> }
      iex> Surge.Events.MessageReceived.from_json(data)
      %Surge.Events.MessageReceived{
        id: "msg_01jav96823f9x9054d6gyzpp16",
        body: "I don't have friends, I got family.",
        attachments: [
          %Surge.Messages.Attachment{
            id: "att_01jav8z6x1j4m1b3w8v2jz7j3r",
            type: "image",
            url: "https://toretto.family/image.jpg"
          }
        ],
        received_at: ~U[2024-10-22 23:32:49Z],
        conversation: %Surge.Messages.Conversation{
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
      }

  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      body: data["body"],
      attachments: parse_attachments(data["attachments"]),
      received_at: parse_datetime(data["received_at"]),
      conversation: parse_conversation(data["conversation"])
    }
  end

  # Private

  @spec parse_attachments(list(map()) | nil) :: list(Attachment.t())
  defp parse_attachments(nil), do: []

  defp parse_attachments(attachments) when is_list(attachments) do
    Enum.map(attachments, &Attachment.from_json/1)
  end

  @spec parse_datetime(String.t() | nil) :: DateTime.t() | nil
  defp parse_datetime(nil), do: nil

  defp parse_datetime(str) when is_binary(str) do
    case DateTime.from_iso8601(str) do
      {:ok, datetime, _} -> datetime
      _ -> nil
    end
  end

  @spec parse_conversation(map() | nil) :: Conversation.t() | nil
  defp parse_conversation(nil), do: nil
  defp parse_conversation(data) when is_map(data), do: Conversation.from_json(data)
end

