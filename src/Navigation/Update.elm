module Navigation.Update
  ( init
  , update
  , Action(..)
  ) where

import Effects exposing (Effects)

import Navigation.Model exposing (Model, initialModel)

type Action = NoOp

init : (Model, Effects Action)
init =
    ( initialModel
    , Effects.none
    )

update :  Action -> Model -> (Model, Effects Action)
update action model =
  ( model
  , Effects.none
  )
