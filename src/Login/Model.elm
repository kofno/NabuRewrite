module Login.Model where

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

initialModel : Model
initialModel = Model "" "" Nothing Nothing


