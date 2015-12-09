module Login.View
  ( view
  ) where

import Signal exposing (Address)
import Html exposing (Html, Attribute, div, button, span, input, text)
import Html.Attributes exposing (style, placeholder, type', value)
import Html.Events exposing (on, onClick, targetValue)

import Login.Model exposing (Model)
import Login.Update exposing (Action(..))

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
