module Authorizable
  def authorize
    system('oauth2l fetch --json client_secret.json https://www.googleapis.com/auth/contacts https://www.googleapis.com/auth/contacts.readonly')
  end

  def authorized?
    credentials = File.join(File.expand_path('~'), '.oauth2l.token')
    File.exists?(credentials) && !File.zero?(credentials)
  end
end
