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
       , findElements
       , findChild
       , findChildren
       , navigateBack
       , navigateForward
       , refresh
       , to
       , getCurrentUrl
       , executeStr
       , sendKeysEl
       , clickEl
       , getCssValue
       , getAttribute
       , getTitle
       , isDisplayed
       , isEnabled
       , getInnerHtml
       , clearEl
       ) where

import Prelude
import Control.Monad.Eff (Eff())
import Data.Maybe (Maybe())
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Aff (Aff())
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


foreign import _findElement :: forall e a. Maybe a -> (a -> Maybe a) -> 
                               Driver -> Locator -> Aff (selenium :: SELENIUM|e) (Maybe Element)
foreign import _findChild :: forall e a. Maybe a -> (a -> Maybe a) -> 
                             Element -> Locator -> Aff (selenium :: SELENIUM|e) (Maybe Element)
foreign import _findElements :: forall e. Driver -> Locator -> Aff (selenium :: SELENIUM|e) (Array Element)
foreign import _findChildren :: forall e. Element -> Locator -> Aff (selenium :: SELENIUM|e) (Array Element)

-- | Tries to find an element starting from `document` will return `Nothing` if there
-- | is no element can be found by locator
findElement :: forall e. Driver -> Locator -> Aff (selenium :: SELENIUM|e) (Maybe Element)
findElement = _findElement Nothing Just 

-- | Finds elements by locator from `document`
findElements :: forall e f. (Unfoldable f) => Driver -> Locator -> Aff (selenium :: SELENIUM|e) (f Element) 
findElements driver locator = 
  unfoldr (\xs -> (\rec -> Tuple rec.head rec.tail) <$> uncons xs) <$> (_findElements driver locator)

-- | Same as `findElement` but starts searching from custom element 
findChild :: forall e. Element -> Locator -> Aff (selenium :: SELENIUM|e) (Maybe Element)
findChild = _findChild Nothing Just

-- | Same as `findElements` but starts searching from custom element
findChildren :: forall e f. (Unfoldable f) => Element -> Locator -> Aff (selenium ::SELENIUM|e) (f Element) 
findChildren el locator = 
  unfoldr (\xs -> (\rec -> Tuple rec.head rec.tail) <$> uncons xs) <$> (_findChildren el locator)


foreign import navigateBack :: forall e. Driver -> Aff (selenium :: SELENIUM|e) Unit
foreign import navigateForward :: forall e. Driver -> Aff (selenium :: SELENIUM|e) Unit
foreign import refresh :: forall e. Driver -> Aff (selenium :: SELENIUM|e) Unit
foreign import to :: forall e. String -> Driver -> Aff (selenium :: SELENIUM|e) Unit
foreign import getCurrentUrl :: forall e. Driver -> Aff (selenium :: SELENIUM|e) String
foreign import getTitle :: forall e. Driver -> Aff (selenium :: SELENIUM|e) String
-- | Executes javascript script from `String` argument.
foreign import executeStr :: forall e. Driver -> String -> Aff (selenium :: SELENIUM|e) Foreign

foreign import sendKeysEl :: forall e. String -> Element -> Aff (selenium :: SELENIUM|e) Unit
foreign import clickEl :: forall e. Element -> Aff (selenium :: SELENIUM|e) Unit
foreign import getCssValue :: forall e. Element -> String -> Aff (selenium :: SELENIUM|e) String
foreign import getAttribute :: forall e. Element -> String -> Aff (selenium :: SELENIUM|e) String
foreign import isDisplayed :: forall e. Element -> Aff (selenium :: SELENIUM|e) Boolean
foreign import isEnabled :: forall e. Element -> Aff (selenium :: SELENIUM|e) Boolean
foreign import getInnerHtml :: forall e. Element -> Aff (selenium :: SELENIUM|e) String
-- | Clear `value` of element, if it has no value will do nothing. 
-- | If `value` is weakly referenced by `virtual-dom` (`purescript-halogen`) 
-- | will not work -- to clear such inputs one should use direct signal from 
-- | `Selenium.ActionSequence`
foreign import clearEl :: forall e. Element -> Aff (selenium :: SELENIUM|e) Unit

          




