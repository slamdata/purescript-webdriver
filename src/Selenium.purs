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

import Effect.Aff (Aff, attempt)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect (Effect)
import Effect.Exception (error)
import Control.Monad.Error.Class (throwError)
import Control.Promise (Promise)
import Control.Promise (fromAff) as Promise
import Data.Array (uncons)
import Data.Either (either)
import Foreign (Foreign)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds)
import Data.Tuple (Tuple(..))
import Data.Unfoldable (class Unfoldable, unfoldr)
import Selenium.Types (Driver, WindowHandle, Location, Window, Size, Element, FileDetector, Locator)

foreign import _get
  ∷ Driver
  → String
  → EffectFnAff Unit

foreign import _wait
  ∷ Effect (Promise Boolean)
  → Milliseconds
  → Driver
  → EffectFnAff Unit

foreign import _quit
  ∷ Driver
  → EffectFnAff Unit

get
  ∷ Driver
  → String
  → Aff Unit
get driver str = fromEffectFnAff $ _get driver str

-- | Wait until first argument returns 'true'. If it returns false an error will be raised
wait
  ∷ Aff Boolean
  → Milliseconds
  → Driver
  → Aff Unit
wait action time driver = fromEffectFnAff $ _wait (Promise.fromAff action) time driver

-- | Finalizer
quit
  ∷ Driver
  → Aff Unit
quit driver = fromEffectFnAff $ _quit driver

-- LOCATOR BUILDERS
foreign import _byClassName
  ∷ String → EffectFnAff Locator
foreign import _byCss
  ∷ String → EffectFnAff Locator
foreign import _byId
  ∷ String → EffectFnAff Locator
foreign import _byName
  ∷ String → EffectFnAff Locator
foreign import _byXPath
  ∷ String → EffectFnAff Locator

foreign import _affLocator
  ∷ (Element → Effect (Promise Element))
  → EffectFnAff Locator

foreign import showLocator
  ∷ Locator
  → String

foreign import _findElement
  ∷ ∀ a
  . Maybe a
  → (a → Maybe a)
  → Driver
  → Locator
  → EffectFnAff (Maybe Element)

foreign import _findChild
  ∷ ∀ a
  . Maybe a
  → (a → Maybe a)
  → Element
  → Locator
  → EffectFnAff (Maybe Element)

foreign import _findElements
  ∷ Driver
  → Locator
  → EffectFnAff (Array Element)

foreign import _findChildren
  ∷ Element
  → Locator
  → EffectFnAff (Array Element)

foreign import _findExact
  ∷ Driver
  → Locator
  → EffectFnAff Element

foreign import _childExact
  ∷ Element
  → Locator
  → EffectFnAff Element

-- LOCATOR BUILDERS
byClassName
  ∷ String → Aff Locator
byClassName className = fromEffectFnAff $ _byClassName className

byCss
  ∷ String → Aff Locator
byCss css = fromEffectFnAff $ _byCss css

byId
  ∷ String → Aff Locator
byId id = fromEffectFnAff $ _byId id

byName
  ∷ String → Aff Locator
byName name = fromEffectFnAff $ _byName name

byXPath
  ∷ String → Aff Locator
byXPath xpath = fromEffectFnAff $ _byXPath xpath

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
  ∷ (Element → Aff Element)
  → Aff Locator
affLocator locator = fromEffectFnAff $ _affLocator (Promise.fromAff <<< locator)

-- | Tries to find an element starting from `document`; will return `Nothing` if there
-- | is no element can be found by locator
findElement
  ∷ Driver → Locator → Aff (Maybe Element)
findElement driver =
  fromEffectFnAff <<< _findElement Nothing Just driver

-- | Same as `findElement` but starts searching from custom element
findChild
  ∷ Element
  → Locator
  → Aff (Maybe Element)
findChild element = fromEffectFnAff <<< _findChild Nothing Just element

findExact
  ∷ Driver
  → Locator
  → Aff Element
findExact driver = fromEffectFnAff <<< _findExact driver

childExact
  ∷ Element
  → Locator
  → Aff Element
childExact element locator = fromEffectFnAff $ _childExact element locator

