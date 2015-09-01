-- | Most functions of `Selenium` use `Driver` as an argument
-- | This module supposed to make code a bit cleaner through
-- | putting `Driver` to `ReaderT`
module Selenium.Monad where

import Prelude
import Control.Monad.Error.Class (throwError)
import Control.Monad.Eff.Exception (error, Error())
import Data.Either (Either())
import Data.Maybe (Maybe())
import Data.Foreign (Foreign())
import Data.Maybe.Unsafe (fromJust)
import Data.List
import DOM
import Selenium.Types
import Control.Monad.Eff.Console (CONSOLE())
import Control.Monad.Trans
import Control.Monad.Reader.Trans
import Control.Monad.Reader.Class
import qualified Control.Monad.Aff as A
import qualified Selenium as S
import qualified Selenium.ActionSequence as S
import qualified Selenium.XHR as S 
-- | `Driver` is field of `ReaderT` context
-- | Usually selenium tests are run with tons of configs (i.e. xpath locators,
-- | timeouts) all those configs can be putted to `Selenium e o a`
type Selenium e o a = 
  ReaderT
    {driver :: Driver |o} 
    (A.Aff (console :: CONSOLE, selenium :: SELENIUM, dom :: DOM |e)) a

-- | get driver from context
getDriver :: forall e o. Selenium e o Driver 
getDriver = _.driver <$> ask


-- LIFT `Aff` combinators to `Selenium.Monad`
apathize :: forall e o a. Selenium e o a -> Selenium e o Unit
apathize check = ReaderT \r ->
  A.apathize $ runReaderT check r

attempt :: forall e o a. Selenium e o a -> Selenium e o (Either Error a)
attempt check = ReaderT \r ->
  A.attempt $ runReaderT check r

later :: forall e o a. Int -> Selenium e o a -> Selenium e o a
later time check = ReaderT \r ->
  A.later' time $ runReaderT check r


-- LIFT `Selenium` funcs to `Selenium.Monad`
get :: forall e o. String -> Selenium e o Unit
get url = 
  getDriver >>= lift <<< flip S.get url

wait :: forall e o. Selenium e o Boolean -> Int -> Selenium e o Unit
wait check time = ReaderT \r ->
  S.wait (runReaderT check r) time r.driver

byCss :: forall e o. String -> Selenium e o Locator
byCss = lift <<< S.byCss

byXPath :: forall e o. String -> Selenium e o Locator
byXPath = lift <<< S.byXPath

byId :: forall e o. String -> Selenium e o Locator
byId = lift <<< S.byId

byName :: forall e o. String -> Selenium e o Locator
byName = lift <<< S.byName

byClassName :: forall e o. String -> Selenium e o Locator
byClassName = lift <<< S.byClassName

-- | get element by action returning an element
-- | ```purescript
-- | locator \el -> do 
-- |   commonElements <- byCss ".common-element" >>= findElements el 
-- |   flaggedElements <- traverse (\el -> Tuple el <$> isVisible el) commonElements
-- |   maybe err pure $ foldl foldFn Nothing flaggedElements
-- |   where
-- |   err = throwError $ error "all common elements are not visible"
-- |   foldFn Nothing (Tuple el true) = Just el
-- |   foldFn a _ = a 
-- | ```
locator :: forall e o. (Element -> Selenium e o Element) -> Selenium e o Locator
locator checkFn = ReaderT \r ->
  S.affLocator (\el -> runReaderT (checkFn el) r)

-- | Tries to find element and return it wrapped in `Just` 
findElement :: forall e o. Locator -> Selenium e o (Maybe Element) 
findElement locator =
  getDriver >>= lift <<< flip S.findElement locator

findElements :: forall e o. Locator -> Selenium e o (List Element)
findElements locator = 
  getDriver >>= lift <<< flip S.findElements locator

-- | Tries to find child and return it wrapped in `Just`
findChild :: forall e o. Element -> Locator -> Selenium e o (Maybe Element)
findChild el loc = lift $ S.findChild el loc

findChildren :: forall e o. Element -> Locator -> Selenium e o (List Element)
findChildren el loc = lift $ S.findChildren el loc

getInnerHtml :: forall e o. Element -> Selenium e o String
getInnerHtml = lift <<< S.getInnerHtml

isDisplayed :: forall e o. Element -> Selenium e o Boolean
isDisplayed = lift <<< S.isDisplayed

isEnabled :: forall e o. Element -> Selenium e o Boolean
isEnabled = lift <<< S.isEnabled

getCssValue :: forall e o. Element -> String -> Selenium e o String
getCssValue el key = lift $ S.getCssValue el key

getAttribute :: forall e o. Element -> String -> Selenium e o String
getAttribute el attr = lift $ S.getAttribute el attr

clearEl :: forall e o. Element -> Selenium e o Unit
clearEl = lift <<< S.clearEl

sendKeysEl :: forall e o. String -> Element -> Selenium e o Unit
sendKeysEl ks el = lift $ S.sendKeysEl ks el

script :: forall e o. String -> Selenium e o Foreign
script str =
  getDriver >>= flip S.executeStr str >>> lift

getCurrentUrl :: forall e o. Selenium e o String
getCurrentUrl = getDriver >>= S.getCurrentUrl >>> lift

navigateBack :: forall e o. Selenium e o Unit
navigateBack = getDriver >>= S.navigateBack >>> lift

navigateForward :: forall e o. Selenium e o Unit
navigateForward = getDriver >>= S.navigateForward >>> lift

navigateTo :: forall e o. String -> Selenium e o Unit
navigateTo url = getDriver >>= S.navigateTo url >>> lift

setFileDetector :: forall e o. FileDetector -> Selenium e o Unit
setFileDetector fd = getDriver >>= flip S.setFileDetector fd >>> lift

getTitle :: forall e o. Selenium e o String
getTitle = getDriver >>= S.getTitle >>> lift


-- | Run sequence of actions 
sequence :: forall e o. S.Sequence Unit -> Selenium e o Unit
sequence seq = do
  getDriver >>= lift <<< flip S.sequence seq

-- | Same as `sequence` but takes function of `ReaderT` as an argument
actions :: forall e o. ({driver :: Driver |o} -> S.Sequence Unit) -> Selenium e o Unit 
actions seqFn = do 
  ctx <- ask
  sequence $ seqFn ctx

-- | Stop computations
stop :: forall e o. Selenium e o Unit
stop = wait (later top $ pure false) top

refresh :: forall e o. Selenium e o Unit
refresh = getDriver >>= S.refresh >>> lift 

quit :: forall e o. Selenium e o Unit
quit = getDriver >>= S.quit >>> lift

takeScreenshot :: forall e o. Selenium e o String
takeScreenshot = getDriver >>= S.takeScreenshot >>> lift

-- | Tries to find element, if has no success throws an error
findExact :: forall e o. Locator -> Selenium e o Element
findExact loc = getDriver >>= flip S.findExact loc >>> lift 

-- | Tries to find child, if has no success throws an error
childExact :: forall e o. Element -> Locator -> Selenium e o Element
childExact el loc = lift $ S.childExact el loc 

startSpying :: forall e o. Selenium e o Unit
startSpying = getDriver >>= S.startSpying >>> lift 

stopSpying :: forall e o. Selenium e o Unit
stopSpying = getDriver >>= S.stopSpying >>> lift

clearLog :: forall e o. Selenium e o Unit
clearLog = getDriver >>= S.clearLog >>> lift

getXHRStats :: forall e o. Selenium e o (List XHRStats)
getXHRStats = getDriver >>= S.getStats >>> map toList >>> lift
