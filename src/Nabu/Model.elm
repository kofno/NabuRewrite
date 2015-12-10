module Nabu.Model where

import Navigation.Model as Navigation
import Login.Model as Login

type alias Model =
  { navigation: Navigation.Model
  , login:      Login.Model
  , session:    Maybe Login.User
  }

