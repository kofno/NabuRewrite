module CouchDB
  ( login
  , logout
  , currentSession
  ) where

import Http exposing (RawError, Response)
import Task exposing (Task)
import Json.Encode as Json


currentSession : Task RawError Response
currentSession = Http.send httpSettings sessionRequest

logout : Task RawError Response
logout = Http.send httpSettings logoutRequest

login : String -> String -> Task RawError Response
login username password =
  loginRequest username password
    |> Http.send httpSettings


sessionRequest : Http.Request
sessionRequest =
  { verb    = "GET"
  , headers = []
  , url     = "http://localhost:5984/_session"
  , body    = Http.empty
  }

logoutRequest : Http.Request
logoutRequest =
  { verb    = "DELETE"
  , headers = []
  , url     = "http://localhost:5984/_session"
  , body    = Http.empty
  }

httpSettings : Http.Settings
httpSettings =
  { timeout= 0
  , onStart= Nothing
  , onProgress= Nothing
  , desiredResponseType= Nothing
  , withCredentials= True
  }

loginRequest : String -> String -> Http.Request
loginRequest username password =
  { verb = "POST"
  , headers =
      [ ("Accept", "application/json")
      , ("Content-Type", "application/json")
      ]
  , url = "http://localhost:5984/_session"
  , body = Http.string
      ( Json.encode 0 ( Json.object
                      [ ("name", Json.string username)
                      , ("password", Json.string password)
                      ]
                    )
      )
  }
