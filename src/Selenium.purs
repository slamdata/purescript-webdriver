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
  , switchToActiveElement
  , close
  ) where

import Prelude
import Control.Monad.Aff (Aff, attempt)
import Control.Monad.Eff.Exception (error)
import Control.Monad.Error.Class (throwError)
import Data.Array (uncons)
import Data.Either (either)
import Data.Foreign (Foreign)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds)
import Data.Tuple (Tuple(..))
import Data.Unfoldable (class Unfoldable, unfoldr)

import Selenium.Types
  ( SELENIUM
  , Driver
  , WindowHandle
  , Location
  , Window
  , Size
  , Element
  , FileDetector
  , Locator
  )

-- | Go to url
foreign import get
  ∷ ∀ e
  . Driver
  → String
  → Aff (selenium ∷ SELENIUM|e) Unit

-- | Wait until first argument returns 'true'. If it returns false an error will be raised
foreign import wait
  ∷ ∀ e
  . Aff (selenium ∷ SELENIUM|e) Boolean
  → Milliseconds
  → Driver
  → Aff (selenium ∷ SELENIUM|e) Unit

-- | Finalizer
foreign import quit
  ∷ ∀ e
  . Driver
  → Aff (selenium ∷ SELENIUM|e) Unit

-- LOCATOR BUILDERS
foreign import byClassName
  ∷ ∀ e. String → Aff (selenium ∷ SELENIUM|e) Locator
foreign import byCss
  ∷ ∀ e. String → Aff (selenium ∷ SELENIUM|e) Locator
foreign import byId
  ∷ ∀ e. String → Aff (selenium ∷ SELENIUM|e) Locator
foreign import byName
  ∷ ∀ e. String → Aff (selenium ∷ SELENIUM|e) Locator
foreign import byXPath
  ∷ ∀ e. String → Aff (selenium ∷ SELENIUM|e) Locator
-- | Build locator from asynchronous function returning element.
-- | I.e. this locator will find first visible element with `.common-element` class
-- | ```purescript
-- | affLocator \el → do
-- |   commonElements ← byCss ".common-element" >>= findElements el
-- |   flagedElements ← traverse (\el → Tuple el <$> isVisible el) commonElements
-- |   maybe err pure $ foldl foldFn Nothing flagedElements
-- |   where
-- |   err = throwError $ error "all common elements are not visible"
-- |   foldFn Nothing (Tuple el true) = Just el
-- |   foldFn a _ = a
-- | ```
foreign import affLocator
  ∷ ∀ e
  . (Element → Aff (selenium ∷ SELENIUM|e) Element)
  → Aff (selenium ∷ SELENIUM|e) Locator

foreign import showLocator
  ∷ Locator
  → String

foreign import _findElement
  ∷ ∀ e a
  . Maybe a
  → (a → Maybe a)
  → Driver
  → Locator
  → Aff (selenium ∷ SELENIUM|e) (Maybe Element)

foreign import _findChild
  ∷ ∀ e a
  . Maybe a
  → (a → Maybe a)
  → Element
  → Locator
  → Aff (selenium ∷ SELENIUM|e) (Maybe Element)

foreign import _findElements
  ∷ ∀ e
  . Driver
  → Locator
  → Aff (selenium ∷ SELENIUM|e) (Array Element)

foreign import _findChildren
  ∷ ∀ e
  . Element
  → Locator
  → Aff (selenium ∷ SELENIUM|e) (Array Element)

foreign import findExact
  ∷ ∀ e
  . Driver
  → Locator
  → Aff (selenium ∷ SELENIUM|e) Element

foreign import childExact
  ∷ ∀ e
  . Element
  → Locator
  → Aff (selenium ∷ SELENIUM|e) Element

-- | Tries to find an element starting from `document`; will return `Nothing` if there
-- | is no element can be found by locator
findElement
  ∷ ∀ e. Driver → Locator → Aff (selenium ∷ SELENIUM|e) (Maybe Element)
findElement =
  _findElement Nothing Just

-- | Tries to find element and throws an error if it succeeds.
loseElement
  ∷ ∀ e
  . Driver
  → Locator
  → Aff (selenium ∷ SELENIUM|e) Unit
loseElement driver locator = do
  result ← attempt $ findExact driver locator
  either (const $ pure unit) (const $ throwError $ error failMessage) result
    where
    failMessage = "Found element with locator: " <> showLocator locator

-- | Finds elements by locator from `document`
findElements
  ∷ ∀ e f. (Unfoldable f) ⇒ Driver → Locator → Aff (selenium ∷ SELENIUM|e) (f Element)
