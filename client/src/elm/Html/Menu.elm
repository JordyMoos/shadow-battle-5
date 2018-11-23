module Html.Menu exposing (main)

import Html exposing (Html, div, li, text, ul)
import Html.Attributes exposing (class)


main : Html msg
main =
    div
        []
        [ ul [ class "regular" ]
            [ li [ class "border" ] [ text "Members: 3" ]
            , li [ class "border" ] [ text "Online: 3" ]
            , li [] [ text "Latest member: Jordy" ]
            ]
        , ul [ class "regular" ]
            [ li [ class "border" ] [ text "Start" ]
            , li [ class "border" ] [ text "Help/FAQ" ]
            , li [] [ text "Contact" ]
            ]
        , ul [ class "regular" ]
            [ li [ class "border" ] [ text "Login" ]
            , li [ class "border" ] [ text "Activate" ]
            , li [] [ text "Sign up" ]
            ]
        ]
