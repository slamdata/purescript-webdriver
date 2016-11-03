-- | Most functions of `Selenium` use `Driver` as an argument
-- | This module supposed to make code a bit cleaner through
-- | putting `Driver` to `ReaderT`
module Selenium.Monad where

import Prelude

import Control.Monad.Aff as A
import Control.Monad.Aff.Reattempt (reattempt)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Exception (Error)
import Control.Monad.Eff.Ref (REF)
import Control.Monad.Reader.Trans (ReaderT(..), lift, ask, runReaderT)

import Data.Either (Either)
import Data.Foreign (Foreign)
import Data.List (List, fromFoldable)
import Data.Maybe (Maybe)

import DOM (DOM)

import Selenium as S
import Selenium.ActionSequence as AS
import Selenium.Types
  ( WindowHandle
  , XHRStats
  , Element
  , Locator
  , Driver
  , FileDetector
  , Location
  , Size
  , Window
  , SELENIUM
  )
import Selenium.XHR as XHR

-- | `Driver` is field of `ReaderT` context
-- | Usually selenium tests are run with tons of configs (i.e. xpath locators,
-- | timeouts) all those configs can be putted to `Selenium e o a`
type Selenium e o =
  ReaderT
    {driver ∷ Driver, defaultTimeout ∷ Int |o}
    (A.Aff (console ∷ CONSOLE, selenium ∷ SELENIUM, dom ∷ DOM, ref ∷ REF |e))

-- | get driver from context
getDriver ∷ ∀ e o. Selenium e o Driver
getDriver = _.driver <$> ask

getWindow ∷ ∀ e o. Selenium e o Window
getWindow = getDriver >>= lift <<< S.getWindow

getWindowPosition ∷ ∀ e o. Selenium e o Location
getWindowPosition = getWindow >>= lift <<< S.getWindowPosition

getWindowSize ∷ ∀ e o. Selenium e o Size
getWindowSize = getWindow >>= lift <<< S.getWindowSize

maximizeWindow ∷ ∀ e o. Selenium e o Unit
maximizeWindow = getWindow >>= lift <<< S.maximizeWindow

setWindowPosition ∷ ∀ e o. Location → Selenium e o Unit
setWindowPosition pos = getWindow >>= S.setWindowPosition pos >>> lift

setWindowSize ∷ ∀ e o. Size → Selenium e o Unit
setWindowSize size = getWindow >>= S.setWindowSize size >>> lift

getWindowScroll ∷ ∀ e o. Selenium e o Location
getWindowScroll = getDriver >>= S.getWindowScroll >>> lift

-- LIFT `Aff` combinators to `Selenium.Monad`
apathize ∷ ∀ e o a. Selenium e o a → Selenium e o Unit
apathize check = ReaderT \r →
  A.apathize $ runReaderT check r

attempt ∷ ∀ e o a. Selenium e o a → Selenium e o (Either Error a)
attempt check = ReaderT \r →
  A.attempt $ runReaderT check r

later ∷ ∀ e o a. Int → Selenium e o a → Selenium e o a
later time check = ReaderT \r →
  A.later' time $ runReaderT check r


-- LIFT `Selenium` funcs to `Selenium.Monad`
get ∷ ∀ e o. String → Selenium e o Unit
get url =
  getDriver >>= lift <<< flip S.get url

wait ∷ ∀ e o. Selenium e o Boolean → Int → Selenium e o Unit
wait check time = ReaderT \r →
  S.wait (runReaderT check r) time r.driver

-- | Tries the provided Selenium computation repeatedly until the provided timeout expires
tryRepeatedlyTo' ∷ ∀ a e o. Int → Selenium e o a → Selenium e o a
tryRepeatedlyTo' time selenium = ReaderT \r →
  reattempt time (runReaderT selenium r)

-- | Tries the provided Selenium computation repeatedly until `Selenium`'s defaultTimeout expires
tryRepeatedlyTo ∷ ∀ a e o. Selenium e o a → Selenium e o a
tryRepeatedlyTo selenium = ask >>= \r → tryRepeatedlyTo' r.defaultTimeout selenium

byCss ∷ ∀ e o. String → Selenium e o Locator
byCss = lift <<< S.byCss

byXPath ∷ ∀ e o. String → Selenium e o Locator
byXPath = lift <<< S.byXPath

byId ∷ ∀ e o. String → Selenium e o Locator
byId = lift <<< S.byId

byName ∷ ∀ e o. String → Selenium e o Locator
byName = lift <<< S.byName

byClassName ∷ ∀ e o. String → Selenium e o Locator
byClassName = lift <<< S.byClassName

-- | get element by action returning an element
-- | ```purescript
-- | locator \el → do
-- |   commonElements ← byCss ".common-element" >>= findElements el
-- |   flaggedElements ← traverse (\el → Tuple el <$> isVisible el) commonElements
-- |   maybe err pure $ foldl foldFn Nothing flaggedElements
-- |   where
-- |   err = throwError $ error "all common elements are not visible"
-- |   foldFn Nothing (Tuple el true) = Just el
-- |   foldFn a _ = a
-- | ```
locator ∷ ∀ e o. (Element → Selenium e o Element) → Selenium e o Locator
locator checkFn = ReaderT \r →
  S.affLocator (\el → runReaderT (checkFn el) r)

-- | Tries to find element and return it wrapped in `Just`
findElement ∷ ∀ e o. Locator → Selenium e o (Maybe Element)
findElement l =
  getDriver >>= lift <<< flip S.findElement l

findElements ∷ ∀ e o. Locator → Selenium e o (List Element)
findElements l =
  getDriver >>= lift <<< flip S.findElements l

