module BetaGouv.DSFR.Button exposing (ButtonConfig, ButtonSize(..), ButtonType(..), IconPosition(..), MandatoryButtonConfig, OptionalButtonConfig, buttonSize, buttonType, defaultOptions, disable, iconAttr, large, new, reset, secondary, small, submit, view, withAttrs, withDisabled, withIcon, withOptions, withPrimary, withSize, withType)

import Accessibility as Html
import Html.Attributes as Attr
import Html.Events as Events
import Html.Extra


new : MandatoryButtonConfig msg -> ButtonConfig msg
new mandatory =
    { mandatory = mandatory, optional = defaultOptions }


view : ButtonConfig msg -> Html.Html msg
view { mandatory, optional } =
    let
        { label, onClick } =
            mandatory

        { disabled, type_, icon, size, primary, extraAttrs } =
            optional
    in
    Html.button
        (Attr.class "fr-btn"
            :: Attr.classList [ ( "fr-btn--secondary", not primary ) ]
            :: Attr.disabled disabled
            :: buttonType type_
            :: iconAttr icon
            :: buttonSize size
            :: (onClick
                    |> Maybe.map Events.onClick
                    |> Maybe.withDefault Html.Extra.noAttr
               )
            :: extraAttrs
        )
        [ Html.text label ]


type alias ButtonConfig msg =
    { mandatory : MandatoryButtonConfig msg
    , optional : OptionalButtonConfig msg
    }


type alias MandatoryButtonConfig msg =
    { onClick : Maybe msg
    , label : String
    }


type alias OptionalButtonConfig msg =
    { disabled : Bool
    , type_ : ButtonType
    , size : ButtonSize
    , icon : IconPosition
    , primary : Bool
    , extraAttrs : List (Html.Attribute msg)
    }


type ButtonType
    = ClickableBtn
    | SubmitBtn
    | ResetBtn


type ButtonSize
    = SmallBtn
    | MediumBtn
    | LargeBtn


type IconPosition
    = NoIcon
    | LeftIcon String
    | RightIcon String
    | OnlyIcon String


withOptions : OptionalButtonConfig msg -> ButtonConfig msg -> ButtonConfig msg
withOptions optional config =
    { config | optional = optional }


withType : ButtonType -> ButtonConfig msg -> ButtonConfig msg
withType type_ { mandatory, optional } =
    { mandatory = mandatory, optional = { optional | type_ = type_ } }


withSize : ButtonSize -> ButtonConfig msg -> ButtonConfig msg
withSize size { mandatory, optional } =
    { mandatory = mandatory, optional = { optional | size = size } }


withPrimary : Bool -> ButtonConfig msg -> ButtonConfig msg
withPrimary primary { mandatory, optional } =
    { mandatory = mandatory, optional = { optional | primary = primary } }


withIcon : IconPosition -> ButtonConfig msg -> ButtonConfig msg
withIcon icon { mandatory, optional } =
    { mandatory = mandatory, optional = { optional | icon = icon } }


withDisabled : Bool -> ButtonConfig msg -> ButtonConfig msg
withDisabled disabled { mandatory, optional } =
    { mandatory = mandatory, optional = { optional | disabled = disabled } }


withAttrs : List (Html.Attribute msg) -> ButtonConfig msg -> ButtonConfig msg
withAttrs extraAttrs { mandatory, optional } =
    { mandatory = mandatory, optional = { optional | extraAttrs = extraAttrs } }


submit : ButtonConfig msg -> ButtonConfig msg
submit =
    withType SubmitBtn


reset : ButtonConfig msg -> ButtonConfig msg
reset =
    withType ResetBtn


secondary : ButtonConfig msg -> ButtonConfig msg
secondary =
    withPrimary False


small : ButtonConfig msg -> ButtonConfig msg
small =
    withSize SmallBtn


large : ButtonConfig msg -> ButtonConfig msg
large =
    withSize LargeBtn


disable : ButtonConfig msg -> ButtonConfig msg
disable =
    withDisabled True


defaultOptions : OptionalButtonConfig msg
defaultOptions =
    { disabled = False
    , type_ = ClickableBtn
    , size = MediumBtn
    , icon = NoIcon
    , primary = True
    , extraAttrs = []
    }


buttonType : ButtonType -> Html.Attribute msg
buttonType type_ =
    case type_ of
        SubmitBtn ->
            Attr.type_ "submit"

        ResetBtn ->
            Attr.type_ "reset"

        ClickableBtn ->
            Attr.type_ "button"


iconAttr : IconPosition -> Html.Attribute msg
iconAttr icon =
    case icon of
        NoIcon ->
            Html.Extra.noAttr

        LeftIcon iconName ->
            Attr.classList [ ( iconName, True ), ( "fr-btn--icon-left", True ) ]

        RightIcon iconName ->
            Attr.classList [ ( iconName, True ), ( "fr-btn--icon-right", True ) ]

        OnlyIcon iconName ->
            Attr.class iconName


buttonSize : ButtonSize -> Html.Attribute msg
buttonSize size =
    case size of
        SmallBtn ->
            Attr.class "fr-btn--sm"

        MediumBtn ->
            Html.Extra.noAttr

        LargeBtn ->
            Attr.class "fr-btn--lg"