-- | Tries to find element and throws an error if it succeeds.
loseElement
  ∷ Driver
  → Locator
  → Aff Unit
loseElement driver locator = do
  result ← attempt $ findExact driver locator
  either (const $ pure unit) (const $ throwError $ error failMessage) result
    where
    failMessage = "Found element with locator: " <> showLocator locator

-- | Finds elements by locator from `document`
findElements
  ∷ ∀ f. (Unfoldable f) ⇒ Driver → Locator → Aff (f Element)
findElements driver locator =
  map fromArray $ fromEffectFnAff $ _findElements driver locator

-- | Same a `findElements` but starts searching from custom element
findChildren
  ∷ ∀ f
  . (Unfoldable f)
  ⇒ Element
  → Locator
  → Aff (f Element)
findChildren el locator =
  map fromArray $ fromEffectFnAff $ _findChildren el locator

foreign import _setFileDetector
  ∷ Driver → FileDetector → EffectFnAff Unit
foreign import _navigateBack
  ∷ Driver → EffectFnAff Unit
foreign import _navigateForward
  ∷ Driver → EffectFnAff Unit
foreign import _refresh
  ∷ Driver → EffectFnAff Unit
foreign import _navigateTo
  ∷ String → Driver → EffectFnAff Unit
foreign import _getCurrentUrl
  ∷ Driver → EffectFnAff String
foreign import _getTitle
  ∷ Driver → EffectFnAff String
foreign import _executeStr
  ∷ Driver → String → EffectFnAff Foreign
foreign import _sendKeysEl
  ∷ String → Element → EffectFnAff Unit
foreign import _clickEl
  ∷ Element → EffectFnAff Unit
foreign import _getCssValue
  ∷ Element → String → EffectFnAff String
foreign import _getAttribute
  ∷ ∀ a
  . Maybe a
  → (a → Maybe a)
  → Element
  → String
  → EffectFnAff (Maybe String)

setFileDetector
  ∷ Driver → FileDetector → Aff Unit
setFileDetector driver detector = fromEffectFnAff $ _setFileDetector driver detector

navigateBack
  ∷ Driver → Aff Unit
navigateBack driver = fromEffectFnAff $ _navigateBack driver

navigateForward
  ∷ Driver → Aff Unit
navigateForward driver = fromEffectFnAff $ _navigateForward driver

refresh
  ∷ Driver → Aff Unit
refresh driver = fromEffectFnAff $ _refresh driver

navigateTo
  ∷ String → Driver → Aff Unit
navigateTo uri driver = fromEffectFnAff $ _navigateTo uri driver

getCurrentUrl
  ∷ Driver → Aff String
getCurrentUrl driver = fromEffectFnAff $ _getCurrentUrl driver

getTitle
  ∷ Driver → Aff String
getTitle driver = fromEffectFnAff $ _getTitle driver

-- | Executes javascript script from `String` argument.
executeStr
  ∷ Driver → String → Aff Foreign
executeStr driver strToExecute = fromEffectFnAff $ _executeStr driver strToExecute

sendKeysEl
  ∷ String → Element → Aff Unit
sendKeysEl key element = fromEffectFnAff $ _sendKeysEl key element

clickEl
  ∷ Element → Aff Unit
clickEl element = fromEffectFnAff $ _clickEl element

getCssValue
  ∷ Element → String → Aff String
getCssValue element attribute = fromEffectFnAff $ _getCssValue element attribute

-- | Tries to find an element starting from `document`; will return `Nothing` if there
-- | is no element can be found by locator
getAttribute
  ∷ Element → String → Aff (Maybe String)
getAttribute element string = fromEffectFnAff $ _getAttribute Nothing Just element string

foreign import _getText
  ∷ Element → EffectFnAff String
foreign import _isDisplayed
  ∷ Element → EffectFnAff Boolean
foreign import _isEnabled
  ∷ Element → EffectFnAff Boolean
foreign import _getInnerHtml
  ∷ Element → EffectFnAff String
foreign import _getSize
  ∷ Element → EffectFnAff Size
foreign import _getLocation
  ∷ Element → EffectFnAff Location
foreign import _clearEl
  ∷ Element → EffectFnAff Unit

foreign import _takeScreenshot
  ∷ Driver → EffectFnAff String
