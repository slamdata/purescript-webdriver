module Test.Main where

import Prelude

import Data.Maybe (maybe)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Aff (launchAff, delay)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Selenium (byCss, byName, clickEl, findElement, get, getTitle, quit, sendKeysEl, wait)
import Selenium.Browser (Browser(..))
import Selenium.Builder (browser, build)

main :: Effect Unit
main = do
  void $ launchAff do
    driver <- build $ browser Chrome
    get driver "http://google.com/ncr"
    byName "q" >>=
      findElement driver >>=
      maybe noInput (goInput driver)
  where
  noInput = void (liftEffect (log "No input, sorry :("))

  goInput driver el = do
    sendKeysEl "webdriver" el
    byCss ".ds .lsbb button.lsb" >>=
      findElement driver >>=
      maybe noButton (goButton driver)

  noButton = void $ liftEffect (log "No submit button")

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
