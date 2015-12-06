module Login where

import Signal exposing (Address)

import Http

import Html exposing (Html, Attribute, div, button, text, input, span)
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
  }

init : (Model, Effects Action)
init =
  let
    model = Model "" "" Nothing Nothing
  in
    ( model, currentSession )

-- Update

type Action = Username String
            | Password String
            | SessionStatus (Result Http.Error (Maybe User))
            | AuthRequest
            | AuthResponse (Result Http.Error User)
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

    SessionStatus result ->
      ( sessionUpdate result model
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
    |> Task.toResult
    |> Task.map AuthResponse
    |> Effects.task

authenticationDecoder : JD.Decoder User
authenticationDecoder =
  object2 User
    ("name"  := string)
    ("roles" := list string)

loginUpdate : Result Http.Error User -> Model -> Model
loginUpdate authResult model =
  case authResult of
    Err error ->
      { model |
        errMessage = Just (responseError error)
      , user = Nothing
      , password = ""
      }

    Ok user ->
      { model | errMessage = Nothing, user = Just user, password = "" }

sessionUpdate : Result Http.Error (Maybe User) -> Model -> Model
sessionUpdate result model =
  case result of
    Err error ->
      { model |
        errMessage = Just (responseError error)
      , user = Nothing
      }

    Ok maybeUser ->
      { model | errMessage = Nothing, user = maybeUser }

responseError : Http.Error -> String
responseError error =
  case error of
    Http.BadResponse status msg ->
      case status of
        401 -> "Username and password are not correct."
        _   -> toString status ++ " " ++ msg

    Http.NetworkError ->
      "You are disconnected"

    Http.Timeout ->
      "It is taking too long to get a response from the server"

    Http.UnexpectedPayload msg ->
      "Unexpected response: " ++ msg

currentSession : Effects Action
currentSession =
  CouchDB.currentSession
    |> Http.fromJson sessionDecoder
    |> Task.toResult
    |> Task.map SessionStatus
    |> Effects.task

sessionDecoder : JD.Decoder (Maybe User)
sessionDecoder =
  JD.maybe ( object2 User
              (JD.at ["userCtx", "name"] string)
              (JD.at ["userCtx", "roles"] (list string))
           )

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
    [ div []
        [ div [ fieldNamedStyle "160px" ] [ text "" ]
        , viewError model.errMessage
        ]
    , field "text" address Username "Username" model.username
    , field "password" address Password "Password" model.password
    , div []
        [ div [ fieldNamedStyle "160px" ] [ text "" ]
        , button [ onClick address AuthRequest ] [ text "Login" ]
        , button [ onClick address Logout ] [ text "Logout" ]
        ]
    ]

viewError : Maybe String -> Html
viewError em =
  case em of
    Nothing  -> span [] [ text "" ]
    Just msg -> span [] [ text msg ]

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
