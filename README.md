# Surge SDK for Elixir

[Surge](https://surge.app) is the easiest SMS API for developers. We write all
of our code in Elixir, and we're proud to maintain a first party client for
Elixir.

## Installation

Add `surge` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:surge_api, "~> 0.1.0"}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Configuration

Configure your Surge API credentials in your application configuration:

```elixir
# config/config.exs
config :surge,
  api_key: System.get_env("SURGE_API_KEY"),
  base_url: System.get_env("SURGE_API_URL", "https://api.surge.app")
```

## Quick Start

### Using the Default Client

The SDK will automatically use your configured API key:

```elixir
# Send a message
{:ok, message} = Surge.Messages.create(account.id, %{
  from: "+15551234567",
  to: "+15559876543",
  body: "Hello from Surge!"
})
```

### Using a Custom Client

You can create a client to use specific credentials, base URL, or other options:

```elixir
client = Surge.Client.new("sk_test_your_api_key")

# Use the client for API calls
{:ok, account} = Surge.Accounts.create(client, %{name: "Test Account"})
```

## Error Handling

All API calls return either `{:ok, result}` or `{:error, error}`:

```elixir
case Surge.Messages.create("acct_123", params) do
  {:ok, message} ->
    IO.puts("Message sent: #{message.id}")
  
  {:error, %Surge.Error{} = error} ->
    IO.puts("Error: #{error.message}")
    IO.puts("Error type: #{error.type}")
    IO.puts("Error details: #{inspect(error.detail)}")
end
```

## Advanced Configuration

### Custom Request Options

You can pass custom options to the underlying HTTP client:

```elixir
client = Surge.Client.new("api_key", 
  req_options: [
    timeout: 30_000,
    retry: :transient
  ]
)
```

### Using a Different Base URL

For testing or using a different Surge environment:

```elixir
client = Surge.Client.new("api_key", base_url: "https://staging.surge.app")
```

## Documentation

Generate the documentation locally:

```bash
mix docs
open doc/index.html
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This SDK is distributed under the MIT license. See `LICENSE` for more information.

## Support

For questions and support:
- Email: support@surge.app
- Documentation: https://docs.surge.app
- API Status: https://status.surge.app

