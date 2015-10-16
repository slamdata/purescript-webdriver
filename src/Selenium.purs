module Selenium
       ( get
       , wait
       , quit
       , byClassName
       , byCss
       , byId
       , byName
       , byXPath
       , affLocator
       , findElement
       , loseElement
       , findElements
       , findChild
       , findChildren
       , findExact
       , showLocator
       , childExact
       , navigateBack
       , navigateForward
       , refresh
       , navigateTo
       , getCurrentUrl
       , executeStr
       , sendKeysEl
       , clickEl
       , getCssValue
       , getAttribute
       , getText
       , getTitle
       , isDisplayed
       , isEnabled
       , getInnerHtml
       , getSize
       , getLocation
       , clearEl
       , setFileDetector
       , takeScreenshot
       , saveScreenshot
       , setWindowSize
       , getWindowSize
       , maximizeWindow
       , setWindowPosition
       , getWindowPosition
       , getWindow
       , getWindowScroll
       , getWindowHandle
       , getAllWindowHandles
       , switchTo
       , close
       ) where

import Prelude
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Exception (error)
import Control.Monad.Error.Class (throwError)
import Data.Maybe (Maybe())
import Data.Either (either)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Aff (Aff(), attempt)
import Selenium.Types
import Data.Unfoldable (Unfoldable, unfoldr)
import Data.Foreign (Foreign())
import Data.Maybe (Maybe(..))
import Data.Array (uncons)
import Data.Tuple (Tuple(..))
import DOM (DOM())

-- | Go to url
foreign import get :: forall e. Driver -> String -> Aff (selenium :: SELENIUM|e) Unit
-- | Wait until first argument returns 'true'. If it returns false an error will be raised
foreign import wait :: forall e. Aff (selenium :: SELENIUM|e) Boolean ->
                                 Int -> Driver ->
                                 Aff (selenium :: SELENIUM|e) Unit

-- | Finalizer
foreign import quit :: forall e. Driver -> Aff (selenium :: SELENIUM|e) Unit


-- LOCATOR BUILDERS
foreign import byClassName :: forall e. String -> Aff (selenium :: SELENIUM|e) Locator
foreign import byCss :: forall e. String -> Aff (selenium :: SELENIUM|e) Locator
foreign import byId :: forall e. String -> Aff (selenium :: SELENIUM|e) Locator
foreign import byName :: forall e. String -> Aff (selenium :: SELENIUM|e) Locator
foreign import byXPath :: forall e. String -> Aff (selenium :: SELENIUM|e) Locator
-- | Build locator from asynchronous function returning element.
-- | I.e. this locator will find first visible element with `.common-element` class
-- | ```purescript
-- | affLocator \el -> do
-- |   commonElements <- byCss ".common-element" >>= findElements el
-- |   flagedElements <- traverse (\el -> Tuple el <$> isVisible el) commonElements
-- |   maybe err pure $ foldl foldFn Nothing flagedElements
-- |   where
-- |   err = throwError $ error "all common elements are not visible"
-- |   foldFn Nothing (Tuple el true) = Just el
-- |   foldFn a _ = a
-- | ```
foreign import affLocator :: forall e. (Element -> Aff (selenium :: SELENIUM|e) Element) -> Aff (selenium :: SELENIUM|e) Locator

foreign import showLocator :: Locator -> String

foreign import _findElement :: forall e a. Maybe a -> (a -> Maybe a) ->
                               Driver -> Locator -> Aff (selenium :: SELENIUM|e) (Maybe Element)
foreign import _findChild :: forall e a. Maybe a -> (a -> Maybe a) ->
                             Element -> Locator -> Aff (selenium :: SELENIUM|e) (Maybe Element)
foreign import _findElements :: forall e. Driver -> Locator -> Aff (selenium :: SELENIUM|e) (Array Element)
foreign import _findChildren :: forall e. Element -> Locator -> Aff (selenium :: SELENIUM|e) (Array Element)
foreign import findExact :: forall e. Driver -> Locator -> Aff (selenium :: SELENIUM|e) Element
foreign import childExact :: forall e. Element -> Locator -> Aff (selenium :: SELENIUM|e) Element

-- | Tries to find an element starting from `document`; will return `Nothing` if there
-- | is no element can be found by locator
findElement :: forall e. Driver -> Locator -> Aff (selenium :: SELENIUM|e) (Maybe Element)
findElement = _findElement Nothing Just

-- | Tries to find element and throws an error if it succeeds.
loseElement :: forall e. Driver -> Locator -> Aff (selenium :: SELENIUM|e) Unit
loseElement driver locator = do
  result <- attempt $ findExact driver locator
  either (const $ pure unit) (const $ throwError $ error failMessage) result
    where
    failMessage = "Found element with locator: " ++ showLocator locator

-- | Finds elements by locator from `document`
findElements :: forall e f. (Unfoldable f) => Driver -> Locator -> Aff (selenium :: SELENIUM|e) (f Element)
findElements driver locator = map fromArray $ _findElements driver locator

