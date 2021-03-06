module Page.Race.List exposing (view)

import Html exposing (Html, h2, div, text, a, table, tr, td, th, thead, tbody)
import Html.Attributes exposing (href, class, style)
import Date
import Date.Extra.Format
import Date.Extra.Config.Config_nl_nl exposing (config)
import Date.Extra
import App.Msg
import Data.Race exposing (Race)
import Data.RaceResult exposing (RaceResult)


dateFormat : Date.Date -> String
dateFormat date =
    Date.Extra.Format.format config "%d-%m-%Y" date


view : List Race -> List RaceResult -> Html App.Msg.Msg
view races results =
    div []
        [ h2 [ class "title is-2" ] [ text "Races" ]
        , addButton
        , raceTable races results
        ]


addButton : Html App.Msg.Msg
addButton =
    a [ href "#races/add", class "button" ] [ text "Add race" ]


raceTable : List Race -> List RaceResult -> Html App.Msg.Msg
raceTable unsortedRaces results =
    let
        races =
            unsortedRaces |> List.sortWith (\ra rb -> Date.Extra.compare ra.date rb.date) |> List.reverse
    in
        table [ class "table" ]
            [ thead []
                [ tr []
                    [ th [] [ text "Name" ]
                    , th [] [ text "Date" ]
                    , th [] [ text "Category" ]
                    , th [] [ text "Riders" ]
                    ]
                ]
            , tbody []
                (List.map
                    (\race ->
                        let
                            dateString =
                                dateFormat race.date
                        in
                            tr []
                                [ td []
                                    [ a
                                        [ href ("#races/" ++ race.key), style [ ( "display", "block" ) ] ]
                                        [ text race.name ]
                                    ]
                                , td [] [ text <| dateString ]
                                , td [] [ text (toString race.raceType) ]
                                , td [] [ text (toString (countParticipants race.key results)) ]
                                ]
                    )
                    races
                )
            ]


countParticipants : String -> List RaceResult -> Int
countParticipants raceKey results =
    List.length
        (List.filter
            (\result -> result.raceKey == raceKey)
            results
        )
