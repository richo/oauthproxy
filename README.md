This is a basic reverseproxy-type-thing for apps that want to use oauth, but by
design do not have a callback API owing to not actually being HTTP.

The short version of the workflow is:

- Connect to oauth.psych0.tk on port 2000
- Recieve 128 bytes from the socket. this is your callback id
- Send http://oauth.psych0.tk/callback/[callback_id] as your callback url
- Recieve a further 20 bytes from the socket. This is your access token

Job done!
