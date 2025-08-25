defmodule Surge.EmptyApiKeyTest do
  use ExUnit.Case, async: false

  describe "Surge.Client.default_client/0" do
    test "raises error when API key not configured" do
      # Ensure API key is not set
      Application.delete_env(:surge_api, :api_key)

      assert_raise RuntimeError,
                   "Surge API key not configured. Set :surge_api, :api_key in your config.",
                   fn -> Surge.Client.default_client() end

      Application.put_env(:surge_api, :api_key, "sk_default_123")
    end
  end
end
