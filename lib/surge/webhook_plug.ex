if Code.ensure_loaded?(Plug) do
  defmodule Surge.WebhookPlug do
    @moduledoc """
    Helper `Plug` to process webhook events and send them to a custom handler.

    ## Installation

    To handle webhook events, you must first configure your application's endpoint.
    Add the following to `endpoint.ex`, **before** `Plug.Parsers` is loaded.

    ```elixir
    plug Surge.WebhookPlug,
      at: "/webhook/surge",
      handler: MyAppWeb.SurgeHandler,
      secret: "whsec_******"
    ```

    If you have not yet added a webhook to your Surge account, you can do so
    through the Surge dashboard. Use the route you configured in the endpoint
    above and copy the webhook secret into your app's configuration.

    ### Supported options

    - `at`: The URL path your application should listen for Surge webhooks on.
      Configure this to match whatever you set in the webhook.
    - `handler`: Custom event handler module that accepts `Surge.Events.Event` structs
      and processes them within your application. You must create this module.
    - `secret`: Webhook secret starting with `whsec_` obtained from Surge.
      This can also be a function or a tuple for runtime configuration.
    - `tolerance`: Maximum age (in seconds) allowed for the webhook event.
      Default is 300 seconds (5 minutes). See `Surge.Webhook.construct_event/4` for more information.

    ## Handling events

    You will need to create a custom event handler module to handle events.

    Your event handler module should implement the `Surge.WebhookHandler`
    behavior, defining a `handle_event/1` function which takes a `Surge.Events.Event`
    struct and returns either `{:ok, term}` or `:ok`. This will mark the event as
    successfully processed. Alternatively handler can signal an error by returning
    `:error` or `{:error, reason}` tuple, where reason is an atom or a string.
    HTTP status code 400 will be used for errors.

    ### Example

    ```elixir
    # lib/myapp_web/surge_handler.ex

    defmodule MyAppWeb.SurgeHandler do
      @behaviour Surge.WebhookHandler

      @impl true
      def handle_event(%Surge.Events.Event{type: :message_received} = event) do
        # TODO: handle incoming message
        IO.inspect(event.data.body, label: "Received")
        :ok
      end

      @impl true
      def handle_event(%Surge.Events.Event{type: :message_failed} = event) do
        # TODO: handle failed message
        {:error, :retry_later}
      end

      # Return HTTP 200 for unhandled events
      @impl true
      def handle_event(_event), do: :ok
    end
    ```

    ### Runtime configuration

    If you're loading config dynamically at runtime (eg with `runtime.exs`
    or an OTP app) you must pass a tuple or function as the secret.

    ```elixir
    # With a tuple
    plug Surge.WebhookPlug,
      at: "/webhook/surge",
      handler: MyAppWeb.SurgeHandler,
      secret: {Application, :get_env, [:myapp, :surge_webhook_secret]}

    # Or, with a function
    plug Surge.WebhookPlug,
      at: "/webhook/surge",
      handler: MyAppWeb.SurgeHandler,
      secret: fn -> Application.get_env(:myapp, :surge_webhook_secret) end
    ```

    """

    import Plug.Conn
    alias Plug.Conn
    alias Surge.Events.Event

    @behaviour Plug

    @impl true
    def init(opts) do
      path_info = String.split(opts[:at], "/", trim: true)

      opts
      |> Enum.into(%{})
      |> Map.put_new(:path_info, path_info)
    end

    @impl true
    def call(
          %Conn{method: "POST", path_info: path_info} = conn,
          %{
            path_info: path_info,
            secret: secret,
            handler: handler
          } = opts
        ) do
      secret = parse_secret!(secret)

      with [signature] <- get_req_header(conn, "surge-signature"),
           {:ok, payload, conn} <- Conn.read_body(conn),
           {:ok, %Event{} = event} <- construct_event(payload, signature, secret, opts),
           :ok <- handle_event!(handler, event) do
        send_resp(conn, 200, "Webhook received.") |> halt()
      else
        {:handle_error, reason} -> send_resp(conn, 400, reason) |> halt()
        _ -> send_resp(conn, 400, "Bad request.") |> halt()
      end
    end

    @impl true
    def call(%Conn{path_info: path_info} = conn, %{path_info: path_info}) do
      send_resp(conn, 400, "Bad request.") |> halt()
    end

    @impl true
    def call(conn, _), do: conn

    defp construct_event(payload, signature, secret, %{tolerance: tolerance}) do
      Surge.Webhook.construct_event(payload, signature, secret, tolerance: tolerance)
    end

    defp construct_event(payload, signature, secret, _opts) do
      Surge.Webhook.construct_event(payload, signature, secret)
    end

    defp handle_event!(handler, %Event{} = event) do
      case handler.handle_event(event) do
        {:ok, _} ->
          :ok

        :ok ->
          :ok

        {:error, reason} when is_binary(reason) ->
          {:handle_error, reason}

        {:error, reason} when is_atom(reason) ->
          {:handle_error, Atom.to_string(reason)}

        :error ->
          {:handle_error, ""}

        resp ->
          raise """
          #{inspect(handler)}.handle_event/1 returned an invalid response. Expected {:ok, term}, :ok, {:error, reason} or :error
          Got: #{inspect(resp)}

          Event data: #{inspect(event)}
          """
      end
    end

    defp parse_secret!({m, f, a}), do: apply(m, f, a)
    defp parse_secret!(fun) when is_function(fun), do: fun.()
    defp parse_secret!(secret) when is_binary(secret), do: secret

    defp parse_secret!(secret) do
      raise """
      The Surge webhook secret is invalid. Expected a string, tuple, or function.
      Got: #{inspect(secret)}

      If you're setting the secret at runtime, you need to pass a tuple or function.
      For example:

      plug Surge.WebhookPlug,
        at: "/webhook/surge",
        handler: MyAppWeb.SurgeHandler,
        secret: {Application, :get_env, [:myapp, :surge_webhook_secret]}
      """
    end
  end
end

