module Nabu.View where

import Signal

import Html exposing (Html, div)

import Nabu.Model  as Nabu exposing (Model)
import Nabu.Update as Nabu exposing (Action)

import Navigation.Update as Navigation
import Navigation.View as Navigation

import Login.Update as Login
import Login.View as Login

view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ Navigation.view
        (Signal.forwardTo address Nabu.Navigate)
        model.navigation
        model.session
    , Login.view
        (Signal.forwardTo address Nabu.Authenticate)
        model.login
    ]
