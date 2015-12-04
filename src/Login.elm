module Login where

import Signal exposing (Address)

import Http

import Html exposing (Html, Attribute, div, button, text, input)
import Html.Attributes exposing (type', placeholder, value, style)
import Html.Events exposing (onClick, on, targetValue)

import Task
import Effects exposing (Effects)

import Debug

import Json.Encode as JE
import Json.Decode exposing ((:=), string, list, object2)
import Json.Decode as JD

import CouchDB

-- Model

type alias User =
  { name : String
  , roles : List String
  }

type alias Model =
  { username   : String
  , password   : String
  , errMessage : Maybe String
  , user       : Maybe User
  , result     : Maybe Http.Response
  , me         : Maybe String
  }

init : (Model, Effects Action)
init =
  let
    model = Model "" "" Nothing Nothing Nothing Nothing
  in
    ( model, currentSession )

-- Update

type Action = Username String
            | Password String
            | SessionStatus (Maybe User)
            | AuthRequest
            | AuthResponse (Maybe User)
            | Logout
            | LogoutResponse (Maybe Http.Response)

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Username s ->
      ( { model | username = s }
      , Effects.none
      )

    Password s ->
      ( { model | password = s }
      , Effects.none
      )

    AuthRequest ->
      ( model, authenticate model )

    AuthResponse authResult ->
      ( loginUpdate authResult model
      , Effects.none
      )

    SessionStatus maybeS ->
      ( { model | user = maybeS }
      , Effects.none
      )

    Logout ->
      ( model, logout)

    LogoutResponse _ ->
      init


authenticate : Model -> Effects Action
authenticate model =
  CouchDB.login model.username model.password
    |> Http.fromJson authenticationDecoder
    |> Task.toMaybe
    |> Task.map AuthResponse
    |> Effects.task

authenticationDecoder : JD.Decoder User
authenticationDecoder =
  object2 User
    ("name"  := string)
    ("roles" := list string)

loginUpdate : Maybe User -> Model -> Model
loginUpdate authResult model =
  case authResult of
    Nothing ->
      { model |
        errMessage = Just "Username or password was not correct"
      , user = authResult
      , password = ""
      }

    Just user ->
      { model | errMessage = Nothing, user = authResult, password = "" }

currentSession : Effects Action
currentSession =
  CouchDB.currentSession
    |> Http.fromJson sessionDecoder
    |> Task.toMaybe
    |> Task.map SessionStatus
    |> Effects.task

sessionDecoder : JD.Decoder User
sessionDecoder =
  object2 User
    (JD.at ["userCtx", "name"] string)
    (JD.at ["userCtx", "roles"] (list string))

userRequest : Model -> Http.Request
userRequest model =
  { verb    = "GET"
  , headers = []
  , url     = "http://localhost:5984/_users/org.couchdb.user:" ++ model.username
  , body    = Http.empty
  }

logout : Effects Action
logout =
  CouchDB.logout
    |> Task.toMaybe
    |> Task.map LogoutResponse
    |> Effects.task


-- View

view : Address Action -> Model -> Html
view address model =
  div []
    [ field "text" address Username "Username" model.username
    , field "password" address Password "Password" model.password
    , div []
        [ div [ fieldNamedStyle "160px" ] [ text "" ]
        , button [ onClick address AuthRequest ] [ text "Login" ]
        , button [ onClick address Logout ] [ text "Logout" ]
        ]
    , div []
        [ div [ fieldNamedStyle "160px" ] [ text "" ]
        , viewError model.errMessage
        ]
    ]

viewError : Maybe String -> Html
viewError em =
  case em of
    Nothing  -> div [] [ text "" ]
    Just msg -> div [] [ text msg ]

field : String
     -> Address Action
     -> (String -> Action)
     -> String
     -> String
     -> Html
field fieldType address toAction name content =
  div []
    [ div [ fieldNamedStyle "160px" ] [ text name ]
    , input
        [ type' fieldType
        , placeholder name
        , value content
        , on "input" targetValue (\s -> Signal.message address (toAction s))
        ]
        []
    ]

fieldNamedStyle : String -> Attribute
fieldNamedStyle px =
  style
    [ ("width", px)
    , ("padding", "10px")
    , ("text-align", "right")
    , ("display", "inline-block")
    ]
