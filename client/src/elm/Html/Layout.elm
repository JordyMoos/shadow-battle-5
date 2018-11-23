module Html.Layout exposing (default)

import Html exposing (Html, br, div)
import Html.Attributes exposing (class, id)
import Html.Menu


default : Html msg -> Html msg
default content =
    div
        [ id "shadow_left" ]
        [ div [ id "shadow_right" ]
            [ container content
            ]
        ]


container : Html msg -> Html msg
container content =
    div
        [ id "container" ]
        [ div [ id "header_top" ] []
        , div [ id "header" ] []
        , div [ id "header_bottom" ] []
        , div
            [ id "body" ]
            [ body content
            ]
        , div [ id "footer" ] []
        ]


body : Html msg -> Html msg
body content =
    div
        [ id "body" ]
        [ div [ id "menu" ] [ Html.Menu.main ]
        , div [ id "cotnetn" ] [ content ]
        , br [ class "clear" ] []
        ]
