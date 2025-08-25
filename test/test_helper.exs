Application.put_env(:surge_api, :api_key, "sk_default_123")

Application.put_env(:surge_api, :req_options,
  connect_options: [timeout: 15_000],
  plug: {Req.Test, Surge.TestClient}
)

ExUnit.start()
