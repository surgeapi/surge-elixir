defmodule Surge.VerificationsTest do
  use ExUnit.Case, async: false

  alias Surge.Client
  alias Surge.Verifications
  alias Surge.Verifications.Verification
  alias Surge.Verifications.VerificationCheck

  import Surge.VerificationsFixtures

  describe "create/2" do
    test "creates a verification with phone number matching OpenAPI example" do
      # Example request from OpenAPI spec
      params = %{
        phone_number: "+18015551234"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/verifications"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]

        assert conn.params["phone_number"] == "+18015551234"

        # Example response from OpenAPI spec
        response_body = verification_fixture()

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Verification{} = verification} = Verifications.create(client, params)
      assert verification.id == "vfn_01jayh15c2f2xamftg0xpyq1nj"
      assert verification.attempt_count == 0
      assert verification.phone_number == "+18015551234"
      assert verification.status == :pending
    end

    test "creates a verification with additional parameters" do
      params = %{
        phone_number: "+18015555678",
        locale: "es",
        custom_message: "Su código es: {{code}}"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.params["phone_number"] == "+18015555678"
        assert conn.params["locale"] == "es"
        assert conn.params["custom_message"] == "Su código es: {{code}}"

        response_body =
          verification_fixture(%{
            "phone_number" => "+18015555678"
          })

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %Verification{} = verification} = Verifications.create(client, params)
      assert verification.phone_number == "+18015555678"
    end

    test "returns error when phone number is invalid" do
      params = %{
        phone_number: "invalid"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(400)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "validation_error",
            "message" => "Invalid phone number format"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Verifications.create(client, params)
      assert error.type == "validation_error"
      assert error.message == "Invalid phone number format"
    end

    test "returns error when rate limit exceeded" do
      params = %{
        phone_number: "+18015551234"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(429)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "rate_limit_error",
            "message" => "Too many verification attempts for this phone number"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Verifications.create(client, params)
      assert error.type == "rate_limit_error"
      assert error.message == "Too many verification attempts for this phone number"
    end

    test "handles connection errors" do
      params = %{
        phone_number: "+18015551234"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Verifications.create(client, params)
      assert error.type == "connection_error"
    end
  end

  describe "create/1" do
    test "uses default client" do
      params = %{
        phone_number: "+18015551234"
      }

      response_body = verification_fixture()

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(201)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %Verification{} = verification} = Verifications.create(params)
      assert verification.id == "vfn_01jayh15c2f2xamftg0xpyq1nj"
    end
  end

  describe "check/3" do
    test "checks verification with correct code (ok result)" do
      verification_id = "vfn_01jayh15c2f2xamftg0xpyq1nj"

      # Example request from OpenAPI spec
      params = %{
        code: "123456"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.method == "POST"
        assert conn.request_path == "/verifications/vfn_01jayh15c2f2xamftg0xpyq1nj/checks"
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_test_123"]
        assert Plug.Conn.get_req_header(conn, "accept") == ["application/json"]

        assert conn.params["code"] == "123456"

        # Example response from OpenAPI spec - successful verification
        response_body = verification_check_ok_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %VerificationCheck{} = check} =
               Verifications.check(client, verification_id, params)

      assert check.result == :ok
      assert check.verification.id == "vfn_01jayh15c2f2xamftg0xpyq1nj"
      assert check.verification.status == :verified
      assert check.verification.attempt_count == 1
    end

    test "checks verification with incorrect code (pending status)" do
      verification_id = "vfn_01jayh15c2f2xamftg0xpyq1nj"

      params = %{
        code: "000000"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert conn.params["code"] == "000000"

        # Example response - incorrect code, still pending
        response_body = verification_check_incorrect_pending_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %VerificationCheck{} = check} =
               Verifications.check(client, verification_id, params)

      assert check.result == :incorrect
      assert check.verification.status == :pending
      assert check.verification.attempt_count == 1
    end

    test "checks verification with incorrect code (exhausted status)" do
      verification_id = "vfn_01jayh15c2f2xamftg0xpyq1nj"

      params = %{
        code: "999999"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        # Example response - incorrect code, max attempts reached
        response_body = verification_check_incorrect_exhausted_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %VerificationCheck{} = check} =
               Verifications.check(client, verification_id, params)

      assert check.result == :incorrect
      assert check.verification.status == :exhausted
      assert check.verification.attempt_count == 3
    end

    test "checks expired verification" do
      verification_id = "vfn_01jayh15c2f2xamftg0xpyq1nj"

      params = %{
        code: "123456"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        # Example response - verification expired
        response_body = verification_check_expired_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %VerificationCheck{} = check} =
               Verifications.check(client, verification_id, params)

      assert check.result == :expired
      assert check.verification.status == :expired
      assert check.verification.attempt_count == 0
    end

    test "checks already verified verification" do
      verification_id = "vfn_01jayh15c2f2xamftg0xpyq1nj"

      params = %{
        code: "123456"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        # Example response - already verified
        response_body = verification_check_already_verified_fixture()

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:ok, %VerificationCheck{} = check} =
               Verifications.check(client, verification_id, params)

      assert check.result == :already_verified
      assert check.verification.status == :verified
      assert check.verification.attempt_count == 1
    end

    test "returns error when verification not found" do
      verification_id = "vfn_nonexistent"

      params = %{
        code: "123456"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        conn
        |> Plug.Conn.put_status(404)
        |> Req.Test.json(%{
          "error" => %{
            "type" => "not_found_error",
            "message" => "Verification 'vfn_nonexistent' not found"
          }
        })
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Verifications.check(client, verification_id, params)
      assert error.type == "not_found_error"
      assert error.message == "Verification 'vfn_nonexistent' not found"
    end

    test "handles connection errors" do
      verification_id = "vfn_01jayh15c2f2xamftg0xpyq1nj"

      params = %{
        code: "123456"
      }

      Req.Test.expect(Surge.TestClient, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      client = Client.new("sk_test_123", req_options: [plug: {Req.Test, Surge.TestClient}])

      assert {:error, error} = Verifications.check(client, verification_id, params)
      assert error.type == "connection_error"
    end
  end

  describe "check/2" do
    test "uses default client" do
      verification_id = "vfn_01jayh15c2f2xamftg0xpyq1nj"

      params = %{
        code: "123456"
      }

      response_body = verification_check_ok_fixture()

      Req.Test.expect(Surge.TestClient, fn conn ->
        assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer sk_default_123"]

        conn
        |> Plug.Conn.put_status(200)
        |> Req.Test.json(response_body)
      end)

      assert {:ok, %VerificationCheck{} = check} = Verifications.check(verification_id, params)
      assert check.result == :ok
    end
  end

  describe "Verification.from_json/1" do
    test "parses pending verification" do
      data = verification_fixture()

      verification = Verification.from_json(data)

      assert verification.id == "vfn_01jayh15c2f2xamftg0xpyq1nj"
      assert verification.attempt_count == 0
      assert verification.phone_number == "+18015551234"
      assert verification.status == :pending
    end

    test "parses verified verification" do
      data = verified_verification_fixture()

      verification = Verification.from_json(data)

      assert verification.status == :verified
      assert verification.attempt_count == 1
    end

    test "parses exhausted verification" do
      data = exhausted_verification_fixture()

      verification = Verification.from_json(data)

      assert verification.status == :exhausted
      assert verification.attempt_count == 3
    end

    test "parses expired verification" do
      data = expired_verification_fixture()

      verification = Verification.from_json(data)

      assert verification.status == :expired
      assert verification.attempt_count == 0
    end

    test "handles nil fields" do
      data = verification_with_nil_fields_fixture()

      verification = Verification.from_json(data)

      assert verification.id == "vfn_nilfields"
      assert is_nil(verification.attempt_count)
      assert is_nil(verification.phone_number)
      assert is_nil(verification.status)
    end

    test "handles unknown status" do
      data = verification_with_unknown_status_fixture()

      verification = Verification.from_json(data)

      assert verification.id == "vfn_unknown"
      assert verification.phone_number == "+18015559999"
      # Unknown status should be parsed as nil
      assert is_nil(verification.status)
    end

    test "handles minimal data" do
      data = minimal_verification_fixture()

      verification = Verification.from_json(data)

      assert verification.id == "vfn_minimal123"
      assert is_nil(verification.attempt_count)
      assert is_nil(verification.phone_number)
      assert is_nil(verification.status)
    end

    test "handles empty map" do
      data = %{}

      verification = Verification.from_json(data)

      assert is_nil(verification.id)
      assert is_nil(verification.attempt_count)
      assert is_nil(verification.phone_number)
      assert is_nil(verification.status)
    end
  end

  describe "VerificationCheck.from_json/1" do
    test "parses successful verification check" do
      data = verification_check_ok_fixture()

      check = VerificationCheck.from_json(data)

      assert check.result == :ok
      assert check.verification.status == :verified
    end

    test "parses incorrect code with pending status" do
      data = verification_check_incorrect_pending_fixture()

      check = VerificationCheck.from_json(data)

      assert check.result == :incorrect
      assert check.verification.status == :pending
    end

    test "parses incorrect code with exhausted status" do
      data = verification_check_incorrect_exhausted_fixture()

      check = VerificationCheck.from_json(data)

      assert check.result == :incorrect
      assert check.verification.status == :exhausted
    end

    test "parses expired verification check" do
      data = verification_check_expired_fixture()

      check = VerificationCheck.from_json(data)

      assert check.result == :expired
      assert check.verification.status == :expired
    end

    test "parses already verified check" do
      data = verification_check_already_verified_fixture()

      check = VerificationCheck.from_json(data)

      assert check.result == :already_verified
      assert check.verification.status == :verified
    end

    test "handles nil fields" do
      data = verification_check_with_nil_fields_fixture()

      check = VerificationCheck.from_json(data)

      assert is_nil(check.result)
      assert is_nil(check.verification)
    end

    test "handles unknown result" do
      data = verification_check_with_unknown_result_fixture()

      check = VerificationCheck.from_json(data)

      # Unknown result should be parsed as nil
      assert is_nil(check.result)
      assert check.verification.id == "vfn_01jayh15c2f2xamftg0xpyq1nj"
    end

    test "handles minimal verification in check" do
      data = verification_check_minimal_fixture()

      check = VerificationCheck.from_json(data)

      assert check.result == :ok
      assert check.verification.id == "vfn_minimal123"
      assert is_nil(check.verification.phone_number)
      assert is_nil(check.verification.status)
    end

    test "handles empty map" do
      data = %{}

      check = VerificationCheck.from_json(data)

      assert is_nil(check.result)
      assert is_nil(check.verification)
    end

    test "parses all result types correctly" do
      # Test exhausted result specifically
      data = %{"result" => "exhausted", "verification" => minimal_verification_fixture()}
      check = VerificationCheck.from_json(data)
      assert check.result == :exhausted

      # Test ok result
      data = %{"result" => "ok", "verification" => minimal_verification_fixture()}
      check = VerificationCheck.from_json(data)
      assert check.result == :ok

      # Test incorrect result
      data = %{"result" => "incorrect", "verification" => minimal_verification_fixture()}
      check = VerificationCheck.from_json(data)
      assert check.result == :incorrect

      # Test expired result
      data = %{"result" => "expired", "verification" => minimal_verification_fixture()}
      check = VerificationCheck.from_json(data)
      assert check.result == :expired
    end
  end
end
