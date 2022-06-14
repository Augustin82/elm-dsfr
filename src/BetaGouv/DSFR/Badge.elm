module BetaGouv.DSFR.Badge exposing (..)

import Accessibility exposing (Attribute, Html, div, li, p, ul)
import BetaGouv.DSFR.Color exposing (CustomColor)
import Html.Attributes exposing (class)
import Html.Attributes.Extra exposing (empty)
import Html.Extra exposing (static)
import Accessibility exposing (span)


type BadgeConfig
    = Default { label : Label, color : CustomColor } (List (Attribute Never))
    | System { label : Label, context : Context, withIcon : Bool } (List (Attribute Never))


type alias Label =
    Html Never


type Size
    = SM
    | MD


type Context
    = Success
    | Error
    | Info
    | Warning
    | New


customColorToClass : CustomColor -> String
customColorToClass customColor =
    (++) "fr-badge--" <|
        case customColor of
            DSFR.Color.Standard ->
                ""

            DSFR.Color.GreenEmeraude ->
                "green-emeraude"

            DSFR.Color.GreenMenthe ->
                "green-menthe"

            DSFR.Color.BlueCumulus ->
                "blue-cumulus"

            DSFR.Color.BlueFrance ->
                "blue-france"

            DSFR.Color.BrownCaramel ->
                "brown-caramel"

            DSFR.Color.BrownOpera ->
                "brown-opera"


contextToClass : Context -> String
contextToClass context =
    (++) "fr-badge--" <|
        case context of
            Success ->
                "success"

            Error ->
                "error"

            Info ->
                "info"

            Warning ->
                "warning"

            New ->
                "new"


badgeMD : BadgeConfig -> Html msg
badgeMD =
    badge MD


badgeSM : BadgeConfig -> Html msg
badgeSM =
    badge SM


groupMD : List BadgeConfig -> Html msg
groupMD =
    group MD


groupSM : List BadgeConfig -> Html msg
groupSM =
    group SM


default : Html Never -> BadgeConfig
default label =
    Default { label = label, color = DSFR.Color.standard } []


withColor : CustomColor -> BadgeConfig -> BadgeConfig
withColor color config =
    case config of
        Default c attrs ->
            Default { c | color = color } attrs

        System _ _ ->
            config


system : { context : Context, withIcon : Bool } -> Html Never -> BadgeConfig
system { context, withIcon } label =
    System { label = label, context = context, withIcon = withIcon } []


withAttrs : List (Attribute Never) -> BadgeConfig -> BadgeConfig
withAttrs attrs config =
    case config of
        Default c _ ->
            Default c attrs

        System c _ ->
            System c attrs


group : Size -> List BadgeConfig -> Html msg
group size configs =
    static <|
        ul [ class "fr-badge-group" ] <|
            List.map (view size >> List.singleton >> li []) <|
                configs


badge : Size -> BadgeConfig -> Html msg
badge size config =
    static <|
        view size config


view : Size -> BadgeConfig -> Html Never
view size config =
    let
        sizeAttr =
            case size of
                MD ->
                    empty

                SM ->
                    class "fr-badge--sm"

        ( colorAttrs, iconAttrs ) =
            case config of
                Default { color } _ ->
                    ( class <| customColorToClass color, empty )

                System { context, withIcon } _ ->
                    ( class <| contextToClass context
                    , if withIcon then
                        empty

                      else
                        class "fr-badge--no-icon"
                    )

        ( content, extraAttrs ) =
            case config of
                Default { label } attrs ->
                    ( label, attrs )

                System { label } attrs ->
                    ( label, attrs )
    in
    span [] <|
        [ p
            (class "fr-badge"
                :: sizeAttr
                :: colorAttrs
                :: iconAttrs
                :: extraAttrs
            )
            [ content ]
        ]
