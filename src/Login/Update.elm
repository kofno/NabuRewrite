module Login.Update
  ( update
  , init
  , Action(..)
  ) where

import Login.Model exposing (Model, User, initialModel)

import Effects exposing (Effects)
import Task

import CouchDB
import Http

import Json.Decode exposing (Decoder, (:=), object2, string, list, at, maybe)

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

init : (Model, Effects Action)
init = ( initialModel, currentSession )

authenticate : Model -> Effects Action
authenticate model =
  CouchDB.login model.username model.password
    |> Http.fromJson authenticationDecoder
    |> Task.toResult
    |> Task.map AuthResponse
    |> Effects.task

authenticationDecoder : Decoder User
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

sessionDecoder : Decoder (Maybe User)
sessionDecoder =
  maybe ( object2 User
              (at ["userCtx", "name"] string)
              (at ["userCtx", "roles"] (list string))
           )

logout : Effects Action
logout =
  CouchDB.logout
    |> Task.toMaybe
    |> Task.map LogoutResponse
    |> Effects.task


