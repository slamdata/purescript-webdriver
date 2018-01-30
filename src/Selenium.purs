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

import Control.Monad.Aff (Aff, attempt)
import Control.Monad.Aff.Compat (EffFnAff, fromEffFnAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (error)
import Control.Monad.Error.Class (throwError)
import Control.Promise (Promise)
import Control.Promise (fromAff) as Promise
import Data.Array (uncons)
import Data.Either (either)
import Data.Foreign (Foreign)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds)
import Data.Tuple (Tuple(..))
import Data.Unfoldable (class Unfoldable, unfoldr)
import Selenium.Types (SELENIUM, Driver, WindowHandle, Location, Window, Size, Element, FileDetector, Locator)

foreign import _get
  ∷ ∀ e
  . Driver
  → String
  → EffFnAff (selenium ∷ SELENIUM|e) Unit

foreign import _wait
  ∷ ∀ e
  . Eff (selenium ∷ SELENIUM|e) (Promise Boolean)
  → Milliseconds
  → Driver
  → EffFnAff (selenium ∷ SELENIUM|e) Unit

foreign import _quit
  ∷ ∀ e
  . Driver
  → EffFnAff (selenium ∷ SELENIUM|e) Unit

get
  ∷ ∀ e
  . Driver
  → String
  → Aff (selenium ∷ SELENIUM|e) Unit
get driver str = fromEffFnAff $ _get driver str

-- | Wait until first argument returns 'true'. If it returns false an error will be raised
wait
  ∷ ∀ e
  . Aff (selenium ∷ SELENIUM|e) Boolean
  → Milliseconds
  → Driver
  → Aff (selenium ∷ SELENIUM|e) Unit
wait action time driver = fromEffFnAff $ _wait (Promise.fromAff action) time driver

-- | Finalizer
quit
  ∷ ∀ e
  . Driver
  → Aff (selenium ∷ SELENIUM|e) Unit
quit driver = fromEffFnAff $ _quit driver

-- LOCATOR BUILDERS
foreign import _byClassName
  ∷ ∀ e. String → EffFnAff (selenium ∷ SELENIUM|e) Locator
foreign import _byCss
  ∷ ∀ e. String → EffFnAff (selenium ∷ SELENIUM|e) Locator
foreign import _byId
  ∷ ∀ e. String → EffFnAff (selenium ∷ SELENIUM|e) Locator
foreign import _byName
  ∷ ∀ e. String → EffFnAff (selenium ∷ SELENIUM|e) Locator
foreign import _byXPath
  ∷ ∀ e. String → EffFnAff (selenium ∷ SELENIUM|e) Locator

foreign import _affLocator
  ∷ ∀ e
  . (Element → Eff (selenium ∷ SELENIUM|e) (Promise Element))
  → EffFnAff (selenium ∷ SELENIUM|e) Locator

foreign import showLocator
  ∷ Locator
  → String

foreign import _findElement
  ∷ ∀ e a
  . Maybe a
  → (a → Maybe a)
  → Driver
  → Locator
  → EffFnAff (selenium ∷ SELENIUM|e) (Maybe Element)

foreign import _findChild
  ∷ ∀ e a
  . Maybe a
  → (a → Maybe a)
  → Element
  → Locator
  → EffFnAff (selenium ∷ SELENIUM|e) (Maybe Element)

foreign import _findElements
  ∷ ∀ e
  . Driver
  → Locator
  → EffFnAff (selenium ∷ SELENIUM|e) (Array Element)

foreign import _findChildren
  ∷ ∀ e
  . Element
  → Locator
  → EffFnAff (selenium ∷ SELENIUM|e) (Array Element)

foreign import _findExact
  ∷ ∀ e
  . Driver
  → Locator
  → EffFnAff (selenium ∷ SELENIUM|e) Element

foreign import _childExact
  ∷ ∀ e
  . Element
  → Locator
  → EffFnAff (selenium ∷ SELENIUM|e) Element

-- LOCATOR BUILDERS
byClassName
  ∷ ∀ e. String → Aff (selenium ∷ SELENIUM|e) Locator
