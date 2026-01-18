defmodule Surge.WebhookTest do
  use ExUnit.Case, async: true

  alias Surge.Webhook
  alias Surge.Events.Event

  describe "construct_event/4" do
    test "constructs event with valid signature" do
      payload = ~s({"type":"message.received","account_id":"acct_123","data":{"id":"msg_456"}})
      secret = "whsec_test123"
      timestamp = System.system_time(:second)

      signed_payload = "#{timestamp}.#{payload}"

      signature_hash =
        :crypto.mac(:hmac, :sha256, secret, signed_payload) |> Base.encode16(case: :lower)

      signature = "t=#{timestamp},v1=#{signature_hash}"

      assert {:ok, %Event{} = event} = Webhook.construct_event(payload, signature, secret)
      assert event.account_id == "acct_123"
      assert event.type == :message_received
      assert event.data.id == "msg_456"
    end

    test "constructs event with custom tolerance" do
      payload = ~s({"type":"message.received","account_id":"acct_123","data":{"id":"msg_456"}})
      secret = "whsec_test123"
      # Use timestamp from 10 minutes ago
      timestamp = System.system_time(:second) - 600

      signed_payload = "#{timestamp}.#{payload}"

      signature_hash =
        :crypto.mac(:hmac, :sha256, secret, signed_payload) |> Base.encode16(case: :lower)

      signature = "t=#{timestamp},v1=#{signature_hash}"

      # Should fail with default tolerance (5 minutes)
      assert {:error, :timestamp_too_old} = Webhook.construct_event(payload, signature, secret)

      # Should succeed with 11 minute tolerance
      assert {:ok, %Event{}} = Webhook.construct_event(payload, signature, secret, tolerance: 660)
    end

    test "fails with invalid JSON payload" do
      payload = "not valid json"
      secret = "whsec_test123"
      timestamp = System.system_time(:second)

      signed_payload = "#{timestamp}.#{payload}"

      signature_hash =
        :crypto.mac(:hmac, :sha256, secret, signed_payload) |> Base.encode16(case: :lower)

      signature = "t=#{timestamp},v1=#{signature_hash}"

      assert {:error, %Jason.DecodeError{}} = Webhook.construct_event(payload, signature, secret)
    end

    test "fails with invalid signature" do
      payload = ~s({"type":"message.received","account_id":"acct_123","data":{"id":"msg_456"}})
      secret = "whsec_test123"
      signature = "t=#{System.system_time(:second)},v1=invalid_signature"

      assert {:error, :invalid_signature} = Webhook.construct_event(payload, signature, secret)
    end
  end

  describe "verify_signature/4" do
    test "verifies valid signature" do
      payload = ~s({"type":"message.received"})
      secret = "whsec_test123"
      timestamp = System.system_time(:second)

      signed_payload = "#{timestamp}.#{payload}"

      signature_hash =
        :crypto.mac(:hmac, :sha256, secret, signed_payload) |> Base.encode16(case: :lower)

      signature = "t=#{timestamp},v1=#{signature_hash}"

      assert :ok = Webhook.verify_signature(payload, signature, secret)
    end

    test "verifies with multiple v1 signatures (key rotation)" do
      payload = ~s({"type":"message.received"})
      secret = "whsec_test123"
      timestamp = System.system_time(:second)

      signed_payload = "#{timestamp}.#{payload}"

      valid_signature =
        :crypto.mac(:hmac, :sha256, secret, signed_payload) |> Base.encode16(case: :lower)

      old_signature =
        :crypto.mac(:hmac, :sha256, "old_secret", signed_payload) |> Base.encode16(case: :lower)

      # Include both old and new signatures
      signature = "t=#{timestamp},v1=#{old_signature},v1=#{valid_signature}"

      assert :ok = Webhook.verify_signature(payload, signature, secret)
    end

    test "rejects invalid signature" do
      payload = ~s({"type":"message.received"})
      secret = "whsec_test123"
      timestamp = System.system_time(:second)
      signature = "t=#{timestamp},v1=invalid_signature_hash"

      assert {:error, :invalid_signature} = Webhook.verify_signature(payload, signature, secret)
    end

    test "rejects timestamp outside tolerance window" do
      payload = ~s({"type":"message.received"})
      secret = "whsec_test123"
      # Timestamp from 6 minutes ago
      timestamp = System.system_time(:second) - 360

      signed_payload = "#{timestamp}.#{payload}"

      signature_hash =
        :crypto.mac(:hmac, :sha256, secret, signed_payload) |> Base.encode16(case: :lower)

      signature = "t=#{timestamp},v1=#{signature_hash}"

      # Default tolerance is 5 minutes
      assert {:error, :timestamp_too_old} = Webhook.verify_signature(payload, signature, secret)
    end

    test "accepts timestamp within custom tolerance" do
      payload = ~s({"type":"message.received"})
      secret = "whsec_test123"
      # Timestamp from 6 minutes ago
      timestamp = System.system_time(:second) - 360

      signed_payload = "#{timestamp}.#{payload}"

      signature_hash =
        :crypto.mac(:hmac, :sha256, secret, signed_payload) |> Base.encode16(case: :lower)

      signature = "t=#{timestamp},v1=#{signature_hash}"

      # With 7 minute tolerance
      assert :ok = Webhook.verify_signature(payload, signature, secret, 420)
    end

    test "rejects malformed signature header" do
      payload = ~s({"type":"message.received"})
      secret = "whsec_test123"

      # Missing timestamp
      assert {:error, :invalid_signature_header} =
               Webhook.verify_signature(payload, "v1=somehash", secret)

      # Missing v1
      assert {:error, :invalid_signature_header} =
               Webhook.verify_signature(payload, "t=12345", secret)

      # Invalid format
      assert {:error, :invalid_signature_header} =
               Webhook.verify_signature(payload, "invalid", secret)

      # Empty string
      assert {:error, :invalid_signature_header} = Webhook.verify_signature(payload, "", secret)
    end

    test "rejects tampered payload" do
      original_payload = ~s({"type":"message.received","amount":100})
      tampered_payload = ~s({"type":"message.received","amount":1000})
      secret = "whsec_test123"
      timestamp = System.system_time(:second)

      # Sign the original payload
      signed_payload = "#{timestamp}.#{original_payload}"

      signature_hash =
        :crypto.mac(:hmac, :sha256, secret, signed_payload) |> Base.encode16(case: :lower)

      signature = "t=#{timestamp},v1=#{signature_hash}"

      # Try to verify with tampered payload
      assert {:error, :invalid_signature} =
               Webhook.verify_signature(tampered_payload, signature, secret)
    end

    test "handles future timestamps within tolerance" do
      payload = ~s({"type":"message.received"})
      secret = "whsec_test123"
      # Timestamp 1 minute in the future
      timestamp = System.system_time(:second) + 60

      signed_payload = "#{timestamp}.#{payload}"

      signature_hash =
        :crypto.mac(:hmac, :sha256, secret, signed_payload) |> Base.encode16(case: :lower)

      signature = "t=#{timestamp},v1=#{signature_hash}"

      # Should accept future timestamp within tolerance
      assert :ok = Webhook.verify_signature(payload, signature, secret)
    end

    test "ignores non-v1 signature versions" do
      payload = ~s({"type":"message.received"})
      secret = "whsec_test123"
      timestamp = System.system_time(:second)

      signed_payload = "#{timestamp}.#{payload}"

      valid_signature =
        :crypto.mac(:hmac, :sha256, secret, signed_payload) |> Base.encode16(case: :lower)

      # Include v2 (future version) and v1
      signature = "t=#{timestamp},v2=future_signature,v1=#{valid_signature}"

      assert :ok = Webhook.verify_signature(payload, signature, secret)
    end

    test "handles uppercase hex in signature" do
      payload = ~s({"type":"message.received"})
      secret = "whsec_test123"
      timestamp = System.system_time(:second)

      signed_payload = "#{timestamp}.#{payload}"
      # Create uppercase signature (should not match)
      signature_hash =
        :crypto.mac(:hmac, :sha256, secret, signed_payload) |> Base.encode16(case: :upper)

      signature = "t=#{timestamp},v1=#{signature_hash}"

      # Should fail because we expect lowercase hex
      assert {:error, :invalid_signature} = Webhook.verify_signature(payload, signature, secret)
    end
  end
end

