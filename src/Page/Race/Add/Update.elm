port module Page.Race.Add.Update exposing (update)

import Date
import Date.Extra.Format
import Date.Extra.Config.Config_nl_nl exposing (config)
import Json.Encode
import Json.Decode
import Json.Decode.Extra
import Ui.Calendar
import App.Model exposing (App)
import App.Page
import Page.Race.Add.Model as RaceAdd
import Page.Race.Add.Msg as Msg exposing (Msg)
import Data.RaceType as RaceType exposing (raceTypeToString)


port addRace : Json.Encode.Value -> Cmd msg


update : Msg -> App -> ( App, Cmd Msg )
update msg app =
    case app.page of
        App.Page.RaceAdd page ->
            case msg of
                Msg.Submit ->
                    addSubmit page app

                Msg.Name name ->
                    let
                        nextPage =
                            App.Page.RaceAdd
                                { page | name = name }
                    in
                        ( { app | page = nextPage }, Cmd.none )

                Msg.RaceType raceType ->
                    let
                        nextPage =
                            App.Page.RaceAdd
                                { page | raceType = raceType }
                    in
                        ( { app | page = nextPage }, Cmd.none )

                Msg.Calendar msg_ ->
                    let
                        ( calendar, cmd ) =
                            Ui.Calendar.update msg_ page.calendar

                        nextPage =
                            App.Page.RaceAdd
                                { page | calendar = calendar }
                    in
                        ( { app | page = nextPage }
                        , Cmd.map Msg.Calendar cmd
                        )

        _ ->
            ( app, Cmd.none )


dateFormat : Date.Date -> String
dateFormat date =
    Date.Extra.Format.format config "%Y-%m-%d 00:00:00" date


addSubmit : RaceAdd.Model -> App.Model.App -> ( App, Cmd Msg )
addSubmit raceAdd app =
    let
        dateString =
            dateFormat raceAdd.calendar.value

        payload =
            Json.Encode.object
                [ ( "name", Json.Encode.string raceAdd.name )
                , ( "date", Json.Encode.string dateString )
                , ( "category", Json.Encode.string <| raceTypeToString raceAdd.raceType )
                ]
    in
        ( app, addRace payload )
