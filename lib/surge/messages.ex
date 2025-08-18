defmodule Surge.Messages do
  @moduledoc """
  Functions for managing Surge messages.
  """

  alias Surge.Client
  alias Surge.Messages.Message

  @doc """
  Creates and enqueues a new message to be sent.

  Messages are always sent asynchronously. When you hit this endpoint, the
  message will be created within Surge’s system and enqueued for sending, and
  then the id for the new message will be returned. When the message is actually
  sent, a `message.sent` webhook event will be triggered and sent to any webhook
  endpoints that you have subscribed to this event type. Then a
  `message.delivered` webhook event will be triggered when the carrier sends us
  a delivery receipt.

  By default all messages will be sent immediately. If you would like to
  schedule sending for some time up to 60 days in the future, you can do that by
  providing a value for the `send_at` field. This should be formatted as an
  ISO8601 datetime like `2028-10-14T18:06:00Z`.

  You must include either a `body` or `attachments` field (or both) in the
  request body. The `body` field should contain the text of the message you want
  to send, and the `attachments` field should be an array of objects with a
  `url` field pointing to the file you want to attach. Surge will download these
  files and send them as attachments in the message.

  You can provide either a `conversation` object or a `to` field to specify the
  intended recipient of the message, but an error will be returned if both
  fields are provided. Similarly the `from` field cannot be used together with
  the `conversation` field, and `conversation.phone_number` should be specified
  instead.

  ## Examples

      iex> Surge.Messages.create("acct_123", %{
      ...>   from: "+15551234567",
      ...>   to: "+15559876543",
      ...>   body: "Hello from Surge!"
      ...> })
      {:ok, %Surge.Messages.Message{}}

      iex> # With attachments
      iex> Surge.Messages.create("acct_123", %{
      ...>   from: "+15551234567",
      ...>   to: "+15559876543",
      ...>   body: "Check out this image!",
      ...>   attachments: [
      ...>     %{url: "https://example.com/image.jpg", content_type: "image/jpeg"}
      ...>   ]
      ...> })
      {:ok, %Surge.Messages.Message{}}

      iex> # With contact information
      iex> Surge.Messages.create("acct_123", %{
      ...>   attachments: [%{url: "https://toretto.family/coronas.gif"}],
      ...>   body: "Check out this image!",
      ...>   conversation: %{
      ...>     contact: %{
      ...>       first_name: "Dominic",
      ...>       last_name: "Toretto",
      ...>       phone_number: "+18015551234"
      ...>     }
      ...>   }
      ...> })
      {:ok, %Surge.Messages.Message{}}

      iex> client = Surge.Client.new("your_api_key")
      iex> Surge.Messages.create(client, "acct_123", %{to: "+15551234567", body: "Test"})
      {:ok, %Surge.Messages.Message{}}

  """
  @spec create(String.t(), map()) :: {:ok, Message.t()} | {:error, Surge.Error.t()}
  @spec create(Client.t(), String.t(), map()) :: {:ok, Message.t()} | {:error, Surge.Error.t()}
  def create(client \\ Client.default_client(), account_id, params)

  def create(%Client{} = client, account_id, params) do
    opts = [json: params, path_params: [account_id: account_id]]

    case Client.request(client, :post, "/accounts/:account_id/messages", opts) do
      {:ok, data} -> {:ok, Message.from_json(data)}
      error -> error
    end
  end
end
