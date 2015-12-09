module Navigation.View
  ( view
  ) where

import Signal exposing (Address)

import Html exposing (Html, div, ul, li, a, text)
import Html.Attributes exposing (href)

import Login.Model as Login

import Navigation.Model exposing (Model)
import Navigation.Update exposing (Action)

view : Address Action -> Model -> Maybe Login.User -> Html
view address model user =
  div []
    [ a [href "#"] [ text model.brand ]
    , viewMenuItems user
    ]

viewUser : Maybe Login.User -> Html
viewUser user =
  case user of
    Nothing ->
      text "Please login"

    Just u ->
      text ("Welcome, " ++ u.name)

viewMenuItems : Maybe Login.User -> Html
viewMenuItems user =
  case user of
    Nothing ->
      ul []
        [ li [] [ viewUser user ] ]

    Just _ ->
      ul []
        [ li [] [ text "Item 1" ]
        , li [] [ text "Item 2" ]
        , li [] [ viewUser user ]
        ]
