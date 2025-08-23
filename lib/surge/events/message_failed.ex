defmodule Surge.Events.MessageFailed do
  @moduledoc """
  The `message.failed` event is delivered whenever a message sent from your
  Surge number fails to be delivered to the recipient’s device.

  ## Common Use Cases

  * Track delivery status of sent messages in your own system
  * Update conversation analytics
  * Log customer interactions
  * Surface errors to users
  """

  alias Surge.Messages.Attachment
  alias Surge.Messages.Conversation

  @type failure_reason ::
          :carrier_error | :invalid_number | :blocked | :spam_detected | :rate_limited

  @type t :: %__MODULE__{
          id: String.t() | nil,
          body: String.t() | nil,
          attachments: list(Attachment.t()),
          conversation: Conversation.t() | nil,
          failed_at: DateTime.t() | nil,
          failure_reason: failure_reason() | nil
        }

  defstruct [
    :id,
    :body,
    :attachments,
    :conversation,
    :failed_at,
    :failure_reason
  ]

  @doc """
  Converts JSON webhook payload to MessageFailed struct.

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
      ...>   },
      ...>   "failed_at" => "2024-10-21T23:29:42Z",
      ...>   "failure_reason" => "carrier_error"
      ...> }
      iex> Surge.Events.MessageFailed.from_json(data)
      %Surge.Events.MessageFailed{
        id: "msg_01jjnn7s0zfx5tdcsxjfy93et2",
        body: "Dude, I almost had you!",
        attachments: [
          %Surge.Messages.Attachment{
            id: "att_01jjnn75vgepj8bnnttfw1st5s",
            type: "image",
            url: "https://toretto.family/skyline.jpg"
          }
        ],
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
        },
        failed_at: ~U[2024-10-21 23:29:42Z],
        failure_reason: :carrier_error
      }

  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      body: data["body"],
      attachments: parse_attachments(data["attachments"]),
      conversation: parse_conversation(data["conversation"]),
      failed_at: parse_datetime(data["failed_at"]),
      failure_reason: parse_failure_reason(data["failure_reason"])
    }
  end

  # Private

  @spec parse_attachments(list(map()) | nil) :: list(Attachment.t())
  defp parse_attachments(nil), do: []

  defp parse_attachments(attachments) when is_list(attachments) do
    Enum.map(attachments, &Attachment.from_json/1)
  end

  @spec parse_conversation(map() | nil) :: Conversation.t() | nil
  defp parse_conversation(nil), do: nil
  defp parse_conversation(data) when is_map(data), do: Conversation.from_json(data)

  @spec parse_datetime(String.t() | nil) :: DateTime.t() | nil
  defp parse_datetime(nil), do: nil

  defp parse_datetime(str) when is_binary(str) do
    case DateTime.from_iso8601(str) do
      {:ok, datetime, _} -> datetime
      _ -> nil
    end
  end

  @spec parse_failure_reason(String.t() | nil) :: failure_reason() | nil
  defp parse_failure_reason(nil), do: nil
  defp parse_failure_reason("carrier_error"), do: :carrier_error
  defp parse_failure_reason("invalid_number"), do: :invalid_number
  defp parse_failure_reason("blocked"), do: :blocked
  defp parse_failure_reason("spam_detected"), do: :spam_detected
  defp parse_failure_reason("rate_limited"), do: :rate_limited
  defp parse_failure_reason(_), do: nil
end