findElements driver locator =
  map fromArray $ _findElements driver locator

-- | Same as `findElement` but starts searching from custom element
findChild
  ∷ ∀ e. Element → Locator → Aff (selenium ∷ SELENIUM|e) (Maybe Element)
findChild =
  _findChild Nothing Just

-- | Same as `findElements` but starts searching from custom element
findChildren
  ∷ ∀ e f
  . (Unfoldable f)
  ⇒ Element
  → Locator
  → Aff (selenium ∷SELENIUM|e) (f Element)
findChildren el locator =
  map fromArray $ _findChildren el locator

foreign import setFileDetector
  ∷ ∀ e. Driver → FileDetector → Aff (selenium ∷ SELENIUM|e) Unit
foreign import navigateBack
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) Unit
foreign import navigateForward
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) Unit
foreign import refresh
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) Unit
foreign import navigateTo
  ∷ ∀ e. String → Driver → Aff (selenium ∷ SELENIUM|e) Unit
foreign import getCurrentUrl
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) String
foreign import getTitle
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) String
-- | Executes javascript script from `String` argument.
foreign import executeStr
  ∷ ∀ e. Driver → String → Aff (selenium ∷ SELENIUM|e) Foreign
foreign import sendKeysEl
  ∷ ∀ e. String → Element → Aff (selenium ∷ SELENIUM|e) Unit
foreign import clickEl
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) Unit
foreign import getCssValue
  ∷ ∀ e. Element → String → Aff (selenium ∷ SELENIUM|e) String
foreign import _getAttribute
  ∷ ∀ e a
  . Maybe a
  → (a → Maybe a)
  → Element
  → String
  → Aff (selenium ∷ SELENIUM|e) (Maybe String)

-- | Tries to find an element starting from `document`; will return `Nothing` if there
-- | is no element can be found by locator
getAttribute
  ∷ ∀ e. Element → String → Aff (selenium ∷ SELENIUM|e) (Maybe String)
getAttribute = _getAttribute Nothing Just

foreign import getText
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) String
foreign import isDisplayed
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) Boolean
foreign import isEnabled
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) Boolean
foreign import getInnerHtml
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) String
foreign import getSize
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) Size
foreign import getLocation
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) Location
-- | Clear `value` of element, if it has no value will do nothing.
-- | If `value` is weakly referenced by `virtual-dom` (`purescript-halogen`)
-- | will not work -- to clear such inputs one should use direct signal from
-- | `Selenium.ActionSequence`
foreign import clearEl
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) Unit

-- | Returns png base64 encoded png image
foreign import takeScreenshot
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM |e) String

-- | Saves screenshot to path
foreign import saveScreenshot
  ∷ ∀ e. String → Driver → Aff (selenium ∷ SELENIUM |e) Unit
foreign import getWindow
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) Window
foreign import getWindowPosition
  ∷ ∀ e. Window → Aff (selenium ∷ SELENIUM|e) Location
foreign import getWindowSize
  ∷ ∀ e. Window → Aff (selenium ∷ SELENIUM|e) Size
foreign import maximizeWindow
  ∷ ∀ e. Window → Aff (selenium ∷ SELENIUM|e) Unit
foreign import setWindowPosition
  ∷ ∀ e. Location → Window → Aff (selenium ∷ SELENIUM|e) Unit
foreign import setWindowSize
  ∷ ∀ e. Size → Window → Aff (selenium ∷ SELENIUM|e) Unit
foreign import getWindowScroll
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) Location
foreign import getWindowHandle
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) WindowHandle
foreign import _getAllWindowHandles
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) (Array WindowHandle)

getAllWindowHandles
  ∷ ∀ f e
  . (Unfoldable f)
  ⇒ Driver
  → Aff (selenium ∷ SELENIUM |e) (f WindowHandle)
getAllWindowHandles driver =
  map fromArray $ _getAllWindowHandles driver

fromArray
  ∷ ∀ a f. (Unfoldable f) ⇒ Array a → f a
fromArray =
  unfoldr (\xs → (\rec → Tuple rec.head rec.tail) <$> uncons xs)

foreign import switchTo
  ∷ ∀ e. WindowHandle → Driver → Aff (selenium ∷ SELENIUM |e) Unit
foreign import switchToActiveElement 
  ∷ ∀ e . Driver → Aff (selenium ∷ SELENIUM | e) Unit
foreign import close
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM |e) Unit