byClassName className = fromEffFnAff $ _byClassName className

byCss
  ∷ ∀ e. String → Aff (selenium ∷ SELENIUM|e) Locator
byCss css = fromEffFnAff $ _byCss css

byId
  ∷ ∀ e. String → Aff (selenium ∷ SELENIUM|e) Locator
byId id = fromEffFnAff $ _byId id

byName
  ∷ ∀ e. String → Aff (selenium ∷ SELENIUM|e) Locator
byName name = fromEffFnAff $ _byName name

byXPath
  ∷ ∀ e. String → Aff (selenium ∷ SELENIUM|e) Locator
byXPath xpath = fromEffFnAff $ _byXPath xpath

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
affLocator
  ∷ ∀ e
  . (Element → Aff (selenium ∷ SELENIUM|e) Element)
  → Aff (selenium ∷ SELENIUM|e) Locator
affLocator locator = fromEffFnAff $ _affLocator (Promise.fromAff <<< locator)

-- | Tries to find an element starting from `document`; will return `Nothing` if there
-- | is no element can be found by locator
findElement
  ∷ ∀ e. Driver → Locator → Aff (selenium ∷ SELENIUM|e) (Maybe Element)
findElement driver =
  fromEffFnAff <<< _findElement Nothing Just driver

-- | Same as `findElement` but starts searching from custom element
findChild
  ∷ ∀ e
  . Element
  → Locator
  → Aff (selenium ∷ SELENIUM|e) (Maybe Element)
findChild element = fromEffFnAff <<< _findChild Nothing Just element

findExact
  ∷ ∀ e
  . Driver
  → Locator
  → Aff (selenium ∷ SELENIUM|e) Element
findExact driver = fromEffFnAff <<< _findExact driver

childExact
  ∷ ∀ e
  . Element
  → Locator
  → Aff (selenium ∷ SELENIUM|e) Element
childExact element locator = fromEffFnAff $ _childExact element locator

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
  map fromArray $ fromEffFnAff $ _findElements driver locator

-- | Same a `findElements` but starts searching from custom element
findChildren
  ∷ ∀ e f
  . (Unfoldable f)
  ⇒ Element
  → Locator
  → Aff (selenium ∷SELENIUM|e) (f Element)
findChildren el locator =
  map fromArray $ fromEffFnAff $ _findChildren el locator

foreign import _setFileDetector
  ∷ ∀ e. Driver → FileDetector → EffFnAff (selenium ∷ SELENIUM|e) Unit
foreign import _navigateBack
  ∷ ∀ e. Driver → EffFnAff (selenium ∷ SELENIUM|e) Unit
foreign import _navigateForward
  ∷ ∀ e. Driver → EffFnAff (selenium ∷ SELENIUM|e) Unit
foreign import _refresh
  ∷ ∀ e. Driver → EffFnAff (selenium ∷ SELENIUM|e) Unit
foreign import _navigateTo
  ∷ ∀ e. String → Driver → EffFnAff (selenium ∷ SELENIUM|e) Unit
foreign import _getCurrentUrl
  ∷ ∀ e. Driver → EffFnAff (selenium ∷ SELENIUM|e) String
foreign import _getTitle
  ∷ ∀ e. Driver → EffFnAff (selenium ∷ SELENIUM|e) String
foreign import _executeStr
  ∷ ∀ e. Driver → String → EffFnAff (selenium ∷ SELENIUM|e) Foreign
foreign import _sendKeysEl
  ∷ ∀ e. String → Element → EffFnAff (selenium ∷ SELENIUM|e) Unit
foreign import _clickEl
  ∷ ∀ e. Element → EffFnAff (selenium ∷ SELENIUM|e) Unit
foreign import _getCssValue
  ∷ ∀ e. Element → String → EffFnAff (selenium ∷ SELENIUM|e) String
foreign import _getAttribute
  ∷ ∀ e a
  . Maybe a
  → (a → Maybe a)
  → Element
  → String
  → EffFnAff (selenium ∷ SELENIUM|e) (Maybe String)