-- | Same as `findElement` but starts searching from custom element
findChild :: forall e. Element -> Locator -> Aff (selenium :: SELENIUM|e) (Maybe Element)
findChild = _findChild Nothing Just

-- | Same as `findElements` but starts searching from custom element
findChildren :: forall e f. (Unfoldable f) => Element -> Locator -> Aff (selenium ::SELENIUM|e) (f Element)
findChildren el locator = map fromArray $ _findChildren el locator

foreign import setFileDetector :: forall e. Driver -> FileDetector -> Aff (selenium :: SELENIUM|e) Unit

foreign import navigateBack :: forall e. Driver -> Aff (selenium :: SELENIUM|e) Unit
foreign import navigateForward :: forall e. Driver -> Aff (selenium :: SELENIUM|e) Unit
foreign import refresh :: forall e. Driver -> Aff (selenium :: SELENIUM|e) Unit
foreign import navigateTo :: forall e. String -> Driver -> Aff (selenium :: SELENIUM|e) Unit
foreign import getCurrentUrl :: forall e. Driver -> Aff (selenium :: SELENIUM|e) String
foreign import getTitle :: forall e. Driver -> Aff (selenium :: SELENIUM|e) String
-- | Executes javascript script from `String` argument.
foreign import executeStr :: forall e. Driver -> String -> Aff (selenium :: SELENIUM|e) Foreign

foreign import sendKeysEl :: forall e. String -> Element -> Aff (selenium :: SELENIUM|e) Unit
foreign import clickEl :: forall e. Element -> Aff (selenium :: SELENIUM|e) Unit
foreign import getCssValue :: forall e. Element -> String -> Aff (selenium :: SELENIUM|e) String
foreign import _getAttribute :: forall e a. Maybe a -> (a -> Maybe a) ->
                                Element -> String -> Aff (selenium :: SELENIUM|e) (Maybe String)

-- | Tries to find an element starting from `document`; will return `Nothing` if there
-- | is no element can be found by locator
getAttribute :: forall e. Element -> String -> Aff (selenium :: SELENIUM|e) (Maybe String)
getAttribute = _getAttribute Nothing Just

foreign import getText :: forall e. Element -> Aff (selenium :: SELENIUM|e) String
foreign import isDisplayed :: forall e. Element -> Aff (selenium :: SELENIUM|e) Boolean
foreign import isEnabled :: forall e. Element -> Aff (selenium :: SELENIUM|e) Boolean
foreign import getInnerHtml :: forall e. Element -> Aff (selenium :: SELENIUM|e) String
foreign import getSize :: forall e. Element -> Aff (selenium :: SELENIUM|e) Size
foreign import getLocation :: forall e. Element -> Aff (selenium :: SELENIUM|e) Location
-- | Clear `value` of element, if it has no value will do nothing.
-- | If `value` is weakly referenced by `virtual-dom` (`purescript-halogen`)
-- | will not work -- to clear such inputs one should use direct signal from
-- | `Selenium.ActionSequence`
foreign import clearEl :: forall e. Element -> Aff (selenium :: SELENIUM|e) Unit

-- | Returns png base64 encoded png image
foreign import takeScreenshot :: forall e. Driver -> Aff (selenium :: SELENIUM |e) String

-- | Saves screenshot to path
foreign import saveScreenshot :: forall e. String -> Driver -> Aff (selenium :: SELENIUM |e) Unit

foreign import getWindow :: forall e. Driver -> Aff (selenium :: SELENIUM|e) Window

foreign import getWindowPosition :: forall e. Window -> Aff (selenium :: SELENIUM|e) Location

foreign import getWindowSize :: forall e. Window -> Aff (selenium :: SELENIUM|e) Size

foreign import maximizeWindow :: forall e. Window -> Aff (selenium :: SELENIUM|e) Unit

foreign import setWindowPosition :: forall e. Location -> Window -> Aff (selenium :: SELENIUM|e) Unit

foreign import setWindowSize :: forall e. Size -> Window -> Aff (selenium :: SELENIUM|e) Unit

foreign import getWindowScroll :: forall e. Driver -> Aff (selenium :: SELENIUM|e) Location

foreign import getWindowHandle :: forall e. Driver -> Aff (selenium :: SELENIUM|e) WindowHandle

foreign import _getAllWindowHandles :: forall e. Driver -> Aff (selenium :: SELENIUM|e) (Array WindowHandle)

getAllWindowHandles :: forall f e. (Unfoldable f) => Driver -> Aff (selenium :: SELENIUM |e) (f WindowHandle)
getAllWindowHandles driver = map fromArray $ _getAllWindowHandles driver


fromArray :: forall a f. (Unfoldable f) => Array a -> f a
fromArray = unfoldr (\xs -> (\rec -> Tuple rec.head rec.tail) <$> uncons xs)

foreign import switchTo :: forall e. WindowHandle -> Driver -> Aff (selenium :: SELENIUM |e) Unit

foreign import close :: forall e. Driver -> Aff (selenium :: SELENIUM |e) Unit
