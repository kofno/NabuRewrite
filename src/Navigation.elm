module Navigation where

import Effects exposing (Effects)
import Signal exposing (Address)

import Html exposing (Html, div, ul, li, a, text)
import Html.Attributes exposing (href)

import Login

-- Model

type alias Model =
  { brand: String
  }

init : (Model, Effects Action)
init =
    ( Model "Nabu"
    , Effects.none
    )

-- Update

type Action = NoOp

update :  Action -> Model -> (Model, Effects Action)
update action model =
  ( model
  , Effects.none
  )

-- View

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
