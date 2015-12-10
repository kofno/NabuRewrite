module Nabu.Update
  ( init
  , update
  , Action(..)
  ) where

import Effects exposing (Effects)

import Nabu.Model exposing (Model)

import Login.Update as Login
import Navigation.Update as Navigation

type Action
  = Navigate Navigation.Action
  | Authenticate Login.Action

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

