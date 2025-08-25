defmodule Surge.WebhookHandler do
  @moduledoc """
  Behavior for handling Surge webhook events.

  Implement this behavior in your application to process webhook events.

  ## Example

      defmodule MyApp.SurgeHandler do
        @behaviour Surge.WebhookHandler

        @impl true
        def handle_event(%Surge.Events.Event{type: :message_received} = event) do
          # Process incoming message
          IO.inspect(event.data.body, label: "Received message")
          :ok
        end

        @impl true
        def handle_event(%Surge.Events.Event{type: :message_failed} = event) do
          # Handle failed message
          IO.inspect(event.data.failure_reason, label: "Message failed")
          {:ok, :handled}
        end

        # Return HTTP 200 for unhandled events
        @impl true
        def handle_event(_event), do: :ok
      end

  """

  alias Surge.Events.Event

  @doc """
  Handles a webhook event.

  This function will be called with a parsed `Surge.Events.Event` struct.

  ## Return values

    * `:ok` - Event was processed successfully
    * `{:ok, term}` - Event was processed successfully with a result
    * `:error` - Event processing failed (returns HTTP 400)
    * `{:error, reason}` - Event processing failed with reason (returns HTTP 400)

  """
  @callback handle_event(Event.t()) :: :ok | {:ok, term()} | :error | {:error, atom() | String.t()}
end