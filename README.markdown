# nabu

I'm re-writing an existing application. The application is written in rails. I
want to try out Elm. So I'm rewriting the application piece by piece in Elm.

Couchdb will be used on the backend. Most of the logic will happen on the
frontend. I will use couchdb for authentication. I'd like to introduce pouchdb
for synching frontend and backend. This will eventually mean needing ports to
that library.

## current state

I created a login component. It talks to couchdb. It can login and logout. When
it initializes, it tries to establish if a session exists.

I created a navigation component. Navigation renders based differently if
there's an active user session of not.

Each component is split into three elm files. Model, Update and View.

There is a library for talking to couchdb. It only talks to the _session end
point.


