defmodule Surge.Events.MessageSent do
  @moduledoc """
  The `message.sent` event is delivered whenever a message is sent from your
  Surge number to another phone number.

  ## Common Use Cases

  * Track sent messages in your own system
  * Update conversation analytics
  * Log customer interactions
  """

  alias Surge.Messages.Attachment
  alias Surge.Messages.Conversation

  @type t :: %__MODULE__{
          id: String.t() | nil,
          body: String.t() | nil,
          attachments: list(Attachment.t()),
          sent_at: DateTime.t() | nil,
          conversation: Conversation.t() | nil
        }

  defstruct [
    :id,
    :body,
    :attachments,
    :sent_at,
    :conversation
  ]

  @doc """
  Converts JSON webhook payload to MessageSent struct.

  ## Examples

      iex> data = %{
      ...>   "id" => "msg_01jjnn7s0zfx5tdcsxjfy93et2",
      ...>   "body" => "Dude, I almost had you!",
      ...>   "attachments" => [
      ...>     %{
      ...>       "id" => "att_01jjnn75vgepj8bnnttfw1st5s",
      ...>       "type" => "image",
      ...>       "url" => "https://toretto.family/skyline.jpg"
      ...>     }
      ...>   ],
      ...>   "sent_at" => "2024-10-21T23:29:41Z",
      ...>   "conversation" => %{
      ...>     "id" => "cnv_01jav8xy7fe4nsay3c9deqxge9",
      ...>     "phone_number" => %{
      ...>       "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
      ...>       "number" => "+18015556789",
      ...>       "type" => "local"
      ...>     },
      ...>     "contact" => %{
      ...>       "email" => "dom@toretto.family",
      ...>       "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
      ...>       "first_name" => "Dominic",
      ...>       "last_name" => "Toretto",
      ...>       "metadata" => %{
      ...>         "car" => "1970 Dodge Charger R/T"
      ...>       },
      ...>       "phone_number" => "+18015551234"
      ...>     }
      ...>   }
      ...> }
      iex> Surge.Events.MessageSent.from_json(data)
      %Surge.Events.MessageSent{
        id: "msg_01jjnn7s0zfx5tdcsxjfy93et2",
        body: "Dude, I almost had you!",
        attachments: [
          %Surge.Messages.Attachment{
            id: "att_01jjnn75vgepj8bnnttfw1st5s",
            type: "image",
            url: "https://toretto.family/skyline.jpg"
          }
        ],
        sent_at: ~U[2024-10-21 23:29:41Z],
        conversation: %Surge.Messages.Conversation{
          id: "cnv_01jav8xy7fe4nsay3c9deqxge9",
          phone_number: %Surge.PhoneNumbers.PhoneNumber{
            id: "pn_01jsjwe4d9fx3tpymgtg958d9w",
            number: "+18015556789",
            type: :local
          },
          contact: %Surge.Contacts.Contact{
            email: "dom@toretto.family",
            id: "ctc_01ja88cboqffhswjx8zbak3ykk",
            first_name: "Dominic",
            last_name: "Toretto",
            metadata: %{
              "car" => "1970 Dodge Charger R/T"
            },
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
      sent_at: parse_datetime(data["sent_at"]),
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

