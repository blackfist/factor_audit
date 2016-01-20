# FactorAudit
Audits a GitHub org to see who hasn't turned on two factor authentication

## Code Smells
This was a learning exercise and there is some downright shitty code in some
places. Such as

* There is a `:timer.sleep` call in FactorAudit.main which is there so that `UserList` has time to finish. There's probably a better way to do that.
* Do I really need to enrich the users in a separate process? It was a fun learning exercise but I'm not sure that was actually necessary to make this code perform well.
* This code has zero protection for rate limiting. In fact, since I enrich the user data in parallel there's a good chance that you'll get rate limited if you have a lot of users that don't have 2FA turned on.

## Shit I need to fix

* I need to figure out how to read the headers that come back from GitHub and get the url for the next page of results. GitHub paginates the answer so right now this is only reading the first page of results. However, parsing the headers was not trivial enough to make it into my proof of concept code.