foreign import _saveScreenshot
  ∷ String → Driver → EffectFnAff Unit

foreign import _getWindow
  ∷ Driver → EffectFnAff Window
foreign import _getWindowPosition
  ∷ Window → EffectFnAff Location
foreign import _getWindowSize
  ∷ Window → EffectFnAff Size
foreign import _maximizeWindow
  ∷ Window → EffectFnAff Unit
foreign import _setWindowPosition
  ∷ Location → Window → EffectFnAff Unit
foreign import _setWindowSize
  ∷ Size → Window → EffectFnAff Unit
foreign import _getWindowScroll
  ∷ Driver → EffectFnAff Location
foreign import _getWindowHandle
  ∷ Driver → EffectFnAff WindowHandle
foreign import _getAllWindowHandles
  ∷ Driver → EffectFnAff (Array WindowHandle)

getText
  ∷ Element → Aff String
getText element = fromEffectFnAff $ _getText element

isDisplayed
  ∷ Element → Aff Boolean
isDisplayed element = fromEffectFnAff $ _isDisplayed element

isEnabled
  ∷ Element → Aff Boolean
isEnabled element = fromEffectFnAff $ _isEnabled element

getInnerHtml
  ∷ Element → Aff String
getInnerHtml element = fromEffectFnAff $ _getInnerHtml element

getSize
  ∷ Element → Aff Size
getSize element = fromEffectFnAff $ _getSize element

getLocation
  ∷ Element → Aff Location
getLocation element = fromEffectFnAff $ _getLocation element

-- | Clear `value` of element, if it has no value will do nothing.
-- | If `value` is weakly referenced by `virtual-dom` (`purescript-halogen`)
-- | will not work -- to clear such inputs one should use direct signal from
-- | `Selenium.ActionSequence`
clearEl
  ∷ Element → Aff Unit
clearEl element = fromEffectFnAff $ _clearEl element

-- | Returns png base64 encoded png image
takeScreenshot
  ∷ Driver → Aff String
takeScreenshot driver = fromEffectFnAff $ _takeScreenshot driver

-- | Saves screenshot to path
saveScreenshot
  ∷ String → Driver → Aff Unit
saveScreenshot name driver = fromEffectFnAff $ _saveScreenshot name driver

getWindow
  ∷ Driver → Aff Window
getWindow driver = fromEffectFnAff $ _getWindow driver

getWindowPosition
  ∷ Window → Aff Location
getWindowPosition window = fromEffectFnAff $ _getWindowPosition window

getWindowSize
  ∷ Window → Aff Size
getWindowSize window = fromEffectFnAff $ _getWindowSize window

maximizeWindow
  ∷ Window → Aff Unit
maximizeWindow window = fromEffectFnAff $ _maximizeWindow window

setWindowPosition
  ∷ Location → Window → Aff Unit
setWindowPosition location window = fromEffectFnAff $ _setWindowPosition location window

setWindowSize
  ∷ Size → Window → Aff Unit
setWindowSize size window = fromEffectFnAff $ _setWindowSize size window

getWindowScroll
  ∷ Driver → Aff Location
getWindowScroll driver = fromEffectFnAff $ _getWindowScroll driver

getWindowHandle
  ∷ Driver → Aff WindowHandle
getWindowHandle driver = fromEffectFnAff $ _getWindowHandle driver

getAllWindowHandles
  ∷ ∀ f
  . (Unfoldable f)
  ⇒ Driver
  → Aff (f WindowHandle)
getAllWindowHandles driver =
  map fromArray $ fromEffectFnAff $ _getAllWindowHandles driver

fromArray
  ∷ ∀ a f. (Unfoldable f) ⇒ Array a → f a
fromArray =
  unfoldr (\xs → (\rec → Tuple rec.head rec.tail) <$> uncons xs)

foreign import _switchTo
  ∷ WindowHandle → Driver → EffectFnAff Unit
foreign import _close
  ∷ Driver → EffectFnAff Unit

switchTo
  ∷ WindowHandle → Driver → Aff Unit
switchTo handle driver = fromEffectFnAff $ _switchTo handle driver

close
  ∷ Driver → Aff Unit
close driver = fromEffectFnAff $ _close driver
