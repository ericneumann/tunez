defmodule Tunez.Accounts.User.Senders.SendMagicLinkEmail do
  @moduledoc """
  Sends a magic link email
  """

  use AshAuthentication.Sender
  use TunezWeb, :verified_routes

  import Swoosh.Email
  alias Tunez.Mailer

  @impl true
  def send(user_or_email, token, _) do
    # if you get a user, its for a user that already exists.
    # if you get an email, then the user does not yet exist.

    email =
      case user_or_email do
        %{email: email} -> email
        email -> email
      end

    Tunez.Emails.deliver_magic_link_email(
      email,
      url(~p"/auth/user/magic_link/?token=#{token}")
    )
  end

  defp body(params) do
    """
    Hello, #{params[:email]}! Click this link to sign in:

    #{url(~p"/auth/user/magic_link/?token=#{params[:token]}")}
    """
  end
end
