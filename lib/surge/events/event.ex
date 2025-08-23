defmodule Surge.Events.Event do
  @moduledoc """
  A wrapper for webhook events that contains the event data and metadata.
  
  The Event struct includes the account ID, event type, and the parsed event data
  which varies based on the type of event.
  """

  alias Surge.Events.{
    CallEnded,
    ConversationCreated,
    MessageDelivered,
    MessageFailed,
    MessageReceived,
    MessageSent
  }

  @type event_type ::
          :call_ended
          | :conversation_created
          | :message_delivered
          | :message_failed
          | :message_received
          | :message_sent

  @type event_data ::
          CallEnded.t()
          | ConversationCreated.t()
          | MessageDelivered.t()
          | MessageFailed.t()
          | MessageReceived.t()
          | MessageSent.t()

  @type t :: %__MODULE__{
          account_id: String.t() | nil,
          type: event_type() | nil,
          data: event_data() | nil
        }

  defstruct [
    :account_id,
    :type,
    :data
  ]

  @doc """
  Converts JSON webhook payload to Event struct.

  ## Examples

      iex> data = %{
      ...>   "account_id" => "acct_01japd271aeatb7txrzr2xj8sg",
      ...>   "type" => "message.received",
      ...>   "data" => %{
      ...>     "id" => "msg_01jav96823f9x9054d6gyzpp16",
      ...>     "body" => "I don't have friends, I got family.",
      ...>     "attachments" => [
      ...>       %{
      ...>         "id" => "att_01jav8z6x1j4m1b3w8v2jz7j3r",
      ...>         "type" => "image",
      ...>         "url" => "https://toretto.family/image.jpg"
      ...>       }
      ...>     ],
      ...>     "received_at" => "2024-10-22T23:32:49Z",
      ...>     "conversation" => %{
      ...>       "id" => "cnv_01jav8xy7fe4nsay3c9deqxge9",
      ...>       "phone_number" => %{
      ...>         "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
      ...>         "number" => "+18015556789",
      ...>         "type" => "local"
      ...>       },
      ...>       "contact" => %{
      ...>         "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
      ...>         "first_name" => "Dominic",
      ...>         "last_name" => "Toretto",
      ...>         "phone_number" => "+18015551234"
      ...>       }
      ...>     }
      ...>   }
      ...> }
      iex> Surge.Events.Event.from_json(data)
      %Surge.Events.Event{
        account_id: "acct_01japd271aeatb7txrzr2xj8sg",
        type: :message_received,
        data: %Surge.Events.MessageReceived{
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
      }

  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    type = parse_type(data["type"])

    %__MODULE__{
      account_id: data["account_id"],
      type: type,
      data: parse_data(type, data["data"])
    }
  end

  # Private

  @spec parse_type(String.t() | nil) :: event_type() | nil
  defp parse_type(nil), do: nil
  defp parse_type("call.ended"), do: :call_ended
  defp parse_type("conversation.created"), do: :conversation_created
  defp parse_type("message.delivered"), do: :message_delivered
  defp parse_type("message.failed"), do: :message_failed
  defp parse_type("message.received"), do: :message_received
  defp parse_type("message.sent"), do: :message_sent
  defp parse_type(_), do: nil

  @spec parse_data(event_type() | nil, map() | nil) :: event_data() | nil
  defp parse_data(nil, _), do: nil
  defp parse_data(_, nil), do: nil

  defp parse_data(:call_ended, data) when is_map(data) do
    CallEnded.from_json(data)
  end

  defp parse_data(:conversation_created, data) when is_map(data) do
    ConversationCreated.from_json(data)
  end

  defp parse_data(:message_delivered, data) when is_map(data) do
    MessageDelivered.from_json(data)
  end

  defp parse_data(:message_failed, data) when is_map(data) do
    MessageFailed.from_json(data)
  end

  defp parse_data(:message_received, data) when is_map(data) do
    MessageReceived.from_json(data)
  end

  defp parse_data(:message_sent, data) when is_map(data) do
    MessageSent.from_json(data)
  end

  defp parse_data(_, _), do: nil
end