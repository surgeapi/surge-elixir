defmodule Surge.MixProject do
  use Mix.Project

  def project do
    [
      app: :surge,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Elixir client SDK for the Surge API",
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5"},
      {:jason, "~> 1.4"},
      {:hammox, "~> 0.7", only: :test},
      {:ex_doc, "~> 0.38", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/surge_api/surge-elixir"},
      maintainers: ["Dennis Beatty"]
    ]
  end

  defp docs do
    [
      main: "Surge",
      groups_for_modules: [
        Accounts: [
          Surge.Accounts,
          Surge.Accounts.Account,
          Surge.Accounts.AccountStatus,
          Surge.Accounts.Organization
        ],
        Blasts: [Surge.Blasts, Surge.Blasts.Blast],
        Campaigns: [Surge.Campaigns, Surge.Campaigns.Campaign],
        Contacts: [Surge.Contacts, Surge.Contacts.Contact],
        Messages: [Surge.Messages, Surge.Messages.Attachment, Surge.Messages.Message],
        "Phone Numbers": [Surge.PhoneNumbers, Surge.PhoneNumbers.PhoneNumber],
        Users: [Surge.Users, Surge.Users.User],
        Verifications: [
          Surge.Verifications,
          Surge.Verifications.Verification,
          Surge.Verifications.VerificationCheck
        ]
      ]
    ]
  end
end
