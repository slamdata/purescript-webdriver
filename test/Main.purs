module Test.Main where

import Prelude
import Control.Monad.Aff (launchAff, delay)
import Control.Monad.Aff.Console (log)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Maybe (maybe)
import Data.Time.Duration (Milliseconds(..))
import Selenium (findElement, byName, get, getTitle, quit, wait, clickEl, sendKeysEl)
import Selenium.Browser (Browser(..))
import Selenium.Builder (browser, build)
import Selenium.Types (SELENIUM)

main :: Eff (selenium :: SELENIUM, console :: CONSOLE, exception :: EXCEPTION) Unit
main = do
  void $ launchAff do
    driver <- build $ browser Chrome
    get driver "http://google.com/ncr"
    byName "q" >>=
      findElement driver >>=
      maybe noInput (goInput driver)
  where
  noInput = void $ log "No input, sorry :("

  goInput driver el = do
    sendKeysEl "webdriver" el
    byName "btnG" >>=
      findElement driver >>=
      maybe noButton (goButton driver)

  noButton = void $ log "No submit button"

  goButton driver button = do
    clickEl button
    wait (titleAff driver) (Milliseconds 1000.0) driver
    quit driver

  titleAff driver = do
    title <- getTitle driver
    if title == "webdriver - Google Search"
      then pure true
      else do
        delay (Milliseconds 50.0)
        titleAff driver
