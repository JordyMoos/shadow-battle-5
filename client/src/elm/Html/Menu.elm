module Html.Menu exposing (main)

import Html exposing (Html, a, div, li, text, ul)
import Html.Attributes exposing (class, href)
import Route


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
            [ a [ Route.href Route.Home ] [ li [ class "border" ] [ text "Start" ] ]
            , a [ Route.href Route.Faq ] [ li [ class "border" ] [ text "Help/FAQ" ] ]
            , li [] [ text "Contact" ]
            ]
        , ul [ class "regular" ]
            [ li [ class "border" ] [ text "Login" ]
            , li [ class "border" ] [ text "Activate" ]
            , li [] [ text "Sign up" ]
            ]
        ]