setFileDetector
  ∷ ∀ e. Driver → FileDetector → Aff (selenium ∷ SELENIUM|e) Unit
setFileDetector driver detector = fromEffFnAff $ _setFileDetector driver detector

navigateBack
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) Unit
navigateBack driver = fromEffFnAff $ _navigateBack driver

navigateForward
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) Unit
navigateForward driver = fromEffFnAff $ _navigateForward driver

refresh
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) Unit
refresh driver = fromEffFnAff $ _refresh driver

navigateTo
  ∷ ∀ e. String → Driver → Aff (selenium ∷ SELENIUM|e) Unit
navigateTo uri driver = fromEffFnAff $ _navigateTo uri driver

getCurrentUrl
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) String
getCurrentUrl driver = fromEffFnAff $ _getCurrentUrl driver

getTitle
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) String
getTitle driver = fromEffFnAff $ _getTitle driver

-- | Executes javascript script from `String` argument.
executeStr
  ∷ ∀ e. Driver → String → Aff (selenium ∷ SELENIUM|e) Foreign
executeStr driver strToExecute = fromEffFnAff $ _executeStr driver strToExecute

sendKeysEl
  ∷ ∀ e. String → Element → Aff (selenium ∷ SELENIUM|e) Unit
sendKeysEl key element = fromEffFnAff $ _sendKeysEl key element

clickEl
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) Unit
clickEl element = fromEffFnAff $ _clickEl element

getCssValue
  ∷ ∀ e. Element → String → Aff (selenium ∷ SELENIUM|e) String
getCssValue element attribute = fromEffFnAff $ _getCssValue element attribute

-- | Tries to find an element starting from `document`; will return `Nothing` if there
-- | is no element can be found by locator
getAttribute
  ∷ ∀ e. Element → String → Aff (selenium ∷ SELENIUM|e) (Maybe String)
getAttribute element string = fromEffFnAff $ _getAttribute Nothing Just element string

foreign import _getText
  ∷ ∀ e. Element → EffFnAff (selenium ∷ SELENIUM|e) String
foreign import _isDisplayed
  ∷ ∀ e. Element → EffFnAff (selenium ∷ SELENIUM|e) Boolean
foreign import _isEnabled
  ∷ ∀ e. Element → EffFnAff (selenium ∷ SELENIUM|e) Boolean
foreign import _getInnerHtml
  ∷ ∀ e. Element → EffFnAff (selenium ∷ SELENIUM|e) String
foreign import _getSize
  ∷ ∀ e. Element → EffFnAff (selenium ∷ SELENIUM|e) Size
foreign import _getLocation
  ∷ ∀ e. Element → EffFnAff (selenium ∷ SELENIUM|e) Location
foreign import _clearEl
  ∷ ∀ e. Element → EffFnAff (selenium ∷ SELENIUM|e) Unit

foreign import _takeScreenshot
  ∷ ∀ e. Driver → EffFnAff (selenium ∷ SELENIUM |e) String
foreign import _saveScreenshot
  ∷ ∀ e. String → Driver → EffFnAff (selenium ∷ SELENIUM |e) Unit

foreign import _getWindow
  ∷ ∀ e. Driver → EffFnAff (selenium ∷ SELENIUM|e) Window
foreign import _getWindowPosition
  ∷ ∀ e. Window → EffFnAff (selenium ∷ SELENIUM|e) Location
foreign import _getWindowSize
  ∷ ∀ e. Window → EffFnAff (selenium ∷ SELENIUM|e) Size
foreign import _maximizeWindow
  ∷ ∀ e. Window → EffFnAff (selenium ∷ SELENIUM|e) Unit
foreign import _setWindowPosition
  ∷ ∀ e. Location → Window → EffFnAff (selenium ∷ SELENIUM|e) Unit
foreign import _setWindowSize
  ∷ ∀ e. Size → Window → EffFnAff (selenium ∷ SELENIUM|e) Unit
foreign import _getWindowScroll
  ∷ ∀ e. Driver → EffFnAff (selenium ∷ SELENIUM|e) Location
