module Nabu where

import Effects exposing (Effects)
import Signal

import Html exposing (Html, div)

import Login
import Navigation

-- Model


type alias Model =
  { navigation: Navigation.Model
  , login:      Login.Model
  , session:    Maybe Login.User
  }

init : (Model, Effects Action)
init =
  let
    (nav, navFx)     = Navigation.init
    (login, loginFx) = Login.init
  in
    ( Model nav login Nothing
    , Effects.batch
        [ Effects.map Navigate navFx
        , Effects.map Authenticate loginFx
        ]
    )

-- Update

type Action = Navigate Navigation.Action
            | Authenticate Login.Action

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Navigate act ->
      let
        (nav, fx) = Navigation.update act model.navigation
      in
        ( Model nav model.login model.session
        , Effects.map Navigate fx
        )

    Authenticate act ->
      let
        (auth, fx) = Login.update act model.login
      in
        ( Model model.navigation auth auth.user
        , Effects.map Authenticate fx
        )

-- View

view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [ Navigation.view (Signal.forwardTo address Navigate) model.navigation model.session
    , Login.view (Signal.forwardTo address Authenticate) model.login
    ]