-- | Tries to find child and return it wrapped in `Just`
findChild ∷ ∀ e o. Element → Locator → Selenium e o (Maybe Element)
findChild el loc = lift $ S.findChild el loc

findChildren ∷ ∀ e o. Element → Locator → Selenium e o (List Element)
findChildren el loc = lift $ S.findChildren el loc

getInnerHtml ∷ ∀ e o. Element → Selenium e o String
getInnerHtml = lift <<< S.getInnerHtml

getSize ∷ ∀ e o. Element → Selenium e o Size
getSize = lift <<< S.getSize

getLocation ∷ ∀ e o. Element → Selenium e o Location
getLocation = lift <<< S.getLocation

isDisplayed ∷ ∀ e o. Element → Selenium e o Boolean
isDisplayed = lift <<< S.isDisplayed

isEnabled ∷ ∀ e o. Element → Selenium e o Boolean
isEnabled = lift <<< S.isEnabled

getCssValue ∷ ∀ e o. Element → String → Selenium e o String
getCssValue el key = lift $ S.getCssValue el key

getAttribute ∷ ∀ e o. Element → String → Selenium e o (Maybe String)
getAttribute el attr = lift $ S.getAttribute el attr

getText ∷ ∀ e o. Element → Selenium e o String
getText el = lift $ S.getText el

clearEl ∷ ∀ e o. Element → Selenium e o Unit
clearEl = lift <<< S.clearEl

clickEl ∷ ∀ e o. Element → Selenium e o Unit
clickEl = lift <<< S.clickEl

sendKeysEl ∷ ∀ e o. String → Element → Selenium e o Unit
sendKeysEl ks el = lift $ S.sendKeysEl ks el

script ∷ ∀ e o. String → Selenium e o Foreign
script str =
  getDriver >>= flip S.executeStr str >>> lift

getCurrentUrl ∷ ∀ e o. Selenium e o String
getCurrentUrl = getDriver >>= S.getCurrentUrl >>> lift

navigateBack ∷ ∀ e o. Selenium e o Unit
navigateBack = getDriver >>= S.navigateBack >>> lift

navigateForward ∷ ∀ e o. Selenium e o Unit
navigateForward = getDriver >>= S.navigateForward >>> lift

navigateTo ∷ ∀ e o. String → Selenium e o Unit
navigateTo url = getDriver >>= S.navigateTo url >>> lift

setFileDetector ∷ ∀ e o. FileDetector → Selenium e o Unit
setFileDetector fd = getDriver >>= flip S.setFileDetector fd >>> lift

getTitle ∷ ∀ e o. Selenium e o String
getTitle = getDriver >>= S.getTitle >>> lift


-- | Run sequence of actions
sequence ∷ ∀ e o. AS.Sequence Unit → Selenium e o Unit
sequence seq = do
  getDriver >>= lift <<< flip AS.sequence seq

-- | Same as `sequence` but takes function of `ReaderT` as an argument
actions
  ∷ ∀ e o
  . ({driver ∷ Driver, defaultTimeout ∷ Int |o} → AS.Sequence Unit)
  → Selenium e o Unit
actions seqFn = do
  ctx ← ask
  sequence $ seqFn ctx

-- | Stop computations
stop ∷ ∀ e o. Selenium e o Unit
stop = wait (later top $ pure false) top

refresh ∷ ∀ e o. Selenium e o Unit
refresh = getDriver >>= S.refresh >>> lift

quit ∷ ∀ e o. Selenium e o Unit
quit = getDriver >>= S.quit >>> lift

takeScreenshot ∷ ∀ e o. Selenium e o String
takeScreenshot = getDriver >>= S.takeScreenshot >>> lift

saveScreenshot ∷ ∀ e o. String → Selenium e o Unit
saveScreenshot name = getDriver >>= S.saveScreenshot name >>> lift

-- | Tries to find element, if has no success throws an error
findExact ∷ ∀ e o. Locator → Selenium e o Element
findExact loc = getDriver >>= flip S.findExact loc >>> lift

-- | Tries to find element and throws an error if it succeeds.
loseElement ∷ ∀ e o. Locator → Selenium e o Unit
loseElement loc = getDriver >>= flip S.loseElement loc >>> lift

-- | Tries to find child, if has no success throws an error
childExact ∷ ∀ e o. Element → Locator → Selenium e o Element
childExact el loc = lift $ S.childExact el loc

startSpying ∷ ∀ e o. Selenium e o Unit
startSpying = getDriver >>= XHR.startSpying >>> lift

stopSpying ∷ ∀ e o. Selenium e o Unit
stopSpying = getDriver >>= XHR.stopSpying >>> lift

clearLog ∷ ∀ e o. Selenium e o Unit
clearLog = getDriver >>= XHR.clearLog >>> lift

getXHRStats ∷ ∀ e o. Selenium e o (List XHRStats)
getXHRStats = getDriver >>= XHR.getStats >>> map fromFoldable >>> lift


getWindowHandle ∷ ∀ e o. Selenium e o WindowHandle
getWindowHandle = getDriver >>= S.getWindowHandle >>> lift

getAllWindowHandles ∷ ∀ e o. Selenium e o (List WindowHandle)
getAllWindowHandles = getDriver >>= S.getAllWindowHandles >>> lift

switchTo ∷ ∀ e o. WindowHandle → Selenium e o Unit
switchTo w = getDriver >>= S.switchTo w >>> lift

closeWindow ∷ ∀ e o. Selenium e o Unit
closeWindow = getDriver >>= S.close >>> lift