foreign import _getWindowHandle
  ∷ ∀ e. Driver → EffFnAff (selenium ∷ SELENIUM|e) WindowHandle
foreign import _getAllWindowHandles
  ∷ ∀ e. Driver → EffFnAff (selenium ∷ SELENIUM|e) (Array WindowHandle)

getText
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) String
getText element = fromEffFnAff $ _getText element

isDisplayed
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) Boolean
isDisplayed element = fromEffFnAff $ _isDisplayed element

isEnabled
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) Boolean
isEnabled element = fromEffFnAff $ _isEnabled element

getInnerHtml
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) String
getInnerHtml element = fromEffFnAff $ _getInnerHtml element

getSize
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) Size
getSize element = fromEffFnAff $ _getSize element

getLocation
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) Location
getLocation element = fromEffFnAff $ _getLocation element

-- | Clear `value` of element, if it has no value will do nothing.
-- | If `value` is weakly referenced by `virtual-dom` (`purescript-halogen`)
-- | will not work -- to clear such inputs one should use direct signal from
-- | `Selenium.ActionSequence`
clearEl
  ∷ ∀ e. Element → Aff (selenium ∷ SELENIUM|e) Unit
clearEl element = fromEffFnAff $ _clearEl element

-- | Returns png base64 encoded png image
takeScreenshot
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM |e) String
takeScreenshot driver = fromEffFnAff $ _takeScreenshot driver

-- | Saves screenshot to path
saveScreenshot
  ∷ ∀ e. String → Driver → Aff (selenium ∷ SELENIUM |e) Unit
saveScreenshot name driver = fromEffFnAff $ _saveScreenshot name driver

getWindow
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) Window
getWindow driver = fromEffFnAff $ _getWindow driver

getWindowPosition
  ∷ ∀ e. Window → Aff (selenium ∷ SELENIUM|e) Location
getWindowPosition window = fromEffFnAff $ _getWindowPosition window

getWindowSize
  ∷ ∀ e. Window → Aff (selenium ∷ SELENIUM|e) Size
getWindowSize window = fromEffFnAff $ _getWindowSize window

maximizeWindow
  ∷ ∀ e. Window → Aff (selenium ∷ SELENIUM|e) Unit
maximizeWindow window = fromEffFnAff $ _maximizeWindow window

setWindowPosition
  ∷ ∀ e. Location → Window → Aff (selenium ∷ SELENIUM|e) Unit
setWindowPosition location window = fromEffFnAff $ _setWindowPosition location window

setWindowSize
  ∷ ∀ e. Size → Window → Aff (selenium ∷ SELENIUM|e) Unit
setWindowSize size window = fromEffFnAff $ _setWindowSize size window

getWindowScroll
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) Location
getWindowScroll driver = fromEffFnAff $ _getWindowScroll driver

getWindowHandle
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM|e) WindowHandle
getWindowHandle driver = fromEffFnAff $ _getWindowHandle driver

getAllWindowHandles
  ∷ ∀ f e
  . (Unfoldable f)
  ⇒ Driver
  → Aff (selenium ∷ SELENIUM |e) (f WindowHandle)
getAllWindowHandles driver =
  map fromArray $ fromEffFnAff $ _getAllWindowHandles driver

fromArray
  ∷ ∀ a f. (Unfoldable f) ⇒ Array a → f a
fromArray =
  unfoldr (\xs → (\rec → Tuple rec.head rec.tail) <$> uncons xs)

foreign import _switchTo
  ∷ ∀ e. WindowHandle → Driver → EffFnAff (selenium ∷ SELENIUM |e) Unit
foreign import _close
  ∷ ∀ e. Driver → EffFnAff (selenium ∷ SELENIUM |e) Unit

switchTo
  ∷ ∀ e. WindowHandle → Driver → Aff (selenium ∷ SELENIUM |e) Unit
switchTo handle driver = fromEffFnAff $ _switchTo handle driver

close
  ∷ ∀ e. Driver → Aff (selenium ∷ SELENIUM |e) Unit
close driver = fromEffFnAff $ _close driver
